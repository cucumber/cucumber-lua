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