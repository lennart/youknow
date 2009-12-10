class Artist < CouchRest::ExtendedDocument
  use_database ::SiteConfig.database
  include DuckTypedDesignDoc
  include CouchRest::Validation
  property :name
  ducktype_traits :name

  validates_presence_of :name

  view_by :name, :ducktype => true
end
