local exports = {}

---@class player_cube
local base_player = { x = 0, y = 0, size = 0 }

function base_player:draw()
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.rectangle("fill",
        self.x - self.size / 2,
        self.y - self.size / 2,
        self.size,
        self.size)
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

    self.x = x
    self.y = y

    -- update size
    self.size = self.size - 10 * dt
end

---@return player_cube
function exports.init_player()
    local player = { size = 80 }
    player = setmetatable(player, { __index = base_player })
    return player
end

return exports
