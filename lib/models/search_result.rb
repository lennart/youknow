load 'extensions/lucene_search.rb'
load 'extensions/couchrest_ducktyped_design_doc.rb'
class SearchResult < CouchRest::ExtendedDocument 
  use_database ::SiteConfig.database
  include DuckTypedDesignDoc
  include CouchRest::Validation

  property :title
  property :tags
  property :duration
  property :embed_url
  property :video_id
  property :source
  property :format_ids, :default => []

  ducktype_traits :title, :embed_url, :duration

  search_by :title, :ducktype => true
  view_by :video_id, :ducktype => true

  timestamps!
end
