class Main
#  use Rack::Proxy do |req|
#    puts req.to_yaml
#    if req["X-SomeRandomShit"] == "readable"
#      URI.parse("http://aludose/readable/test")
#    else
#      URI.parse("http://google.com")
#    end
#  end

  get "/" do
    haml :home
  end

  get "/readable/?" do 
    body = ""
    URI.parse(params[:url]).open {|f| body = f.read }
    haml :readable, {}, :readable_content => Readability::Document.new(body).content
  end
end
