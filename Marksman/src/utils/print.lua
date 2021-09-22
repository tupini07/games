local function get_length_of_text(text) return #text * 4 end

return {
    get_length_of_text = get_length_of_text,
    print_centered = function(text, y, color)
        if color == nil then color = 7 end
        local text_x = 64 - get_length_of_text(text) / 2
        print(text, text_x, y, color)
    end,
    print_centered_with_backdrop = function(text, y, text_color, backdrop_color)
        if text_color == nil then text_color = 7 end
        if backdrop_color == nil then backdrop_color = 0 end

        local text_x = 64 - get_length_of_text(text) / 2

        print(text, text_x + 1, y + 1, backdrop_color)
        print(text, text_x, y, text_color)
    end
}
