--
-- log.lua
--
-- Copyright (c) 2016 rxi
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

---@alias lib.log-level
---| '"trace"'
---| '"debug"'
---| '"info"'
---| '"warn"'
---| '"error"'
---| '"fatal"'

---@alias lib.log-log fun(...)

---@class lib.log
---@field usecolor boolean (true)
---@field outfile? string (nil)
---@field level lib.log-level ("trace")
---@field trace lib.log-log
---@field debug lib.log-log
---@field info lib.log-log
---@field warn lib.log-log
---@field error lib.log-log
---@field fatal lib.log-log
local log = { _version = "0.1.0" }

log.usecolor = true
log.outfile = nil
log.level = "trace"

local modes = {
  { name = "trace", color = "\27[34m" },
  { name = "debug", color = "\27[36m" },
  { name = "info", color = "\27[32m" },
  { name = "warn", color = "\27[33m" },
  { name = "error", color = "\27[31m" },
  { name = "fatal", color = "\27[35m" },
}

local levels = {}
for i, v in ipairs(modes) do
  levels[v.name] = i
end

local round = function(x, increment)
  increment = increment or 1
  x = x / increment
  return (x > 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)) * increment
end

local _tostring = tostring

local tostring = function(...)
  local t = {}
  for i = 1, select("#", ...) do
    local x = select(i, ...)
    if type(x) == "number" then
      x = round(x, 0.01)
    end
    t[#t + 1] = _tostring(x)
  end
  return table.concat(t, " ")
end

for i, x in ipairs(modes) do
  local nameupper = x.name:upper()
  log[x.name] = function(...)
    -- Return early if we're below the log level
    if i < levels[log.level] then
      return
    end

    local msg = tostring(...)
    local info = debug.getinfo(2, "Sl")
    local lineinfo = info.short_src .. ":" .. info.currentline

    -- Output to console
    print(
      string.format(
        "%s%s[%-6s%s]%s %s%s%s%s : %s",
        log.usecolor and "\27[1m" or "",
        log.usecolor and x.color or "",
        nameupper,
        os.date("%H:%M:%S"),
        log.usecolor and "\27[0m" or "",
        log.usecolor and x.color or "",
        log.usecolor and "\27[4m" or "",
        lineinfo,
        log.usecolor and "\27[0m" or "",
        msg
      )
    )

    -- Output to log file
    if log.outfile then
      local fp = io.open(log.outfile, "a")
      local str = string.format(
        "[%-6s%s] %s: %s\n",
        nameupper,
        os.date(),
        lineinfo,
        msg
      )
      fp:write(str)
      fp:close()
    end
  end
end

return log
