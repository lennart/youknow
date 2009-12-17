require ::File.join(::File.dirname(__FILE__),*%w{.. .. config boot})
require ::File.join(::File.dirname(__FILE__),*%w{.. .. config app_config})
require ::File.join(::File.dirname(__FILE__),*%w{.. models youtube})
require 'open3'
module Video2Music
  @queue = :default

  def self.perform(params)
    source, video, destination, metadata = params["destination"]
    video = YouTubeVideo.new params["video"]
    `ffmpeg -i "#{source}" -y -f mp3 -sameq "#{destination}"`
    Resque.enqueue(SongImporter,destination, metadata)
    File.unlink(source)
  end
end
