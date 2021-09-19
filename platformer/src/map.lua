local sprite_flags = {solid = 0, bullseye = 1}

local bullseye = require("entities/bullseye")

local map = {
    draw = function() map(0, 0, 0, 0, 33, 33) end,
    sprite_flags = sprite_flags,
    cell_has_flag = function(flag, x, y) return fget(mget(x, y), flag) end,
    replace_entities = function()
        for x = 0, 128 do
            for y = 0, 64 do
                local sprt = mget(x, y)
                if sprt == 3 then
                    mset(x, y, 0)
                    PLAYER.x = x * 8
                    PLAYER.y = y * 8
                end

                if sprt == 5 then
                    -- this means it's the top left corner of left-facing bullseye
                    bullseye.replace_in_map(x, y, bullseye.orientation.left)
                end
            end
        end
    end
}

return map
