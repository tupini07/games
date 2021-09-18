local camera_utils = require("camera")
local math = require("utils/math")
local map = require("map")
local bow = require("bow")

player = {
    x = 0,
    y = 0,
    dx = 0,
    dy = 0,
    ddy = 0.12,
    dir = 1,
    is_jumping = false,
    changing_bow_dir = false
}

local function move_player()
    local jumping_mod = 0.55
    if not player.is_jumping then jumping_mod = 1 end
    if not player.changing_bow_dir then
        if btn(0) then
            player.dx = player.dx - 1 * jumping_mod
        elseif btn(1) then
            player.dx = player.dx + 1 * jumping_mod
        end

        if btnp(2) and not player.is_jumping then player.dy = -2 end
    end

    -- cap deltas
    player.dx = math.cap_with_sign(player.dx, 0, 2)
    player.dy = math.cap_with_sign(player.dy, 0, 2)

    -- apply velocity
    player.dir = sgn(player.dx)
    player.x = player.x + player.dx
    player.y = player.y + player.dy

    -- apply gravity
    player.dy = player.dy + player.ddy

    -- apply friction
    player.dx = player.dx * 0.5
end

local function check_floor()
    local bottom_x = flr((player.x + 4) / 8)
    local bottom_y = flr((player.y + 8) / 8)

    local is_bottom_floor = map.cell_has_flag(map.sprite_flags.solid, bottom_x,
                                              bottom_y)

    if is_bottom_floor then
        player.is_jumping = false
        player.y = (bottom_y - 1) * 8
        player.dy = 0
    else
        player.is_jumping = true
    end
end

local function check_walls()
    local pl_y = flr(player.y / 8)
    local left_x = flr(player.x / 8)
    local right_x = flr((player.x + 8) / 8)

    local is_left_wall = map.cell_has_flag(map.sprite_flags.solid, left_x, pl_y)
    local is_right_wall = map.cell_has_flag(map.sprite_flags.solid, right_x,
                                            pl_y)

    -- todo this is not working properly
    if is_left_wall then
        player.x = ((left_x + 1) * 8)
        player.dx = 0
    elseif is_right_wall then
        player.x = ((right_x - 1) * 8)
        player.dx = 0
    end
end

local function change_bow_direction()
    if btn(4) then
        player.changing_bow_dir = true
        local left = btn(0)
        local right = btn(1)
        local up = btn(2)
        local down = btn(3)

        -- first check corners
        -- see bow.lua for map of directions
        if up and left then
            player.dir = -1
            bow.change_dir(4)
        elseif up and right then
            player.dir = 1
            bow.change_dir(2)
        elseif down and left then
            player.dir = -1
            bow.change_dir(6)
        elseif down and right then
            player.dir = 1
            bow.change_dir(8)
        elseif up then
            player.dir = 1
            bow.change_dir(3)
        elseif right then
            player.dir = 1
            bow.change_dir(1)
        elseif down then
            player.dir = 1
            bow.change_dir(7)
        elseif left then
            player.dir = -1
            bow.change_dir(5)
        end
    else
        player.changing_bow_dir = false
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
        -- camera_utils.camera_center(player.x, player.y, 128, 64)

        bow.update()
    end,
    draw = function()
        spr(3, player.x, player.y, 1, 1, player.dir == -1)
        bow.draw()
    end
}

