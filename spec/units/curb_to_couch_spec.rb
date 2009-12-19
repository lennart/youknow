describe "Posting Data From Curb to CouchDB" do
  before do
    @file = File.new ::File.join(SINATRA_ROOT, "utils", "placebo.mp4.sample")
  end

  it "should download from url" do
    url = "http://www.google.com"
    path = ::File.join(SINATRA_ROOT,"tmp","#{UUID.generate :compact}.mp3")
    file = CurbToCouch.download(url, path)
    File.size(file).should_not == 0
  end

  it "should build a curb field from fieldname and content" do
    field = CurbToCouch.field_for_curb("breakfast", ["ham","eggs"].to_json)
    field.should be_kind_of(Curl::PostField)
    field.content.should == "[\"ham\",\"eggs\"]"
    field.name.should == "breakfast"
  end

  it "should build a curb file field from data" do
    field = CurbToCouch.file_for_curb("placebo_songs", @file, "Placebo - Come Home.mp4", "video/mp4")
    field.should be_kind_of(Curl::PostField)
    field.content.should_not be_nil
    field.content_type.should == "video/mp4"
    field.remote_file.should == "Placebo - Come Home.mp4"
    field.name.should == "placebo_songs"
  end

  it "should build a field array for file and document" do
    array = CurbToCouch.fields_for_doc_with_attachment({:title => "Come Home", :artist => "Placebo"}, @file, "placebo.mp4", "video/mp4")

    array.should be_kind_of(Array)
    array.each do |f|
      f.should be_kind_of(Curl::PostField)
    end
    array.first.name.should == "_doc"
    array.last.name.should == "_attachments"
  end

end
