return {
    draw_current_level_text = function()
        if SAVE_DATA.current_level == 1 then
            print("move with ⬅️➡️⬇️⬆️", 13, 93, 5)
            print("fire arrows with ❎")
            print("while pressing 🅾️ use\narrows to aim")
        end

    end
}
