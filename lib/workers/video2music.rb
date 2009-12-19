require ::File.join(::File.dirname(__FILE__),*%w{.. .. config boot})
require 'open3'
module Video2Music
  @queue = :high
    TO_OGG = lambda do |input|
      quiet = "" # "2> /dev/null "
      destination = escape_quotes(replace_extension(input, "ogg"))
      `ffmpeg -i "#{escape_quotes(input)}" -f wav - #{quiet}| oggenc -q 4 -Q - > "#{destination}"`
      destination
    end

    COPY_AUDIO_STREAM = lambda do |input|
      destination = escape_quotes(replace_extension(input,"mp3"))
      `ffmpeg -i "#{escape_quotes(input)}" -acodec copy -f mp3 #{destination}`
      destination
    end
  class << self 
    def escape_quotes(str)
      str.gsub(/"/,'\"')
    end

    def replace_extension(path, extension)
      path.gsub(/\.[0-9A-Za-z]{3,4}/,".#{extension}")
    end


    def perform(params)
      video_id, source, metadata = params
      video = YouTubeVideo.by_video_id(:key => video_id).first
      raise "YouTube Video Missing" if video.nil?
      destination = case video.best_format_name
                    when "flv" then
                      TO_OGG.call(source)
                    when "flv#22.05Khz" then
                      COPY_AUDIO_STREAM.call(source)
                    when "flv#44.1Khz" then
                      COPY_AUDIO_STREAM.call(source)
                    when "flv@480p" then
                      TO_OGG.call(source)
                    when "mp4" then
                      TO_OGG.call(source)
                    when "mp4@720p" then
                      TO_OGG.call(source)
                    when "mp4@1080p" then
                      TO_OGG.call(source)
                    else
                      COPY_AUDIO_STREAM.call(source)
                    end
      Resque.enqueue(SongImporter,[destination, metadata, video_id])
      File.unlink(source)
    end
  end
end
