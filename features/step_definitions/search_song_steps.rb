Given /^I visit the search page$/ do
  visit "/search"
end

Given /^I fill in "([^\"]*)" as the (.*)$/ do |string, field|
  fill_in field, :with => string
end

When /^I click "([^\"]*)"$/ do |value|
  click_button value 
end

Then /^I should see a link to add "([^\"]*)" to the library$/ do |name|
  has_css? "#results"
  find_link(name).should_not be_nil
end

