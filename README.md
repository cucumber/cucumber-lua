# Cucumber-Lua

A [wire protocol](https://github.com/cucumber/cucumber/wiki/Wire-Protocol) implementation for [cucumber](http://cucumbers.info/) that executes steps defined in [Lua](http://www.lua.org/)

#### Usage

Install using luarocks:

	luarocks build https://raw.github.com/cucumber/cucumber-lua/master/cucumber-lua-0.0-1.rockspec

Add a .wire file telling cucumber that Lua is listening:

###### /features/step_definitions/lua-cucumber.wire

	host: 0.0.0.0
	port: 9666

Run the CucumberLua server:

	cucumber-lua

Then run cucumber in another terminal:

	cucumber

#### Lua Step Definitions

###### /features/step_definitions/steps.lua

	Calculator = require("calculator")
	
	Before(function()
		Calculator:Reset()
	end)
	
	Given("I have entered (%d+) into the calculator", function (number)
		Calculator:Enter(number)
	end)
	
	When("I press add", function ()
		Calculator:Add()
	end)
	
	Then("the result should be (%d+) on the screen", function (number)
		assert(Calculator.result == tonumber(number),
			   "Expected " .. number .. ", was " .. Calculator.result)
	end)

#### Running the CucumberLua specs

	lua spec/runner.lua
