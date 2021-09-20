local sprite_flags = {solid = 0, bullseye = 1}

local bullseye = require("entities/bullseye")

--- @return Vector
local function level_to_map_coords(level_num)
    -- first we get 0 indexed coordinates for the "block" which 
    -- is the level

    -- 16 levels per row in map editor
    local map_row = flr(level_num / 16)

    --  8 levels per column in map editor
    local map_column = (level_num % 16) - 1

    return {x = map_column * 16, y = map_row * 16}
end

local map = {
    draw = function() map(0, 0, 0, 0, 33, 33) end,
    sprite_flags = sprite_flags,
    cell_has_flag = function(flag, x, y) return fget(mget(x, y), flag) end,
    level_to_map_coords = level_to_map_coords,
    replace_entities = function(current_level)
        local level_block_coords = level_to_map_coords(current_level)

        local level_x2 = level_block_coords.x + 16
        local level_y2 = level_block_coords.y + 16

        for x = level_block_coords.x, level_x2 do
            for y = level_block_coords.y, level_y2 do
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
