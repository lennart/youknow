class GuessingClass
  extend Guessing
end
TO_GUESS=[
  { :string =>  "Major Lazer \"Pon de floor\"",
    :title => "Pon de floor", 
    :artist => "Major Lazer"},
  { :string => "System of a down-Your own pace(36 demo)",
    :title => "Your own pace",
    :artist => "System of a down",
    :genre => ["36","demo"]
  }
] 
describe "The Guessing of Title and Artist" do
  before do
    make_metadata = lambda do |hash|
      hash[:string] = Metadata.new :title => hash[:string]
      hash
    end
    @metadatas = TO_GUESS.map {|e| make_metadata.call(e)}
  end
  it "should guess when metadata is missing an artist" do
    @metadatas.each do |m|
      guessed = GuessingClass.guess_best_metadata(m[:string])
      guessed.title.should == m[:title]
      guessed.artist.should == m[:artist]
      if m[:genre]
        guessed.genre.should_not be_empty
        guessed.genre.should include(*m[:genre])
      end
    end
  end

  it "should not guess when metadata is complete" do
    metadata = Metadata.new
    metadata.artist = "Bob Marley"
    metadata.title = "Jammin'"
    guessed_metadata = GuessingClass.guess_best_metadata metadata
    guessed_metadata.artist.should == "Bob Marley"
    guessed_metadata.title.should == "Jammin'"
  end
end
