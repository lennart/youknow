
class ModularApplication < Sinatra::Base
  helpers Sinatra::UrlForHelper

  register Sinatra::StaticAssets

  load 'actions/song.rb'
  register SongActions
  load 'actions/search.rb'
  register SearchActions

  enable :xhtml
  enable :sessions

  error do
    e = request.env['sinatra.error']
    puts e.to_s
    puts e.backtrace.join("\n")
    "Application error"
  end

  helpers do
  end


  delete '/albums/:id' do
   # SongGenerator.dele(params[:id])
  end

  delete '/albums/:id/tracks' do
   # SongGenerator.delete_album(params[:id], true)
  end

  get '/albums/:id/tracks' do |id|
    Album.with_tracks(id)
  end

  post '/downloader/?' do
    meta = Metadata.new JSON.parse(params[:blip])
    convert = params[:convert_to_audio]
    BlipFM.download_blip(meta, convert)
    return {"result" => "ok"}.to_json
  end

  get "/blip/:username/?" do |user|
    haml :blip, {}, :blips => BlipFM.with_blips(user)
  end

end
