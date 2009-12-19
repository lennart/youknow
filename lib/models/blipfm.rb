BLIPFM_ROOT="http://api.blip.fm/blip/"
class BlipFM
  extend Guessing
  class << self
    def sync username
      with_blips(username) do |blip|
        download_blip(blip, true)
      end
    end

    def download_blip(blip, convert = false)
      if blip.video_id?  
        download_youtube_video(blip.video_id, blip, convert)
      else
        download_mp3(blip.url, blip)
      end
    end

    def with_blips username, &block
      uri = URI.parse(BLIPFM_ROOT)
      uri.query = { :username => username}.map{|k,v| "#{k}=#{v}" }.join("&")
      uri.path << "getUserProfile.json"
      blips_raw = Curl::Easy.perform(uri.to_s).body_str
      blips = JSON.parse(blips_raw)["result"]["collection"]["Blip"]

      blips.map do |blip|
        meta = Metadata.new
        meta.blip_id = blip["id"]
        meta.blip_time = blip["unixTime"]
        meta.blip_user = blip["ownerId"]
        meta.title = blip["title"]
        meta.artist = blip["artist"]
        meta.blip = blip["message"]
        meta.reblip_id = blip["reblipId"]
        case blip["type"]
        when "youtubeVideo":
          meta.video_id = blip["url"]
          meta.source = "YouTube"
        when "songUrl":
          meta.url = blip["url"]
          meta.source = "HTTP"
        end
        yield meta if block_given?
        meta
      end
    end


    def download_youtube_video(video_id, metadata, convert = false) 
      puts "Should now download Youtube Video"
      video = YouTubeVideo.by_video_id(:key => video_id).first
      unless video
        remote = YouTubeG::Client.new
        video = YouTubeVideo.new remote.videos_by(:query => video_id, :per_page => 1).videos.first
        raise "Cannot save video" unless video.save
      end
      options = {:convert_to_audio => convert,
        :metadata => metadata}

      video.download_best_video options
    end

    def download_mp3(url, metadata)
      metadata = guess_best_metadata metadata
      return false if metadata.artist.blank?
      destination = sinatra("tmp","#{UUID.generate :compact}.mp3") 

      Resque.enqueue ::SongImporter, [url, metadata]
    end

  end
end
