ENV['RAILS_ENV'] ||= 'development'
require File.join(File.dirname(__FILE__), '..', 'config', 'environment')

RUBY = '/Users/spamram/.rvm/rubies/ruby-1.9.2-p180/bin/ruby'

# Possibly have the start/stop all functionality within rails and have the start
# command to be parsed by the listener pass the account info to connect so this
# script doesn't need to launch a separate rails instance.

def startAll
  Account.active_accounts.each do |account|
    # go through each account and start the daemons.
    start account
  end
end

def stopAll
  Account.all.each do |account|
    stop account
  end
end

def start( account )
  %x[#{RUBY} idle_ctl.rb start #{account.id} -- #{account.username} #{account.password}]
end

def stop( account )
  %x[#{RUBY} idle_ctl.rb stop #{account.id}]
end

startAll

#loop do
#  sleep 5
  #listen for new commands on the queue.
  
  #parse the commands and take the appropriate actions.
  # example actions:
  #   start a new account checking process
  #   stop a running account checking process
  #   update account information (restart with new information basically)
  #   add process to the hash or whatever is used to track them
#end

