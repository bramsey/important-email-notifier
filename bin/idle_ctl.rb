require 'rubygems'
require 'daemons'

dir = File.dirname(__FILE__)
Daemons.run(dir + '/idle.rb')