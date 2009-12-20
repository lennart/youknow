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
      file.open if file.kind_of? Tempfile
      threads, metadata = prepare_for_import(tag)
      begin
        threads.each { |t| t.join }
      rescue SongGeneratorError => e
        raise e
      end

      song = find_or_create_song_by_name(tag, metadata, morph_source) do
        file
      end
      return song.id
    end

    def add_song_from_url(url, tag)
      raise SongGeneratorError.new({:missing => :all}) unless tag.kind_of? Metadata
      threads, metadata = prepare_for_import(tag)
      begin
        threads.each { |t| t.join }
      rescue SongGeneratorError => e
        raise e
      end
  
      path = ::File.join(SINATRA_ROOT,"tmp","#{UUID.generate :compact}.mp3")

      song = find_or_create_song_by_name(tag, metadata) do
        CurbToCouch.download url, path
      end
      return song.id
    end

    def prepare_for_import tag, threads = [], metadata = OpenStruct.new(:filter => OpenStruct.new)
      check_metadata(tag)
      if not tag.album.blank? and tag.track
        threads << Thread.new(metadata) do |metadata|
          metadata.filter.album = find_or_create_album_by_title(tag)
        end
      end

      threads << Thread.new(metadata) do |metadata|
        metadata.filter.artist = find_or_create_artist_by_name(tag)
      end
      [threads, metadata]
    end

    def check_metadata(tag)
      raise SongGeneratorError.new({:missing => :album}) if not (title = tag.album).blank? and tag.track == 0
      raise SongGeneratorError.new({:missing => :artist}) if (name = tag.artist).blank? 
      raise SongGeneratorError.new({:missing => :title}) if (title = tag.title).blank?
    end

    def add_album_to_song song, album = nil, track = nil
      unless album.nil?
        raise SongGeneratorError.new({:missing => :album}) unless track.is_a?(Integer) and track != 0 
        if song.appears_on_album and not song.appears_on_album.empty?
          song.appears_on_album[album.id] = track
        else
          song.appears_on_album = { album.id => track } 
        end
      end
    end

    def find_or_create_song_by_name(tag, metadata, morph_source = nil)
      title = tag.title.strip
      track = tag.track

      potential_songs = Song.by_title_and_artist  :key => [title, metadata.filter.artist.id]
      song = if potential_songs.empty?
               if morph_source.respond_to? :morph_to
                 a = morph_source.morph_to(Song)
                 a.title = title
               else
                 a = Song.new  :title => title
               end
               add_album_to_song a, metadata.filter.album, track
               a.written_by = [metadata.filter.artist.id]
               if tag.genre
                 a.tags ||= []
                 if tag.genre.kind_of?(Array)
                   a.tags.concat tag.genre
                 else
                   a.tags << tag.genre
                 end
                 a.tags.uniq!
               end
               raise SongGeneratorError.new({:missing => :all}) unless a.save
               unless a.has_attachment?("audio/default")
                 data = yield 
                 mimetype = MIME.check_magics(data).type || "audio/mpeg"
                 a.put_attachment "audio/default", data.read, :content_type => mimetype.to_s
               end
               a
             else
               song = potential_songs.first
               add_album_to_song song, metadata.filter.album, track
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
