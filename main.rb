
class ModularApplication < Sinatra::Base
  load 'extensions/couchrest_ducktyped_design_doc.rb'
  load 'models/album.rb'
  load 'workers/downloader.rb'
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
    video = YouTubeVideo.by_video_id(:key => params[:video_id]).first
    if video
      video.download_best_video
    else
      halt [404, "Couldn't find Video with this ID"]
    end
  end

end
