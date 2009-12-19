require 'ostruct'
require 'id3lib'
configure :integration do
  SiteConfig = OpenStruct.new(
    :title => 'a name for your blog',
    :author => 'Joel Tulloch',
    :couchdb_host => 'http://localhost:5984',
    :database_name => 'media_integration',
    :host_url => "http://localhost",
    :url_base_database => nil,
    :ping_services => 'ping.xml',  #relative to /config
    :log_folder => 'logs', #will be placed in the application root		
    :admin_password => 'changethis',
    :admin_cookie_key => 'admin_cookie_key',
    :admin_cookie_value => '54l976913ace58',
    :disqus_shortname => nil
  )
end
configure :development do

  SiteConfig = OpenStruct.new(
    :title => 'a name for your blog',
    :author => 'Joel Tulloch',
    :couchdb_host => 'http://localhost:5984',
    :host_url => "http://aludose",
    :database_name => 'media_dev',
    :url_base_database => nil,
    :ping_services => 'ping.xml',  #relative to /config
    :log_folder => 'logs', #will be placed in the application root		
    :admin_password => 'changethis',
    :admin_cookie_key => 'admin_cookie_key',
    :admin_cookie_value => '54l976913ace58',
    :disqus_shortname => nil
  )
end

configure :test do
  SiteConfig = OpenStruct.new(
    :title => 'My blog',
    :author => 'Anonymous Coward',
    :couchdb_host => 'http://localhost:5984',
    :host_url => "http://aludose",
    :database_name => 'media_test',
    :url_base_database => nil,
    :ping_services => 'ping.xml',  #relative to /config
    :log_folder => 'logs', #will be placed in the application root		
    :admin_password => 'changethis',
    :admin_cookie_key => 'admin_cookie_key',
    :admin_cookie_value => '54l976913ace58',
    :disqus_shortname => nil
  )
end
configure do
  SiteConfig.database = CouchRest.new(SiteConfig.couchdb_host).database!(SiteConfig.database_name)
end
include MainHelper
