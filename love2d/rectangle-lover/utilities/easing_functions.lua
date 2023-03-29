local exports = {}

---@param x number in range [0,1]. Represents the percentage of the animation that has completed
---@return number
function exports.ease_out_circ(x)
    -- https://easings.net/#easeOutCirc
    return math.sqrt(1 - math.pow(x - 1, 2))
end

---@param x number in range [0,1]. Represents the percentage of the animation that has completed
---@return number
function exports.ease_out_quad(x)
    return 1 - (1 - x) * (1 - x)
end

return exports
