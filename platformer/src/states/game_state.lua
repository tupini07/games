local map = require("src/map")
local camera_utils = require("src/camera")

local player = require("entities/player")
local arrow = require("entities/arrow")
local bullseye = require("entities/bullseye")

local savefile_manager = require("managers/savefile")
local level_win = false

local function level_init()
    map.replace_entities(SAVE_DATA.current_level)
    camera_utils.focus_section(SAVE_DATA.current_level) -- need to move this to a level manager
end

function WIN_LEVEL() level_win = true end

function LOSE_LEVEL() end

local function level_win_update()
    if btnp(5) then
        level_win = false

        SAVE_DATA.current_level = SAVE_DATA.current_level + 1
        savefile_manager.persist_save_data()

        level_init()
    end
end
local function level_win_draw()
    local lvl_map_coords = map.level_to_map_coords(SAVE_DATA.current_level)

    local banner_x1 = lvl_map_coords.x * 8
    local banner_y1 = lvl_map_coords.y * 8 + 48

    local banner_x2 = banner_x1 + 128
    local banner_y2 = banner_y1 + 46

    rectfill(banner_x1, banner_y1, banner_x2, banner_y2, 7)
    print("good job!", banner_x1 + 10, banner_y1 + 10, 5)
    print("press ❎ to continue...", banner_x1 + 10, banner_y1 + 20, 5)
end

local function init()
    player.init()
    level_init()
end

local function update()
    if not level_win then
        player.update()
        arrow.update_all()
    else
        level_win_update()
    end
end

local function draw()
    cls(12)

    map.draw()
    player.draw()
    bullseye.draw()
    arrow.draw_all()
    if level_win then level_win_draw() end
end

return {init = init, update = update, draw = draw}
