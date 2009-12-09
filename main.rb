require File.join(File.dirname(__FILE__),*%w{vendor gems environment})
Bundler.require_env
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')

class ModularApplication < Sinatra::Base
  load 'extensions/couchrest_ducktyped_design_doc.rb'
  helpers Sinatra::UrlForHelper

  register Sinatra::StaticAssets

  enable :xhtml
  enable :sessions

  error do
    e = request.env['sinatra.error']
    puts e.to_s
    puts e.backtrace.join("\n")
    "Application error"
  end

  helpers do
  end


end
