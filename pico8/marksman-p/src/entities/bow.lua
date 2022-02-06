local arrows = require("entities/arrow")

--[[
directions:
  4   3   2
  5  bow  1
  6   7   8
--]]

BOW = {x = 0, y = 0, dir = 1}

local function fire_arrow()
    local arrow_dir = (BOW.dir - 1) / 8
    -- 0.25 is up 
    -- 0.75 is down
    if btnp(5) then arrows.fire_arrow(BOW.x, BOW.y, 5, arrow_dir) end
end

return {
    change_dir = function(dir) BOW.dir = dir end,
    init = function()
        BOW.x = PLAYER.x
        BOW.y = PLAYER.y + 4
    end,
    update = function()
        BOW.x = PLAYER.x
        BOW.y = PLAYER.y + 4

        fire_arrow()
    end,
    draw = function()
        local srpn = 19
        if BOW.dir == 1 or BOW.dir == 5 then
            srpn = 19
        elseif BOW.dir == 3 or BOW.dir == 7 then
            srpn = 18
        else
            srpn = 20
        end

        local flip_x = BOW.dir == 4 or BOW.dir == 5 or BOW.dir == 6
        local flip_y = BOW.dir == 6 or BOW.dir == 7 or BOW.dir == 8

        spr(srpn, BOW.x, BOW.y, 1, 1, flip_x, flip_y)
    end
}
