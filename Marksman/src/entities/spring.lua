local physics_utils = require("utils/physics")

--- @class Spring:table
--- @field public x number
--- @field public y number
--- @field public state number 0, 1, or 2 - from less to more expanded
--- @field public orientation number
--- @field public collider BoxCollider

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
--- @param s Spring
--- @param body BoxPhysicsBody
--- @return boolean if the body was springed or not
local function try_spring_body(s, body)
    local is_colliding = physics_utils.box_collision({
        x = s.x + s.collider.x,
        y = s.y + s.collider.y,
        h = s.collider.h,
        w = s.collider.w
    }, {
        x = body.x + body.collider.x,
        y = body.y + body.collider.y,
        h = body.collider.h,
        w = body.collider.w
    })

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
    end

    return is_colliding
end

return {
    orientations = orientations,
    replace_in_map = replace_in_map,
    try_spring_body = try_spring_body,
    init = function() SPRINGS = {} end,
    draw = function() foreach(SPRINGS, draw_spring) end,
    update = function() foreach(SPRINGS, update_spring) end
}
