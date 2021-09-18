-- Marksman
-- by Dadum

local map = require("src/map")
local player = require("src/player")
local arrow = require("src/arrow")

function _init()
    player.init()
    map.replace_entities()
end

function _update()
    player.update()
    arrow.update_all()
end

function _draw()
    cls(6)
    map.draw()
    player.draw()
    arrow.draw_all()
end
