require 'rubygems'
require 'rest_client'
require 'json'
filename = ARGV[0]
if filename and File.exists?(filename)
  begin
    file = File.new filename
 response = RestClient.post "http://localhost/web/songs", file.read, :content_type => "audio/mpeg"
 puts response
  rescue RuntimeError => e
    puts e
  end
else
  puts "No File at #{filename}"
end
