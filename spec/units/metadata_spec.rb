describe "The one and only Metadata" do
  before do
    @meta = Metadata.new
  end

  it "should not contain a 'couchrest-type'" do
    @meta.to_hash.should_not have_key("couchrest-type")
  end

  it "should let one add arbitrary properties" do
    Metadata.class_eval do
      undef video_id
      undef video_id=
      properties.delete properties.select{|p| p.name == "video_id" }.first
    end
    lambda { @meta.video_id }.should raise_error(NoMethodError)
    @meta.video_id= "FunkyVideoId"
    @meta.video_id.should == "FunkyVideoId"
  end

  it "should respond 'true' when asking for property that exists" do
    @meta.video_id = "GreaT"
    @meta.video_id?.should == true
  end

  it "should respond 'false' when asking for non-existant property" do
    @meta.video_id?.should == false
  end

  it "should leave properties undefined when setting to blank string" do
    @meta.video_id = ""
    @meta.video_id?.should == false
    @meta.artist = ""
    @meta.artist?.should == false
  end

  it "should still allow empty arrays and hashes as values" do
    @meta.video_id = []
    @meta.video_id?.should == true
    @meta.artist = {}
    @meta.artist?.should == true
  end

  it "should getter on initialization for set properties" do
    @meta.video_id = "Klar"
    Metadata.class_eval do
      undef video_id
      undef video_id=
      properties.delete properties.select{|p| p.name == "video_id" }.first
    end
    new_meta = Metadata.new @meta.to_hash
    new_meta.video_id.should == "Klar"
  end
end
