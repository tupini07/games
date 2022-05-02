-- bootstrap the compiler
fennel = require("lib.fennel")
table.insert(package.loaders or package.searchers, fennel.make_searcher({correlate=true}))

local make_love_searcher = function(env)
  return function(module_name)
    local path = module_name:gsub("%.", "/") .. ".fnl"
    if love.filesystem.getInfo(path) then
      return function(...)
        local code = love.filesystem.read(path)
        return fennel.eval(code, {env=env}, ...)
      end, path
    end
  end
end

table.insert(package.loaders, make_love_searcher(_G))
table.insert(fennel["macro-searchers"], make_love_searcher("_COMPILER"))

-- table.pack is not available in love2d since it uses luajit which
-- exposes lua 5.1
function table.pack(...)
    t = {...}
    t.n = select("#", ...)

    return t
end


require("wrap")
