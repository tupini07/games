local map = require("src/map")
local camera_utils = require("src/camera")
local graphics_utils = require("utils/graphics")

local player = require("entities/player")
local arrow = require("entities/arrow")
local bullseye = require("entities/bullseye")
local spring = require("entities/spring")
local spikes = require("entities/spikes")

local decorations = require("managers/decorations")
local savefile_manager = require("managers/savefile")
local particles = require("managers/particles")
local level_text = require("managers/level_text")

local banner_countdown = 10
local level_done = false

local show_win_banner = false
local show_lost_banner = false

PLAYER_ORIGINAL_POS_IN_LVL = {x = 0, y = 0}

local function level_reset()
    arrow.clear()
    PLAYER.x = PLAYER_ORIGINAL_POS_IN_LVL.x
    PLAYER.y = PLAYER_ORIGINAL_POS_IN_LVL.y
    player.reset_for_new_level()
    show_win_banner = false
    show_lost_banner = false
end

local function new_level_init()
    arrow.clear()
    banner_countdown = 10
    spring.init()
    spikes.init()
    decorations.init()
    map.replace_entities(SAVE_DATA.current_level)
    camera_utils.focus_section(SAVE_DATA.current_level)
    player.reset_for_new_level()
    show_win_banner = false
    show_lost_banner = false
end

local function finish_game()
    graphics_utils.fade_all_immediately()
    SWITCH_GAME_STATE(GAME_STATES_ENUM.end_game_state)
    level_done = false
    show_win_banner = false
    show_lost_banner = false
end

function WIN_LEVEL()
    level_done = true
    show_win_banner = true
end

function LOSE_LEVEL()
    level_done = true
    show_lost_banner = true
end

local level_change_coroutine_registered = false

local function level_done_update()
    if btnp(5) then
        if show_win_banner and SAVE_DATA.current_level == 23 then
            -- player has just completed last elevel
            finish_game()
        else
            if not level_change_coroutine_registered then
                level_change_coroutine_registered = true
                add(COROUTINES,
                    graphics_utils.execute_in_between_fades(nil, function()
                    if show_win_banner then
                        SAVE_DATA.current_level = SAVE_DATA.current_level + 1
                        -- go to new level
                        new_level_init()
                    elseif show_lost_banner then
                        level_reset()
                    end

                    savefile_manager.persist_save_data()
                end, function()
                    level_done = false
                    level_change_coroutine_registered = false
                    pal()
                end))
            end
        end
    end
end

local function level_win_draw()
    local lvl_cords = camera_utils.get_game_space_coords_for_current_lvl()

    local banner_x1 = lvl_cords.x
    local banner_y1 = lvl_cords.y + 48

    local banner_x2 = banner_x1 + 127
    local banner_y2 = banner_y1 + 46

    rectfill(banner_x1, banner_y1, banner_x2, banner_y2, 7)

    local line_x1 = banner_x1 + 3
    local line_y1 = banner_y1 + 3

    local line_x2 = banner_x2 - 3
    local line_y2 = banner_y2 - 3

    rect(line_x1, line_y1, line_x2, line_y2, 6)
    pset(line_x1 - 1, line_y1 - 1, 6)
    pset(line_x2 + 1, line_y1 - 1, 6)
    pset(line_x1 - 1, line_y2 + 1, 6)
    pset(line_x2 + 1, line_y2 + 1, 6)

    print("good job!\n", banner_x1 + 14, banner_y1 + 14, 5)
    print("press ❎ to continue", banner_x1 + 14, banner_y1 + 26, 5)
end

local function level_lost_draw()
    local lvl_cords = camera_utils.get_game_space_coords_for_current_lvl()

    local banner_x1 = lvl_cords.x
    local banner_y1 = lvl_cords.y + 48

    local banner_x2 = banner_x1 + 127
    local banner_y2 = banner_y1 + 46

    rectfill(banner_x1, banner_y1, banner_x2, banner_y2, 7)

    local line_x1 = banner_x1 + 3
    local line_y1 = banner_y1 + 3

    local line_x2 = banner_x2 - 3
    local line_y2 = banner_y2 - 3

    rect(line_x1, line_y1, line_x2, line_y2, 6)
    pset(line_x1 - 1, line_y1 - 1, 6)
    pset(line_x2 + 1, line_y1 - 1, 6)
    pset(line_x1 - 1, line_y2 + 1, 6)
    pset(line_x2 + 1, line_y2 + 1, 6)

    print("you died!\n", banner_x1 + 14, banner_y1 + 14, 8)
    print("press ❎ to try again", banner_x1 + 14, banner_y1 + 26, 5)
end

local function draw_current_lvl()
    local game_space = camera_utils.get_game_space_coords_for_current_lvl()

    local base_x = (game_space.x + 128) - 20
    local base_y = game_space.y + 1

    -- level indicator container
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
    decorations.update()
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
    map.draw_level_decorations()
    level_text.draw_current_level_text()
    bullseye.draw()
    arrow.draw_all()
    player.draw()
    map.draw()
    spring.draw()
    spikes.draw()
    decorations.draw_decorations()
    particles.draw()
    draw_current_lvl()

    if level_done and show_lost_banner then
        if banner_countdown > 0 then
            banner_countdown = banner_countdown - 1
        else
            level_lost_draw()
        end
    end
    if level_done and show_win_banner then
        if banner_countdown > 0 then
            banner_countdown = banner_countdown - 1
        else
            level_win_draw()
        end
    end
end

return {init = init, update = update, draw = draw}
