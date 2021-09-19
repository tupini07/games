local map = require("src/map")
local camera_utils = require("src/camera")

local player = require("entities/player")
local arrow = require("entities/arrow")
local bullseye = require("entities/bullseye")

local current_level = 1

local function level_init()
    map.replace_entities(current_level)
    camera_utils.focus_section(current_level) -- need to move this to a level manager
end

function WIN_LEVEL()
    current_level = current_level + 1
    level_init()
end

function LOSE_LEVEL() end

local function init()
    current_level = 1

    player.init()
    level_init()
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
