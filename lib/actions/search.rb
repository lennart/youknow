module SearchActions
  load 'models/search.rb'
  def self.registered(app)
    app.instance_eval do
      get "/search/?" do
        haml :search
      end

      post "/search" do
        limit = params[:limit] ? params[:limit] : 4
        results = Search.query(params[:query],limit)
        haml :search_results, {}, :results => results
      end
    end
  end

end
