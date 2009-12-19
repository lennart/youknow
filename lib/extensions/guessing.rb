module Guessing  
  def guess_best_metadata(metadata)
    if metadata.artist.blank?
      metadata.artist,metadata.title, metadata.genre = extract_artist_and_title(metadata.title)
    end
    metadata
  end

  def extract_artist_and_title(string)
    title = string || ""
    artist = ""
    genre = []
    [/\A\s*(.+)\s*-\s*([^-\(\)]+)\s*(\(.+\))?\s*\Z/,
      /\A\s*(.+)\s*"([^"\(\)]+)\s*(\([^"]+\))?"\s*\Z/].each do |rxp|
        string =~ rxp
          tags = $3
          if tags
            genre = tags[1..tags.length-2].split(" ").map{|t| t.strip}
          end
          break unless (title = $2 || "").blank? or (artist = $1 || "").blank?
      end
    return [artist.strip,title.strip, genre]
  end
end
