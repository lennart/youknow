require File.join(File.dirname(__FILE__), "..", "spec_helper")
describe "A YouTube Video" do
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

    it "should set expire dates" do
      @video_from_model.deep_links_expire_at(:time).should be_kind_of(Time)
    end

    it "should add all available streams" do
      @video_from_model.available_streams.should_not be_empty
    end

    it "should update stream urls if they expired when queried for" do
      old_streams = {35 => "http://go.to.hell/this/file/doesnt/exist/anymore"}
      @video_from_model.available_streams = old_streams.dup
      @video_from_model.deep_links_expire_at = (Time.now - 3600).to_i
      @video_from_model.deep_link.should_not be_nil
      @video_from_model.available_streams[35].should_not == old_streams[35]
      (@video_from_model.deep_links_expire_at > (Time.now.to_i)).should be_true
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
    Resque.expects(:enqueue).with(kind_of(Module),kind_of(YouTubeVideo),kind_of(String),kind_of(Hash)).returns(true)
    video = YouTubeVideo.new :video_id => @video_result_id
    video.download_best_video
  end
end
