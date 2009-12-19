module SongActions
  load 'models/song.rb'
  load 'models/song_generator.rb'
  def self.registered(app)
    app.instance_eval do
      post '/songs/?' do
        begin
          { "id" => SongGenerator.add_song(params["_attachments"][:tempfile], Metadata.new(JSON.parse(params["_doc"])))}.to_json
        rescue SongGeneratorError => e
          return e.reason.to_json
        end

      end

      delete '/songs/:id' do
        Song.get(params[:id]).destroy
      end

      get '/songs/?' do
        songs = Song.all
        haml :songs, {}, :songs => songs
      end

      get '/songs.m3u' do
        songs = Song.all
        content_type = "audio/x-mpegurl"
        ["#EXTM3U"].concat(songs.map do |song|
          if song.has_attachment? "audio/default"
            artist = Artist.get song.written_by.first
            url = song.attachment_url "audio/default"
            ["#EXTINF:#{song["duration"] ? song["duration"] : -1},#{artist.name},#{song.title}",url.gsub(/\A#{song.database.to_s}/, SiteConfig.host_url+"/"+SiteConfig.database_name)]
          end
        end).flatten.compact.join("\n")

      end
    end
  end
end
