local particles = require("managers/particles")

    local lvl_cords = map.get_game_space_coords_for_current_lvl()
    local banner_x1 = lvl_cords.x
    local banner_y1 = lvl_cords.y + 48
    particles.init()
    particles.update()
    decorations.draw_background()
    particles.draw()
