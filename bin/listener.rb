ENV['RAILS_ENV'] ||= 'development'
require File.join(File.dirname(__FILE__), '..', 'config', 'environment')

RUBY = '/Users/spamram/.rvm/rubies/ruby-1.9.2-p180/bin/ruby'

Account.active_accounts.each do |account|
  # go through each account and start the daemons.
  %x[#{RUBY} idle_ctl.rb start #{account.id} -- #{account.username} #{account.password}]
end

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

