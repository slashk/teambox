@wip
Feature: Importing data

Background: 
  Given a project exists with name: "Ruby Rockstars"
  And I am logged in as mislav
  And I am in the project called "Ruby Rockstars"
  And I am an administrator in the organization of the project called "Ruby Rockstars"
  And deferred data processing is off

Scenario: Mislav imports an historic project
  When I go to the your data page
  And I follow "Import"
  And I choose "Teambox"
  And I attach the file "spec/fixtures/teamboxdump.json" to "teambox_data_import_data"
  And I press "Import data"
  Then I should see "Andrew Wiggin (@gandhi_1)"
  And I should see "Andrew Wiggin (@gandhi_2)"
  And I should see "Andrew Wiggin (@gandhi_3)"
  And I should see "Andrew Wiggin (@gandhi_4)"
  Then show me the page
  When I select the following:
    | Andrew Wiggin (@gandhi_1)             |  Mislav Marohnić (@mislav) |
    | Andrew Wiggin (@gandhi_2)             |  Mislav Marohnić (@mislav) |
    | Andrew Wiggin (@gandhi_3)             |  Mislav Marohnić (@mislav) |
    | Andrew Wiggin (@gandhi_4)             |  Mislav Marohnić (@mislav) |
    | Put all projects in this organization | Teambox #1                 |
  And I press "Import"
  Then I should see "Imported projects"
  And I should see "Teambox #1"

Scenario: Mislav gets fed up of Basecamp and moves to Teambox
  When I go to the your data page
  And I follow "Import"
