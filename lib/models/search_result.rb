load 'extensions/lucene_search.rb'
class SearchResult < CouchRest::ExtendedDocument 
  use_database ::SiteConfig.database
  include DuckTypedDesignDoc
  include CouchRest::Validation

  property :title
  property :tags
  property :duration
  property :embed_url
  property :url

  ducktype_traits :title, :embed_url, :url, :duration

  search_by :title, :ducktype => true


end
