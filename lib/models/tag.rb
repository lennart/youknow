class Tag < CouchRest::ExtendedDocument
  use_database ::SiteConfig.database
  property :tags


  view_by :name, :map => 
"function(doc) {
  if(doc.tags) {
    for(var i = 0; i < doc.tags.length; i++) {
      emit(doc.tags[i], null);   
    }
  }
}", :reduce => <<REDUCE
function(keys, values) {
return sum(values);
}
REDUCE
         
end
