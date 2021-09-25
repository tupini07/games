local map = require("map")

local types = {cloud1 = 1, cloud2 = 2}

local function replace_in_map() end

local function draw_background()
    local lvl_cords = map.get_game_space_coords_for_current_lvl()

    sspr(0, 80, 31, 31, lvl_cords.x + 8, lvl_cords.y + 8, 112, 112)
end

return {
    draw_background = draw_background,
    replace_in_map = replace_in_map,
    types = types
}
