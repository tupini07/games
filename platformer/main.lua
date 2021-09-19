-- Marksman
-- by Dadum

local save_manager = require("utils/save_manager")
local state_manager = require("states/state_manager")

function _init()
    save_manager.init()
    state_manager.init()
end

function _update()
    state_manager.update()
end

function _draw()
    state_manager.draw()
end
