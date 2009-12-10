require File.join(File.dirname(__FILE__), "base")
describe "A Song" do
  before do
    @song = Song.new :title => "15 Step"
  end

  it "should be possible to use all views" do
    Song.by_title.should be_empty
    Song.by_title_and_artist.should be_empty
    Song.by_title_and_album.should be_empty
    Song.by_title_and_artist_and_album.should be_empty
  end
end
