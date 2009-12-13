module LuceneSearch
  def search_by *keys
    opts = keys.pop if keys.last.is_a?(Hash)
    opts ||= {}
    self['fulltext'] ||= {}
    method_name = "by_#{keys.join('_and_')}"

    if opts[:index]
      fulltext_search = {}
      fulltext_search['index'] = opts.delete(:index)
      self['fulltext'][method_name] = fulltext_search
    else
      doc_keys = keys.collect{|k|"doc['#{k}']"} # this is where :require => 'doc.x == true' would show up
      guards = doc_keys
      index_function = <<-JAVASCRIPT
function(doc) {
  var ret = new Document();
      #{guards.map {|g| "ret.add(#{g});" }}
  return ret;
}
      JAVASCRIPT
      self['fulltext'][method_name] = {
        'defaults' => { "store" => "no" },
        'index' => index_function
      }
    end
    method_name
  end
end
module LuceneSearchMixin
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def search index, query, options = {}
      unless design_doc_fresh            
        refresh_design_doc_on(self.database)
      end
      options[:include_docs] = true  
      ret = self.database.search(self.to_s, index, query, options)  
      ret['rows'].collect!{|r| self.new(r['doc'])}  
      ret  
    end

    def search_by(*keys)
      design_doc.search_by(*keys)
    end
  end

end

class CouchRest::Database

  def search(design, index, query, options={})  
    CouchRest.get CouchRest.paramify_url("#{@root}/_fti/#{design}/#{index}", options.merge(:q => query))  
  end  
end
CouchRest::Design.send :include, LuceneSearch
CouchRest::ExtendedDocument.send :include, LuceneSearchMixin
