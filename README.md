# Cucumber-Lua
[![Build Status](https://travis-ci.org/cucumber/cucumber-lua.svg?branch=master)](https://travis-ci.org/cucumber/cucumber-lua)

A [wire protocol](https://github.com/cucumber/cucumber-ruby-wire) server for [cucumber-ruby](http://github.com/cucumber/cucumber-ruby) that executes steps defined in [Lua](http://www.lua.org/)

#### Installation

1. Install Lua 5.2

2. Install cucumber-lua using luarocks:

```
luarocks build https://raw.github.com/cucumber/cucumber-lua/master/cucumber-lua-0.0-2.rockspec
```

3. Install [Ruby]([url](https://www.ruby-lang.org/en/documentation/installation/)), [cucumber-ruby]([url](http://github.com/cucumber/cucumber-ruby)) and the [wire protocol gem]([url](https://github.com/cucumber/cucumber-ruby-wire)).

Create a `Gemfile`

```
source 'https://rubygems.org'

gem "cucumber"
gem "cucumber-wire"
```

Then ask [Bundler]([url](https://bundler.io/)) to install the gems:

    bundle install
    
Add a file to load the wire protocol plugin:

    echo "require 'cucumber/wire'" > features/support/wire.rb

5. Add a .wire file telling cucumber that Lua is listening:

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
bundle exec cucumber
```

#### Lua Step Definitions

cucumber-lua expects you to define a single file for step definitions (features/step_definitions/steps.lua). If you need anything more than a single file, use lua modules and require them from your main steps file (that means we don't need luafilesystem).

Create your step definitions using the following global keywords:

* `Before(fn)` - called before each scenario
* `After(fn)` - called after each scenario
* `Given(step, fn)` - define a step where a pre-condition/state is declared
* `When(step, fn)` - define a step where user action or behaviour is performed
* `Then(step, fn)` - define a step where the outcome is observed
* `Pending(message)` - indicate a step as pending implementation

Note: If a `Before` or `After` function fails the whole scenario is reported as failed.

###### /features/step_definitions/steps.lua

```Lua
Calculator = require("calculator")

Before(function()
    Calculator:Reset()
end)

After(function()
    print("I am called after each scenario")
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
