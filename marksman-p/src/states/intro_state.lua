local decorations = require("managers/decorations")
local print_utils = require("utils/print")

local is_start_text_on = false

local function init() end

local function update()
    if GLOBAL_TIMER % 30 == 0 then is_start_text_on = not is_start_text_on end

    if btnp(5) then SWITCH_GAME_STATE(GAME_STATES_ENUM.gameplay_state) end
end

local function draw_intro_text()
    color(5)
    print("hear ye! hear ye!", 32, 16)

    local wrapped_text = print_utils.wrap_text_at_size(
                             "the most prestigious archery competition is now open to all that can string a bow. He who completes every stage will have an assured place among the king's own marksmen",
                             11 * 8)
    cursor(19, 22)
    print(wrapped_text)

    -- for off text
    local start_fg_c = 7
    local start_bg_c = 5

    if is_start_text_on then
        start_fg_c = 5
        start_bg_c = 7
    end

    print_utils.print_centered_text_with_outline("press ❎ to start", 89,
                                                 start_fg_c, start_bg_c)
end

local function draw()
    cls(12)
    sspr(0, 32, 31, 31, 0, 0, 128, 128)
    map(96, 48, 0, 0, 16, 16)

    draw_intro_text()
end

return {init = init, update = update, draw = draw}
