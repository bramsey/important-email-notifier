SERVER = 'imap.gmail.com' # parameterize when supporting other hosts)
HOST_URL = 'http://dev.vybly.com'
USERNAME = ARGV[0] unless ARGV[0].nil?
#PW = ARGV[1] unless ARGV[1].nil?
TOKEN = ARGV[1] unless ARGV[1].nil?
SECRET = ARGV[2] unless ARGV[2].nil?

if ARGV.length != 3
  puts "usage: ruby <script> <username> <token> <secret>"
  ARGV.each {|arg| puts "#{arg}<"}
  exit
end

#require 'net/imap'
#require 'rubygems'
require 'mail'
require 'time'
require 'date'
require 'gmail'
require 'net/http'
require 'gmail_xoauth'

# Extend support for idle command. See online.
# http://www.ruby-forum.com/topic/50828
# but that was wrong. see /opt/ruby-1.9.1-p243/lib/net/imap.rb.
class Net::IMAP
  def idle
    puts 'starting idle'
    cmd = "IDLE"
    synchronize do
      @idle_tag = generate_tag
      put_string(@idle_tag + " " + cmd)
      put_string(CRLF)
    end
  end

  def say_done
    cmd = "DONE"
    synchronize do
      put_string(cmd)
      put_string(CRLF)
    end
  end

  def await_done_confirmation
    synchronize do
      get_tagged_response(@idle_tag, nil)
      puts 'just got confirmation'
    end
  end
end

class MailReader
  attr_reader :imap

  public
  def initialize
    @imap = nil
    start_imap
  end

  def process
    puts "checking #{USERNAME}."
    #msg_ids = @imap.search(["UNSEEN", 'HEADER', 'X-Priority', "1"])
    msg_ids = @imap.search(["UNSEEN"])
    msg_ids ||= []
    puts "found #{msg_ids.length} messages"
    responded = false
    msg_ids.each do |msg_id|
      mail = Mail.new(@imap.fetch(msg_id, 'RFC822').first.attr['RFC822'])
      @imap.store msg_id, '-FLAGS', [:Seen]
      
      puts "New mail from #{mail.from.first}:"
      
      # Flags will be true if desired condition is met.
      toFlag = mail.to.include? USERNAME
      noReplyFlag = !(mail.from.collect {|e| e.include? "noreplys"}.include?(true))
      listFlag = mail.header['List-Unsubscribe'].nil? && mail.header['List-Id'].nil?
      notifierFlag = !mail.from.include?("vybly.notifier@gmail.com")
      
      processFlag = toFlag && noReplyFlag && listFlag && notifierFlag
      
      puts "toFlag: #{toFlag.to_s}"
      puts "noReplyFlag: #{noReplyFlag.to_s}"
      puts "processFlag: #{processFlag.to_s}"
      
      priority = mail.header['X-Priority'].value if mail.header['X-Priority']
      priorityFlag = (priority == 1)
      subjFlag = (mail.subject[0] == "!")
      directFlag = priorityFlag || subjFlag
      
      puts "priorityFlag: #{priorityFlag.to_s}"
      puts "subjFlag: #{subjFlag.to_s}"
      puts "directFlag: #{directFlag.to_s}"
      
      if processFlag
        if directFlag
          # Call direct notification of recipient without autoreply
          priority ||= "1"
          response = send_init_with_priority( mail.from.first, 
                                              USERNAME,
                                              priority,
                                              mail.subject )
          puts "direct response: #{response}"
          @imap.store msg_id, '+FLAGS', [:Seen] unless response == "Ignore"
        else
          # Do autoreply stuff
          token = send_init( mail.from.first, USERNAME, mail.subject )
          if token != "Ignore"
            send_response( mail.from.first, mail.subject, token )
            puts "response sent"
            responded = true
            @imap.store msg_id, '+FLAGS', [:Seen]
          else
            puts "ignoring"
          end unless (token.nil? || token == " ")
        end
      end  
    end
    trash_sent_messages if responded
  end
  
  def send_response( sender, subj, token )
    smtp = Net::SMTP.new('smtp.gmail.com', 587)
    smtp.enable_starttls_auto
    secret = {
      :consumer_key => 'anonymous',
      :consumer_secret => 'anonymous',
      :token => TOKEN,
      :token_secret => SECRET
    }
    
    smtp.start('gmail.com', USERNAME, secret, :xoauth)
    
    
    mail = Mail.new do
      from USERNAME
      to sender
      subject "Re: #{subj}"
      body "I'm currently in the middle of something and not checking email;" +
        "if you feel it important for your message to reach me right away, please " +
        "click the following link, but note that if I disagree, such notices may be " +
        "less likely to get my attention in the future.  #{token}"
    end
    
    
    smtp.send_message mail.to_s, USERNAME, sender
    smtp.finish
  end
  
  def trash_sent_messages
    # Move sent token messages to trash:
    @imap.select '[Gmail]/All Mail'
    remove_ids = @imap.uid_search(["FROM", "#{USERNAME}", "BODY", "prioritize?token="])
    remove_ids.each do |rid|
      nmail = Mail.new(@imap.uid_fetch(rid, 'RFC822').first.attr['RFC822'])
      
      puts "#{rid} | from: #{nmail.from.first}, to: #{nmail.to.first}"
      puts "subject: #{nmail.subject}"
      
      @imap.uid_store(rid, "+FLAGS", [:Deleted])
      @imap.uid_copy(rid, '[Gmail]/Trash')
    end unless remove_ids.empty?
    @imap.expunge
    
    # Delete token messages from trash:
    @imap.select '[Gmail]/Trash'
    trash_ids = @imap.uid_search(["FROM", "#{USERNAME}", "BODY", "prioritize?token="])
    trash_ids.each do |tid|
      puts "flag #{tid} delete"
      @imap.uid_store(tid, "+FLAGS", [:Deleted])
    end
    @imap.expunge
    puts "expunging."
    
    @imap.select 'Inbox' # Set back to Inbox for idle checking.
  end
  
  def send_init( sender, recipient, subject)
    url = URI.parse("#{HOST_URL}/messages/init")
    subject ||= ""
    post_args = { :sender => sender,
                  :recipient => recipient,
                  :subject => subject }
    
    response, data = Net::HTTP.post_form(url, post_args)
    
    response.code == "200" ?
      data : "Ignore"
  end
  
  def send_init_with_priority( sender, recipient, priority, subject)
    url = URI.parse("#{HOST_URL}/messages/init")
    subject ||= ""
    post_args = { :sender => sender,
                  :recipient => recipient,
                  :priority => priority,
                  :subject => subject }
    
    response, data = Net::HTTP.post_form(url, post_args)
    
    response.code == "200" ?
      data : "Ignore"
  end

  def tidy
    stop_imap
  end

  def bounce_idle
    # Bounces the idle command.
    @imap.say_done
    @imap.await_done_confirmation
    # Do a manual check, just in case things aren't working properly.
    process
    @imap.idle
  end

  private
  def start_imap
    @imap = Net::IMAP.new SERVER, ssl: true

    #@imap.login USERNAME, PW
    @imap.authenticate('XOAUTH', USERNAME, 
        :consumer_key => 'anonymous', 
        :consumer_secret => 'anonymous', 
        :token => TOKEN, 
        :token_secret => SECRET
      )
    @imap.select 'INBOX'

    # Add handler.
    @imap.add_response_handler do |resp|
      if resp.kind_of?(Net::IMAP::UntaggedResponse) and resp.name == "EXISTS"
        @imap.say_done
        Thread.new do
          @imap.await_done_confirmation
          process
          @imap.idle
        end
      end
    end

    process
    @imap.idle
  end

  def stop_imap
    @imap.done
  end
end

#Net::IMAP.debug = true

reader = MailReader.new

loop do
  sleep 10*60
  puts "bouncing account #{USERNAME}"
  reader.bounce_idle
end