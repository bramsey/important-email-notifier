ENV['RAILS_ENV'] ||= 'development'
require File.join(File.dirname(__FILE__), '..', 'config', 'environment')
require 'starling'

ENV['RAILS_ENV'] == 'development' ?
  RUBY = '/Users/spamram/.rvm/rubies/ruby-1.9.2-p180/bin/ruby' : # Dev path
  RUBY = '/home/bill/.rvm/rubies/ruby-1.9.2-p180/bin/ruby' # Production path

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

starling = Starling.new('127.0.0.1:22122')


loop do
  command = starling.get('idler_queue')
  action = command.split[0]
  account = command.split[1]
  
  case action
  when "start"
    start( Account.find(account) )
  when "stop"
    stop( Account.find(account) )
  else
    puts "invalid command"
  end
  
  sleep 5
  #listen for new commands on the queue.
  
  
  
  #parse the commands and take the appropriate actions.
  # example actions:
  #   start a new account checking process
  #   stop a running account checking process
  #   update account information (restart with new information basically)
  #   add process to the hash or whatever is used to track them
end

