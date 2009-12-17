require File.join(File.dirname(__FILE__), "..", "spec_helper")
require 'models/blipfm'
describe "The BlipFM Sync" do
  before do
    @song_url = "http://walrusmusicblog.com/wp-content/uploads/2009/09/07-Plain-Material-1.mp3"
    @youtube_video_id = "QB0ordd2nOI"
    @list_of_blips = [
  { "reblipId"=>"29576103", "artist"=>"Memory Tapes",
    "toId"=>"", "title"=>"Plain Material",
    "via"=>"", "unixTime"=>"1260529825",
    "url"=>@song_url,
    "viaUrl"=>"", "id"=>"29606518",
    "bitrate"=>"", "thumbplayLink"=>"",
    "type"=>"songUrl", "replyId"=>"",
    "genre"=>"", "insTime"=>"2009-12-11 11:10:25",
    "ownerId"=>"374032", "status"=>"active",
    "message"=>"[reply]DeadCabbage[/reply]: \"Memory Tapes \342\200\223 Plain Material\"",
    "owner"=> {
      "lastBlipTime"=>"2009-12-15 09:38:15", 
      "name"=>"", "updateTime"=>"2009-12-15 17:38:15",
      "timeZone"=>"Europe/Berlin",
      "profilePic"=>"http://pics03.bliptastic.com/374-374032.jpeg", "id"=>"374032",
      "insTime"=>"2009-05-30 00:36:41", "website"=>"http://lmaa.posterous.com",
      "countryAbbr"=>"de", "urlName"=>"lmaa",
      "listeners"=>"43", "propsCount"=>"0",
      "status"=>"active"
    }
  },
  { "reblipId"=>"29815933", "artist"=>"The Cinematic Orchestra",
    "toId"=>"", "title"=>"To Build a Home",
    "via"=>"", "unixTime"=>"1260898695",
    "url"=>@youtube_video_id, "viaUrl"=>"",
    "id"=>"29967483", "bitrate"=>"",
    "thumbplayLink"=>"http://offers.thumbplay.com/offers/1461/artisttitle2?thpartist=The+Cinematic+Orchestra&thptitle=To+Build+A+Home+%28Grey+Reverend+Version%29&selectedContent=578879",
    "type"=>"youtubeVideo", "replyId"=>"",
    "genre"=>"", "insTime"=>"2009-12-15 17:38:15",
    "ownerId"=>"374032", "status"=>"active",
    "message"=>"reminds me of the old ones by coldplay",
    "owner"=> {
      "lastBlipTime"=>"2009-12-15 09:38:15", "name"=>"",
      "updateTime"=>"2009-12-15 17:38:15", "timeZone"=>"Europe/Berlin",
      "profilePic"=>"http://pics02.bliptastic.com/374-374032.jpeg", "id"=>"374032",
      "insTime"=>"2009-05-30 00:36:41", "website"=>"http://lmaa.posterous.com",
      "countryAbbr"=>"de", "urlName"=>"lmaa",
      "listeners"=>"43", "propsCount"=>"0",
      "status"=>"active"}
    }
  ]
  @blip_profile_url = "http://api.blip.fm/blip/getUserProfile.json?username=lmaa"
  end
  it "should fetch the latest Blips for 'lmaa'" do
    some_json_string = "some json containing blips"
    json = {"result" => {"collection" => {"Blip" => @list_of_blips}}}
    easy = stub_everything(:body_str => some_json_string)
    Curl::Easy.expects(:perform).with(@blip_profile_url).returns(easy)
    JSON.expects(:parse).with(some_json_string).returns(json)
    Resque.expects(:enqueue).with(::Downloader,kind_of(YouTubeVideo),kind_of(String),kind_of(Hash))
    Resque.expects(:enqueue).with(::Downloader,kind_of(String),kind_of(String),kind_of(Hash))
    BlipFM.sync("lmaa")
  end
end
