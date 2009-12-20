require ::File.join(::File.dirname(__FILE__),*%w{.. .. config boot})
class DownloaderError < StandardError
end
module Downloader
  @queue = :default

  class << self
    def prepare_params source_id, destination, options
      raise DownloaderError.new "YouTube Video ID missing or invalid" unless source_id and source_id.kind_of?(String)
      meta = OpenStruct.new :destination => destination, :data => Metadata.new(options["metadata"]),
        :convert_to_audio => options["convert_to_audio"]
      meta.source = YouTubeVideo.by_video_id(:key => source_id).first

      raise DownloaderError.new "YouTube Video with Video ID #{source_id} missing" unless meta.source
      meta.link = meta.source.deep_link options["format"]
      meta.destination = destination
      meta.attachment_name = YouTubeVideo.format_name(options["format"].to_i)
      meta.attachment_content_type = "video/mp4"
      meta.attachment_name =~ /(^[0-9A-Za-z]{3})/
        if $1 == "flv"
          meta.attachment_content_type = "video/x-flv"
        end
      meta
    end

    def fetch_video_file source, link, destination, attachment_name, attachment_content_type 
      attachment = nil
      unless source.has_attachment? attachment_name
        attachment = CurbToCouch.download(link, destination)
        source.put_attachment(attachment_name,attachment.read,:content_type => attachment_content_type)
      else
        f = File.new destination, "w"
        f.write source.fetch_attachment(attachment_name)
        f.close
      end
      attachment
    end

    def perform(params)
      meta = prepare_params(*params)
      attachment = fetch_video_file meta.source, meta.link, meta.destination, meta.attachment_name, meta.attachment_content_type
      if meta.convert_to_audio
        if meta.data.nil? or meta.data.artist.blank?
          raise DownloaderError.new("Cannot Convert to Song, since Artist is missing")
        else
          Resque.enqueue(Video2Music,
                         [meta.source.video_id, 
                           meta.destination, 
                           meta.data])
        end
      else
        File.unlink(attachment.path)
      end
    end

  end
end
