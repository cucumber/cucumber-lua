# Cucumber-Lua

A [wire protocol](https://github.com/cucumber/cucumber/wiki/Wire-Protocol) implementation for [cucumber](http://cucumbers.info/) that executes steps defined in [Lua](http://www.lua.org/)

#### Installation

1. Install Lua 5.2

2. Install cucumber-lua using luarocks:

```
luarocks build https://raw.github.com/cucumber/cucumber-lua/master/cucumber-lua-0.0-2.rockspec
```

3. Add a .wire file telling cucumber that Lua is listening:

###### /features/step_definitions/cucumber-lua.wire

```
host: 0.0.0.0
port: 9666
```

#### Usage

Run the cucumber-lua server:

```
cucumber-lua
```

Then run cucumber in another terminal:

```
cucumber
```

#### Lua Step Definitions

cucumber-lua expects you to define a single file for step definitions (features/step_definitions/steps.lua). If you need anything more than a single file, use lua modules and require them from your main steps file (that means we don't need luafilesystem)

###### /features/step_definitions/steps.lua

```Lua
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

Then("Something not yet implemented", function ()
    Pending("It's not ready yet")
end)
```

#### Running the Cucumber-Lua specs

```
lua spec/runner.lua
```
