local physics_utils = require("utils/physics")

--- @type Spike[]
SPIKES = {}

local orientations = {down = 1, up = 2}

local function replace_in_map(mapx, mapy, orientation)
    mset(mapx, mapy, 0)

    --- @type BoxCollider
    local collider

    if orientation == orientations.down then
        collider = {x = 0, y = 0, h = 3, w = 8}
    elseif orientation == orientations.up then
        collider = {x = 0, y = 5, h = 3, w = 8}
    end

    add(SPIKES, {
        x = mapx * 8,
        y = mapy * 8,
        orientation = orientation,
        collider = collider
    })
end

---@param s Spike
local function draw_spike(s)
    local sprtn
    if s.orientation == orientations.down then
        sprtn = 13
    elseif s.orientation == orientations.up then
        sprtn = 14
    end

    spr(sprtn, s.x, s.y)
end

return {
    orientations = orientations,
    replace_in_map = replace_in_map,
    init = function() SPIKES = {} end,
    draw = function() foreach(SPIKES, draw_spike) end
}
