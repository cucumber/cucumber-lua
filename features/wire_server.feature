Feature: Wire Server
  
  An implementation of the cucumber wire protocol, as defined at
  https://github.com/cucumber/cucumber/blob/master/legacy_features/wire_protocol.feature
  
  Scenario: Undefined step matches
    Given there is no step matching "Given I'm squashed"
    Then the server should respond as follows:
      | request                                                  | response       |
      | ["step_matches",{"name_to_match":"Given I'm squashed"}]  | ["success",[]] |

  Scenario: Defined step matches
    Given the following step definitions:
    """
      Given("I'm happy", function()
      end)
    """
    Then the server should respond as follows:
      | request                                                | response                                                                             |
      | ["step_matches",{"name_to_match":"Given I'm happy"}]   | ["success",[{"id":"I'm happy","regexp":"I'm happy","source":"I'm happy","args":[]}]] |

  Scenario: Defined step matches with arguments
    Given the following step definitions:
      """
        Given("I'm (%d+) years (%w+)", function(years, adjective)
        end)
      """
    Then the server should respond as follows:
      | request                                                      | response                                                                                                                                                             |
      | ["step_matches",{"name_to_match":"Given I'm 10 years old"}]  | ["success",[{"id":"I'm (%d+) years (%w+)","regexp":"I'm (%d+) years (%w+)","source":"I'm (%d+) years (%w+)","args":[{"val":"10","pos":10},{"val":"old","pos":19}]}]] |
      | ["step_matches",{"name_to_match":"Given I'm 23 years new"}]  | ["success",[{"id":"I'm (%d+) years (%w+)","regexp":"I'm (%d+) years (%w+)","source":"I'm (%d+) years (%w+)","args":[{"val":"23","pos":10},{"val":"new","pos":19}]}]] |

  Scenario: Passing steps
    Given the following step definitions:
      """
        Given("I'm harmless", function()
        end)
      """
    Then the server should respond as follows:
      | request                                                   | response                                                                                      |
      | ["step_matches",{"name_to_match":"Given I'm harmless"}]   | ["success",[{"id":"I'm harmless","regexp":"I'm harmless","source":"I'm harmless","args":[]}]] |
      | ["begin_scenario"]                                        | ["success"]                                                                                   |
      | ["invoke",{"id":"I'm harmless","args":[]}]                | ["success"]                                                                                   |
      | ["end_scenario"]                                          | ["success"]                                                                                   |

  Scenario: Passing steps with arguments
    Given the following step definitions:
      """
        Given("I'm a (%w+)", function(noun)
        end)
      """
    Then the server should respond as follows:
      | request                                                   | response                                                                                                            |
      | ["step_matches",{"name_to_match":"Given I'm a teapot"}]   | ["success",[{"id":"I'm a (%w+)","regexp":"I'm a (%w+)","source":"I'm a (%w+)","args":[{"val":"teapot","pos":12}]}]] |
      | ["begin_scenario"]                                        | ["success"]                                                                                                         |
      | ["invoke",{"id":"I'm a (%w+)","args":[]}]                 | ["success"]                                                                                                         |
      | ["end_scenario"]                                          | ["success"]                                                                                                         |

  Scenario: Failing steps
    Given the following step definitions:
      """
        Given("I'm explosive", function()
          error("boom")
        end)
      """
    Then the server should respond as follows:
      | request                                                   | response                                                                                                                               |
      | ["step_matches",{"name_to_match":"Given I'm explosive"}]  | ["success",[{"id":"I'm explosive","regexp":"I'm explosive","source":"I'm explosive","args":[]}]]                                       |
      | ["begin_scenario"]                                        | ["success"]                                                                                                                            |
      | ["invoke",{"id":"I'm explosive","args":[]}]               | ["fail",{"message":".\/features\/step_definitions\/steps.lua:2: boom","exception":".\/features\/step_definitions\/steps.lua:2: boom"}] |

  Scenario: Failing steps with arguments
    Given the following step definitions:
      """
        Given("I go (%w+)", function(adjective)
          error(adjective)
        end)
      """
    Then the server should respond as follows:
      | request                                                   | response                                                                                                                                |
      | ["step_matches",{"name_to_match":"Given I go bang"}]      | ["success",[{"id":"I go (%w+)","regexp":"I go (%w+)","source":"I go (%w+)","args":[{"val":"bang","pos":11}]}]]                          |
      | ["begin_scenario"]                                        | ["success"]                                                                                                                             |
      | ["invoke",{"id":"I go (%w+)","args":["bang"]}]            | ["fail",{"message":".\/features\/step_definitions\/steps.lua:2: bang","exception":".\/features\/step_definitions\/steps.lua:2: bang"}]  |
      | ["end_scenario"]                                          | ["success"]                                                                                                                             |

  Scenario: Pending steps
    Given the following step definitions:
      """
        Given("I'm not ready", function()
          Pending("coming soon")
        end)
      """
    Then the server should respond as follows:
      | request                                                   | response                                                                                         |
      | ["step_matches",{"name_to_match":"Given I'm not ready"}]  | ["success",[{"id":"I'm not ready","regexp":"I'm not ready","source":"I'm not ready","args":[]}]] |
      | ["begin_scenario"]                                        | ["success"]                                                                                      |
      | ["invoke",{"id":"I'm not ready","args":[]}]               | ["pending","coming soon"]                                                                        |
      | ["end_scenario"]                                          | ["success"]                                                                                      |

  Scenario: Snippets
    Given there is no step matching "Given we're all wired"    
    Then the server should respond as follows:
      | request                                                                                            | response                                                     |
      | ["step_matches",{"name_to_match":"Given we're all wired"}]                                         | ["success",[]]                                               |
      | ["snippet_text",{"step_keyword":"Given","multiline_arg_class":"","step_name":"we're all wired"}]   | ["success","Given(\"we're all wired\", function ()\n\nend)"] |
      | ["end_scenario"]                                                                                   | ["success"]                                                  |

  Scenario: Update lua steps without restarting the server
    Given the following step definitions:
      """
        Given("I barf", function(adjective)
          error("oopsie")
        end)
        """
    Then the server should respond as follows:
      | request                                            | response                                                                                                                                   |
      | ["step_matches",{"name_to_match":"Given I barf"}]  | ["success",[{"id":"I barf","regexp":"I barf","source":"I barf","args":[]}]]                                                                |
      | ["begin_scenario"]                                 | ["success"]                                                                                                                                |
      | ["invoke",{"id":"I barf","args":[]}]               | ["fail",{"message":".\/features\/step_definitions\/steps.lua:2: oopsie","exception":".\/features\/step_definitions\/steps.lua:2: oopsie"}] |
    Given the following step definitions:
      """
        Given("I barf", function(adjective)
        end)
        """
    Then the server should respond as follows:
      | request                                            | response                                                                    |
      | ["step_matches",{"name_to_match":"Given I barf"}]  | ["success",[{"id":"I barf","regexp":"I barf","source":"I barf","args":[]}]] |
      | ["begin_scenario"]                                 | ["success"]                                                                 |
      | ["invoke",{"id":"I barf","args":[]}]               | ["success"]                                                                 |
      | ["end_scenario"]                                   | ["success"]                                                                 |
      
