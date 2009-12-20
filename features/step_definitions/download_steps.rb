Given /^generic metadata for a Song$/ do
  Resque.working.should be_empty
  Resque.redis.flush_all
  @metadata = Metadata.new(:video_id => "2ds_MpPdH5o", 
                          :title => "Evil Baby", :artist => "YouTube shit", 
                          :duration => 16, :source => "YouTube")
end

When /^I start the download$/ do
  post "/downloader", { :blip => @metadata.to_json , :convert_to_audio => true}
end

Then /^I should have the Song in my Library$/ do
  @worker = Resque::Worker.new("*")
  @worker.process
  @worker.process
  job = Resque.reserve :medium
  @worker.process(job)

  if Resque::Failure.count > 0
    Resque::Failure.all.each do |job|
      pp job
    end
  end
  Resque::Failure.count.should == 0
  video = YouTubeVideo.by_video_id(:key => "2ds_MpPdH5o").first
  video.should_not be_nil
  video.should have_attachment("mp4")
  video.should have_attachment("audio/default")
  video["_attachments"]["audio/default"]["content_type"].should == "audio/x-vorbis+ogg"
end

