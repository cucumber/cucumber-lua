require 'lfs'
package.path = "./src/?.lua;./spec/?.lua;" .. package.path

require("dsl")

for file in lfs.dir ("./spec") do
	if ( file:endsWith("_spec.lua") ) then
	  require( file:gsub('.lua', '') )
	end
end

print ( "" )

printFailures()

print ( "" )

printSummary()

print ( "" )
