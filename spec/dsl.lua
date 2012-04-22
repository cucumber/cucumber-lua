local inspect = require("inspect")
local passes = 0
local fails = 0
local failures = {}

local descriptions = {
  size = 0,
  items = {},
 
  push = function (s, item)
    s.size = s.size + 1
    s.items[s.size] = item
  end,
 
  pop = function (s)
    if (s.size <= 0) then return nil end
    local item = s.items[s.size]
    s.size = s.size - 1
    return item
  end,
 
  concatenate = function (s)
    local str = ""
    for i = 1, s.size do
      if (i == 1) then
        str = s.items[i]
      else
        str = str .. " (" .. s.items[i] .. ")"
      end
    end
    return str
  end
}

function describe( name, fn )
  descriptions:push(name)
  fn()
  descriptions:pop()
end

function it( name, fn )
  local pass, err = pcall( fn )
  if pass then
    passes = passes + 1
    io.write( green( "." ) )
  else
    fails = fails + 1
    recordFailure(name, err)
    io.write( red( "." ) )
  end
end

function fail( message )
  error( { message = message .. "\n    " .. traceback() } )
end

function recordFailure(name, err)
  table.insert( failures,
                red("\nFAIL ") ..
                descriptions:concatenate() ..
                " " ..
                name ..
                ":\n  - " ..
                (err.message or err or "") )  
end

function traceback()
  for line in string.gmatch(debug.traceback(), "[^\n]+in function \<[^\n]+") do
    return string.gsub(string.gsub(line, ": in function \<.+\>", ""), "%s+", "")
  end
end

function red( str )
  return '\27[31m' .. str .. '\27[0m' 
end

function green( str )
  return '\27[32m' .. str .. '\27[0m' 
end

function equal( a, b )
  if a ~= b then
    fail( "expected " .. inspect(a) .. " to equal " .. inspect(b) )
  end
end

function printFailures()
  for i,v in ipairs(failures) do
    print ( v )
  end
end

function printSummary()
  print ( green(passes) .. " passed, " .. red(fails) .. " failed" )
end

function string.endsWith(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end