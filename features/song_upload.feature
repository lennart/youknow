Feature: Add a Song to the library
In order to add a Song to the Library
I need to be able to upload an MP3

  Scenario: Upload a valid MP3
    Given I have "Salmon Dance" as an MP3 File
    When I post the file to "/songs"
    Then I should get an ID back, identifying the Song
