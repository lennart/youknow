require 'models/tag'
describe "Tags" do
  before :all do
    tagged_doc = lambda do |tags|
      doc = Tag.new :tags => tags
      doc.save
    end
    recreate_db
    tagged_doc.call ["stuff", "hell yeah", "WTF", "punk"]
    tagged_doc.call ["stuff", "creative commons", "punk"]
    tagged_doc.call ["weird fishing", "stuff"]
    tagged_doc.call ["creative commons", "WTF"]

  end

  specify "should be listable by name" do
    tags = Tag.by_name :reduce => false
    tags.should_not be_empty
  end

  specify "should list 3 docs tagged with 'stuff'" do
    tags = Tag.by_name :key => "stuff", :reduce => false
    tags.size.should == 3
  end

#  specify "should have 
end
