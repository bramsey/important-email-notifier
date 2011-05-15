ENV['RAILS_ENV'] ||= 'development'
require File.join(File.dirname(__FILE__), '..', 'config', 'environment')

ACCOUNT = Account.first
SERVER = 'imap.gmail.com'
USERNAME = ACCOUNT.username
PW = ACCOUNT.password

require 'net/imap'
require 'rubygems'
require 'mail'
require 'time'
require 'date'
require 'gmail'

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
    puts 'checking server.'
    msg_ids = @imap.search(["UNSEEN", 'HEADER', 'X-Priority', "1"])
    msg_ids ||= []
    puts "found #{msg_ids.length} messages"
    msg_ids.each do |msg_id|
      mail = Mail.new(@imap.fetch(msg_id, 'RFC822').first.attr['RFC822'])
      
      RAILS_DEFAULT_LOGGER.error("\n New mail from #{mail.from.first} \n")
      puts "New mail from #{mail.from.first}:"
      #puts "To: #{mail.to.first}"
      #puts "Subject: #{mail.subject}"

      puts "user: #{ACCOUNT.user.name}"
      unless ACCOUNT.user.has_account?( mail.from.first )
        token = Message.initiate( mail.from.first, mail.to.first )
        puts "inited"
        send_response( ACCOUNT, mail.from.first, mail.subject, token )
        puts "response sent"
      end

      @imap.store msg_id, '+FLAGS', [:Seen]
    end
  end
  
  def send_response( account, sender, subj, token )
    Gmail.new( account.username, account.password ) do |gmail|

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

    @imap.login USERNAME, PW
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
if ACCOUNT.active
  r = MailReader.new
  loop do
    sleep 10*60
    puts 'bouncing...'
    r.bounce_idle
  end
end