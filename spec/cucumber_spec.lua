CucumberLua = require("cucumber")

describe("CucumberLua", function()

  local respond = function(args)
    return CucumberLua:RespondToWireRequest(args)
  end

  it("finds step matches with no arguments", function()
    Given("I have toast", function()
    end)
    local args = { "step_matches", { name_to_match = "I have toast" } }
    local response = respond(args)
    equal(response[1], "success")
    equal(#response[2], 1)
    equal(response[2][1]["regexp"], "I have toast")
  end)

  it("finds step matches with arguments", function()
    Given("I divide (%d+) by (%d+)", function(x, y)
    end)
    local args = { "step_matches", { name_to_match = "I divide 12 by 4" } }
    local response = respond(args)
    equal(response[1], "success")
    equal(#response[2], 1)
    equal(response[2][1]["regexp"], "I divide (%d+) by (%d+)")
    equal(#response[2][1]["args"], 2)
    equal(response[2][1]["args"][1]["val"], "12")
    equal(response[2][1]["args"][1]["pos"], 9)
    equal(response[2][1]["args"][2]["val"], "4")
    equal(response[2][1]["args"][2]["pos"], 15)
  end)

  it("fails to match steps", function()
    local args = { "step_matches", { name_to_match = "I am lost" } }
    local response = respond(args)
    equal(response[1], "success")
    equal(#response[2], 0)
  end)

  it("invokes steps with no arguments", function()
    local count = 0
    Given("I crawl along", function()
      count = count + 1
    end)
    local args = { "invoke", { id = "I crawl along", args = {} } }
    local response = respond(args)
    equal(response[1], "success")
    equal(count, 1)
  end)

  it("invokes steps with arguments", function()
    local recorded_age = nil
    local recorded_day = nil
    Given("I am (%d) years old (%a+)", function(age, day)
      recorded_age = age
      recorded_day = day
    end)
    local args = { "invoke", { id = "I am (%d) years old (%a+)", args = { "9", "today" } } }
    local response = respond(args)
    equal(response[1], "success")
    equal(recorded_age, "9")
    equal(recorded_day, "today")
  end)

  it("invokes failing steps", function()
    Given("I throw up", function()
      error("blurgh")
    end)
    local args = { "invoke", { id = "I throw up", args = {} } }
    local response = respond(args)
    equal(response[1], "fail")
    equal(response[2]["message"], "./spec/cucumber_spec.lua:68: blurgh")
  end)

  it("invokes pending steps", function()
    Given("I am coming soon", function()
      Pending("later on")
    end)
    local args = { "invoke", { id = "I am coming soon", args = {} } }
    local response = respond(args)
    equal(response[1], "pending")
    equal(response[2], "later on")
  end)

  it("formats step definition snippets", function()
    local args = { "snippet_text", { step_keyword = "Given", step_name = "we're all wired" } }
    local response = respond(args)
    equal(response[1], "success")
    equal(response[2], "Given(\"we're all wired\", function ()\n\nend)")
  end)

  it("creates a new world for each scenario", function()
    World.foo = "bar"
    equal(respond({ "begin_scenario" })[1], "success")
    equal(World.foo, nil)
  end)

  it("executes hooks before each scenario", function()
    local msg = ""
    Before(function()
      msg = msg .. "X"
    end)
    Before(function()
      msg = msg .. "Y"
    end)
    equal(respond({ "begin_scenario" })[1], "success")
    equal(msg, "XY")
    equal(respond({ "begin_scenario" })[1], "success")
    equal(msg, "XYXY")
  end)

  it("executes hooks after each scenario", function()
    local msg = ""
    After(function()
      msg = msg .. "X"
    end)
    After(function()
      msg = msg .. "Y"
    end)
    equal(respond({ "end_scenario" })[1], "success")
    equal(msg, "XY")
    equal(respond({ "end_scenario" })[1], "success")
    equal(msg, "XYXY")
  end)

end)
