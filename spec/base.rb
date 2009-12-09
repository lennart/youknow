require File.join(File.dirname(__FILE__),*%w{.. vendor gems environment})
Bundler.require_env :test
set :environment, :test
require File.join(File.dirname(__FILE__),*%w{.. config app_config})
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'main'
