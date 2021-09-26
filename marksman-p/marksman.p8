pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
package={loaded={},_c={}}
package._c["managers/savefile"]=function()
SAVE_DATA = {current_level = 1}

local save_data_points = {current_level = 1}

local function load_save_data()
    SAVE_DATA.current_level = dget(save_data_points.current_level)
end

return {
    init = function()
        cartdata("dadum_marksman")
        load_save_data()
    end,
    load_save_data = load_save_data,
    persist_save_data = function()
        dset(save_data_points.current_level, SAVE_DATA.current_level)
    end
}
end
package._c["managers/state"]=function()
local game_state = require("states/game_state")
local intro_state = require("states/intro_state")

GAME_STATE = {}
GAME_STATES_ENUM = {intro_state = 1, gameplay_state = 2}

function SWITCH_GAME_STATE(new_state)
    if new_state ~= GAME_STATE.current_state then
        GAME_STATE.current_state = new_state
        if new_state == GAME_STATES_ENUM.intro_state then
            intro_state.init()
        elseif new_state == GAME_STATES_ENUM.gameplay_state then
            game_state.init()
        end
    end
end

local function act_for_current_state(act_map)
    local act_to_perform = act_map[GAME_STATE.current_state]
    act_to_perform()
end

return {
    GAME_STATES_ENUM = GAME_STATES_ENUM,
    SWITCH_GAME_STATE = SWITCH_GAME_STATE,
    init = function() SWITCH_GAME_STATE(GAME_STATES_ENUM.intro_state) end,
    update = function()
        act_for_current_state({
            [GAME_STATES_ENUM.intro_state] = intro_state.update,
            [GAME_STATES_ENUM.gameplay_state] = game_state.update
        })
    end,
    draw = function()
        act_for_current_state({
            [GAME_STATES_ENUM.intro_state] = intro_state.draw,
            [GAME_STATES_ENUM.gameplay_state] = game_state.draw
        })
    end
}
end
package._c["states/game_state"]=function()
local map = require("src/map")
local camera_utils = require("src/camera")
local graphics_utils = require("utils/graphics")

local player = require("entities/player")
local arrow = require("entities/arrow")
local bullseye = require("entities/bullseye")
local spring = require("entities/spring")

local decorations = require("managers/decorations")
local savefile_manager = require("managers/savefile")
local particles = require("managers/particles")
local level_text = require("managers/level_text")

local debug = require("utils/debug")


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
    level_text.draw_current_level_text()
    bullseye.draw()
    arrow.draw_all()
    player.draw()
    spring.draw()
    particles.draw()
    if level_win and show_win_banner then level_win_draw() end
    debug.track_mouse_coordinates()

end

return {init = init, update = update, draw = draw}
end
package._c["src/map"]=function()
local sprite_flags = {solid = 0, bullseye = 1}

local bullseye = require("entities/bullseye")
local spring = require("entities/spring")

--- @return Vector
local function level_to_map_coords(level_num)
    -- first we get 0 indexed coordinates for the "block" which 
    -- is the level

    -- 16 levels per row in map editor
    local map_row = flr(level_num / 16)

    --  8 levels per column in map editor
    local map_column = (level_num % 16) - 1

    return {x = map_column * 16, y = map_row * 16}
end

--- @return Vector
local function get_game_space_coords_for_current_lvl()
    local lvl_map_coords = level_to_map_coords(SAVE_DATA.current_level)

    return {x = lvl_map_coords.x * 8, y = lvl_map_coords.y * 8}
end

local map = {
    draw = function()
        -- TODO use level_to_map_coords for more efficient drawing
        map(0, 0, 0, 0, 128, 64)
    end,
    sprite_flags = sprite_flags,
    cell_has_flag = function(flag, x, y) return fget(mget(x, y), flag) end,
    level_to_map_coords = level_to_map_coords,
    get_game_space_coords_for_current_lvl = get_game_space_coords_for_current_lvl,
    replace_entities = function(current_level)
        local level_block_coords = level_to_map_coords(current_level)

        local level_x2 = level_block_coords.x + 16
        local level_y2 = level_block_coords.y + 16

        for x = level_block_coords.x, level_x2 do
            for y = level_block_coords.y, level_y2 do
                local sprt = mget(x, y)
                if sprt == 3 then
                    mset(x, y, 0)
                    PLAYER.x = x * 8
                    PLAYER.y = y * 8
                end

                if sprt == 57 then
                    bullseye.replace_in_map(x, y, bullseye.orientation.left)
                elseif sprt == 58 then
                    bullseye.replace_in_map(x, y, bullseye.orientation.right)
                end

                if sprt == 37 then
                    spring.replace_in_map(x, y, spring.orientations.top)
                elseif sprt == 40 then
                    spring.replace_in_map(x, y, spring.orientations.right)
                elseif sprt == 43 then
                    spring.replace_in_map(x, y, spring.orientations.bottom)
                elseif sprt == 44 then
                    spring.replace_in_map(x, y, spring.orientations.left)
                end
            end
        end
    end
}

return map
end
package._c["entities/bullseye"]=function()
--- @type Bullseye
BULLSEYE = {
    x = 0,
    y = 0,
    orientation = 1,
    sprite_x = 0,
    sprite_y = 0,
    hitbox_x = 0,
    hitbox_y = 0,
    hitbox_h = 0,
    hitbox_w = 0
}

local orientations = {left = 1, right = 2}

return {
    orientation = orientations,
    replace_in_map = function(mapx, mapy, type)
        mset(mapx, mapy, 0)
        mset(mapx + 1, mapy, 0)
        mset(mapx, mapy + 1, 0)
        mset(mapx + 1, mapy + 1, 0)

        BULLSEYE.x = mapx * 8
        BULLSEYE.y = mapy * 8

        BULLSEYE.orientation = type
        if type == orientations.left or type == orientations.right then
            BULLSEYE.sprite_x = 40
            BULLSEYE.sprite_y = 0

            BULLSEYE.hitbox_w = 6
            BULLSEYE.hitbox_h = 6
        end

        if type == orientations.left then
            BULLSEYE.hitbox_x = BULLSEYE.x + 6
            BULLSEYE.hitbox_y = BULLSEYE.y + 7

        elseif type == orientations.right then
            BULLSEYE.hitbox_x = BULLSEYE.x + 4
            BULLSEYE.hitbox_y = BULLSEYE.y + 7
        end
    end,

    draw = function()
        sspr(BULLSEYE.sprite_x, BULLSEYE.sprite_y, 16, 16, BULLSEYE.x,
             BULLSEYE.y, 16, 16, BULLSEYE.orientation == orientations.right)
    end
}
end
package._c["entities/spring"]=function()
local physics_utils = require("utils/physics")

--- @type Spring[]
SPRINGS = {}

local orientations = {left = 1, right = 2, top = 3, bottom = 4}

local function replace_in_map(mapx, mapy, orientation)
    --- @type BoxCollider
    local collider

    if orientation == orientations.top then
        collider = {x = 0, y = 4, h = 4, w = 8}
    elseif orientation == orientations.bottom then
        collider = {x = 0, y = 0, h = 4, w = 8}
    elseif orientation == orientations.left then
        collider = {x = 4, y = 0, h = 8, w = 4}
    elseif orientation == orientations.right then
        collider = {x = 0, y = 0, h = 8, w = 4}
    end

    mset(mapx, mapy, 0)
    add(SPRINGS, {
        x = mapx * 8,
        y = mapy * 8,
        state = 0,
        orientation = orientation,
        collider = collider
    })
end

--- @param s Spring
local function draw_spring(s)
    local base_sprite
    local flip_v = false
    local flip_h = false
    if s.orientation == orientations.top then
        base_sprite = 37
    elseif s.orientation == orientations.bottom then
        base_sprite = 37
        flip_v = true
    elseif s.orientation == orientations.right then
        base_sprite = 40
    elseif s.orientation == orientations.left then
        base_sprite = 40
        flip_h = true
    end

    spr(base_sprite + s.state, s.x, s.y, 1, 1, flip_h, flip_v)
end

--- @param s Spring
local function update_spring(s)
    if s.state > 0 and GLOBAL_TIMER % 3 == 0 then s.state = s.state - 1 end
end

--- if body is colliding with spring then spring it!
--- @param body BoxPhysicsBody
--- @return boolean if the body was springed or not
local function try_spring_body(body)
    for s in all(SPRINGS) do
        local is_colliding = physics_utils.box_collision(
                                 physics_utils.resolve_box_body_collider(s),
                                 physics_utils.resolve_box_body_collider(body))

        if is_colliding then
            s.state = 2
            if s.orientation == orientations.top then
                body.dy = -3
            elseif s.orientation == orientations.bottom then
                body.dy = 3
            elseif s.orientation == orientations.left then
                body.dx = -3
            elseif s.orientation == orientations.right then
                body.dx = 3
            end
            return
        end
    end
end

return {
    orientations = orientations,
    replace_in_map = replace_in_map,
    try_spring_body = try_spring_body,
    init = function() SPRINGS = {} end,
    draw = function() foreach(SPRINGS, draw_spring) end,
    update = function() foreach(SPRINGS, update_spring) end
}
end
package._c["utils/physics"]=function()
return {
    --- @param point Vector
    --- @param box_top_left Vector 
    point_in_box = function(point, box_top_left, box_h, box_w)
        local bx1 = box_top_left.x + box_w
        local by1 = box_top_left.y + box_h
        return
            box_top_left.x <= point.x and point.x <= bx1 and box_top_left.y <=
                point.y and point.y <= by1
    end,
    --- @param box_body BoxPhysicsBody
    --- @return BoxCollider
    resolve_box_body_collider = function(box_body)
        return {
            x = box_body.x + box_body.collider.x,
            y = box_body.y + box_body.collider.y,
            w = box_body.collider.w,
            h = box_body.collider.h
        }
    end,
    --- @param collider_1 BoxCollider
    --- @param collider_2 BoxCollider
    box_collision = function(collider_1, collider_2)
        return collider_1.x < collider_2.x + collider_2.w and collider_2.x <
                   collider_1.x + collider_1.w and collider_1.y < collider_2.y +
                   collider_2.h and collider_2.y < collider_1.y + collider_1.h
    end
}
end
package._c["src/camera"]=function()
local map = require("src/map")

return {
    camera_center = function(x, y, map_tiles_width, map_tiles_height)
        local cam_x = x - 60
        local cam_y = y - 60

        cam_x = mid(0, cam_x, map_tiles_width * 8 - 127)
        cam_y = mid(0, cam_y, map_tiles_height * 8 - 127)

        camera(cam_x, cam_y)
    end,
    focus_section = function(current_level)
        local lvl_cords = map.get_game_space_coords_for_current_lvl()

        camera(lvl_cords.x, lvl_cords.y)
    end
}
end
package._c["utils/graphics"]=function()
-- Node: this table was generated from http://kometbomb.net/pico8/fadegen.html
local fadeTable = {
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {1, 1, 129, 129, 129, 129, 129, 129, 129, 129, 0, 0, 0, 0, 0},
    {2, 2, 2, 130, 130, 130, 130, 130, 128, 128, 128, 128, 128, 0, 0},
    {3, 3, 3, 131, 131, 131, 131, 129, 129, 129, 129, 129, 0, 0, 0},
    {4, 4, 132, 132, 132, 132, 132, 132, 130, 128, 128, 128, 128, 0, 0},
    {5, 5, 133, 133, 133, 133, 130, 130, 128, 128, 128, 128, 128, 0, 0},
    {6, 6, 134, 13, 13, 13, 141, 5, 5, 5, 133, 130, 128, 128, 0},
    {7, 6, 6, 6, 134, 134, 134, 134, 5, 5, 5, 133, 130, 128, 0},
    {8, 8, 136, 136, 136, 136, 132, 132, 132, 130, 128, 128, 128, 128, 0},
    {9, 9, 9, 4, 4, 4, 4, 132, 132, 132, 128, 128, 128, 128, 0},
    {10, 10, 138, 138, 138, 4, 4, 4, 132, 132, 133, 128, 128, 128, 0},
    {11, 139, 139, 139, 139, 3, 3, 3, 3, 129, 129, 129, 0, 0, 0},
    {12, 12, 12, 140, 140, 140, 140, 131, 131, 131, 1, 129, 129, 129, 0},
    {13, 13, 141, 141, 5, 5, 5, 133, 133, 130, 129, 129, 128, 128, 0},
    {14, 14, 14, 134, 134, 141, 141, 2, 2, 133, 130, 130, 128, 128, 0},
    {15, 143, 143, 134, 134, 134, 134, 5, 5, 5, 133, 133, 128, 128, 0}
}

local function fade(i)
    for c = 0, 15 do
        if flr(i + 1) >= 16 then
            pal(c, 0, 1)
        else
            pal(c, fadeTable[c + 1][flr(i + 1)], 1)
        end
    end
end

return {fade = fade}
end
package._c["entities/player"]=function()
local math = require("utils/math")
local map = require("src/map")
local bow = require("entities/bow")
local spring = require("entities/spring")

local particles = require("managers/particles")

PLAYER = {
    x = 0,
    y = 0,
    dx = 0,
    dy = 0,
    ddy = 0.12,
    dir = 1,
    collider = {x = 0, y = 0, w = 8, h = 16},
    is_jumping = false,
    changing_bow_dir = false
}

local function move_player()
    local jumping_mod = 0.55
    if not PLAYER.is_jumping then jumping_mod = 1 end
    if not PLAYER.changing_bow_dir then
        if btn(0) then
            PLAYER.dx = PLAYER.dx - 1 * jumping_mod
        elseif btn(1) then
            PLAYER.dx = PLAYER.dx + 1 * jumping_mod
        end

        if btnp(2) and not PLAYER.is_jumping then PLAYER.dy = -2 end
    end

    -- cap deltas
    PLAYER.dx = math.cap_with_sign(PLAYER.dx, 0, 3)
    PLAYER.dy = math.cap_with_sign(PLAYER.dy, 0, 3)

    -- apply velocity
    PLAYER.x = PLAYER.x + PLAYER.dx
    PLAYER.y = PLAYER.y + PLAYER.dy

    -- apply gravity
    PLAYER.dy = PLAYER.dy + PLAYER.ddy

    -- apply friction
    PLAYER.dx = PLAYER.dx * 0.6
    if abs(PLAYER.dx) < 0.1 then PLAYER.dx = 0 end
end

local function check_floor()
    local bottom_x = flr((PLAYER.x + 4) / 8)
    local bottom_y = flr((PLAYER.y + 16) / 8)

    local is_bottom_floor = map.cell_has_flag(map.sprite_flags.solid, bottom_x,
                                              bottom_y)

    if is_bottom_floor then
        if PLAYER.is_jumping then
            -- we're landing
            for _ = 1, 5 do
                local displacement = rnd(4) - 4
                particles.make_particle(PLAYER.x + 4 + displacement,
                                        PLAYER.y + 16, -PLAYER.dx * 0.1,
                                        -PLAYER.dy * 0.1, 0, 1, 7, 7)
            end

        end

        PLAYER.is_jumping = false
        PLAYER.y = (bottom_y - 2) * 8
        PLAYER.dy = 0
    else
        PLAYER.is_jumping = true
    end
end

local function check_walls()
    -- check that top-{movement-dir} and bottom-{movement-dir} corners
    -- are not colliding
    local pl_top_left = {x = PLAYER.x, y = PLAYER.y + 4}
    local pl_top_right = {x = PLAYER.x + 8, y = PLAYER.y + 4}
    local pl_btm_left = {x = PLAYER.x, y = PLAYER.y + 12}
    local pl_btm_right = {x = PLAYER.x + 8, y = PLAYER.y + 12}

    for corner in all({pl_top_left, pl_top_right, pl_btm_left, pl_btm_right}) do
        local map_x = flr(corner.x / 8)
        local map_y = flr(corner.y / 8)

        local is_colliding = map.cell_has_flag(map.sprite_flags.solid, map_x,
                                               map_y)

        if is_colliding then
            PLAYER.dx = 0
            local is_facing_left = sgn(PLAYER.x - corner.x)
            local pixel_space_x = (map_x + is_facing_left) * 8
            PLAYER.x = pixel_space_x
            return
        end
    end
end

local function change_bow_direction()
    if btn(4) then
        PLAYER.changing_bow_dir = true
        local left = btn(0)
        local right = btn(1)
        local up = btn(2)
        local down = btn(3)

        -- first check corners
        -- see bow.lua for map of directions
        if up and left then
            PLAYER.dir = -1
            bow.change_dir(4)
        elseif up and right then
            PLAYER.dir = 1
            bow.change_dir(2)
        elseif down and left then
            PLAYER.dir = -1
            bow.change_dir(6)
        elseif down and right then
            PLAYER.dir = 1
            bow.change_dir(8)
        elseif up then
            PLAYER.dir = 1
            bow.change_dir(3)
        elseif right then
            PLAYER.dir = 1
            bow.change_dir(1)
        elseif down then
            PLAYER.dir = 1
            bow.change_dir(7)
        elseif left then
            PLAYER.dir = -1
            bow.change_dir(5)
        end
    else
        PLAYER.changing_bow_dir = false
    end
end

local function draw_player()
    local flip_x = PLAYER.dir == -1

    function draw_pl_sprite(sprt_x)
        sspr(sprt_x, 0, 8, 16, PLAYER.x, PLAYER.y, 8, 16, flip_x)
    end

    if PLAYER.is_jumping then
        draw_pl_sprite(80)
    elseif PLAYER.dx == 0 then
        -- idle
        draw_pl_sprite(56)
    else
        if GLOBAL_TIMER % 8 == 0 then
            draw_pl_sprite(64)
        else
            draw_pl_sprite(72)
        end
    end
end

return {
    init = function()
        -- player = {x = 5 * 8, y = 11 * 8} 
        bow.init()
    end,
    reset_for_new_level = function()
        PLAYER.dir = 1
        bow.change_dir(7)
    end,
    update = function()
        change_bow_direction()
        move_player()
        check_floor()
        check_walls()
        spring.try_spring_body(PLAYER)

        bow.update()
    end,
    draw = function()
        draw_player()
        bow.draw()
    end
}

end
package._c["utils/math"]=function()
local math = {
    cap_with_sign = function(number, low, high)
        return sgn(number) * mid(low, abs(number), high)
    end,
    vector_distance = function(vec1, vec2)
        return sqrt((vec2.x - vec1.x) ^ 2 + (vec2.y - vec1.y) ^ 2)
    end,
    vector_magnitude = function(vec) return sqrt((vec.x) ^ 2 + (vec.y) ^ 2) end,
    get_nearest = function(num, ...)
        local options = {...}
        local nearest = options[1]
        local nearest_difference = abs(num - options[1])

        for opt in all(options) do
            local opt_difference = abs(num - opt)
            if opt_difference < nearest_difference then
                nearest = opt
                nearest_difference = opt_difference
            end
        end

        return nearest
    end
}

return math
end
package._c["entities/bow"]=function()
local arrows = require("entities/arrow")

--[[
directions:
  4   3   2
  5  bow  1
  6   7   8
--]]

BOW = {x = 0, y = 0, dir = 1}

local function fire_arrow()
    local arrow_dir = (BOW.dir - 1) / 8
    -- 0.25 is up 
    -- 0.75 is down
    if btnp(5) then arrows.fire_arrow(BOW.x, BOW.y, 5, arrow_dir) end
end

return {
    change_dir = function(dir) BOW.dir = dir end,
    init = function()
        BOW.x = PLAYER.x
        BOW.y = PLAYER.y + 4
    end,
    update = function()
        BOW.x = PLAYER.x
        BOW.y = PLAYER.y + 4

        fire_arrow()
    end,
    draw = function()
        local srpn = 19
        if BOW.dir == 1 or BOW.dir == 5 then
            srpn = 19
        elseif BOW.dir == 3 or BOW.dir == 7 then
            srpn = 18
        else
            srpn = 20
        end

        local flip_x = BOW.dir == 4 or BOW.dir == 5 or BOW.dir == 6
        local flip_y = BOW.dir == 6 or BOW.dir == 7 or BOW.dir == 8

        spr(srpn, BOW.x, BOW.y, 1, 1, flip_x, flip_y)
    end
}
end
package._c["entities/arrow"]=function()
local math = require("utils/math")
local map = require("src/map")
local spring = require("entities/spring")

local particles = require("managers/particles")

--- @type Arrow[]
ARROWS = {}

local function fire_arrow(x, y, force, angle)
    local dx = cos(angle) * force
    local dy = sin(angle) * force

    --- @type BoxCollider
    local collider = {x = 0, y = 0, h = 0, w = 0}

    --- @type Arrow
    local a = {
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        lifetime = 60,
        is_stuck = false,
        collider = collider
    }

    add(ARROWS, a)
end

--- @param a Arrow
local function get_clamped_arrow_dir(a)
    local angle = atan2(a.dx, a.dy)

    -- see quadrant in bow.lua
    local segment = math.get_nearest(angle, 1, 0.11, 0.25, 0.38, 0.5, 0.63,
                                     0.75, 0.86)
    local directions_map = {
        [1] = 1,
        [0.11] = 2,
        [0.25] = 3,
        [0.38] = 4,
        [0.5] = 5,
        [0.63] = 6,
        [0.75] = 7,
        [0.86] = 8
    }

    return directions_map[segment]
end

--- @param a Arrow
--- @return Vector
local function get_collision_vec(a)
    local arrow_dir = get_clamped_arrow_dir(a)

    local collision_x
    local collision_y

    if arrow_dir == 1 then
        collision_x = a.x + 5
        collision_y = a.y + 4
    elseif arrow_dir == 2 then
        collision_x = a.x + 5
        collision_y = a.y + 3
    elseif arrow_dir == 3 then
        collision_x = a.x + 4
        collision_y = a.y + 3
    elseif arrow_dir == 4 then
        collision_x = a.x + 3
        collision_y = a.y + 3
    elseif arrow_dir == 5 then
        collision_x = a.x + 3
        collision_y = a.y + 4
    elseif arrow_dir == 6 then
        collision_x = a.x + 3
        collision_y = a.y + 5
    elseif arrow_dir == 7 then
        collision_x = a.x + 4
        collision_y = a.y + 5
    elseif arrow_dir == 8 then
        collision_x = a.x + 5
        collision_y = a.y + 5
    end

    return {x = collision_x, y = collision_y}
end

--- @param a Arrow
local function make_floor_walls_colission_dust(a)
    local cv = get_collision_vec(a)
    for _ = 1, 5 do
        local displacement = rnd(4) - 4
        particles.make_particle(cv.x + displacement, cv.y + displacement,
                                -a.dx * 0.1, -a.dy * 0.1, 0, 1, rnd({5, 6, 7}),
                                7)
    end
end

--- Gets the direction of the arrow clamped to one of the 8 cardinal directions
--- @param a Arrow
local function collide_with_floor_walls(a)
    -- we want to check if the 1/3 nearest to the sprite limit in the direction in which
    -- the arrow is moving, is colliding with a wall or floor (a collidable sprite). If yes
    -- then stop arrow
    local collision_vec = get_collision_vec(a)

    local is_colliding_with_solid = map.cell_has_flag(map.sprite_flags.solid,
                                                      flr(collision_vec.x / 8),
                                                      flr(collision_vec.y / 8))

    -- if collision point lies in a "solid" map tile then stop movement
    if is_colliding_with_solid then
        local angle = atan2(a.dx, a.dy)
        a.x = a.x - cos(angle) * 3
        a.y = a.y - sin(angle) * 3

        a.is_stuck = true
        make_floor_walls_colission_dust(a)
    end
end

--- @param a Arrow
local function make_bullseye_colission_dust(a)
    local cv = get_collision_vec(a)
    for _ = 1, 8 do
        local displacement = rnd(4) - 4
        particles.make_particle(cv.x + displacement, cv.y + displacement,
                                -a.dx * 0.1, -a.dy * 0.1, 0, 1,
                                rnd({7, 10, 11}), 7)
    end
end

--- @param a Arrow
local function collide_with_bullseye(a)
    -- if collission_vec is inside the bullseye hitbox then we have a collission
    local collision_vec = get_collision_vec(a)

    local bullseye_hitbox_x2 = BULLSEYE.hitbox_x + BULLSEYE.hitbox_w
    local bullseye_hitbox_y2 = BULLSEYE.hitbox_y + BULLSEYE.hitbox_h

    if collision_vec.x >= BULLSEYE.hitbox_x and collision_vec.x <=
        bullseye_hitbox_x2 and collision_vec.y >= BULLSEYE.hitbox_y and
        collision_vec.y <= bullseye_hitbox_y2 then
        a.is_stuck = true
        make_bullseye_colission_dust(a)
        WIN_LEVEL()
    end
end

--- @param a Arrow
local function update_collider(a)
    local arrow_dir = get_clamped_arrow_dir(a)
    if arrow_dir == 1 then
        a.collider = {x = 6, y = 3, w = 2, h = 3}
    elseif arrow_dir == 2 then
        a.collider = {x = 4, y = 1, w = 3, h = 3}
    elseif arrow_dir == 3 then
        a.collider = {x = 3, y = 0, w = 3, h = 2}
    elseif arrow_dir == 4 then
        a.collider = {x = 1, y = 1, w = 3, h = 3}
    elseif arrow_dir == 5 then
        a.collider = {x = 0, y = 3, w = 2, h = 3}
    elseif arrow_dir == 6 then
        a.collider = {x = 1, y = 4, w = 3, h = 3}
    elseif arrow_dir == 7 then
        a.collider = {x = 3, y = 6, w = 3, h = 2}
    elseif arrow_dir == 8 then
        a.collider = {x = 4, y = 4, w = 3, h = 3}
    end
end

local function make_trail(a)
    if rnd(1) < 0.8 then return end
    local collision_vec = get_collision_vec(a)
    local diffx = (collision_vec.x - a.x)
    local diffy = (collision_vec.y - a.y)

    local colors = {7, 8, 9}
    particles.make_pixel_particle(a.x + diffy, a.y + diffx, 0, 0, 0.01,
                                  rnd(colors), 7)
end

--- @param a Arrow
local function update_arrow(a)
    if a.lifetime == 0 then
        del(ARROWS, a)
        return
    else
        a.lifetime = a.lifetime - 1
    end

    if a.is_stuck then return end

    a.y = a.y + a.dy
    a.x = a.x + a.dx

    -- apply gravity
    a.dy = a.dy + 0.12

    update_collider(a)
    collide_with_floor_walls(a)
    collide_with_bullseye(a)
    make_trail(a)
    spring.try_spring_body(a)
end

--- @param a Arrow
local function draw_arrow(a)
    local arrow_dir = get_clamped_arrow_dir(a)

    local sprtn

    if arrow_dir == 1 or arrow_dir == 5 then
        sprtn = 35
    elseif arrow_dir == 3 or arrow_dir == 7 then
        sprtn = 34
    else
        sprtn = 36
    end

    local flip_x = arrow_dir == 4 or arrow_dir == 5 or arrow_dir == 6
    local flip_y = arrow_dir == 6 or arrow_dir == 7 or arrow_dir == 8

    spr(sprtn, a.x, a.y, 1, 1, flip_x, flip_y)
end

return {
    update_all = function() foreach(ARROWS, update_arrow) end,
    draw_all = function() foreach(ARROWS, draw_arrow) end,
    fire_arrow = fire_arrow
}
end
package._c["managers/particles"]=function()
PARTICLES = {}

local function make_circle_particle(x, y, dx, dy, dyy, size, c, lifetime)
    local p = {
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        dyy = dyy,
        c = c,
        size = size,
        lifetime = lifetime
    }

    function p:update()
        if self.lifetime == 0 then del(PARTICLES, self) end
        self.lifetime = self.lifetime - 1

        self.x = self.x + self.dx
        self.y = self.y + self.dy
        self.dy = self.dy + self.dyy
    end

    function p:draw() circfill(self.x, self.y, self.size, self.c) end

    add(PARTICLES, p)
end

local function make_pixel_particle(x, y, dx, dy, dyy, c, lifetime)
    local p = {
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        dyy = dyy,
        c = c,
        size = size,
        lifetime = lifetime
    }

    function p:update()
        if self.lifetime == 0 then del(PARTICLES, self) end
        self.lifetime = self.lifetime - 1

        self.x = self.x + self.dx
        self.y = self.y + self.dy
        self.dy = self.dy + self.dyy
    end

    function p:draw() pset(self.x, self.y, self.c) end

    add(PARTICLES, p)
end

return {
    make_pixel_particle = make_pixel_particle,
    make_particle = make_circle_particle,
    init = function() PARTICLES = {} end,
    update = function() for p in all(PARTICLES) do p:update() end end,
    draw = function() for p in all(PARTICLES) do p:draw() end end
}
end
package._c["managers/decorations"]=function()
local map = require("map")

local types = {cloud1 = 1, cloud2 = 2}

local function replace_in_map() end

local function draw_background()
    local lvl_cords = map.get_game_space_coords_for_current_lvl()

    sspr(0, 80, 31, 31, lvl_cords.x + 8, lvl_cords.y + 8, 112, 112)
end

return {
    draw_background = draw_background,
    replace_in_map = replace_in_map,
    types = types
}
end
package._c["map"]=function()
local sprite_flags = {solid = 0, bullseye = 1}

local bullseye = require("entities/bullseye")
local spring = require("entities/spring")

--- @return Vector
local function level_to_map_coords(level_num)
    -- first we get 0 indexed coordinates for the "block" which 
    -- is the level

    -- 16 levels per row in map editor
    local map_row = flr(level_num / 16)

    --  8 levels per column in map editor
    local map_column = (level_num % 16) - 1

    return {x = map_column * 16, y = map_row * 16}
end

--- @return Vector
local function get_game_space_coords_for_current_lvl()
    local lvl_map_coords = level_to_map_coords(SAVE_DATA.current_level)

    return {x = lvl_map_coords.x * 8, y = lvl_map_coords.y * 8}
end

local map = {
    draw = function()
        -- TODO use level_to_map_coords for more efficient drawing
        map(0, 0, 0, 0, 128, 64)
    end,
    sprite_flags = sprite_flags,
    cell_has_flag = function(flag, x, y) return fget(mget(x, y), flag) end,
    level_to_map_coords = level_to_map_coords,
    get_game_space_coords_for_current_lvl = get_game_space_coords_for_current_lvl,
    replace_entities = function(current_level)
        local level_block_coords = level_to_map_coords(current_level)

        local level_x2 = level_block_coords.x + 16
        local level_y2 = level_block_coords.y + 16

        for x = level_block_coords.x, level_x2 do
            for y = level_block_coords.y, level_y2 do
                local sprt = mget(x, y)
                if sprt == 3 then
                    mset(x, y, 0)
                    PLAYER.x = x * 8
                    PLAYER.y = y * 8
                end

                if sprt == 57 then
                    bullseye.replace_in_map(x, y, bullseye.orientation.left)
                elseif sprt == 58 then
                    bullseye.replace_in_map(x, y, bullseye.orientation.right)
                end

                if sprt == 37 then
                    spring.replace_in_map(x, y, spring.orientations.top)
                elseif sprt == 40 then
                    spring.replace_in_map(x, y, spring.orientations.right)
                elseif sprt == 43 then
                    spring.replace_in_map(x, y, spring.orientations.bottom)
                elseif sprt == 44 then
                    spring.replace_in_map(x, y, spring.orientations.left)
                end
            end
        end
    end
}

return map
end
package._c["managers/level_text"]=function()
return {
    draw_current_level_text = function()
        if SAVE_DATA.current_level == 1 then
            print("move with ⬅️➡️⬇️⬆️", 13, 93, 5)
            print("fire arrows with ❎")
            print("while pressing 🅾️ use\narrows to aim")
        end

    end
}
end
package._c["utils/debug"]=function()
local print_utils = require("utils/print")

return {
    log = function(msg) printh(msg, "game_log") end,
    assert = function(condition, msg) assert(condition, msg) end,
    track_mouse_coordinates = function()
        poke(0x5F2D, 1)
        local mousex = mid(0, stat(32), 127)
        local mousey = mid(0, stat(33), 127)

        line(0, mousey, mousex, mousey, 11)
        line(mousex, 0, mousex, mousey, 11)
        pset(mousex, mousey, 7)

        local coords_text = "x:" .. mousex .. " y:" .. mousey
        local txt_pixel_len = print_utils.get_length_of_text(coords_text)

        local px = mid(0, mousex, 127 - txt_pixel_len)
        local py = mid(0, mousey, 127 - 4)

        print(coords_text, px + 1, py + 1, 0)
        print(coords_text, px, py, 11)
    end
}
end
package._c["utils/print"]=function()
local function get_length_of_text(text) return #text * 4 end

local function print_centered_with_backdrop(text, y, text_color, backdrop_color)
    if text_color == nil then text_color = 7 end
    if backdrop_color == nil then backdrop_color = 0 end

    local text_x = 64 - get_length_of_text(text) / 2

    print(text, text_x + 1, y + 1, backdrop_color)
    print(text, text_x, y, text_color)
end

local menu_item_bobbing = false

return {
    get_length_of_text = get_length_of_text,
    print_centered = function(text, y, color)
        if color == nil then color = 7 end
        local text_x = 64 - get_length_of_text(text) / 2
        print(text, text_x, y, color)
    end,
    print_menu_item = function(text, y, is_selected)
        print_centered_with_backdrop(text, y)
        if is_selected then
            local selector_x = (64 - get_length_of_text(text) / 2) - 10

            local extra_spacing = 0
            if GLOBAL_TIMER % 23 == 0 then
                menu_item_bobbing = not menu_item_bobbing
            end

            if menu_item_bobbing then selector_x = selector_x - 1 end

            sspr(65, 25, 7, 6, selector_x, y)
        end
    end,
    print_centered_with_backdrop = print_centered_with_backdrop
}
end
package._c["states/intro_state"]=function()
local print_utils = require("utils/print")
local savefile = require("managers/savefile")

local menu = {}

local function init()
    local is_there_progress = SAVE_DATA.current_level ~= 1

    if is_there_progress then
        add(menu, {
            text = "continue (" .. SAVE_DATA.current_level .. ")",
            action = "continue",
            is_selected = false
        })
    end

    add(menu, {text = "new game", action = "new_game", is_selected = false})

    menu[1].is_selected = true
end

local function show_todo()
    rectfill(10, 32, 117, 120, 7)
    color(0)
    print("\ntodo:", 12, 34)
    print("- nicer win panel")
    print("- sfx")
    print("- music?")
    print("- more levels")
    print("- apply clipping to arrows")
end

local function draw_menu()
    local starting_y = 42
    for menu_item in all(menu) do
        print_utils.print_menu_item(menu_item.text, starting_y,
                                    menu_item.is_selected)
        starting_y = starting_y + 7
    end
end

local function get_selected_menu_item()
    for item in all(menu) do if item.is_selected then return item end end
end

local function update_menu()
    if btnp(2) then
        for i, item in ipairs(menu) do
            if item.is_selected then
                item.is_selected = false
                local top_i = i - 1
                if top_i <= 0 then
                    menu[#menu].is_selected = true
                else
                    menu[top_i].is_selected = true
                end
                break
            end
        end
    elseif btnp(3) then
        for i, item in ipairs(menu) do
            if item.is_selected then
                item.is_selected = false
                local bottom_i = i + 1
                if bottom_i > #menu then
                    menu[1].is_selected = true
                else
                    menu[bottom_i].is_selected = true
                end
                break
            end
        end
    end

    if btnp(5) then
        local selected_item = get_selected_menu_item()
        if selected_item.action == "continue" then
            -- waste tokens
        elseif selected_item.action == "new_game" then
            SAVE_DATA.current_level = 1
            savefile.persist_save_data()
        end

        SWITCH_GAME_STATE(GAME_STATES_ENUM.gameplay_state)
    end
end

local function draw()
    cls(2)
    color(7)
    print_utils.print_centered("marksman", 10)
    print_utils.print_centered("v0.3", 16)
    print_utils.print_centered("press ❎ to select", 22)

    draw_menu()
    -- show_todo()
end

local function update() update_menu() end

return {init = init, update = update, draw = draw}
end
function require(p)
local l=package.loaded
if (l[p]==nil) l[p]=package._c[p]()
if (l[p]==nil) l[p]=true
return l[p]
end
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

function _draw()
    state_manager.draw()
end
__gfx__
00000000333333334444444400111000000000000000000000000000700000000000000070000000700000000000000000000000000000000000000000000000
00000000444444444544555401111000000000000000000000000000073330007000000007333000073330000000000000000000000000000000000000000000
00700700445454544455444401111110000000000000000000000000037333300733300003733330037333300000000000000000000000000000000000000000
0007700044454444454454540aaaa000000000000000000000000000333333330373333033333333333333330000000000000000000000000000000000000000
0007700044544444445445440aaaa00000000000000000007777600000aa5a003333333300aa5a0000aa5a000000000000000000000000000000000000000000
0070070044455444445454440bbbb00000000000000000778887760000aaaa0000aa5a0000aaaa0000aaaa000000000000000000000000000000000000000000
0000000045444454454454540bbbb00000000000000007787778776000aa000000aaaa0000aa000000aa00000000000000000000000000000000000000000000
0000000044444444444444440dddd0000000000000007787888787760333300000aa000003333000033330000000000000000000000000000000000000000000
00000000d5d5d5d5004dd40000000400004444000007887877787876033330000333300003333000033330000000000000000000000000000000000000000000
000000005ddddddd044334400000044000000dd00007878788787876033430000333300003343000033430000000000000000000000000000000000000000000
00000000dd55d5d54400304400000044000003d400078787887878760334300003343000033430000334b0000000000000000000000000000000000000000000
000000005d5d5ddd000030000000033d0000330400078778778788760334300003b430000334b00003b440000000000000000000000000000000000000000000
00000000ddd5d5d5000000000000333d00033004000778878877876003b4b0000344b00003b44000034440000000000000000000000000000000000000000000
000000005d5d55dd00000000000000440000000400007787778874000b4040000b4040000b4040000b4050000000000000000000000000000000000000000000
00000000ddddddd50000000000000440000000000000077888876540004040000050400000405000005000000000000000000000000000000000000000000000
000000005d5d5d5d0000000000000400000000000000007777764004005050000000500000500000000000000000000000000000000000000000000000000000
00000000000000000000500000000000000000000000000000000000000000000040000000040000000004000050050000000400000000000000000000000000
00000000000000000005550000000000000055500000000000000000000000000040000000040000000004000005500000000400000000000000000000000000
00000000000000000000400000000000000004500000000000000000444444445040000005040000050504004444444400000405008888000000800000008000
00000000000000000000400060000050000040500000000000000000000550000540000050540000505054000000000000000450008ee0000000888000888000
00000000000000000000400006444455000400000000000044444444005005000540000050540000505054000000000000000450008220000000088808880000
0000000000000000000040006000005000400000444444440005500000055000504000000504000005050400000000000000040508822e000000888888888000
00000000000000000000700000000000640000000005500000500500005005000040000000040000000004000000000000000400000110000000888080888000
00000000000000000007070000000000060000000050050000055000000550000040000000040000000004000000000000000400000cc0000000088888880000
00000000000000000000000000000000555555555555555555555555555555550000000000577000007750000000000000000900000090000080008000800080
00000000000000000000000000000000557575757575757575757575050505050000050000000000000000000000000000000090000900000088888888888880
00000000000000000000000000000000577777777777777777777755060606060000055000577000007750000000000000000099999900900000880088088000
00000000000000000000000000000000557777777777777777777775000000000444455600507000007050000000000000000099999909900000000088000000
00000000000000000000000000000000577777777777777777777755000000000444455600570000007700000000000000000009999099000000000888800000
00000000000000000000000000000000557777777777777777777775000000000000055000507000007050000000000000000009999990000000008800880000
00000000000000000000000000000000577777777777777777777755000000000000050000577000007750000000000000000009999000000000008000080000
00000000000000000000000000000000557777777777777777777775000000000000000000000000000000000000000000000009009000000000088800888000
00000000044444000044444000000000577777777777777777777755000000000000000000000000100000000000000000000000000000000000000000000000
00000000449999dddd99994400000000557777777777777777777775000000000000000000000000011000100000000000000000000000000000000000000000
00000004490000000000009440000000577777777777777777777755000000000000000000000000000000010000000000000000000000000000000000000000
00000044900000000000000944000000557777777777777777777775000000000000000000000000011000000000000000000000000000000000000000000000
00000499000000000000000099400000577777777777777777777755000000000000000000000000100000000000000000000000000000000000000000000000
00004990000000000000000009940000557777777777777777777775606060600000000000000000000000110000000000000000000000000000000000000000
00049000000000000000000000094000577777777777777777777755505050500000000000000000000000000000000000000000000000000000000000000000
04440000000000000000000000004440557777777777777777777775555555550000000000000000000000000000000000000000000000000000000000000000
00000000000000003330000000000000577777777777777777777755000000000000000055555555000000000000000000000000000000000000000000000000
00000003300000333333000000000000557777777777777777777775000000030000000055555555000000000000000000000000000000000000000000000000
00000033330003333333000000000000577777777777777777777755000000033000000055555555000000000777000777000000000077700000077700000000
00003333333333aaa333300000000000557777777777777777777775000000033000000055555555000000007777707777777000000777777777777770000000
00003333333333abb33b333333330000577777777777777777777755000000333300000055555555000007777777777777777700006777777777777777770000
0000333333bb3333bb3b333333330000557777777777777777777775000000333300000055555555000077777777777777777770067777777777777777777000
00003333b33333333bbbb33bb3b33000575757575757575757575755000003333330000055555555000777777777777777777777067777777777777777777600
00003333b34433bb33b3333344b33000555555555555555555555555000003333330000055555555007777777777777777777776066777777777777777777760
00000333b33444333333339493b33000000000005555555555555555000033333333000055555555007777777777777777777776006777777777777777777760
00000333333334493333224333333300000000005555555555555555000033333333000055555555006777777777777777777760006777777777777777777760
000000333333333423342433333a3300000000005555555555555555000033333333000055555555000677777777777777777600006777777777777777777600
0000003a333333332242443333ba3300000000005555555555555555000003333330000055555555000067777777776677766000006777777777777777776000
0000003aa3333333442443333bbbbbb3000008005555555555555555000000333300000055555555000006667766660066600000000667777667777766660000
00000033bb3bbb333342333bbb333bb300008a805555555555555555000000022000000055555555000000066600000000000000000067776006777600000000
000000033bbbb3bb3342333b333943b3000008005555555555555555000000044000000055555555000000000000000000000000000006660000666000000000
000000033333333333244333334233b3000003005555555555555555000000044000000055555555000000000000000000000000000000000000000000000000
00000033333bb333334243339243b330555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
00000033333b34493334233322333300555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
0000003333a332229334233444333000555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
0000000333aa33922234234422bb0000555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
00000000333bb3344244424243b30000555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
000000000033bbb34242442433b30000555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
00000000000333333424244433300000555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
00000000000033333442244400000000555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
00000000000000000244242400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000044242400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000242242400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000442442400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000422424440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000422424240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000222424424000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000242422242000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000004242442242000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000004244242424000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000042442242442400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000422424222244200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000004424422424242440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000044224424422224444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000004222242224242222224400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000042244422444244444422240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccc15cccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccc7711117cccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccc7cc55511c7cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccc7777777ccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccc115151cccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccc11511511ccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccc11111551ccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccc1551151511cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccc5511111515cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccc11ccccccc1111155111511cccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc7715ccccc11111511151155cccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc1511ccccc515155151555115ccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc51151ccc55111111111511511cccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc1115151cc151111151111111115ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc1151111c15115151515151155111cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c111111111511551115111151155155c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11511115155155151111115115111151000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111151511151515151000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5
5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd
dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5
5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd
ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5
5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd
ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5
5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d
d5d5d5d5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccd5d5d5d5
5dddddddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5ddddddd
dd55d5d5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccdd55d5d5
5d5d5dddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d5ddd
ddd5d5d5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccddd5d5d5
5d5d55ddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d55dd
ddddddd5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccddddddd5
5d5d5d5dcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d5d5d
d5d5d5d5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccd5d5d5d5
5dddddddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5ddddddd
dd55d5d5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccdd55d5d5
5d5d5dddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d5ddd
ddd5d5d5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccddd5d5d5
5d5d55ddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d55dd
ddddddd5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccddddddd5
5d5d5d5dcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d5d5d
d5d5d5d5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccd5d5d5d5
5dddddddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5ddddddd
dd55d5d5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccdd55d5d5
5d5d5dddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d5ddd
ddd5d5d5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccddd5d5d5
5d5d55ddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d55dd
ddddddd5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccddddddd5
5d5d5d5dcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d5d5d
d5d5d5d5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccd5d5d5d5
5dddddddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5ddddddd
dd55d5d5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccdd55d5d5
5d5d5dddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d5ddd
ddd5d5d5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccddd5d5d5
5d5d55ddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d55dd
ddddddd5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccddddddd5
5d5d5d5dcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d5d5d
d5d5d5d5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccd5d5d5d5
5dddddddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5ddddddd
dd55d5d5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccdd55d5d5
5d5d5dddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d5ddd
ddd5d5d5cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77776cccddd5d5d5
5d5d55ddcccccccccccccccccccccccccccccccccccccccc555ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77888776cc5d5d55dd
ddddddd5cccccccccccccccccccccccccccccccccccccccc54ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7787778776cddddddd5
5d5d5d5dcccccccccccccccccccccccccccccccccccccccc5c4ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7787888787765d5d5d5d
d5d5d5d5ccccccccccccccccccccccccccccccccccccccccccc4ccccccccccccccccccccccccccccccccccccccccccccccccccccccc7887877787876d5d5d5d5
5dddddddcccccccccccccccccccccccccccccccccccccccccccc4cccccccccccccccccccccccccccccccccccccccccccccccccccccc78787887878765ddddddd
dd55d5d5ccccccccccccccccccccccccccccccccccccccccccccc46cccccccccccccccccccccccccccccccccccccccccccccccccccc7878788787876dd55d5d5
5d5d5dddccccccccccccccccccccccccccccccccccccccccccccc6ccccccccccccccccccccccccccccccccccccccccccccccccccccc78778778788765d5d5ddd
ddd5d5d5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc778878877876cddd5d5d5
5d5d55ddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7787778874cc5d5d55dd
ddddddd5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7788887654cddddddd5
5d5d5d5dcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccc7777764cc45d5d5d5d
d5d5d5d5cccccccccccccccccccccccccccccccccccccccccccccccccccccccc3337ccccccccccccccccccccccccccccccccccccd5d5d5d5d5d5d5d5d5d5d5d5
5dddddddcccccccccccccccccccccccccccccccccccccccccccccccccccccc333373cccccccccccccccccccccccccccccccccccc5ddddddd5ddddddd5ddddddd
dd55d5d5ccccccccccccccccccccccccccccccccccccccccccccccccccccc33333333cccccccccccccccccccccccccccccccccccdd55d5d5dd55d5d5dd55d5d5
5d5d5dddccccccccccccccccccccccccccccccccccccccccccccccccccccccc4444ccccccccccccccccccccccccccccccccccccc5d5d5ddd5d5d5ddd5d5d5ddd
ddd5d5d5ccccccccccccccccccccccccccccccccccccccccccccccccccccccddaaacccccccccccccccccccccccccccccccccccccddd5d5d5ddd5d5d5ddd5d5d5
5d5d55ddccccccccccccccccccccccccccccccccccccccccccccccccccccc4d3caaccccccccccccccccccccccccccccccccccccc5d5d55dd5d5d55dd5d5d55dd
ddddddd5ccccccccccccccccccccccccccccccccccccccccccccccccccccc4c33333ccccccccccccccccccccccccccccccccccccddddddd5ddddddd5ddddddd5
5d5d5d5dccccccccccccccccccccccccccccccccccccccccccccccccccccc4cc3333cccccccccccccccccccccccccccccccccccc5d5d5d5d5d5d5d5d5d5d5d5d
d5d5d5d5ccccccccccccccccccccccccccccccccccccccccccccccccccccc4cc3433ccccccccccccccccccccccccccccccccccccccccccccccccccccd5d5d5d5
5dddddddccccccccccccccccccccccccccccccccccccccccccccccccccccccccb433cccccccccccccccccccccccccccccccccccccccccccccccccccc5ddddddd
dd55d5d5cccccccccccccccccccccccccccccccccccccccccccccccccccccccc44b3ccccccccccccccccccccccccccccccccccccccccccccccccccccdd55d5d5
5d5d5dddcccccccccccccccccccccccccccccccccccccccccccccccccccccccc4443cccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d5ddd
ddd5d5d5cccccccccccccccccccccccccccccccccccccccccccccccccccccccc5c4bccccccccccccccccccccccccccccccccccccccccccccccccccccddd5d5d5
5d5d55ddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5ccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d55dd
ddddddd5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccddddddd5
5d5d5d5dcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d5d5d
d5d5d5d5cc4cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccd5d5d5d5
5dddddddcc4ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5ddddddd
dd55d5d55c4cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccdd55d5d5
5d5d5dddc54ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d5ddd
ddd5d5d5c54cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccddd5d5d5
5d5d55dd5c4ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d55dd
ddddddd5cc4cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccddddddd5
5d5d5d5dcc4ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d5d5d
d5d5d5d5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccd5d5d5d5
5dddddddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5ddddddd
dd55d5d5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccdd55d5d5
5d5d5dddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d5ddd
ddd5d5d5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccddd5d5d5
5d5d55ddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d55dd
ddddddd5ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccddddddd5
5d5d5d5dcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d5d5d
d5d5d5d533333333ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccd5d5d5d5
5ddddddd44444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5ddddddd
dd55d5d544545454ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccdd55d5d5
5d5d5ddd44454444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d5ddd
ddd5d5d544544444ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccddd5d5d5
5d5d55dd44455444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d55dd
ddddddd545444454ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccddddddd5
5d5d5d5d44444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d5d5d
d5d5d5d544444444ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccd5d5d5d5
5ddddddd45445554cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5ddddddd
dd55d5d544554444ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccdd55d5d5
5d5d5ddd45445454cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d5ddd
ddd5d5d544544544ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccddd5d5d5
5d5d55dd44545444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d55dd
ddddddd545445454ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccddddddd5
5d5d5d5d44444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5d5d5d5d
d5d5d5d544444444cc4ccccccccccccc33333333cccccccccccccccccccccccccccccccccccccccccccccccc3333333333333333ccccccccccccccccd5d5d5d5
5ddddddd45445554cc4ccccccccccccc44444444cccccccccccccccccccccccccccccccccccccccccccccccc4444444444444444cccccccccccccccc5ddddddd
dd55d5d5445544445c4ccccccccccccc44545454cccccccccccccccccccccccccccccccccccccccccccccccc4454545444545454ccccccccccccccccdd55d5d5
5d5d5ddd45445454c54ccccccccccccc44454444cccccccccccccccccccccccccccccccccccccccccccccccc4445444444454444cccccccccccccccc5d5d5ddd
ddd5d5d544544544c54ccccccccccccc44544444cccccccccccccccccccccccccccccccccccccccccccccccc4454444444544444ccccccccccccccccddd5d5d5
5d5d55dd445454445c4ccccccccccccc44455444cccccccccccccccccccccccc44444444cccccccccccccccc4445544444455444cccccccccccccccc5d5d55dd
ddddddd545445454cc4ccccccccccccc45444454ccccccccccccccccccccccccccc55ccccccccccccccccccc4544445445444454ccccccccccccccccddddddd5
5d5d5d5d44444444cc4ccccccccccccc44444444cccccccccccccccccccccccccc5cc5cccccccccccccccccc4444444444444444cccccccccccccccc5d5d5d5d
d5d5d5d5444444443333333333333333444444443333333333333333333333333333333333333333ccccccccccccccccccccccccccccccccccccccccd5d5d5d5
5ddddddd454455544444444444444444454455544444444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc5ddddddd
dd55d5d5445544444454545444545454445544444454545444545454445454544454545444545454ccccccccccccccccccccccccccccccccccccccccdd55d5d5
5d5d5ddd454454544445444444454444454454544445444444454444444544444445444444454444cccccccccccccccccccccccccccccccccccccccc5d5d5ddd
ddd5d5d5445445444454444444544444445445444454444444544444445444444454444444544444ccccccccccccccccccccccccccccccccccccccccddd5d5d5
5d5d55dd445454444445544444455444445454444445544444455444444554444445544444455444cccccccccccccccccccccccccccccccccccccccc5d5d55dd
ddddddd5454454544544445445444454454454544544445445444454454444544544445445444454ccccccccccccccccccccccccccccccccccccccccddddddd5
5d5d5d5d444444444444444444444444444444444444444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc5d5d5d5d
d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5
5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd
dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5
5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd
ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5ddd5d5d5
5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd
ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5ddddddd5
5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d

__gff__
0001010000020200000000000000000000010000000202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11000000000000000000000000000011110000000000005a5b5c000000000011110000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11000000000000000000000000000011110000000000006a6b6c000000000011110000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100005d5e5f0000000000000000001111000000000000000000005a5b5c0011110000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100006d6e6f0000000000000000001111000000000000000000006a6b6c0011110000000000000000000001000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100000000000000000000000000001111005d5e5f0000000000000000000011010101000000000000000001000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
113a000000000000000000000000001111006d6e6f0000000000000000000011110000000000000000000001000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100000000000000000000000000001111000000000000000000000000000011110000000000000000000001000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111115758000003000000000057581111000000000000000000000000000011110001000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111116768000000000000000067681111000000000000000000000000000011110001000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111110101010101010101010101011111000000000000000000000000000011110101000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1134353535353535353535353602021111000000000000000000000000000011110000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1144454545454545454545454602021111000000000000000000000000000011110000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1144454545454545454545454602021111000300000000000011390011000011110000000011110000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1154555555555555555555555602021111000000000000000011000011000011110000111111110011111111111100110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0002000000000310503105031050300502d0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344

