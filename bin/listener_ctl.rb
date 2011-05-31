require 'rubygems'
require 'daemons'

dir = File.dirname(__FILE__)

options = {
  :ontop => false,
  :backtrace => true,
  :monitor => true
}

puts "running listener"
Daemons.run(dir + '/listener.rb', options)
