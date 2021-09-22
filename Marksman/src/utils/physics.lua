--- @class PhysicsBody:table
--- @field public x number collider box x
--- @field public y number collider box y
--- @field public w number collider box w
--- @field public h number collider box h
--- @field public dx number
--- @field public dy number
--- @class BoxPhysicsBody:PhysicsBody
--- @field public collider BoxCollider
--- @class BoxCollider:table
--- @field public x number
--- @field public y number
--- @field public w number
--- @field public h number
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
    --- @param collider_1 BoxCollider
    --- @param collider_2 BoxCollider
    box_collision = function(collider_1, collider_2)
        return collider_1.x < collider_2.x + collider_2.w and 
                collider_2.x < collider_1.x + collider_1.w and
                collider_1.y < collider_2.y + collider_2.h and
                collider_2.y < collider_1.y + collider_1.h
    end
}
