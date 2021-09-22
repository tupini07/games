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

local function check_spring_colission()
    for s in all(SPRINGS) do

        if spring.try_spring_body(s, PLAYER) then return end

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
        check_spring_colission()

        bow.update()
    end,
    draw = function()
        draw_player()
        bow.draw()
    end
}

