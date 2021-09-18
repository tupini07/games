local sprite_flags = {solid = 0}

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
                    player.x = x * 8
                    player.y = y * 8
                end
            end
        end
    end
}

return map
