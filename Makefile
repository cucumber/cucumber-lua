spec :
	lua spec/runner.lua

cuke :
	luarocks install cucumber-lua-0.0-2.rockspec
	cucumber

install :
	luarocks install luafilesystem
	luarocks install luasocket
	luarocks install luajson

.PHONY: spec install
