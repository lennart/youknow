source "http://gems.github.com"
gem "sinatra", :git => "git://github.com/sinatra/sinatra"
gem "couchrest", :git => "git://github.com/lennart/couchrest"
gem "emk-sinatra-url-for", :require_as => "sinatra/url_for" 
gem "sinatra-static-assets", :require_as => "sinatra/static_assets", :git => "git://github.com/lennart/sinatra-static-assets"

only :test do
  gem "rack-test", :require_as => "rack/test"
  gem "rspec"
  gem "cucumber"
  gem "timecop"
  gem "mocha"
  gem "capybara", :branch => "0.2.0"
end
# vim:filetype=ruby
