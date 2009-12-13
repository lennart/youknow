require File.join(File.dirname(__FILE__), *%w{.. .. config boot})
Bundler.require_env :test
Sinatra::Application.set :environment, :integration
require File.join(File.dirname(__FILE__),*%w{.. .. config app_config})
app_file = File.join(File.dirname(__FILE__), *%w{.. .. main.rb}) 
require app_file
Sinatra::Application.app_file = app_file

require 'spec/expectations'
require 'capybara/cucumber'
CouchRest.new(SiteConfig.url_base).database!(SiteConfig.database_name).recreate!
Capybara.app = ModularApplication
class MyWorld
  include Rack::Test::Methods

  def app
    ModularApplication
  end
end

World{MyWorld.new}
