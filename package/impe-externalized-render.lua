-- Portable externalized-render helper for IMPE.
-- Usage:
--   texlua impe-externalized-render.lua render ENGINE SOURCE
--   texlua impe-externalized-render.lua mkdir DIRECTORY
--   texlua impe-externalized-render.lua remove PATH [PATH ...]

local lfs = require("lfs")

local function fail(message, code)
  io.stderr:write("impe-externalized-render: " .. message .. "\n")
  os.exit(code or 1)
end

local function exists(path)
  return lfs.attributes(path) ~= nil
end

local function shell_quote(value)
  if package.config:sub(1, 1) == "\\" then
    return '"' .. value:gsub('"', '\\"') .. '"'
  end
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function exit_code(ok, reason, code)
  if type(ok) == "number" then
    return ok
  end
  if ok == true then
    return code or 0
  end
  if reason == "exit" and type(code) == "number" then
    return code
  end
  return 1
end

local function render(engine, source)
  if not engine or engine == "" then
    fail("missing engine name", 2)
  end
  if not source or not exists(source) then
    fail("source file not found: " .. tostring(source), 3)
  end

  local source_dir, source_leaf = source:match("^(.*)[/\\]([^/\\]+)$")
  source_dir = source_dir or "."
  source_leaf = source_leaf or source

  local original_dir = lfs.currentdir()
  local changed, change_error = lfs.chdir(source_dir)
  if not changed then
    fail("cannot enter source directory: " .. tostring(change_error), 4)
  end

  local command = table.concat({
    shell_quote(engine),
    "-interaction=nonstopmode",
    "-halt-on-error",
    shell_quote(source_leaf)
  }, " ")
  local ok, reason, code = os.execute(command)
  lfs.chdir(original_dir)
  os.exit(exit_code(ok, reason, code))
end

local action = arg[1]

if action == "render" then
  render(arg[2], arg[3])
elseif action == "mkdir" then
  local directory = arg[2]
  if not directory or directory == "" then
    fail("missing directory", 2)
  end
  if not exists(directory) then
    local ok, message = lfs.mkdir(directory)
    if not ok then
      fail("cannot create directory " .. directory .. ": " .. tostring(message), 5)
    end
  end
elseif action == "remove" then
  for index = 2, #arg do
    local path = arg[index]
    if exists(path) then
      local ok, message = os.remove(path)
      if not ok then
        fail("cannot remove " .. path .. ": " .. tostring(message), 6)
      end
    end
  end
else
  fail("expected render, mkdir, or remove action", 2)
end
