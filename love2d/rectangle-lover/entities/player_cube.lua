local easing_functions = require "utilities.easing_functions"

local exports = {}

---@class player_cube
local base_player = { x = 0, y = 0, vx = 0, vy = 0, size = 0 }

function base_player:draw()
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.rectangle("fill",
        self.x,
        self.y,
        self.size,
        self.size)

    -- draw lines around the cube
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.x, self.y, self.size, self.size)
end

function base_player:update(dt)
    local x, y = love.mouse.getPosition()

    -- use touch if available
    local touch_ids = love.touch.getTouches()
    if #touch_ids > 0 then
        local tx, ty = love.touch.getPosition(touch_ids[1])
        if tx then
            x = tx
        end

        if ty then
            y = ty
        end
    end

    -- center cube on mouse
    x = x - self.size / 2
    y = y - self.size / 2

    local previous_x = self.x
    local previous_y = self.y

    self.x = x
    self.y = y

    -- update movement velocity
    self.vx = (self.x - previous_x)
    self.vy = (self.y - previous_y)

    -- update size
    self.size = self.size - self.size * easing_functions.ease_out_circ(self.size / 160) * dt

    -- collapse size if necessary
    if self.size < 5 then
        self.size = 0
    end

    -- if size exploded (is nan) then clamp it to 250
    if self.size ~= self.size then
        self.size = 250
    end
end

---@return player_cube
function exports.init_player()
    local player = { size = 80 }
    player = setmetatable(player, { __index = base_player })
    return player
end

return exports
