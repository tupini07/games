local math = require("utils/math")
local map = require("src/map")
local spring = require("entities/spring")
local physics_utils = require("utils/physics")

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
        lifetime = 140,
        is_stuck = false,
        collider = collider
    }

    sfx(23)
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
        sfx(24)
        make_floor_walls_colission_dust(a)
    end
end

--- @param a Arrow
local function make_bullseye_colission_dust(a)
    local cv = get_collision_vec(a)
    for _ = 1, 10 do
        local displacement = rnd(4) - 4
        local x_speed = -a.dx * 0.05
        local y_speed = -a.dy * 0.1 - rnd(0.2)
        particles.make_particle(cv.x + displacement, cv.y + displacement,
                                x_speed, y_speed, 0, 1, rnd({7, 10, 11}), 7)
    end
end

--- @param a Arrow
local function collide_with_bullseye(a)
    local resolved_arrow_c = physics_utils.resolve_box_body_collider(a)

    local is_colliding = physics_utils.is_box_collider_in_circle(
                             resolved_arrow_c, BULLSEYE.hitbox_x,
                             BULLSEYE.hitbox_y, BULLSEYE.hitbox_r)

    if is_colliding then
        a.is_stuck = true
        sfx(25)
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
