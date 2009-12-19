describe "The Song Importer Interface" do
  it "should import a song with correct metadata" do
    metadata = Metadata.new :title => "Come Home", :artist => "Placebo"
    filename = ::File.join(SINATRA_ROOT,"utils","placebo.mp3.sample")
    SongGenerator.expects(:add_song).with(kind_of(File), kind_of(Metadata))
    SongImporter.perform([filename, metadata])
  end

  it "should import a song from URL" do
    metadata = Metadata.new :title => "Come Home", :artist => "Placebo"
    url = "http://google.com"
    SongGenerator.expects(:add_song_from_url).with(url, kind_of(Metadata))
    SongImporter.perform([url, metadata])
  end

  it "should morph a song from YouTubeVideo" do
    metadata = Metadata.new :title => "Come Home", :artist => "Placebo"
    filename = ::File.join(SINATRA_ROOT,"utils","placebo.mp3.sample")
    YouTubeVideo.expects(:by_video_id).returns([YouTubeVideo.new])
    SongGenerator.expects(:add_song).with(kind_of(File), kind_of(Metadata), kind_of(YouTubeVideo))
    SongImporter.perform([filename, metadata, "random youtube id"])
  end
end
