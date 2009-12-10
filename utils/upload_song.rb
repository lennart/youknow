require 'rubygems'
require 'rest_client'
require 'json'
filename = ARGV[0]
host = ARGV[1] || "http://localhost/web/songs"
def upload_file(host, file)
  puts "Uploading #{File.basename file.path}"
  begin
    response = RestClient.post host, file.read, :content_type => "audio/mpeg"
    puts response
  rescue RuntimeError => e
    puts e
  end
end
if filename and File.exists?(filename)
  file = File.new filename
  if File.directory?(file)
    threads = []
    Dir[File.join(file.path,"*.mp3")].each do |filename|
      file = File.new filename
      threads << Thread.new(host, file) do |host, file|
        upload_file host, file
      end
    end
    threads.each { |t| t.join }
  else
    upload_file host, file
  end
else
  puts "No File at #{filename}"
end
