require File.join(File.dirname(__FILE__),*%w{.. vendor gems environment})
Bundler.require_env
$LOAD_PATH.unshift(::File.join(::File.dirname(__FILE__), *%w{.. lib}))
SINATRA_ROOT=::File.join(::File.dirname(__FILE__),"..")
autoload :Downloader, 'workers/downloader'
autoload :DuckTypedDesignDoc, 'extensions/couchrest_ducktyped_design_doc'
autoload :Artist, 'models/artist'
autoload :MorphableDocument, "extensions/morphable_document"
autoload :YouTubeVideo, "models/youtube"
autoload :Metadata, "models/metadata"
autoload :SongImporter, "workers/song_importer"
