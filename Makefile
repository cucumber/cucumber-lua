spec :
	lua spec/runner.lua

install :
	luarocks install luafilesystem
	luarocks install luasocket
	luarocks install luajson

.PHONY: spec install
