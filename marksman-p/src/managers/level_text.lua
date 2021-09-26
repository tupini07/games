return {
    draw_current_level_text = function()
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
    end
}
