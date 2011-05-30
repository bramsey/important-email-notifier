require 'rubygems'
require 'daemons'

dir = File.dirname(__FILE__)

options = {
  :ontop => false,
  :backtrace => true,
  :monitor => true,
  :app_name => ARGV[1]
}

puts "running: #{ARGV[1]}<"
Daemons.run(dir + '/idle.rb', options)
