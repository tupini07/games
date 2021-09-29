local math = require("utils/math")

--- @param collider_1 BoxCollider
--- @param collider_2 BoxCollider
local function box_collision(collider_1, collider_2)
    return collider_1.x < collider_2.x + collider_2.w and collider_2.x <
               collider_1.x + collider_1.w and collider_1.y < collider_2.y +
               collider_2.h and collider_2.y < collider_1.y + collider_1.h
end

--- @param box_body BoxPhysicsBody
--- @return BoxCollider
local function resolve_box_body_collider(box_body)
    return {
        x = box_body.x + box_body.collider.x,
        y = box_body.y + box_body.collider.y,
        w = box_body.collider.w,
        h = box_body.collider.h
    }
end

---@param c BoxCollider
---@param circx number
---@param circy number
---@param circr number
local function is_box_collider_in_circle(c, circx, circy, circr)
    local circ_center = {x = circx, y = circy}
    local box_corners = {
        {x = c.x, y = c.y}, {x = c.x + c.w, y = c.y}, {x = c.x, y = c.y + c.h},
        {x = c.x + c.w, y = c.y + c.h}
    }

    for corner in all(box_corners) do
        if math.vector_distance(corner, circ_center) <= circr then
            return true
        end
    end

    return false
end

return {
    resolve_box_body_collider = resolve_box_body_collider,
    is_box_collider_in_circle = is_box_collider_in_circle,
    box_collision = box_collision,
    --- @param point Vector
    --- @param box_top_left Vector 
    point_in_box = function(point, box_top_left, box_h, box_w)
        local bx1 = box_top_left.x + box_w
        local by1 = box_top_left.y + box_h
        return box_top_left.x < point.x and point.x < bx1 and box_top_left.y <
                   point.y and point.y < by1
    end,
    --- @param box_body BoxPhysicsBody
    --- @param mapx number mapx cell top left x cord
    --- @param mapy number mapx cell top left y cord
    is_body_colliding_with_map_tile = function(box_body, mapx, mapy)
        local is_cell_solid = fget(mget(mapx, mapy), 0)
        if not is_cell_solid then return false end

        local game_x = mapx * 8
        local game_y = mapy * 8

        return box_collision(resolve_box_body_collider(box_body),
                             {x = game_x, y = game_y, h = 8, w = 8})

    end
}
