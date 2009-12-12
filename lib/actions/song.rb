module SongActions
  load 'models/song.rb'
  load 'models/song_generator.rb'
  def self.registered(app)
    app.instance_eval do
      post '/songs/?' do
        tempfile = Tempfile.new((rand*10000).to_s)
        tempfile.write request.body.read
        tempfile.close
        begin
          { "id" => SongGenerator.add_song(tempfile)}.to_json
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
    end
  end
end
