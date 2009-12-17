require File.join(File.dirname(__FILE__), "..", "spec_helper")
require 'models/metadata'
require 'fileutils'
describe "A Song Generator" do
  before(:each) do
    recreate_db
    originalfile = File.new(File.join(File.dirname(__FILE__),"..","..","features", "support", "Salmon Dance.mp3"))
    @tempfile_path = "public/tempfile.mp3"
    FileUtils.cp(originalfile.path,@tempfile_path)
    @tag = Metadata.new
    @tag.title = "15 Step"
    @tag.album = "In Rainbows"
    @tag.artist = "Radiohead"
    @tag.year = 2009
    @tag.track = 1
    @tag.genre = "Rock"
    @tempfile = File.new(@tempfile_path)
  end

  after(:each) do
    FileUtils.rm(@tempfile_path)
  end

  context "generating a new Song" do
    before(:each) do
      id = SongGenerator.add_song(@tempfile, @tag)
      @song = Song.get id
    end

    it "should add '15 Step' with artist, album and audiofile to the library" do
      @song.title.should == "15 Step"
      @song.written_by.size.should == 1
      @song.appears_on_album.size.should == 1
      @song.attachment_url("audio/default").should_not be_nil
    end

    it "should appear on 'In Rainbows'" do
      appearance = @song.appears_on_album.first
      appearance.last.should == 1
      album = Album.get appearance.first
      album.title.should == "In Rainbows"
#      album.attachment_url("cover").should_not be_nil 
    end

    it "should be tagged with 'Rock'" do
      @song.tags.should_not be_nil
      @song.tags.should be_a_kind_of(Array)
      @song.tags.first.should == "Rock"
    end


    it "should be written by 'Radiohead'" do
      artist = Artist.get @song.written_by.first
      artist.should be_kind_of(Artist)
      artist.name.should == "Radiohead"
    end
  end

  context "generating a Song from YouTubeVideo" do
    before do
      @youtube_video_id = "someid"
      @video = YouTubeVideo.new :video_id => @youtube_video_id
      @video.save
      @id = @video.id
      puts "ID: #{@id}"
      @tag.album = ""
      @tag.track = 0
      id = SongGenerator.add_song(@tempfile,@tag,@video)
      puts "ID: #{@id}"
      @youtube_song = Song.get id
    end
    it "should still find the YouTubeVideo" do
      video = YouTubeVideo.get @id
      video.video_id.should == @youtube_video_id
    end

    it "should have added artist 'Radiohead'" do
      puts "Youtube Artist: #{@youtube_song.written_by.to_yaml}"
      artist = Artist.get @youtube_song.written_by.first
      artist.should be_kind_of(Artist)
      artist.name.should == "Radiohead"
    end
  end

  specify "should not generate song with missing artist" do
    @tag.artist = ""
    lambda { SongGenerator.add_song(@tempfile, @tag) }.should raise_error(SongGeneratorError) { |error| error.reason[:missing].should == :artist }
  end

  specify "should not generate song with missing track number" do
    @tag.track = 0 
    lambda { SongGenerator.add_song(@tempfile, @tag) }.should raise_error(SongGeneratorError) { |error| error.reason[:missing].should == :album }
  end

  specify "should not generate song with missing title" do
    @tag.title = ""
    lambda { SongGenerator.add_song(@tempfile, @tag) }.should raise_error(SongGeneratorError) { |error| error.reason[:missing].should == :title }
  end

#  specify "should not generate song with missing id3 tag" do
#    @tag.strip!
#    lambda { SongGenerator.add_song(@tempfile) }.should raise_error(SongGeneratorError) { |error| error.reason[:missing].should == :all }
#  end
#
end
