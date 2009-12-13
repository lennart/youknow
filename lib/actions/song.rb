module SongActions
  load 'models/song.rb'
  load 'models/song_generator.rb'
  def self.registered(app)
    app.instance_eval do
      post '/songs/?' do
        path = ::File.join(::File.dirname(__FILE__), "..","..","tmp",(rand*10000).to_s+".mp3")
        tempfile = ::File.open(path, "wb") do |f|
          f.write request.body.read
        end
        begin
          { "id" => SongGenerator.add_song(File.new(path,"r"))}.to_json
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
