local map = require("src/map")
local camera_utils = require("src/camera")
local graphics_utils = require("utils/graphics")
local print_utils = require("utils/print")

local player = require("entities/player")
local arrow = require("entities/arrow")
local bullseye = require("entities/bullseye")
local spring = require("entities/spring")
local spikes = require("entities/spikes")

local decorations = require("managers/decorations")
local savefile_manager = require("managers/savefile")
local particles = require("managers/particles")
local level_text = require("managers/level_text")

local level_done = false

local show_win_banner = false
local show_lost_banner = false

PLAYER_ORIGINAL_POS_IN_LVL = {x = 0, y = 0}

local function level_reset()
    ARROWS = {}
    PLAYER.x = PLAYER_ORIGINAL_POS_IN_LVL.x
    PLAYER.y = PLAYER_ORIGINAL_POS_IN_LVL.y
    player.reset_for_new_level()
end

local function new_level_init()
    spring.init()
    spikes.init()
    map.replace_entities(SAVE_DATA.current_level)
    camera_utils.focus_section(SAVE_DATA.current_level)
    player.reset_for_new_level()
end

function WIN_LEVEL()
    level_done = true
    show_win_banner = true
end

function LOSE_LEVEL()
    level_done = true
    show_lost_banner = true
end

local function level_change_fadeout_proc()
    local fader = 0
    while fader <= 16 do
        graphics_utils.fade(fader)
        fader = fader + 1
        yield()
    end

    -- setup new level
    if show_win_banner then
        SAVE_DATA.current_level = SAVE_DATA.current_level + 1
        new_level_init()
    elseif show_lost_banner then
        level_reset()
    end

    show_win_banner = false
    show_lost_banner = false

    savefile_manager.persist_save_data()

    while fader >= 0 do
        graphics_utils.fade(fader)
        fader = fader - 1
        yield()
    end

    level_done = false
    pal()
end

local level_change_coroutine = nil
local function get_lvl_change_coroutine_status()
    if level_change_coroutine == nil then
        return "dead"
    else
        return costatus(level_change_coroutine)
    end
end

local function level_done_update()
    local lvl_change_status = get_lvl_change_coroutine_status()

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

local function level_lost_draw()
    local lvl_cords = map.get_game_space_coords_for_current_lvl()

    local banner_x1 = lvl_cords.x
    local banner_y1 = lvl_cords.y + 48

    local banner_x2 = banner_x1 + 128
    local banner_y2 = banner_y1 + 46

    rectfill(banner_x1, banner_y1, banner_x2, banner_y2, 7)
    print("you died!", banner_x1 + 10, banner_y1 + 10, 5)
    print("press ❎ to try again", banner_x1 + 10, banner_y1 + 20, 5)
end

local function draw_current_lvl()
    local game_space = map.get_game_space_coords_for_current_lvl()

    local base_x = (game_space.x + 128) - 20
    local base_y = game_space.y + 1

    sspr(88, 0, 16, 8, base_x, base_y, 19, 13)
    local pos = base_x + 3 * (4 - #("" .. SAVE_DATA.current_level))

    print(SAVE_DATA.current_level, pos, base_y + 4, 5)
end

local function init()
    particles.init()
    player.init()
    new_level_init()
end

local function update()
    particles.update()
    if not level_done then
        player.update()
        arrow.update_all()
        spring.update()
    else
        level_done_update()
    end
end

local function draw()
    cls(12)

    decorations.draw_background()
    map.draw_level_text()
    level_text.draw_current_level_text()
    bullseye.draw()
    arrow.draw_all()
    player.draw()
    map.draw()
    spring.draw()
    spikes.draw()
    particles.draw()
    draw_current_lvl()

    if level_done and show_lost_banner then level_lost_draw() end
    if level_done and show_win_banner then level_win_draw() end
end

return {init = init, update = update, draw = draw}
