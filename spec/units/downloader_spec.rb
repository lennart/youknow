describe "The YouTube Video Downloader" do
  context "downloading a video to destination" do
    before do
      @video_url ="http://some.where-on.ly/we/know" 
      root_path = ::File.join(SINATRA_ROOT,"utils")
      FileUtils.cp ::File.join(root_path,"placebo.mp4.sample"), ::File.join(root_path,"placebo.mp4")
      @tempfile_path = ::File.join(root_path,"placebo.mp4")
    end
    it "should perform the download" do
      @easy = mock()
      @video = stub_everything("youtube video", :deep_link => @video_url)
      YouTubeVideo.expects(:new).returns(@video)
      Curl::Easy.expects(:new).with(@video_url).returns(@easy)
      @easy.stubs(:perform).returns(true)
      @easy.stubs(:on_body)
      @easy.expects(:follow_location=).with(true)
      ::Downloader.perform([{:video_id => "anything"},@tempfile_path,{"convert_to_audio" => false}])
    end
    it "should PUT the video as an attachment" do
      @easy = stub_everything("curl client")
      Curl::Easy.expects(:new).with(@video_url).returns(@easy)
      @video = YouTubeVideo.any_instance
      @video.stubs(:deep_link).returns(@video_url)
      @video.stubs(:put_attachment).returns(true)
      @video.stubs(:best_format_name).returns("mp4@1080p")
      ::Downloader.perform([{:video_id => "anything"},@tempfile_path,{"convert_to_audio" => false}])
    end
    
    it "should unlink the Video if no audio should be produced" do
      @easy = stub_everything("curl client")
      Curl::Easy.expects(:new).with(@video_url).returns(@easy)
      @video = stub_everything("youtube video", :deep_link => @video_url)
      YouTubeVideo.expects(:new).returns(@video)
      Resque.expects(:enqueue).never
      File.expects(:unlink).with(@tempfile_path).once
      ::Downloader.perform([{:video_id => "anything"},@tempfile_path,{"convert_to_audio" => false}])
    end

    it "should raise an error if metadata is missing for video conversion" do
      @easy = stub_everything("curl client")
      Curl::Easy.expects(:new).with(@video_url).returns(@easy)
      @video = stub_everything("youtube video", :deep_link => @video_url)
      YouTubeVideo.expects(:new).returns(@video)
      Resque.expects(:enqueue).never

      lambda { ::Downloader.perform([{:video_id => "anything"},@tempfile_path,{"convert_to_audio" => true}])}.should raise_error(DownloaderError)
    end

    it "should not unlink the Video if audio should be produced" do
      @easy = stub_everything("curl client")
      Curl::Easy.expects(:new).with(@video_url).returns(@easy)
      @video = stub_everything("youtube video", :deep_link => @video_url)
      YouTubeVideo.expects(:new).returns(@video)
      Resque.expects(:enqueue).once
      File.expects(:unlink).never
      ::Downloader.perform([{:video_id => "anything"},@tempfile_path,{"convert_to_audio" => true, "metadata" => Metadata.new(:title => "Frowny", :artist => "The Clown")}])
    end
  end
end
