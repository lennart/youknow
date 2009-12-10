load 'models/song.rb'
class Album < CouchRest::ExtendedDocument
  use_database ::SiteConfig.database
  include DuckTypedDesignDoc
  include CouchRest::Validation
  property :title
  property :release_date, :cast_as => 'Date', :init_method => 'parse'

  ducktype_traits :release_date, :title

  validates_presence_of :release_date
  validates_presence_of :title
  view_by :title, :ducktype => true
  view_by :tracks, :map => <<MAP
function(doc) {
  if(#{ducktype_traits_js}) {
    emit([doc._id,1], null);   
  }
  if(#{::Song.ducktype_traits_js(%w{appears_on_album})}) {
    for(var k in doc.appears_on_album) {
      emit([k,2,doc.appears_on_album[k]], null)
    }
  }
}
MAP

  def self.with_tracks(id, options = {})
    options.merge!(:startkey => [id], :endkey => [id,{}], :raw => true, :include_docs => true)
    raw_tracks = by_tracks(options)
    return [] if raw_tracks.empty?
    class_eval do
      raw_tracks["rows"].map do |row|
        if row["key"][1] == 1
          new(row["doc"])
        else
          ::Song.new(row["doc"])
        end
      end
    end
  end

end
