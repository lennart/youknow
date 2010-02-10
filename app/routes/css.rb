class Main
  get "/stylesheets/:stylesheet.css" do
    content_type "text/css", :charset => "UTF-8"
    sass :"css/#{params[:stylesheet]}"
    etag Time.now.to_i
  end
end
