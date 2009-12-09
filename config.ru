FileUtils.mkdir_p 'log' unless File.exists?('log')
log = File.new("log/sinatra.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)
require File.join(File.dirname(__FILE__), *%w{vendor gems environment})
Bundler.require_env

require File.join(File.dirname(__FILE__), *%w{config app_config})
require File.dirname(__FILE__) + "/main.rb"

set :app_file, File.expand_path(File.dirname(__FILE__) + '/main.rb')
set :public,   File.expand_path(File.dirname(__FILE__) + '/public')
set :views,    File.expand_path(File.dirname(__FILE__) + '/views')
set :env,      :production

disable :run, :reload

run ModularApplication.new
