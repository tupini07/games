local map = require("src/map")

return {
    draw_current_level_text = function()
        local lvl_pos = map.get_game_space_coords_for_current_lvl()
        if SAVE_DATA.current_level == 1 then
            print("move with ⬅️➡️⬇️⬆️", 17, 103, 5)
            print("fire arrows with ❎")
        end

        if SAVE_DATA.current_level == 2 then
            print("use ⬅️➡️⬇️⬆️", 143, 12, 5)
            print("while pressing 🅾️")
            print("to aim")
        end

        if SAVE_DATA.current_level == 3 then
            print("springs will", 314, 88, 5)
            print("take you where")
            print("you need to go")
        end

        if SAVE_DATA.current_level == 4 then
            print("springs also work", 398, 14, 5)
            print("on arrows!")
        end

        if SAVE_DATA.current_level == 5 then
            print("be careful with", lvl_pos.x + 37, 13, 5)
            print("spikes. if you touch")
            print("them you will")
            print("spontaneously")
            print("combust")
        end

        if SAVE_DATA.current_level == 8 then
            cursor(lvl_pos.x + 12, 14)
            color(5)
            print("lets test your")
            print("reflexes")
        end
    end
}
