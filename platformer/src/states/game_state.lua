local map = require("src/map")
local camera_utils = require("src/camera")

local player = require("entities/player")
local arrow = require("entities/arrow")
local bullseye = require("entities/bullseye")

local function init()
    player.init()
    map.replace_entities()
    camera_utils.focus_section(0, 0) -- need to move this to a level manager
end

local function update()
    player.update()
    arrow.update_all()
end

local function draw()
    cls(12)
    map.draw()
    player.draw()
    bullseye.draw()
    arrow.draw_all()
end

return {init = init, update = update, draw = draw}
