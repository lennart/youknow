class CatalogueCollector
  class Catalogue
    attr_accessor :score
    attr_reader :name, :docs
    def initialize(name)
      @name = name
      @score = 0.0
      @doc_count = 0
    end

    def add(doc, score)
      @doc_count += 1
      @score += score
    end

    def to_s(index)
      "#@name: #@doc_count matches with a total score of %0.5f" % @score
    end
  end

  def initialize
    @normalized = false
    @catalogues = Hash.new {|h, key| h[key] = Catalogue.new(key)}
    @catalogue_cache = []
    @age_cache = []
  end

  def rebuild_cache(searcher)
    puts "Rebuilding cache"
    @searcher = searcher
    reader = @searcher.reader
    reader.terms(:title).each do |catalogue, freq|
      puts "Catalogue: #{catalogue}, with freq #{freq}"
      reader.term_docs_for(:title, catalogue).each do |doc_id, freq|
        @catalogue_cache[doc_id] = catalogue
      end
    end
    reader.terms(:date).each do |date_str, freq|
      puts "Parsing Date:#{date_str.class}"
      age = (Time.now - Time.at(date_str.to_i)).to_i
      reader.term_docs_for(:date, date_str).each do |doc_id, freq|
        @age_cache[doc_id] = age
      end
    end
  end


  def filter_proc
    lambda do |doc_id, score, searcher|
      rebuild_cache(searcher) unless @searcher == searcher
      age_weight = 1 / 2 ** (@age_cache[doc_id]/3650.0)
      @catalogues[@catalogue_cache[doc_id]].add(doc_id, score * age_weight)
      age_weight
    end
  end

  def to_s(index)
    buf = []
    normalize_scores unless @normalized
    @catalogues.keys.sort_by {|key|
      -@catalogues[key].score
    }.each {|key|
      buf << @catalogues[key]
    }
    buf
  end
  
  private

  def normalize_scores
    normalization_factor = @catalogues.values.collect {|cat| cat.score}.max
    @catalogues.values.each {|cat| cat.score /= normalization_factor}
    @normalized = true
  end
end

