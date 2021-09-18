local arrows = require("arrow")

--[[
directions:
  4   3   2
  5  bow  1
  6   7   8
--]]

bow = {x = 0, y = 0, dir = 1}

local function fire_arrow()
    local arrow_dir = (bow.dir - 1) / 8
    -- 0.25 is up 
    -- 0.75 is down
    if btnp(5) then arrows.fire_arrow(bow.x, bow.y, 5, arrow_dir) end
end

return {
    change_dir = function(dir) bow.dir = dir end,
    init = function()
        bow.x = player.x
        bow.y = player.y
    end,
    update = function()
        bow.x = player.x
        bow.y = player.y

        fire_arrow()
    end,
    draw = function()
        local srpn = 19
        if bow.dir == 1 or bow.dir == 5 then
            srpn = 19
        elseif bow.dir == 3 or bow.dir == 7 then
            srpn = 18
        else
            srpn = 20
        end

        local flip_x = bow.dir == 4 or bow.dir == 5 or bow.dir == 6
        local flip_y = bow.dir == 6 or bow.dir == 7 or bow.dir == 8

        spr(srpn, bow.x, bow.y, 1, 1, flip_x, flip_y)
    end
}
