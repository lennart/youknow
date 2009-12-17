require ::File.join(::File.dirname(__FILE__),*%w{.. .. config boot})
require ::File.join(::File.dirname(__FILE__),*%w{.. .. config app_config})
require ::File.join(::File.dirname(__FILE__),*%w{video2music})
module Downloader
  @queue = :default

  class << self
    def perform(params)
      source, destination, options = params
      link = source
      can_be_converted = false
      if source.kind_of? Hash
        source = YouTubeVideo.new source 
        link = source.deep_link
        can_be_converted = true
        download(link, destination)
        attachment = File.new(destination,"rb")
        name = source.best_format_name
        content_type = "video/mp4"
        name =~ /(^[0-9A-Za-z]{3})/
          if $1 == "flv"
            content_type = "video/x-flv"
          end
        source.put_attachment(name,attachment.read,:content_type => content_type)
        if options["convert_to_audio"] and can_be_converted
          Resque.enqueue(Video2Music,
                         [attachment.path, 
                         source,
                         attachment.path.gsub(/\.[0-9A-Za-z]{3,4}/,".mp3"),
                         options["metadata"]])
                           
        else
          File.unlink(attachment.path)
        end
      else
        download(link,destination)
        Resque.enqueue(SongImporter, [destination, options["metadata"]])
      end
    end

    def download(url, path)
      file = File.new(path,"wb")
      easy = Curl::Easy.new(url)
      easy.follow_location = true
      easy.on_body do |data| 
        file.write data 
      end
      easy.perform
      file.close
    end
  end
end
