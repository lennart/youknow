require 'net/http'
YOUTUBE="www.youtube.com"

module YouTube
  class Downloader
    class << self
      def make_snip quality, video_id, hash
        return "/get_video?fmt=#{quality}&video_id=#{video_id}&t=#{hash}"
      end

      def fetch_url_for_video_id video_id
        raise if video_id.nil?
        doc = Hpricot(RestClient.get(YOUTUBE+"/watch?v=#{video_id}"))
        (doc/"title").text =~ /\s*YouTube\s*-\s*(.*)\s*/
          title = $1
        (doc/"script").text =~ /\s+'SWF_ARGS':\s+(.*),\s*$/
          flash_vars_string = $1
        if flash_vars_string
          flash_vars = JSON.parse flash_vars_string 
          quality = 22
          if Net::HTTP.new(YOUTUBE).head(make_snip(quality,flash_vars["video_id"],flash_vars["t"])).code == "404"
            quality = 18
          end
          "http://"+YOUTUBE+make_snip(quality,flash_vars["video_id"], flash_vars["t"])
        else 
          raise "couldn't find FlashVars"
        end
      end

      def download_to source, destination
        file = File.new(destination,"wb")
        easy = Curl::Easy.new(source)
        #    easy.verbose = true
        easy.follow_location = true
        easy.on_header do |header|
          header =~ /\AContent-Length: ([0-9]+)/
            length = $1
          if length
            @filesize = length.to_i
          end
          header.size
        end
        easy.on_body do |data| 
          progress ||= ProgressBar.new("Download",@filesize, STDOUT)
          progress.set File.size(file.path) 

          file.write data 
        end
        easy.perform
        file.close
      end
    end
  end
end

