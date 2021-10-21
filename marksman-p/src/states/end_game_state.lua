local print_utils = require("utils/print")
local savefile = require("managers/savefile")
local graphics_utils = require("utils/graphics")

local function init()
    camera()
    add(COROUTINES, cocreate(graphics_utils.complete_unfade_coroutine))
end

local function update()
    if btnp(5) then
        SAVE_DATA.current_level = 1
        savefile.persist_save_data()
        SWITCH_GAME_STATE(GAME_STATES_ENUM.title_state)
    end
end

local function draw_text()
    color(5)

    local wrapped_text = print_utils.wrap_text_at_size(
                             "what an honor! for your exceptional skill and dexterity, you've been named the princess' personal marksman.",
                             11 * 8)
    cursor(18, 16)
    print(wrapped_text)

    -- for off text
    local start_fg_c = 7
    local start_bg_c = 5

    print_utils.print_text_with_outline("thanks for playing ♥", 5 * 8,
                                        13.5 * 8, start_fg_c, start_bg_c)
    print_utils.print_text_with_outline("press ❎ to restart", 5.5 * 8, 14.5 * 8,
                                        start_fg_c, start_bg_c)
end

local function draw()
    cls(12)
    sspr(0, 32, 31, 31, 0, 0, 128, 128)
    map(80, 48, 0, 0, 16, 16)

    draw_text()
end

return {init = init, update = update, draw = draw}
