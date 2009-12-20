Feature: Adding YouTube Video
  
  Scenario: Downloading the Song
    Given generic metadata for a Song
    When I start the download
    Then I should have the Song in my Library

  
