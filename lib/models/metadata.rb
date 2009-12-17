class Metadata < CouchRest::Document
  attr_accessor :title
  attr_accessor :album
  attr_accessor :artist
  attr_accessor :genre
  attr_accessor :track
  attr_accessor :artwork
  attr_accessor :year

end
