describe "The Video to Music Thingy" do
  before do
    path = ::File.join(SINATRA_ROOT,"utils","placebo.mp4.sample")
    @video_path = path.gsub(/\.sample$/,"")
    FileUtils.cp path, @video_path
    @audio_path = ::File.join(SINATRA_ROOT,"utils","placebo.mp3")
  end

  after do
    File.unlink(@audio_path)
  end
  it "should convert Placebo to mp3" do
    video_path = @video_path
    video = YouTubeVideo.new
    audio = @audio_path

    Resque.expects(:enqueue)
    Video2Music.perform([video,video_path,audio,Metadata.new(:title => "Come Home",:artist => "Placebo")])
    File.exists?(audio).should == true
  end
end
