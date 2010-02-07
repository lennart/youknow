class Main
  get "/stylesheets/:stylesheet.css" do
    content_type "text/css", :charset => "UTF-8"
    sass :"css/#{params[:stylesheet]}"
  end
end
