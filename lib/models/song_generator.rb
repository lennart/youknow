load 'models/song.rb'
load 'models/album.rb'
load 'models/artist.rb'
load 'models/metadata.rb'
class SongGeneratorError < RuntimeError
  attr :reason
  def initialize(reason)
    @reason = reason
  end

  def to_json
    (@reason.respond_to?(:to_json) && @reason.respond_to?(:merge)) ? @reason.merge({:error => true}).to_json : {:error => true}
  end

  def to_s
    @reason.to_s
  end
end

class SongGenerator
  class << self
    def add_song(file, tag, morph_source = nil)
      raise SongGeneratorError.new({:missing => :all}) unless tag.kind_of? Metadata
      metadata = {:filter => {}}
      threads = []
      file.open if file.kind_of? Tempfile
      check_metadata(tag)
      unless tag.album.blank? or tag.track == 0
        threads << Thread.new(metadata) do |metadata|
          metadata[:filter][:album] = find_or_create_album_by_title(tag)
        end
      end

      threads << Thread.new(metadata) do |metadata|
        metadata[:filter][:artist] = find_or_create_artist_by_name(tag)
      end
      begin
        threads.each { |t| t.join }
      rescue SongGeneratorError => e
        raise e
      end

      song = find_or_create_song_by_name(tag, metadata, file, morph_source)
      return song.id
    end


    def check_metadata(tag)
      raise SongGeneratorError.new({:missing => :album}) if not (title = tag.album).blank? and tag.track == 0
      raise SongGeneratorError.new({:missing => :artist}) if (name = tag.artist).blank? 
      raise SongGeneratorError.new({:missing => :title}) if (title = tag.title).blank?
    end

    def find_or_create_song_by_name(tag, metadata, file, morph_source = nil)
      title = tag.title.strip
      track = tag.track

      potential_songs = Song.by_title_and_artist  :key => [title, metadata[:filter][:artist].id]
      song = if potential_songs.empty?
               if morph_source.respond_to? :morph_to
                 a = morph_source.morph_to(Song)
                 a.title = title
               else
                 a = Song.new  :title => title
               end
               a.appears_on_album = { metadata[:filter][:album].id => track } if track
               a.written_by = [metadata[:filter][:artist].id]
               if tag.genre
                 a.tags = [tag.genre]
               end
               raise SongGeneratorError.new({:missing => :all}) unless a.save
               a.put_attachment "audio/default", file.read, :content_type => "audio/mpeg"
               a
             else
               song = potential_songs.first
               unless song.appears_on_album
                 song.appears_on_album = { metadata[:filter][:album].id => track } if track
               else
                 song.appears_on_album[metadata[:filter][:album].id] = track if track and metadata[:filter][:album].id
               end

             end
      song
    end


    def find_or_create_album_by_title(tag)
      title = tag.album.strip
      potential_albums = Album.by_title(:key => title)

      album = if potential_albums.empty?
                a = Album.new :title => title
                a.release_date = tag.year != 0 ? Date.strptime(tag.year.to_s, "%Y") : Date.new
                artwork = check_artwork(tag)
                raise SongGeneratorError.new({:missing => :album}) unless a.save
                if artwork
                  a.put_attachment 'cover',artwork.data, 'content_type' => artwork.mimetype
                end
                a
              else
                potential_albums.first
              end
      album
    end

    def check_artwork(tag)
      if tag.artwork
        artwork = tag.artwork

        if artwork.mimetype.blank?
          tmpfile = Tempfile.new("artwork")
          tmpfile.write f.image(0).data
          mimetype = MIME.check_magics(tmpfile)
          if mimetype
            artwork.mimetype = mimetype.type
          else
            return nil
          end
        end
        return artwork
      else
        return nil
      end
    end

    def find_or_create_artist_by_name(tag)
      name = tag.artist.strip
      potential_artists = Artist.by_name(:key => name)
      artist = if potential_artists.empty?
                 a = Artist.new :name => name
                 a.save
                 a
               else
                 potential_artists.first
               end
      artist
    end
  end
end
