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
YOUTUBE_STREAM_NAMES = {"37" => "mp4@1080p", "22" => "mp4@720p", "18" => "mp4", "34" => "flv", "35" => "flv@480p", "17" => "3gp", "5" => "flv#22.05Khz", "6" => "flv#44.1Khz" }
load 'models/search_result.rb'
class YouTubeStreamMissingError < RuntimeError
end
class YouTubeVideo < SearchResult
  ducktype_traits :title, :embed_url, :available_streams
  include MorphableDocument
  include CouchRest::Validation
  include Guessing
  property :deep_links_expire_at, :cast_as => 'Time'
  property :available_streams, :default => {}

  view_by :video_id, :ducktype => true
  validates_presence_of :title, :embed_url, :video_id

  def self.format_name id
    raise "#{id} is not an Integer" unless id.is_a?(Integer)
    YOUTUBE_STREAM_NAMES[id.to_s]
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
      self["deep_links_expire_at"].nil? ? nil : self["deep_links_expire_at"].to_i
    else
      self["deep_links_expire_at"]
    end
  end

  def deep_links_expire_at= new_age
    self["deep_links_expire_at"] = Time.at new_age.to_i
  end

  def format_id_for_name format_name
    YOUTUBE_STREAM_NAMES.select do |id, name|
      name == format_name
    end.first.first
  end

  def deep_link format = nil
    update_volatile_properties if Time.now.to_i >= deep_links_expire_at
    if format
      raise "Format is not an Integer" unless format.is_a?(Integer)
      if available_streams.has_key? format.to_s
        available_streams[format.to_s]
      else
        raise "Format #{format} not available"
      end
    else
      available_streams[best_format.to_s]
    end
  end

  def format_name format_name
    self.class.format_name format_name
  end

  def best_format_name 
    format = best_format
    puts "BestFormat is a:#{format.class}"
    format_name format
  end

  def best_format formats = [YOUTUBE_FULL_HD,YOUTUBE_HD,YOUTUBE_FLV_HIGH,YOUTUBE_SD,YOUTUBE_FLV_STEREO]
    return @_best_format.to_i if @_best_format
    best_format = YOUTUBE_FLV_MONO
    formats.each do |format|
      if available_streams.has_key? format.to_s
        best_format = format.to_i
        break
      end
    end
    @_best_format = best_format
    return best_format.to_i
  end

  def parse_expire url
    uri = URI.parse url
    raise "Query missing #{url}" unless uri.query
    URI.unescape(uri.query) =~ /expire=([0-9]+)&/
      self.deep_links_expire_at = $1
    save
  end

  def update_volatile_properties
    raise "Video ID missing" if self.video_id.nil?
    doc = Hpricot(Curl::Easy.perform(YOUTUBE+"/watch?v=#{video_id}").body_str)
    (doc/"title").text =~ /\s*YouTube\s*-\s*(.*)\s*/
      self.title = $1
    (doc/"script").text =~ /\s+'SWF_ARGS':\s+(.*),\s*$/
      flash_vars_string = $1
    if flash_vars_string
      flash_vars = JSON.parse flash_vars_string 
      URI.unescape(flash_vars["fmt_stream_map"]).split(",").map do |str|
        stream_format, stream_url = str.split "|"
        available_streams[stream_format] = stream_url
      end
      # Set Expiry Time to the expire Timestamp of the first stream url
      parse_expire available_streams.first.last
    else 
      raise YouTubeStreamMissingError.new
    end
  end

  def download_best_video options = {}
    download_video best_format, options
  end

  def download_video format, options = {}
    raise "Format is not an Integer" unless format.is_a?(Integer)
    options[:metadata] = guess_best_metadata(options[:metadata] || Metadata.new(:title => title))
    options[:convert_to_audio] ||= false
    options[:format] = format 
    source = self
    destination = ::File.join(SINATRA_ROOT,"tmp","#{UUID.generate :compact}.#{format_name(format)[0..2]}")
    Resque.enqueue(::Downloader,[source,destination,options])
  end
end

