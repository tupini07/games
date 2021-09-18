local math = require("utils/math")

arrows = {}

local function fire_arrow(x, y, force, angle)
    local dx = cos(angle) * force
    local dy = sin(angle) * force

    add(arrows, {x = x, y = y, dx = dx, dy = dy, lifetime = 60})
end

local function update_arrow(a)
    if a.lifetime == 0 then
        del(arrows, a)
        return
    end

    a.y = a.y + a.dy
    a.x = a.x + a.dx

    -- apply gravity
    a.dy = a.dy + 0.12

    a.lifetime = a.lifetime - 1
end

local function draw_arrow(a)
    local angle = atan2(a.dx, a.dy)

    -- see quadrant in bow.lua
    local segment = math.get_nearest(angle, 1, 0.11, 0.25, 0.38, 0.5, 0.63,
                                     0.75, 0.86)

    local sprtn

    if segment == 1 or segment == 0.5 then
        sprtn = 35
    elseif segment == 0.25 or segment == 0.75 then
        sprtn = 34
    else
        sprtn = 36
    end

    local flip_x = segment == 0.38 or segment == 0.5 or segment == 0.63
    local flip_y = segment == 0.63 or segment == 0.75 or segment == 0.86

    spr(sprtn, a.x, a.y, 1, 1, flip_x, flip_y)
end

return {
    update_all = function() foreach(arrows, update_arrow) end,
    draw_all = function() foreach(arrows, draw_arrow) end,
    fire_arrow = fire_arrow
}
