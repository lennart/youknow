require ::File.join(::File.dirname(__FILE__),*%w{.. .. config boot})
class SongImporter
  @queue = :medium
  def self.perform(params)
    path, metadata, morph_source = params
    uri = path
    begin
      uri = URI.parse path
      mode = :http if not uri.scheme.nil? and uri.scheme.match(/\Ahttps?\Z/)
    rescue URI::InvalidURIError
    end
    mode ||= :file 
    case mode
    when :http then
      SongGenerator.add_song_from_url(uri.to_s, Metadata.new(metadata))
    when :file then
      if morph_source
        SongGenerator.add_song(File.new(uri.to_s),Metadata.new(metadata), YouTubeVideo.by_video_id(:key => morph_source).first)
      else
        SongGenerator.add_song(File.new(uri.to_s),Metadata.new(metadata))
      end
    end
  end
end
