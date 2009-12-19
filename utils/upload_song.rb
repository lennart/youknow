require ::File.join(::File.dirname(__FILE__),"..","config","boot")
require 'base64'
filename = ARGV[0]
host = ARGV[1] || "http://127.0.0.1/web/songs"
def fetch_meta(filename)
  tag = TagLib2::File.new(filename)
  metadata = {}
  %w{artist title}.each do |a|
    value = tag.method(a).call 
    raise "Please fix your Tags: #{a} missing" unless value != ""
    metadata[a] = value
  end
  raise "Please add track for album" if not tag.album == "" and tag.track == 0
  raise "Please add an Album for Track Number" if tag.album == "" and tag.track > 0
  metadata[:track] = tag.track unless tag.track == 0
  metadata[:album] = tag.album unless tag.album == ""
  metadata[:year] = tag.year unless tag.album == 0
  metadata[:genre] = tag.genre unless tag.genre == ""
  if tag.image_count > 0
    artwork = {}
    artwork[:data] = Base64.encode64(tag.image(0).data)
    artwork[:mimetype] = tag.image(0).mime_type
    metadata[:artwork] = artwork
  end
  metadata
end

def upload_file(host, file)
  puts "Uploading #{File.basename file.path}"
  begin
    doc = fetch_meta(file.path)
    content_type = MIME.check_magics(file.path).to_s
    name = File.basename file.path
    fields = CurbToCouch.fields_for_doc_with_attachment(doc, file, name, content_type)
    response = CurbToCouch.post_data host, fields
    puts response
    #response = RestClient.post host, file.read, :content_type => "audio/mpeg"
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
