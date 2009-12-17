require 'net/http'
YOUTUBE="www.youtube.com"
YOUTUBE_FULL_HD=37
YOUTUBE_HD=22
YOUTUBE_SD=18
YOUTUBE_FLV_HIGH=35
YOUTUBE_FLV=34
YOUTUBE_FLV_MONO=5
YOUTUBE_FLV_STEREO=6
YOUTUBE_3GP=17
YOUTUBE_STREAM_NAMES = {37 => "mp4@1080p", 22 => "mp4@720p", 18 => "mp4", 34 => "flv", 35 => "flv@480p", 17 => "3gp", 5 => "flv#mono", 6 => "flv#stereo" }
load 'models/search_result.rb'
class YouTubeStreamMissingError < RuntimeError
end
class YouTubeVideo < SearchResult
  ducktype_traits :title, :embed_url, :duration, :available_streams
  include MorphableDocument
  property :deep_links_expire_at, :cast_as => 'Time'
  property :available_streams, :default => {}

  view_by :video_id, :ducktype => true

  def self.format_name(id)
    YOUTUBE_STREAM_NAMES[id.to_i]
  end

  def initialize(passed_keys = {})
    unless passed_keys.kind_of? YouTubeG::Model::Video
      super passed_keys
    else
      video = passed_keys
      passed_keys = {}
      super
      video.video_id =~ /\/([^\/]*)\Z/
        self.video_id = $1
      self.embed_url = video.embed_url
      self.duration = video.duration
      self.title = video.title
      self.tags = video.keywords
      self.source = "YouTube"
      update_volatile_properties
    end
  end

  def deep_links_expire_at(format = :timestamp)
    if format == :timestamp
      self["deep_links_expire_at"].to_i
    else
      self["deep_links_expire_at"]
    end
  end

  def deep_links_expire_at= new_age
    self["deep_links_expire_at"] = Time.at new_age.to_i
  end

  def deep_link
    update_volatile_properties if Time.now.to_i >= deep_links_expire_at
    available_streams[best_format]
  end

  def best_format_name
    self.class.format_name best_format
  end

  def best_format formats = [YOUTUBE_FULL_HD,YOUTUBE_HD,YOUTUBE_FLV_HIGH,YOUTUBE_SD,YOUTUBE_FLV_STEREO]
    return @best_format if @best_format
    best_format = YOUTUBE_FLV_MONO
    formats.each do |format|
      if available_streams.has_key? format
        best_format = format
        break
      end
    end
    @best_format = best_format
    best_format
  end

  def parse_expire(url)
    URI.unescape((URI.parse url).query) =~ /expire=([0-9]+)&/
      self.deep_links_expire_at = $1
  end

  def update_volatile_properties
    raise if self.video_id.nil?
    doc = Hpricot(Curl::Easy.perform(YOUTUBE+"/watch?v=#{video_id}").body_str)
    (doc/"title").text =~ /\s*YouTube\s*-\s*(.*)\s*/
      self.title = $1
    (doc/"script").text =~ /\s+'SWF_ARGS':\s+(.*),\s*$/
      flash_vars_string = $1
    if flash_vars_string
      flash_vars = JSON.parse flash_vars_string 
      URI.unescape(flash_vars["fmt_stream_map"]).split(",").map do |str|
        stream_format, stream_url = str.split "|"
        available_streams[stream_format.to_i] = stream_url
      end
      puts "Streams: #{available_streams.to_yaml}"
      # Set Expiry Time to the expire Timestamp of the first stream url
      parse_expire available_streams.first.last
    else 
      raise YouTubeStreamMissingError.new
    end
  end

  def download_best_video options = {}
    options["convert_to_audio"] ||= false
    source = self
    destination = ::File.join(SINATRA_ROOT,"tmp","#{UUID.generate :compact}.mp4")
    Resque.enqueue(::Downloader,[source,destination,options])
  end

  private 

  def make_snip quality, video_id, hash
    return "/get_video?fmt=#{quality}&video_id=#{video_id}&t=#{hash}"
  end
end

