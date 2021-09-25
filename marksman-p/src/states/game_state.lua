local map = require("src/map")
local decorations = require("managers/decorations")
local camera_utils = require("src/camera")

local player = require("entities/player")
local arrow = require("entities/arrow")
local bullseye = require("entities/bullseye")
local spring = require("entities/spring")

local savefile_manager = require("managers/savefile")
local particles = require("managers/particles")
local graphics_utils = require("utils/graphics")

local level_win = false
local show_win_banner = false

local function level_init()
    spring.init()
    map.replace_entities(SAVE_DATA.current_level)
    camera_utils.focus_section(SAVE_DATA.current_level) -- need to move this to a level manager
    player.reset_for_new_level()
end

function WIN_LEVEL()
    level_win = true
    show_win_banner = true
end

function LOSE_LEVEL() end

local function level_change_fadeout_proc()
    local fader = 0
    while fader <= 16 do
        graphics_utils.fade(fader)
        fader = fader + 1
        yield()
    end

    -- setup new level
    show_win_banner = false
    SAVE_DATA.current_level = SAVE_DATA.current_level + 1
    savefile_manager.persist_save_data()

    level_init()

    while fader >= 0 do
        graphics_utils.fade(fader)
        fader = fader - 1
        yield()
    end

    level_win = false
    pal()
end

local level_change_coroutine = nil

local function level_win_update()
    local lvl_change_status
    if level_change_coroutine == nil then
        lvl_change_status = "dead"
    else
        lvl_change_status = costatus(level_change_coroutine)
    end

    if btnp(5) then
        if lvl_change_status == "running" then
            return
        elseif lvl_change_status == "dead" then
            level_change_coroutine = cocreate(level_change_fadeout_proc)
        end
    end

    if lvl_change_status == "suspended" then coresume(level_change_coroutine) end
end

local function level_win_draw()
    local lvl_cords = map.get_game_space_coords_for_current_lvl()

    local banner_x1 = lvl_cords.x
    local banner_y1 = lvl_cords.y + 48

    local banner_x2 = banner_x1 + 128
    local banner_y2 = banner_y1 + 46

    rectfill(banner_x1, banner_y1, banner_x2, banner_y2, 7)
    print("good job!", banner_x1 + 10, banner_y1 + 10, 5)
    print("press ❎ to continue...", banner_x1 + 10, banner_y1 + 20, 5)
end

local function init()
    particles.init()
    player.init()
    level_init()
end

local function update()
    particles.update()
    if not level_win then
        player.update()
        arrow.update_all()
        spring.update()
    else
        level_win_update()
    end
end

local function draw()
    cls(12)

    decorations.draw_background()
    map.draw()
    bullseye.draw()
    arrow.draw_all()
    player.draw()
    spring.draw()
    particles.draw()
    if level_win and show_win_banner then level_win_draw() end
end

return {init = init, update = update, draw = draw}
