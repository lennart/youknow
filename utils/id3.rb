require ::File.join(::File.dirname(__FILE__),*%w{.. vendor gems environment})
Bundler.require_env
require 'tempfile'
if ARGV.size > 0
f = TagLib2::File.new(ARGV[0])

puts "\"#{f.title}\" by #{f.artist}"
puts "is tagged as #{f.genre}" unless f.genre.blank?
puts "appears on #{f.album} as Track No. #{f.track}"
puts "running #{f.length/60}:#{f.length%60} minutes"
puts "at #{f.sampleRate}hz"
if f.imageCount > 0
  puts "and has a #{f.image(0).mimeType} Cover for #{f.image(0).type}"
end
else
  puts "Specify file to read ID3Tags from"
end
