ENV['RAILS_ENV'] ||= 'development'
require File.join(File.dirname(__FILE__), '..', 'config', 'environment')

SERVER = 'imap.gmail.com'
HOST_URL = 'http://localhost:3000'

require 'net/imap'
require 'rubygems'
require 'mail'
require 'time'
require 'date'
require 'gmail'
require 'net/http'

LOGGER = RAILS_DEFAULT_LOGGER

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
  def initialize( account )
    @imap = nil
    @account = account
    start_imap
  end

  def process
    puts "checking #{@account.username}."
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
      toFlag = mail.to.include? @account.username
      noReplyFlag = !(mail.from.collect {|e| e.include? "noreplys"}.include?(true))
      selfFlag = !@account.user.has_account?(mail.from.first)
      listFlag = mail.header['List-Unsubscribe'].nil?
      
      processFlag = toFlag && noReplyFlag && selfFlag && listFlag
      
      puts "toFlag: #{toFlag.to_s}"
      puts "noReplyFlag: #{noReplyFlag.to_s}"
      puts "selfFlag: #{selfFlag.to_s}"
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
          response = send_init_with_priority( mail.from.first, 
                                              mail.to.first,
                                              priority,
                                              mail.subject )
          puts "direct response: #{response}"
          @imap.store msg_id, '+FLAGS', [:Seen] unless response == "Ignore"
        else
          # Do autoreply stuff
          token = send_init( mail.from.first, mail.to.first, mail.subject )
          if token != "Ignore"
            send_response( mail.from.first, mail.subject, token )
            puts "response sent"
            responded = true
            @imap.store msg_id, '+FLAGS', [:Seen]
          else
            puts "ignoring"
          end unless token.nil?
        end
      end  
    end
    trash_sent_messages if responded
  end
  
  def send_response( sender, subj, token )
    Gmail.new( @account.username, @account.password ) do |gmail|

      gmail.deliver do
        to sender
        subject "Re: #{subj}"
        text_part do
          body "I'm currently in the middle of something and not checking email;" +
            "if you feel it important for your message to reach me right away, please " +
            "click the following link, but note that if I disagree, such notices may be " +
            "less likely to get my attention in the future.  #{token}"
        end
      end
    end
  end
  
  def trash_sent_messages
    @imap.select '[Gmail]/All Mail'
    remove_ids = @imap.uid_search(["FROM", "#{@account.username}", "BODY", "prioritize?token="])
    #remove_ids = @imap.uid_search(["DELETED"])
    remove_ids.each do |rid|
      #@imap.copy(rid, '[Gmail]/Trash')
      #puts "flagging: #{rid.to_s}"
      nmail = Mail.new(@imap.uid_fetch(rid, 'RFC822').first.attr['RFC822'])
      
      puts "#{rid} | from: #{nmail.from.first}, to: #{nmail.to.first}"
      puts "subject: #{nmail.subject}"
      
      @imap.uid_store(rid, "+FLAGS", [:Deleted])
      @imap.uid_copy(rid, '[Gmail]/Trash')
    end unless remove_ids.empty?
    @imap.expunge
    
    @imap.select '[Gmail]/Trash'
    trash_ids = @imap.uid_search(["FROM", "#{@account.username}", "BODY", "prioritize?token="])
    trash_ids.each do |tid|
      puts "flag #{tid} delete"
      @imap.uid_store(tid, "+FLAGS", [:Deleted])
    end
    @imap.expunge
    #@imap.logout
    puts "expunging."
    
    @imap.select 'Inbox'
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

    @imap.login @account.username, @account.password
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
readers = {}
Account.active_accounts.each do |account|
  readers.store( account.id, MailReader.new(account) )
end

loop do
  sleep 10*60
  readers.each do |key, r|
    puts "bouncing account #{key}"
    r.bounce_idle
  end
end