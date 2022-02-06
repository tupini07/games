local tablex = require("libs.batteries.tablex")

local module = {}

local function make_sand()
    local mx, my = love.mouse.getPosition()

    local sand = {
        x = mx,
        y = my
    }

    function sand:update(dt)
        self.y = self.y + 1 * dt
    end

    function sand:draw()
        love.graphics.setColor(0.3,0.4,0.5,1.0)
        love.graphics.circle("fill", self.x, self.y, 3)
    end

    return sand
end

function module:update()
    MOUSE_CIRCLE.visible = love.mouse.isDown(2)
    if MOUSE_CIRCLE.visible then
        local mx, my = love.mouse.getPosition()
        MOUSE_CIRCLE.x = mx
        MOUSE_CIRCLE.y = my
    end

    if love.mouse.isDown(1) then
        tablex.insert(ENTITIES, make_sand())
    end
end

return module
