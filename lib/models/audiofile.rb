class Audiofile < CouchRest::ExtendedDocument
  use_database ::SiteConfig.database
  include DuckTypedDesignDoc
  include CouchRest::Validation
  ducktype_traits :_attachments
end
