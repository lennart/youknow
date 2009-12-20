describe "A YouTube Video form the API" do
  before :all do
    client = YouTubeG::Client.new
    @video_result_id = "GtIjUn7_erY"
    @video_result = client.videos_by(:query => @video_result_id).videos.first
  end
  context "given a YouTube Video Model as input" do
    before :all do
      @video_from_model = YouTubeVideo.new @video_result
    end
    it "should set the video id" do
      @video_from_model.video_id.should_not be_nil
    end

    it "should update volatile properties" do
      video = YouTubeVideo.new :video_id => "random"
      html = File.read(sinatra("utils","youtube_result.html"))
      Curl::Easy.expects(:perform).with("www.youtube.com/watch?v=random").returns(stub_everything("video",:body_str => html))

      video.update_volatile_properties
      video.deep_links_expire_at.should_not be_nil
    end

    it "should set expire dates" do
      @video_from_model.deep_links_expire_at(:time).should be_kind_of(Time)
    end

    it "should add all available streams" do
      @video_from_model.available_streams.should_not be_empty
    end

    it "should update stream urls if they expired when queried for" do
      old_streams = {"35" => "http://go.to.hell/this/file/doesnt/exist/anymore"}
      old_rev = @video_from_model.rev.dup
      @video_from_model.available_streams = old_streams.dup
      @video_from_model.deep_links_expire_at = (Time.now - 3600).to_i
      @video_from_model.deep_link.should_not be_nil
      @video_from_model.available_streams["35"].should_not == old_streams["35"]
      (@video_from_model.deep_links_expire_at > (Time.now.to_i)).should be_true
      old_rev.should_not == @video_from_model.rev
    end

    it "should set best format" do
      @video_from_model.best_format.should be_kind_of(Integer)
    end

    it "should return string representation for best_format" do
      @video_from_model.best_format_name.should be_kind_of(String)
    end
  end

  it "should accept params as Input" do
    video = YouTubeVideo.new :video_id => @video_result_id
  end

  it "should enqueue a job to resque for downloading" do
    Resque.expects(:enqueue).with(kind_of(Module),kind_of(Array)).returns(true)
    video = YouTubeVideo.new :video_id => @video_result_id, :title => "Blablablas"
    video.download_best_video
  end

end
describe "An existing YouTube Video from the database" do
  before do
  @video = YouTubeVideo.new({"available_streams"=>
  {"35"=>
    "http://v1.lscache1.c.youtube.com/videoplayback?ip=0.0.0.0&sparams=id%2Cexpire%2Cip%2Cipbits%2Citag%2Calgorithm%2Cburst%2Cfactor&algorithm=throttle-factor&itag=35&ipbits=0&burst=40&sver=3&expire=1261278000&key=yt1&signature=CA12CEF17EEAA8E2BDFEAFF9C1C9C89A4F5B624E.674704C7034F3CD52D5A3F1AD6D66D080A8535CB&factor=1.25&id=57bef93cfb8173b6",
   "18"=>
    "http://v10.lscache5.c.youtube.com/videoplayback?ip=0.0.0.0&sparams=id%2Cexpire%2Cip%2Cipbits%2Citag%2Calgorithm%2Cburst%2Cfactor&algorithm=throttle-factor&itag=18&ipbits=0&burst=40&sver=3&expire=1261278000&key=yt1&signature=37D2DE038DEC18AD1965D0FAE2BF4F9B2EE07FE7.567BE28CE24A831434500ED0BAAD4F8DDF3C3104&factor=1.25&id=57bef93cfb8173b6",
   "34"=>
    "http://v12.lscache7.c.youtube.com/videoplayback?ip=0.0.0.0&sparams=id%2Cexpire%2Cip%2Cipbits%2Citag%2Calgorithm%2Cburst%2Cfactor&algorithm=throttle-factor&itag=34&ipbits=0&burst=40&sver=3&expire=1261278000&key=yt1&signature=D45488B443ABADEA9359A45A6F0A6729B45E7CC9.7409E5D57C97F70FAC045C631C5A49761D54FF80&factor=1.25&id=57bef93cfb8173b6",
   "5"=>
    "http://v13.lscache7.c.youtube.com/videoplayback?ip=0.0.0.0&sparams=id%2Cexpire%2Cip%2Cipbits%2Citag%2Calgorithm%2Cburst%2Cfactor&algorithm=throttle-factor&itag=5&ipbits=0&burst=40&sver=3&expire=1261278000&key=yt1&signature=8BEBBDC8E8D9E96378F63B041EF79CAB6471538E.2897B82DEE4E49240427C79493E2A51F59C8E21A&factor=1.25&id=57bef93cfb8173b6"},
 "video_id"=>"V775PPuBc7Y",
 "embed_url"=>"http://www.youtube.com/v/V775PPuBc7Y&feature=youtube_gdata",
 "duration"=>208,
 "title"=>"Sidney Samson - Riverside OFFICIAL VIDEO",
 "tags"=>
  ["Spinnin'",
   "Records",
   "presents",
   "Samsobeats",
   "Sneakerz",
   "Muzik",
   "Sidney",
   "Samson",
   "Riverside.",
   "Official",
   "video"],
 "source"=>"YouTube",
 "deep_links_expire_at"=>(Time.now+360).to_i})

  @video.save
  end
  it "should get '35' as the best format" do
    @video.best_format.should == 35
  end

  it "should get 'flv@480p' as the best_format name" do
    @video.best_format_name.should == "flv@480p"
  end

  it "should get correct best deep link without params" do
    @video.deep_link.should ==  "http://v1.lscache1.c.youtube.com/videoplayback?ip=0.0.0.0&sparams=id%2Cexpire%2Cip%2Cipbits%2Citag%2Calgorithm%2Cburst%2Cfactor&algorithm=throttle-factor&itag=35&ipbits=0&burst=40&sver=3&expire=1261278000&key=yt1&signature=CA12CEF17EEAA8E2BDFEAFF9C1C9C89A4F5B624E.674704C7034F3CD52D5A3F1AD6D66D080A8535CB&factor=1.25&id=57bef93cfb8173b6"
  end

  it "should get correct deep link for format '18'" do
    @video.deep_link(18).should ==  "http://v10.lscache5.c.youtube.com/videoplayback?ip=0.0.0.0&sparams=id%2Cexpire%2Cip%2Cipbits%2Citag%2Calgorithm%2Cburst%2Cfactor&algorithm=throttle-factor&itag=18&ipbits=0&burst=40&sver=3&expire=1261278000&key=yt1&signature=37D2DE038DEC18AD1965D0FAE2BF4F9B2EE07FE7.567BE28CE24A831434500ED0BAAD4F8DDF3C3104&factor=1.25&id=57bef93cfb8173b6"
  end
end
