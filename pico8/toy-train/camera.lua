local logger = require("utils/logger")

return {
    camera_center = function(x, y, map_tiles_width, map_tiles_height)
        local cam_x = x - 60
        local cam_y = y - 60

        cam_x = mid(0, cam_x, map_tiles_width * 8 - 127)
        cam_y = mid(0, cam_y, map_tiles_height * 8 - 127)

        logger.log("x:[" .. x .. "] y:[" .. y .. "] map_tiles_width:[" .. map_tiles_width .. "] map_tiles_height:[" ..
                       map_tiles_height .. "] cam_x:[" .. cam_x .. "] cam_y:[" .. cam_y .. "]")
        camera(cam_x, cam_y)
    end
}
