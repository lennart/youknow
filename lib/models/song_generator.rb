load 'models/song.rb'
load 'models/album.rb'
load 'models/artist.rb'
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
  GENRES = ["Blues ",
"Classic Rock",
"Country",
"Dance",
"Disco",
"Funk",
"Grunge",
"Hip-Hop",
"Jazz",
"Metal",
"New Age",
"Oldies",
"Other",
"Pop",
"R&B",
"Rap",
"Reggae",
"Rock",
"Techno",
"Industrial",
"Alternative",
"Ska",
"Death Metal",
"Pranks",
"Soundtrack",
"Euro-Techno",
"Ambient",
"Trip-Hop",
"Vocal",
"Jazz+Funk",
"Fusion",
"Trance",
"Classical",
"Instrumental",
"Acid",
"House",
"Game",
"Sound Clip",
"Gospel",
"Noise",
"Alternative Rock",
"Bass",
"Soul",
"Punk",
"Space",
"Meditative",
"Instrumental Pop",
"Instrumental Rock",
"Ethnic",
"Gothic",
"Darkwave",
"Techno-Industrial",
"Electronic",
"Pop-Folk",
"Eurodance",
"Dream",
"Southern Rock",
"Comedy",
"Cult",
"Gangsta",
"Top 40",
"Christian Rap",
"Pop/Funk",
"Jungle",
"Native American",
"Cabaret",
"New Wave",
"Psychadelic",
"Rave",
"Showtunes",
"Trailer",
"Lo-Fi",
"Tribal",
"Acid Punk",
"Acid Jazz",
"Polka",
"Retro",
"Musical",
"Rock & Roll",
"Hard Rock",
"Folk",
"Folk-Rock",
"National Folk",
"Swing",
"Fast Fusion",
"Bebob",
"Latin",
"Revival",
"Celtic",
"Bluegrass",
"Avantgarde",
"Gothic Rock",
"Progressive Rock",
"Psychedelic Rock",
"Symphonic Rock",
"Slow Rock",
"Big Band",
"Chorus",
"Easy Listening",
"Acoustic",
"Humour",
"Speech",
"Chanson",
"Opera",
"Chamber Music",
"Sonata",
"Symphony",
"Booty Bass",
"Primus",
"Porn Groove",
"Satire",
"Slow Jam",
"Club",
"Tango",
"Samba",
"Folklore",
"Ballad",
"Power Ballad",
"Rhythmic Soul",
"Freestyle",
"Duet",
"Punk Rock",
"Drum Solo",
"A capella",
"Euro-House",
"Dance Hall"]
  class << self
    def add_song(file)
      metadata = {:filter => {}}
      threads = []
      file.open if file.kind_of? Tempfile
      tag = TagLib2::File.new file.path
      check_id3_tag(tag)
      threads << Thread.new(metadata) do |metadata|
        metadata[:filter][:album] = find_or_create_album_by_title(tag)
      end

      threads << Thread.new(metadata) do |metadata|
        metadata[:filter][:artist] = find_or_create_artist_by_name(tag)
      end
      #threads << Thread.new(metadata) do |metadata|
      #  metadata[:tag] = find_or_create_tag_by_name(tag)
      #end

      begin
        threads.each { |t| t.join }
      rescue SongGeneratorError => e
        raise e
      end

      song = find_or_create_song_by_name(tag, metadata, file)
      return song.id
    end

    def genre_name_from_code(string)
      if match = string.match(/\(([0-9]+)\)/)
        GENRES[match.captures.first.to_i]
      else
        string
      end
    end

    def check_id3_tag(tag)
      raise SongGeneratorError.new({:missing => :album}) if not (title = tag.album).blank? and tag.track == 0
#      raise SongGeneratorError.new({:missing => :tag}) if (name = tag.genre).nil? 
      raise SongGeneratorError.new({:missing => :artist}) if (name = tag.artist).blank? 
      raise SongGeneratorError.new({:missing => :title}) if (title = tag.title).blank?
    end

    def find_or_create_song_by_name(tag, metadata, file)
      title = tag.title.strip
      track = tag.track

      potential_songs = Song.by_title_and_artist  :key => [title, metadata[:filter][:artist].id]
      song = if potential_songs.empty?
               a = Song.new  :title => title
               a.appears_on_album = { metadata[:filter][:album].id => track }
               a.written_by = [metadata[:filter][:artist].id]
#               if tag.lyrics
#                 a.lyrics = tag.lyrics
#               end
               if tag.genre
                 a.tags = [genre_name_from_code(tag.genre)]
               end
               a.save
               a.put_attachment "default", file.read, :content_type => "audio/mpeg"
               a
             else
               potential_songs.first
             end
      song
    end

    def create_attachment(file)
      audiofile = Audiofile.new
      audiofile.save
      audiofile.put_attachment "attachment",
        file.read, :content_type => "audio/mpeg"  
      audiofile
    end

    def find_or_create_album_by_title(tag)
      title = tag.album.strip
      potential_albums = Album.by_title(:key => title)

      album = if potential_albums.empty?
                a = Album.new :title => title
                a.release_date = tag.year != 0 ? Date.strptime(tag.year.to_s, "%Y") : Date.new
                puts "Release date set"
                artwork = check_artwork(tag)
                a.save
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
      puts "Checking Artwork"
      if tag.image_count > 0
        puts "Has Artwork"
        artwork = OpenStruct.new
        artwork.data = tag.image(0).data
        artwork.mimetype = tag.image(0).mimeType

        if artwork.mimetype.blank?
          tmpfile = Tempfile.new("artwork")
          tmpfile.write f.image(0).data
          puts "Checking Mimetype"
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
