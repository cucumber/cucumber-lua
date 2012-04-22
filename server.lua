#!/usr/bin/env lua

-- server.lua
--
-- This script does the same as running bin/cucumber-lua
-- i.e starts a wire server to execute steps.
-- But it uses the local cucumber sources instead of the
-- system-wide luarocks install:
package.path = './src/?.lua;' .. package.path

require("cucumber"):StartListening()