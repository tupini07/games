local print_utils = require("utils/print")

return {
    log = function(msg) printh(msg, "game_log") end,
    assert = function(condition, msg) assert(condition, msg) end,
    track_mouse_coordinates = function()
        poke(0x5F2D, 1)
        local mousex = stat(32)
        local mousey = stat(33)

        line(0, mousey, mousex, mousey, 11)
        line(mousex, 0, mousex, mousey, 11)
        pset(mousex, mousey, 7)

        local coords_text = "x:" .. mousex .. " y:" .. mousey

        print(coords_text, mousex + 1, mousey + 1, 0)
        print(coords_text, mousex, mousey, 11)
    end
}
