unless Object.const_defined? :SINATRA_ROOT
  require File.join(File.dirname(__FILE__),*%w{.. vendor gems environment})
  if ENV["RACK_ENV"]
    Bundler.require_env ENV["RACK_ENV"].to_sym
  else
    Bundler.require_env
  end
  require 'rubygems'
  require 'ferret'

  $LOAD_PATH.unshift(::File.join(::File.dirname(__FILE__), *%w{.. lib}))
  SINATRA_ROOT=::File.expand_path(::File.join(::File.dirname(__FILE__),"..")) 
end
autoload :Album, "models/album"
autoload :MainHelper, "helper/main_helper.rb"
autoload :Artist, "models/artist"
autoload :Song, "models/song"
autoload :SearchResult, "models/search_result"
autoload :Search, "models/search"
autoload :Tag, "models/tag"
autoload :Downloader, 'workers/downloader'
autoload :SongImporter, "workers/song_importer"
autoload :Video2Music, "workers/video2music"
autoload :DuckTypedDesignDoc, 'extensions/couchrest_ducktyped_design_doc'
autoload :MorphableDocument, "extensions/morphable_document"
autoload :Guessing, "extensions/guessing"
autoload :Artist, 'models/artist'
autoload :YouTubeVideo, "models/youtube"
autoload :Metadata, "models/metadata"
autoload :CurbToCouch, "extensions/curb_to_couch"
autoload :SongGenerator, "models/song_generator"
autoload :SongGeneratorError, "models/song_generator"
autoload :BlipFM, "models/blipfm"
autoload :SiteConfig, "config/app_config"
