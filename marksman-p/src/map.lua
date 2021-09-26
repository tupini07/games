local sprite_flags = {solid = 0, bullseye = 1}

local bullseye = require("entities/bullseye")
local spring = require("entities/spring")
local spikes = require("entities/spikes")

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

--- @return Vector
local function get_game_space_coords_for_current_lvl()
    local lvl_map_coords = level_to_map_coords(SAVE_DATA.current_level)

    return {x = lvl_map_coords.x * 8, y = lvl_map_coords.y * 8}
end

local map = {
    draw = function()
        -- TODO use level_to_map_coords for more efficient drawing
        map(0, 0, 0, 0, 128, 64)
    end,
    sprite_flags = sprite_flags,
    cell_has_flag = function(flag, x, y) return fget(mget(x, y), flag) end,
    level_to_map_coords = level_to_map_coords,
    get_game_space_coords_for_current_lvl = get_game_space_coords_for_current_lvl,
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
                    PLAYER_ORIGINAL_POS_IN_LVL.x = x * 8
                    PLAYER_ORIGINAL_POS_IN_LVL.y = y * 8
                end

                if sprt == 57 then
                    bullseye.replace_in_map(x, y, bullseye.orientation.left)
                elseif sprt == 58 then
                    bullseye.replace_in_map(x, y, bullseye.orientation.right)
                end

                if sprt == 55 then
                    spikes.replace_in_map(x, y, spikes.orientations.down)
                elseif sprt == 71 then
                    spikes.replace_in_map(x, y, spikes.orientations.up)
                end

                if sprt == 37 then
                    spring.replace_in_map(x, y, spring.orientations.top)
                elseif sprt == 40 then
                    spring.replace_in_map(x, y, spring.orientations.right)
                elseif sprt == 43 then
                    spring.replace_in_map(x, y, spring.orientations.bottom)
                elseif sprt == 44 then
                    spring.replace_in_map(x, y, spring.orientations.left)
                end
            end
        end
    end
}

return map
