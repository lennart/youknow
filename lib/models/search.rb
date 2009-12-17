
class Search
  load 'models/youtube.rb'
  load 'models/search_result.rb'
  load 'models/ferret_search.rb'
  class << self
    def query string, limit
      results = query_database(string, limit)
      if results.empty?
        query_youtube(string, limit) 
      else
        results
      end
    end


    def query_youtube string, limit
      client = YouTubeG::Client.new
      threads = []
      @results = []
      client.videos_by(:query => string, :page => 1, :per_page => limit).videos.each do |video|
        threads << Thread.new(video) do |video|
          result = YouTubeVideo.new video 
          if result.save
            @results << result
          end
        end
      end
      threads.each do |t| 
        begin
          t.join 
        rescue YouTubeStreamMissingError
          puts "This video does not have an MP4 Stream"
        end
      end
      @results
    end

    def query_database string, limit = nil
      field_infos = Ferret::Index::FieldInfos.new(:term_vector => :no,
                                                  :store => :no, 
                                                  :index => :untokenized_omit_norms)
      field_infos.add_field(:title, :store => :yes, :index => :yes, :boost => 10.0)
      index = Ferret::I.new()
      search_results = SearchResult.all
      search_results.each do |result|
        index << {
          :doc_id => result.id,
          :title => result.title,
          :date => result.created_at.to_i.to_s
        }
      end
      puts index.to_yaml

      catalogue_collector = CatalogueCollector.new
      #      puts "Cache: #{catalogue_collector.instance_variable_get("@catalogue_cache").to_yaml}"
      results = []

      counter = 0
      index.search_each(string) do |id, score|
        results << index[id][:doc_id]
        if limit
          counter += 1
          break if counter == limit
        end
      end
      ::SiteConfig.database.bulk_load(results)["rows"].map do |row|
        doc = row["doc"]
        case doc["source"]
        when "YouTube":
          YouTubeVideo.new doc
        else
          SearchResult.new doc
        end
      end
    end
  end
end
