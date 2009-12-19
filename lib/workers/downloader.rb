require ::File.join(::File.dirname(__FILE__),*%w{.. .. config boot})
class DownloaderError < StandardError
end
module Downloader
  @queue = :default

  class << self
    def perform(params)
      source, destination, options = params
      link = source
      can_be_converted = false
      source = YouTubeVideo.by_video_id(:key => source).first
      raise "YouTube Video missing" unless source
      link = source.deep_link options["format"]
      can_be_converted = true
      name = options["format"]
      content_type = "video/mp4"
      name =~ /(^[0-9A-Za-z]{3})/
        if $1 == "flv"
          content_type = "video/x-flv"
        end
      unless source.has_attachment? name
        attachment = CurbToCouch.download(link, destination)
        source.put_attachment(name,attachment.read,:content_type => content_type)
      else
        f = File.new destination, "w"
        f.write source.fetch_attachment(name)
        f.close
      end
      if options["convert_to_audio"] and can_be_converted
        if options["metadata"].nil? or options["metadata"]["artist"].blank?
          raise DownloaderError.new("Cannot Convert to Song, since Artist is missing")
        else
          Resque.enqueue(Video2Music,
                         [source.video_id, 
                           destination, 
                           options["metadata"]])
        end

      else
        File.unlink(attachment.path)
      end
    end

  end
end
