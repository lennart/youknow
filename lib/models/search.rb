
class Search
  load 'models/youtube.rb'
  load 'models/search_result.rb'
  class << self
    def query string, limit
      results = query_database(string)
      if results.empty?
        query_youtube(string, limit) 
      else
        results
      end
    end

    private

    def query_youtube string, limit
      client = YouTubeG::Client.new
      threads = []
      @results = []
      client.videos_by(:query => string, :page => 1, :per_page => limit).videos.each do |video|
        video.video_id =~ /\/([^\/]*)\Z/
          threads << Thread.new($1) do |video_id|
            result = SearchResult.new :url => YouTube::Downloader.fetch_url_for_video_id(video_id),
              :embed_url => video.embed_url,
              :duration => video.duration,
              :title => video.title
            result.save
            @results << result
          end
      end
      threads.each do |t| 
        begin
          t.join 
        rescue RuntimeError
          nil
        end
      end
      @results
    end

    def query_database string
      SearchResult.search :title, string
    end
  end
end
