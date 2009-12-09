require 'ostruct'
configure :integration do
  Config = OpenStruct.new(
    :title => 'a name for your blog',
    :author => 'Joel Tulloch',
    :url_base => 'http://localhost:5984',
    :database_name => 'scanty_integration',
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

  Config = OpenStruct.new(
    :title => 'a name for your blog',
    :author => 'Joel Tulloch',
    :url_base => 'http://localhost:5984',
    :database_name => 'scanty_dev',
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
  Config = OpenStruct.new(
    :title => 'My blog',
    :author => 'Anonymous Coward',
    :url_base => 'http://localhost:5984',
    :database_name => 'scanty_test',
    :url_base_database => nil,
    :ping_services => 'ping.xml',  #relative to /config
    :log_folder => 'logs', #will be placed in the application root		
    :admin_password => 'changethis',
    :admin_cookie_key => 'admin_cookie_key',
    :admin_cookie_value => '54l976913ace58',
    :disqus_shortname => nil
  )
end
