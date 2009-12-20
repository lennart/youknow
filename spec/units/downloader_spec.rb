def perform metadata, id = "Some Id", path = @tempfile_path, options = {}
  options.merge!({"metadata" => metadata }) 
  options["convert_to_audio"] ||= false
  options["format"] || 18
  ::Downloader.perform([id, path, options])
end

def generic_song passed_keys = {}
  @video = stub_everything("youtube video", :deep_link => @video_url)
  YouTubeVideo.expects(:by_video_id).returns([@video])
  Metadata.new :title => "Some Title", :artist => "Some Artist"
end

describe "The YouTube Video Downloader" do
  context "downloading a video to destination" do
    before do
      @video_url ="http://some.where-on.ly/we/know" 
      root_path = ::File.join(SINATRA_ROOT,"utils")
      FileUtils.cp ::File.join(root_path,"placebo.mp4.sample"), ::File.join(root_path,"placebo.mp4")
      @tempfile_path = ::File.join(root_path,"placebo.mp4")
    end

    it "should prepare Parameters" do
      metadata = generic_song

      meta = ::Downloader.prepare_params("some ID",@tempfile_path, {"convert_to_audio" => false,
                                         "metadata" => metadata,
                                         "format" => 18})

      meta.link.should be_kind_of(String)
      meta.convert_to_audio.should be_false
      meta.attachment_name.should be_kind_of(String)
      meta.data.should be_kind_of(Metadata)
      meta.destination.should be_kind_of(String)
    end

    it "should perform the download" do
      @easy = mock()
      metadata = generic_song

      Curl::Easy.expects(:new).with(@video_url).returns(@easy)
      @easy.stubs(:perform).returns(true)
      @easy.stubs(:on_body)
      @easy.expects(:follow_location=).with(true)

      perform metadata
    end
    it "should PUT the video as an attachment" do
      metadata = generic_song

      @easy = stub_everything("curl client")
      Curl::Easy.expects(:new).with(@video_url).returns(@easy)
      @video.stubs(:deep_link).returns(@video_url)
      @video.stubs(:put_attachment).returns(true)
      @video.stubs(:best_format_name).returns("mp4@1080p")

      perform metadata
    end

    it "should unlink the Video if no audio should be produced" do
      metadata = generic_song

      @easy = stub_everything("curl client")
      Curl::Easy.expects(:new).with(@video_url).returns(@easy)
      Resque.expects(:enqueue).never
      File.expects(:unlink).with(@tempfile_path).once

      perform metadata
    end

    it "should raise an error if metadata is missing for video conversion" do
      metadata = nil

      Curl::Easy.expects(:new).with(@video_url).never
      Resque.expects(:enqueue).never

      lambda do
        perform metadata, "anything", @tempfile_path, {"convert_to_audio" => true}
      end.should raise_error(DownloaderError)
    end

    it "should not unlink the Video if audio should be produced" do
      metadata = generic_song

      @easy = stub_everything("curl client")
      Curl::Easy.expects(:new).with(@video_url).returns(@easy)
      Resque.expects(:enqueue).once
      File.expects(:unlink).never

      perform metadata, "ConvertME", @tempfile_path, {"convert_to_audio" => true}
    end

  end
end
