--- @type Bullseye
BULLSEYE = {
    x = 0,
    y = 0,
    sprite_x = 0,
    sprite_y = 0,
    hitbox_x = 0,
    hitbox_y = 0,
    hitbox_h = 0,
    hitbox_w = 0
}

local orientations = {left = 1}

return {
    orientation = orientations,
    replace_in_map = function(mapx, mapy, type)
        mset(mapx, mapy, 0)
        mset(mapx + 1, mapy, 0)
        mset(mapx, mapy + 1, 0)
        mset(mapx + 1, mapy + 1, 0)

        BULLSEYE.x = mapx * 8
        BULLSEYE.y = mapy * 8

        if type == orientations.left then
            BULLSEYE.sprite_x = 40
            BULLSEYE.sprite_y = 0
            BULLSEYE.hitbox_x = BULLSEYE.x + 6
            BULLSEYE.hitbox_y = BULLSEYE.y + 7

            BULLSEYE.hitbox_w = 6
            BULLSEYE.hitbox_h = 6
        end
    end,

    draw = function()
        sspr(BULLSEYE.sprite_x, BULLSEYE.sprite_y, 16, 16, BULLSEYE.x,
             BULLSEYE.y)
    end
}
