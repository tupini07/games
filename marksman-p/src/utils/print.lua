local function get_length_of_text(text) return #text * 4 end

local function print_centered_with_backdrop(text, y, text_color, backdrop_color)
    if text_color == nil then text_color = 7 end
    if backdrop_color == nil then backdrop_color = 0 end

    local text_x = 64 - get_length_of_text(text) / 2

    print(text, text_x + 1, y + 1, backdrop_color)
    print(text, text_x, y, text_color)
end

local menu_item_bobbing = false

return {
    get_length_of_text = get_length_of_text,
    print_centered = function(text, y, color)
        if color == nil then color = 7 end
        local text_x = 64 - get_length_of_text(text) / 2
        print(text, text_x, y, color)
    end,
    print_menu_item = function(text, y, is_selected)
        print_centered_with_backdrop(text, y, 0, 6)
        if is_selected then
            local selector_x = (64 - get_length_of_text(text) / 2) - 10

            if GLOBAL_TIMER % 13 == 0 then
                menu_item_bobbing = not menu_item_bobbing
            end

            if menu_item_bobbing then selector_x = selector_x - 1 end

            sspr(65, 25, 7, 6, selector_x, y)
        end
    end,
    print_centered_with_backdrop = print_centered_with_backdrop
}
