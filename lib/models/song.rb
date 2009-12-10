class Song < CouchRest::ExtendedDocument
  use_database ::SiteConfig.database
  include DuckTypedDesignDoc
  include CouchRest::Validation
  property :title
  property :appears_on_album, :default => []
  property :written_by, :default => []
  property :audiofiles, :default => []
  property :lyrics
  property :tags, :default => []

  ducktype_traits :title, :written_by, :audiofiles
  validates_presence_of :title

  view_by :title, :ducktype => true
  view_by :title_and_artist, :ducktype => true, :map => <<MAP
function(doc) {
  if (#{ducktype_traits_js}) {
    for(var i in doc.written_by) {
      emit([doc.title,doc.written_by[i]], null);
    }
  }
}
MAP
  view_by :title_and_album, :ducktype => true, :map => <<MAP
function(doc) {
  if (#{ducktype_traits_js(%w{appears_on_album})}) {
    for(var k in doc.appears_on_album) {
      emit([doc.title,k], null);
    }
  }
}
MAP

  view_by :title_and_artist_and_album, :ducktype => true, :map => <<MAP
function(doc) {
  if (#{ducktype_traits_js(%w{appears_on_album})}) {
    for(var k in doc.appears_on_album) {
      for(var i in doc.written_by) {
        emit([doc.title,doc.written_by[i],k], null);
      }
    }
  }
}  
MAP

  def preferred_audiofile_id
    self.audiofiles.first
  end

  def preferred_audiofile_url
    "#{database}/#{self.preferred_audiofile_id}/attachment"
  end

  def preferred_audiofile
    database.get self.preferred_audiofile_id
  end

end
