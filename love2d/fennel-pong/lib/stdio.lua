require("love.event")
local fennel = require("lib.fennel")
local view = fennel.view
local event, channel = ...
local function display(s)
  io.write(s)
  return io.flush()
end
local function prompt()
  return display("\n>> ")
end
local function read_chunk()
  local input = io.read()
  if input then
    return (input .. "\n")
  else
    return nil
  end
end
local input = ""
if channel then
  local bytestream, clearstream = fennel.granulate(read_chunk)
  local read
  local function _2_()
    local c = (bytestream() or 10)
    input = (input .. string.char(c))
    return c
  end
  read = fennel.parser(_2_)
  while true do
    prompt()
    input = ""
    local ok, ast = pcall(read)
    if not ok then
      display(("Parse error:" .. ast .. "\n"))
    else
      love.event.push(event, input)
      display(channel:demand())
    end
  end
else
end
local function start_repl()
  local code = love.filesystem.read("stdio.fnl")
  local lua_s
  if code then
    lua_s = love.filesystem.newFileData(fennel.compileString(code), "io")
  else
    lua_s = love.filesystem.read("lib/stdio.lua")
  end
  local thread = love.thread.newThread(lua_s)
  local io_channel = love.thread.newChannel()
  thread:start("eval", io_channel)
  local function _6_(input0)
    local ok, val = pcall(fennel.eval, input0)
    local function _7_()
      if ok then
        return view(val)
      else
        return val
      end
    end
    return io_channel:push(_7_())
  end
  love.handlers.eval = _6_
  return nil
end
return {start = start_repl}
