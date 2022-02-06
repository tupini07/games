local bullseye = require("entities/bullseye")
local spring = require("entities/spring")
local spikes = require("entities/spikes")
local decorations = require("managers/decorations")
local camera = require("src/camera")

local sprite_flags = {solid = 0, bullseye = 1, level_text_container = 2}

local function cell_has_flag(flag, x, y) return fget(mget(x, y), flag) end

local function is_solid(x, y)
    return cell_has_flag(sprite_flags.solid, flr(x / 8), flr(y / 8))
end

local function is_solid_area(x, y, w, h)
    return is_solid(x, y) or is_solid(x + w, y) or is_solid(x, y + h) or
               is_solid(x + w, y + h) or is_solid(x, y + h / 2) or
               is_solid(x + w, y + h / 2)
end

local map = {
    draw_level_decorations = function()
        local lvl_map_cords = camera.level_to_map_coords(SAVE_DATA.current_level)
        local game_cords = camera.get_game_space_coords_for_current_lvl()
        -- draw level text
        map(lvl_map_cords.x, lvl_map_cords.y, game_cords.x, game_cords.y, 16,
            16, 0x4)
        -- draw sprites without flags
        map(lvl_map_cords.x, lvl_map_cords.y, game_cords.x, game_cords.y, 16,
            16, 0x0)
    end,
    draw = function()
        local lvl_map_cords = camera.level_to_map_coords(SAVE_DATA.current_level)
        local game_cords = camera.get_game_space_coords_for_current_lvl()
        map(lvl_map_cords.x, lvl_map_cords.y, game_cords.x, game_cords.y, 16, 16, 0B11)
    end,
    sprite_flags = sprite_flags,
    cell_has_flag = cell_has_flag,
    is_solid_area = is_solid_area,
    replace_entities = function(current_level)
        local level_block_coords = camera.level_to_map_coords(current_level)

        local level_x2 = level_block_coords.x + 16
        local level_y2 = level_block_coords.y + 16

        for x = level_block_coords.x, level_x2 do
            for y = level_block_coords.y, level_y2 do
                local sprt = mget(x, y)
                if sprt == 3 or sprt == 4 then
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

                if sprt == 13 then
                    spikes.replace_in_map(x, y, spikes.orientations.down)
                elseif sprt == 14 then
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

                decorations.replace_in_map(x, y, sprt)
            end
        end
    end
}

return map
