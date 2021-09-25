local print_utils = require("utils/print")

return {
    log = function(msg) printh(msg, "game_log") end,
    assert = function(condition, msg) assert(condition, msg) end,
    track_mouse_coordinates = function()
        poke(0x5F2D, 1)
        local mousex = mid(0, stat(32), 127)
        local mousey = mid(0, stat(33), 127)

        line(0, mousey, mousex, mousey, 11)
        line(mousex, 0, mousex, mousey, 11)
        pset(mousex, mousey, 7)

        local coords_text = "x:" .. mousex .. " y:" .. mousey
        local txt_pixel_len = print_utils.get_length_of_text(coords_text)

        local px = mid(0, mousex, 127 - txt_pixel_len)
        local py = mid(0, mousey, 127 - 4)

        print(coords_text, px + 1, py + 1, 0)
        print(coords_text, px, py, 11)
    end
}
