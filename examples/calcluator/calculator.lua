Calculator = { numbers = {} }

function Calculator:Reset ()
  self.numbers = {}
end

function Calculator:Enter (number)
  table.insert(self.numbers, number)
end

function Calculator:Add ()
  self.result = 0
  for i = 1, #self.numbers do
    self.result = self.result + self.numbers[i]
  end
end

return Calculator