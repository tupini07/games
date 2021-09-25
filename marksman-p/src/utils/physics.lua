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
