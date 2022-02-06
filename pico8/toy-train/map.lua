local logger = require("utils/logger")

local map = {
    draw = function()
        map(0, 0, 0, 0, 33, 33)
    end,
    track_direction_transforms = function(sprite_num, current_dir)
        if sprite_num == 18 then
            -- horizontal
            if current_dir == "e" or current_dir == "w" then
                return current_dir
            end
        elseif sprite_num == 35 then
            -- vertical
            if current_dir == "n" or current_dir == "s" then
                return current_dir
            end
        elseif sprite_num == 19 then
            -- turn E -> S
            if current_dir == "e" then
                return "s"
            elseif current_dir == "n" then
                return "w"
            end
        elseif sprite_num == 34 then
            -- turn W -> S
            if current_dir == "w" then
                return "s"
            elseif current_dir == "n" then
                return "e"
            end

        elseif sprite_num == 50 then
            -- turn W -> N
            if current_dir == "w" then
                return "n"
            elseif current_dir == "s" then
                return "e"
            end

        elseif sprite_num == 51 then
            -- turn E -> N
            if current_dir == "e" then
                return "n"
            elseif current_dir == "s" then
                return "w"
            end
        end

        logger.assert(false,
            "track_direction_transforms called with an invalid sprite number [" .. sprite_num .. "] or direction [" ..
                current_dir .. "]")
    end
}

return map
