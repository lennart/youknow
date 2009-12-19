require File.join(File.dirname(__FILE__), "..", "spec_helper")
describe "The Search Engine" do
  it "should list 5 results for 'News'" do
    results = Search.query "News", 5
    results.should be_kind_of(Array)
    results.size.should == 5
  end

end
