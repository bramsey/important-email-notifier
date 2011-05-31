require 'rubygems'


dir = File.dirname(__FILE__)

require 'daemons'

options = {
  :ontop => false,
  :backtrace => true,
  :monitor => true
}

puts "running listener"
Daemons.run(dir + '/listener.rb', options)
