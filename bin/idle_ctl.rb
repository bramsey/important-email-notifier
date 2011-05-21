require 'rubygems'
require 'daemons'

dir = File.dirname(__FILE__)

daemon_options =  {
  :multiple => true
}

if ARGV.include?('--')
  ARGV.slice! 0..ARGV.index('--')
else
  ARGV.clear
end

Daemons.run(dir + '/idle.rb', daemon_options)
puts "running: #{ARGV.at(1)}"