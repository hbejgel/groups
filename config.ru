$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubygems'
require './groups'

$stdout.sync = true

run Sinatra::Application

