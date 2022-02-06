--- @type Bullseye
BULLSEYE = {
    x = 0,
    y = 0,
    orientation = 1,
    sprite_x = 0,
    sprite_y = 0,
    hitbox_x = 9,
    hitbox_y = 9,
    hitbox_r = 3
}

local orientations = {left = 1, right = 2}

return {
    orientation = orientations,
    replace_in_map = function(mapx, mapy, type)
        mset(mapx, mapy, 0)
        mset(mapx + 1, mapy, 0)
        mset(mapx, mapy + 1, 0)
        mset(mapx + 1, mapy + 1, 0)

        BULLSEYE.x = mapx * 8
        BULLSEYE.y = mapy * 8

        BULLSEYE.orientation = type
        if type == orientations.left or type == orientations.right then
            BULLSEYE.sprite_x = 40
            BULLSEYE.sprite_y = 0

            BULLSEYE.hitbox_r = 5
        end

        if type == orientations.left then
            BULLSEYE.hitbox_x = BULLSEYE.x + 9
            BULLSEYE.hitbox_y = BULLSEYE.y + 10

        elseif type == orientations.right then
            BULLSEYE.hitbox_x = BULLSEYE.x + 6
            BULLSEYE.hitbox_y = BULLSEYE.y + 10
        end
    end,

    draw = function()
        sspr(BULLSEYE.sprite_x, BULLSEYE.sprite_y, 16, 16, BULLSEYE.x,
             BULLSEYE.y, 16, 16, BULLSEYE.orientation == orientations.right)
    end
}
