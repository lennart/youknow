require 'rubygems'
require 'rest_client'
require 'json'
filename = ARGV[0]
host = ARGV[1] || "http://localhost/web/songs"
if filename and File.exists?(filename)
  begin
    file = File.new filename
    
 response = RestClient.post host, file.read, :content_type => "audio/mpeg"
 puts response
  rescue RuntimeError => e
    puts e
  end
else
  puts "No File at #{filename}"
end
