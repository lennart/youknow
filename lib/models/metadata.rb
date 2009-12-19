class Metadata < CouchRest::ExtendedDocument
  include DuckTypedDesignDoc
  ducktype_traits :title, :artist
  property :title
  property :album
  property :artist
  property :genre
  property :track
  property :artwork
  property :year


  def method_missing(id, *args)
    if id.to_s =~ /(.*)=$/ 
      self.class.class_eval do
        property $1.to_sym
      end
      self.method(id).call *args
    elsif id.to_s =~ /(.*)\?$/
      self.has_key? $1
    else
      super
    end
  end

  def []= key, value
    return if value.blank? and value.is_a? String
    unless self.has_key?(key) or key.to_s == "couchrest-type"
      self.class.class_eval do
        property key.to_sym
      end
    end
    super
  end

  def save
    raise "Not Possible"
  end

  def artwork=(new_artwork)
    self["artwork"] = OpenStruct.new(:data => new_artwork["data"], :mimetype => new_artwork["mimetype"])
  end

end
