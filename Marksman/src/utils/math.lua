--- @class Vector:table
--- @field x number
--- @field y number

local math = {
    cap_with_sign = function(number, low, high)
        return sgn(number) * mid(low, abs(number), high)
    end,
    vector_distance = function(vec1, vec2)
        return sqrt((vec2.x - vec1.x) ^ 2 + (vec2.y - vec1.y) ^ 2)
    end,
    vector_magnitude = function(vec) return sqrt((vec.x) ^ 2 + (vec.y) ^ 2) end,
    get_nearest = function(num, ...)
        local options = {...}
        local nearest = options[1]
        local nearest_difference = abs(num - options[1])

        for opt in all(options) do
            local opt_difference = abs(num - opt)
            if opt_difference < nearest_difference then
                nearest = opt
                nearest_difference = opt_difference
            end
        end

        return nearest
    end
}

return math
