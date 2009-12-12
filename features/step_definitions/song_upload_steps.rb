Given /^I have "([^\"]*)" as an MP3 File$/ do |mp3|
  @file = File.new(File.join(File.dirname(__FILE__),"..", "support","#{mp3}.mp3"))
end

When /^I post the file to "([^\"]*)"$/ do |url|
  post_file "/songs", @file.read, "audio/mpeg"
end

Then /^I should get an ID back, identifying the Song$/ do
  json = JSON.parse last_response.body
  puts json
  json["id"].should_not be_nil
end

