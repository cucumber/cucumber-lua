Feature: Cucumber Lua

  cucumber-lua executes steps defined in Lua

  Background: Wired Up
    Given a file named "features/step_definitions/cucumber-lua.wire" with:
      """
      host: 0.0.0.0
      port: 9666
      """
  
  Scenario: Running Features With Lua Step Definitions
    And a file named "features/step_definitions/steps.lua" with:
      """
      Given("I am happy", function()
        assert(true)
      end)
      
      When("I am sad", function()
        error("sorry")
      end)
      
      Then("that's all", function()
        Pending("because")
      end)
      """
    And a file named "features/whereabouts.feature" with:
      """
      Feature: Whereabouts
        Scenario: At home
          Given I am happy
        
        Scenario: Away
          When I am sad
          
        Scenario: On holiday
          Then I am overjoyed
          
        Scenario: Dead
          And that's all
      """
    When I run `cucumber`
    Then the output should contain:
      """
      Feature: Whereabouts
      
        Scenario: At home  # features/whereabouts.feature:2
          Given I am happy # I am happy
      
        Scenario: Away  # features/whereabouts.feature:5
          When I am sad # I am sad
            ./features/step_definitions/steps.lua:6: sorry (./features/step_definitions/steps.lua:6: sorry from 0.0.0.0:9666)
            features/whereabouts.feature:6:in `When I am sad'
      
        Scenario: On holiday  # features/whereabouts.feature:8
          Then I am overjoyed # features/whereabouts.feature:9
      
        Scenario: Dead   # features/whereabouts.feature:11
          And that's all # that's all
            because (Cucumber::Pending)
            features/whereabouts.feature:12:in `And that's all'
      
      Failing Scenarios:
      cucumber features/whereabouts.feature:5 # Scenario: Away
      
      4 scenarios (1 failed, 1 undefined, 1 pending, 1 passed)
      4 steps (1 failed, 1 undefined, 1 pending, 1 passed)
      """
    And the output should contain:
      """
      You can implement step definitions for undefined steps with these snippets:
      
      Then("I am overjoyed", function ()
      
      end)
      """