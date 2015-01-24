module("cucumber", package.seeall)

require("json")
local socket = require("socket")

local CucumberLua = {
  step_definitions = {},
  before_hooks = {},
  pending_message = "PENDING"
}
local World = {}
local Pending = function(message)
  CucumberLua.pending_message = message
  error("CucumberLua:Pending")
end

function CucumberLua:step_matches(args)
  local text = args["name_to_match"]
  local matches = {}
  for pattern,func in pairs(self.step_definitions) do
    if type(func) == "function" and string.match(text, pattern) then
      table.insert(matches, self:StepMatch(text, pattern))
    end
  end
  return { "success", matches }
end
  
function CucumberLua:begin_scenario(args)
  _G["World"] = {}
  for i,hook in ipairs(self.before_hooks) do
    hook()
  end
  return { "success" }
end
  
function CucumberLua:invoke(args)
  func = self.step_definitions[args["id"]]
  local ok, err = pcall(func, unpack(args["args"]))
  if ok then
    return { "success" }
  else
    if (err:match("CucumberLua:Pending")) then
      return { "pending", CucumberLua.pending_message }
    end
    return { "fail", { message = err, exception = err } }
  end
end

function CucumberLua:ReloadSteps()
  self.step_definitions = {}
  dofile("./features/step_definitions/steps.lua")
end
  
function CucumberLua:snippet_text (args)
  return { "success", args["step_keyword"] ..
           "(\"" .. args["step_name"] .. "\", function ()\n\nend)" }
end

function CucumberLua:FindArgs(str, pattern)
  local patternWithPositions = string.gsub(pattern, "%(", "()(")
  matches = {string.find(str, patternWithPositions)}
  args = {}
  for i = 3, #matches, 2 do
    table.insert(args, {
      ["pos"] = matches[i] - 1,
      ["val"] = matches[i + 1]
    })
  end
  return args
end

function CucumberLua:StepMatch(text, pattern)
  return {
    id = pattern,
    args = self:FindArgs(text, pattern),
    source = pattern,
    regexp = pattern
  }
end

function CucumberLua:RespondToWireRequest (request)
  local command = request[1]
  local args = request[2]
  local response = { "success" }
  if self[command] then
    response = self[command](self, args)
  end
  return response
end

function CucumberLua:Listen (sock)
  local conn = assert(sock:accept())
  self:ReloadSteps()
  local request_json, err = conn:receive()
  while not err do
    local request = json.decode(request_json)
    local response = self:RespondToWireRequest(request)
    local response_json = json.encode(response):gsub("{}", "[]")
    conn:send(response_json .. "\n")
    request_json, err = conn:receive()
  end
  if not err == "closed" then
    print(err)
  end
  self:Listen(sock)
end

function CucumberLua:StartListening ()
  local host = "*"
  local port = 9666
  local sock = assert(socket.bind(host, port))
  local ip, port = sock:getsockname()
  assert(ip, port)
  print("Waiting for cucumber on " .. ip .. ":" .. port .. " (Ctrl+C to quit)")
  self:ReloadSteps()
  self:Listen(sock)
end

local DefineStep = function(text, fn)
  CucumberLua.step_definitions[text] = fn
end

local Before = function(func)
  table.insert(CucumberLua.before_hooks, func)
end

_G["Given"]    = DefineStep
_G["When"]     = DefineStep
_G["Then"]     = DefineStep
_G["Before"]   = Before
_G["World"]    = World
_G["Pending"]  = Pending

return CucumberLua