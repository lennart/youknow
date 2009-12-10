class Audiofile < CouchRest::ExtendedDocument
  use_database CouchRest.new(Config.url_base).database!(Config.database_name)
  include DuckTypedDesignDoc
  include CouchRest::Validation
  ducktype_traits :_attachments
end
