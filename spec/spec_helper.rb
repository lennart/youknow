require File.join(File.dirname(__FILE__),*%w{.. vendor gems environment})
Bundler.require_env :test
set :environment, :test
require File.join(File.dirname(__FILE__),*%w{.. config app_config})
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'main'
def recreate_db
  CouchRest.new(SiteConfig.url_base).database!(SiteConfig.database_name).recreate!
end

def log(msg)
  puts msg
end
Spec::Runner.configure do |config|
  config.mock_with :mocha
end

