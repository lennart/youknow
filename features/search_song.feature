Feature: Find a Song
  In order to hear a song
  I want to search for it
  on youtube 
  and vimeo
  and my network

  Scenario: Searching the web
    Given I visit the search page
    And I fill in "Sidney Samson - Riverside (Original Mix)" as the query
    When I click "Search"
    Then I should see a link to add "Sidney Samson - Riverside (Original Mix)" to the library
