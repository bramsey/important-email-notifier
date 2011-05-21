require 'rubygems'
require 'daemons'

dir = File.dirname(__FILE__)
script = File.basename(__FILE__, ".ctl.rb")

options = {
  :ontop => false,
  :backtrace => true
}

puts "running: #{script}<"
Daemons.run(dir + '/' + script + '.job.rb', options)
