BLIPFM_ROOT="http://api.blip.fm/blip/"
class BlipFM
  class << self
    def sync(username)
      blips_raw = Curl::Easy.perform(BLIPFM_ROOT+"getUserProfile.json?username=#{username}").body_str
      blips = JSON.parse(blips_raw)["result"]["collection"]["Blip"]
      blips.each do |blip|
        metadata = Metadata.new :title => blip["title"],
          :artist => blip["artist"]
        case blip["type"]
        when "youtubeVideo":
          download_youtube_video(blip["url"], metadata)
        when "songUrl":
          download_mp3(blip["url"], metadata)
        end
      end
    end

    def download_youtube_video(video_id, metadata) 
      video = YouTubeVideo.new :video_id => video_id
      options = {:convert_to_audio => true, :metadata => metadata}
      video.download_best_video options
    end

    def download_mp3(url, metadata)
      options = { :metadata => metadata }
      destination = ::File.join(SINATRA_ROOT,"tmp","#{UUID.generate :compact}.mp4")
      Resque.enqueue(::Downloader,[url,destination,options])
    end

  end
end
