-- Marksman
-- by Dadum
local save_manager = require("managers/savefile")
local state_manager = require("managers/state")

GLOBAL_TIMER = 0

function _init()
    save_manager.init()
    state_manager.init()
end

function _update()
    GLOBAL_TIMER = GLOBAL_TIMER + 1
    state_manager.update()
end

function _draw() state_manager.draw() end
