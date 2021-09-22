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
        -- load_save_data()
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

local player = require("entities/player")
local arrow = require("entities/arrow")
local bullseye = require("entities/bullseye")
local spring = require("entities/spring")

local savefile_manager = require("managers/savefile")
local level_win = false

local function level_init()
    spring.init()
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
        spring.update()
    else
        level_win_update()
    end
end

local function draw()
    cls(12)

    map.draw()
    bullseye.draw()
    arrow.draw_all()
    player.draw()
    spring.draw()
    if level_win then level_win_draw() end
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

local map = {
    draw = function() map(0, 0, 0, 0, 33, 33) end,
    sprite_flags = sprite_flags,
    cell_has_flag = function(flag, x, y) return fget(mget(x, y), flag) end,
    level_to_map_coords = level_to_map_coords,
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

                if sprt == 5 then
                    -- this means it's the top left corner of left-facing bullseye
                    bullseye.replace_in_map(x, y, bullseye.orientation.left)
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
    sprite_x = 0,
    sprite_y = 0,
    hitbox_x = 0,
    hitbox_y = 0,
    hitbox_h = 0,
    hitbox_w = 0
}

local orientations = {left = 1}

return {
    orientation = orientations,
    replace_in_map = function(mapx, mapy, type)
        mset(mapx, mapy, 0)
        mset(mapx + 1, mapy, 0)
        mset(mapx, mapy + 1, 0)
        mset(mapx + 1, mapy + 1, 0)

        BULLSEYE.x = mapx * 8
        BULLSEYE.y = mapy * 8

        if type == orientations.left then
            BULLSEYE.sprite_x = 40
            BULLSEYE.sprite_y = 0
            BULLSEYE.hitbox_x = BULLSEYE.x + 6
            BULLSEYE.hitbox_y = BULLSEYE.y + 7

            BULLSEYE.hitbox_w = 6
            BULLSEYE.hitbox_h = 6
        end
    end,

    draw = function()
        sspr(BULLSEYE.sprite_x, BULLSEYE.sprite_y, 16, 16, BULLSEYE.x,
             BULLSEYE.y)
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
local logger = require("utils/logger")
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
        local level_block_coords = map.level_to_map_coords(current_level)

        camera(level_block_coords.x * 8, level_block_coords.y * 8)
    end
}
end
package._c["utils/logger"]=function()
return {
    log = function(msg)
        printh(msg, "game_log")
    end,
    assert = function(condition, msg)
        assert(condition, msg)
    end
}
end
package._c["entities/player"]=function()
local math = require("utils/math")
local map = require("src/map")
local camera_utils = require("src/camera")
local bow = require("entities/bow")
local physics_utils = require("utils/physics")
local spring = require("entities/spring")

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
package._c["states/intro_state"]=function()
-- local state_manager = require("states/state_manager")
local function init() end

local function update()
    if btnp(5) then
        SWITCH_GAME_STATE(GAME_STATES_ENUM.gameplay_state)
        -- state_manager.switch_state(state_manager.states.gameplay_state)
    end
end

local function draw()
    cls(2)
    print("welcome to marksman!")
    print("v0.3")
    print("press ❎ to continue")

    print("\ntodo:")
    print("- lvl selection menu")
    print("  - maybe right after intro?")
    print("     (continue or choose level)") 
    print("- nicer win panel")
    print("- background")
    print("- sfx")
    print("- music?")
    print("- more levels")
    print("- level intro / symbolizer")
    print("- build script: replace upper\n    case with symbols")
    print("- apply clipping to arrows")
end

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

function _draw() state_manager.draw() end
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080008000800080
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088888888888880
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000880088088000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000888800000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008800880000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000080000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088800888000
00000000044444000044444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000449999dddd99994400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000004490000000000009440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000044900000000000000944000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000499000000000000000099400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004990000000000000000009940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00049000000000000000000000094000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04440000000000000000000000004440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090000009000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009000090000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009999990090
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009999990990
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000999909900
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000999999000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000999900000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000900900000
__label__
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
33333333666666666666666666666666333333336666666666666664444666666666666666666666666666663333333333333333666666666666666666666666
444444446666666666666666666666664444444466666666666666cccc4466666666666666666666666666664444444444444444666666666666666666666666
445444546666666666666666666666664454445466666666666666ccccc446666666666666666666666666664454445444544454666666666666666666666666
444444446666666666666666666666664444444466666666666666aaaa6646666666666666666666666666664444444444444444666666666666666666666666
444444446666666666666666666666664444444466666666666666aaaa6646666666666666666666666666664444444444444444666666666666666666666666
444454446666666666666666666666664444544466666666666666bbbb6646666666666666666666666666664444544444445444666666666666666666666666
454444446666666666666666666666664544444466666666666666bbbb6666666666666666666666666666664544444445444444666666666666666666666666
444444446666666666666666666666664444444466666666666666dddd6666666666666666666666666666664444444444444444666666666666666666666666
44444444333333333333333333333333444444443333333333333333333333336666666666666666666666666666666666666666666666666666666666666666
44444454444444444444444444444444444444544444444444444444444444446666666666666666666666666666666666666666666666666666666666666666
44444444445444544454445444544454444444444454445444544454445444546666666666666666666666666666666666666666666666666666666666666666
45445444444444444444444444444444454454444444444444444444444444446666666666666666666666666666666666666666666666666666666666666666
44444444444444444444444444444444444444444444444444444444444444446666666666666666666666666666666666666666666666666666666666666666
44445444444454444444544444445444444454444444544444445444444454446666666666666666666666666666666666666666666666666666666666666666
44444454454444444544444445444444444444544544444445444444454444446666666666666666666666666666666666666666666666666666666666666666
44444444444444444444444444444444444444444444444444444444444444446666666666666666666666666666666666666666666666666666666666666666
44444444444444444444444444444444444444444444444444444444444444443333333333333333666666666666666666666666666666666666666666666666
44444454444444544444445444444454444444544444445444444454444444544444444444444444666666666666666666666666666666666666666666666666
44444444444444444444444444444444444444444444444444444444444444444454445444544454666666666666666666666666666666666666666666666666
45445444454454444544544445445444454454444544544445445444454454444444444444444444666666666666666666666666666666666666666666666666
44444444444444444444444444444444444444444444444444444444444444444444444444444444666666666666666666666666666666666666666666666666
44445444444454444444544444445444444454444444544444445444444454444444544444445444666666666666666666666666666666666666666666666666
44444454444444544444445444444454444444544444445444444454444444544544444445444444666666666666666666666666666666666666666666666666
44444444444444444444444444444444444444444444444444444444444444444444444444444444666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666

__gff__
0001010000020200000000000000000000010000000202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100000000000000000000000005061111000000000000000000000000000011110000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100000000000000000000000015161111000000000000000000000000000011110000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100000000000000000000000011111111000000000000000000000000000011110000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1128000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100030000000000000000000000001111000000000000000000000000000011110000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1101000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1102000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1102280001000000250000010100001111000300000000000011050611000011110000000011110000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1102010102010101010100000000001111000000000000000011151611000011110000111111110011111111111100110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

