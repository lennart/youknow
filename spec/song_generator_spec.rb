require File.join(File.dirname(__FILE__), "base")
require 'fileutils'
describe "A Song Generator" do
  before(:each) do
    recreate_db
    originalfile = File.new(File.join(File.dirname(__FILE__),"..","features", "support", "Salmon Dance.mp3"))
    @tempfile_path = "public/tempfile.mp3"
    FileUtils.cp(originalfile.path,@tempfile_path)
    @tag = ID3Lib::Tag.new @tempfile_path
    @tag.title = "15 Step"
    @tag.album = "In Rainbows"
    @tag.artist = "Radiohead"
    @tag.track = "1/12"
    @tag.genre = "Rock"
    @tag.update!
    @tempfile = File.new(@tempfile_path)
  end

  after(:each) do
    FileUtils.rm(@tempfile_path)
  end

  specify "should generate new song" do
    artwork = if (apic = @tag.select {|k| k[:id] == :APIC }).size > 0
                apic
              end
    log("Should generate new Song")
    id = SongGenerator.add_song(@tempfile)
    song = Song.get id
    song.title.should == "15 Step"
    log("has Title")
    song.written_by.should_not be_nil
    artist = Artist.get song.written_by.first
    artist.should be_kind_of(Artist)
    artist.name.should == "Radiohead"
    log("has Artist")
    song.appears_on_album.should_not be_nil
    song.appears_on_album.should be_a_kind_of(Hash)
    appearance = song.appears_on_album.first
    appearance.last.should == 1
    log("has Appearance on Album")
    album = Album.get appearance.first
    album.title.should == "In Rainbows"
    album.attachment_url("cover").should_not be_nil 
    log("has Album")
    song.tags.should_not be_nil
    song.tags.should be_a_kind_of(Array)
    song.audiofiles.should_not be_nil
    audiofile = Audiofile.get song.audiofiles.first
    audiofile.attachment_url("attachment").should_not be_nil

  end

  specify "should not generate song with missing artist" do
    log("Should fail with missing artist")
    @tag.artist = nil
    @tag.update!
    lambda { SongGenerator.add_song(@tempfile) }.should raise_error(SongGeneratorError) { |error| error.reason[:missing].should == :artist }
  end

  specify "should not generate song with missing track number" do
    log("Should fail with missing track number")
    @tag.track = nil
    @tag.update!
    lambda { SongGenerator.add_song(@tempfile) }.should raise_error(SongGeneratorError) { |error| error.reason[:missing].should == :track }
  end

  specify "should not generate song with missing title" do
    log("Should fail with missing title")
    @tag.title = nil
    @tag.update!
    lambda { SongGenerator.add_song(@tempfile) }.should raise_error(SongGeneratorError) { |error| error.reason[:missing].should == :title }
  end

  specify "should not generate song with missing id3 tag" do
    log("Should fail with missing id3 tag")
    @tag.strip!
    lambda { SongGenerator.add_song(@tempfile) }.should raise_error(SongGeneratorError) { |error| error.reason[:missing].should == :all }
  end

end
