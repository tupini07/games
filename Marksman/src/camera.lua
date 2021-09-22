local map = require("src/map")

return {
    camera_center = function(x, y, map_tiles_width, map_tiles_height)
        local cam_x = x - 60
        local cam_y = y - 60

        cam_x = mid(0, cam_x, map_tiles_width * 8 - 127)
        cam_y = mid(0, cam_y, map_tiles_height * 8 - 127)

        camera(cam_x, cam_y)
    end,
    focus_section = function(current_level)
        local level_block_coords = map.level_to_map_coords(current_level)

        camera(level_block_coords.x * 8, level_block_coords.y * 8)
    end
}
