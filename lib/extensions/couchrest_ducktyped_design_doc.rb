require 'couchrest/mixins/design_doc'
module DuckTypedDesignDoc 
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      def initialize(passed_keys = {}) 
        super
        self.delete("couchrest-type")
      end
    end
  end

  module ClassMethods 
    include CouchRest::Mixins::DesignDoc::ClassMethods

    def ducktype_traits(*traits)
      puts "Will be used #{traits}"
      @traits = traits.map { |t| t.to_sym }
    end

    def ducktype_traits_js(other_traits = [])
      (other_traits + @traits).map {|t| "doc['#{t.to_s}']"}.join " && "
    end

    def default_design_doc
      if @traits.respond_to? :map
        {
          "language" => "javascript",
          "views" => {
          'all' => {
          'map' => "function(doc) {
                  if (#{ducktype_traits_js}) {
                    emit(doc['_id'],1);
                  }
                }"
        }
        }
        }

      else
        raise RuntimeError.new(
          <<CODE 
      Please specify some Traits by which you can Ducktype these Documents.
      Use e.g.: ducktype_traits :can_be_seen_at_night, :colour
CODE
      )
    end
  end
end
end
