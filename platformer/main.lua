-- Marksman
-- by Dadum
local map = require("src/map")
local camera_utils = require("src/camera")

local player = require("entities/player")
local arrow = require("entities/arrow")
local bullseye = require("entities/bullseye")


function _init()
    player.init()
    map.replace_entities()
    camera_utils.focus_section(0, 0) -- need to move this to a level manager
end

function _update()
    player.update()
    arrow.update_all()
end

function _draw()
    cls(12)
    map.draw()
    player.draw()
    bullseye.draw()
    arrow.draw_all()
end
