require File.join(File.dirname(__FILE__),*%w{config boot})

class ModularApplication < Sinatra::Base
  helpers Sinatra::UrlForHelper
  register Sinatra::StaticAssets


  enable :xhtml
  enable :sessions

  set :views, "app/views/"
  Compass.configuration.parse(File.join(SINATRA_ROOT, 'config', 'compass.config'))
  set :haml, { :format => :html5 }
  set :sass, Compass.sass_engine_options

  error do
    e = request.env['sinatra.error']
    puts e.to_s
    puts e.backtrace.join("\n")
    "Application error"
  end

  helpers do
  end

  get '/readable/?' do
    body = ""
    URI.parse(params[:url]).open {|f| body = f.read }
    readable_document = Readability::Document.new(body)
    @encoding = readable_document.encoding
    haml :readable, {}, :readable_content => readable_document.content
  end

  get "/stylesheets/:stylesheet.css" do
    content_type "text/css", :charset => "UTF-8"
    sass :"css/#{params[:stylesheet]}"
  end
end
