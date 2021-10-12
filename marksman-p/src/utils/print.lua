local function get_length_of_text(text) return #text * 4 end

local function print_centered_with_backdrop(text, y, text_color, backdrop_color)
    if text_color == nil then text_color = 7 end
    if backdrop_color == nil then backdrop_color = 0 end

    local text_x = 64 - get_length_of_text(text) / 2

    print(text, text_x + 1, y + 1, backdrop_color)
    print(text, text_x, y, text_color)
end

local menu_item_bobbing = false

local function wrap_text_at_size(text, max_width)
    local end_text = ""
    local tokens = split(text, " ")

    local current_line = ""
    for t in all(tokens) do
        local line_size = #current_line * 4
        local token_size = #t * 4

        -- check if new token plus space is more than width
        if line_size + token_size + 4 > max_width then
            end_text = end_text .. "\n" .. current_line
            current_line = ""
        end

        current_line = current_line .. " " .. t
    end

    end_text = end_text .. "\n" .. current_line
    return end_text
end

local function print_text_with_outline(text, x, y, text_color, bg_color)
    if text_color == nil then text_color = 7 end
    if bg_color == nil then bg_color = 0 end

    for _x = -1, 1 do
        -- print outline on x dim
        for _y = -1, 1 do
            -- and outline on y dim
            print(text, _x + x, _y + y, bg_color)
        end
    end
    print(text, x, y, text_color)
end

local function print_centered_text_with_outline(text, y, text_color, bg_color)
    local text_x = 64 - get_length_of_text(text) / 2
    print_text_with_outline(text, text_x, y, text_color, bg_color)
end

return {
    get_length_of_text = get_length_of_text,
    wrap_text_at_size = wrap_text_at_size,
    print_text_with_outline = print_text_with_outline,
    print_centered_text_with_outline = print_centered_text_with_outline,
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
