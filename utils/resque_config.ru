#!/usr/bin/env ruby
require 'logger'
FileUtils.mkdir_p 'log' unless ::File.exists?('log')
log = ::File.new("log/resque.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)

$LOAD_PATH.unshift ::File.expand_path(::File.dirname(__FILE__) + '/lib')
require 'resque/server'

# Set the RESQUECONFIG env variable if you've a `resque.rb` or similar
# config file you want loaded on boot.
if ENV['RESQUECONFIG'] && ::File.exists?(::File.expand_path(ENV['RESQUECONFIG']))
  load ::File.expand_path(ENV['RESQUECONFIG'])
end

use Rack::ShowExceptions
run Resque::Server.new
