local exports = {}

local base_cube = { x = 0, y = 0, size = 0 }
function base_cube:update(dt)
    self.x = self.x + 1 * dt
end

function base_cube:draw()
    love.graphics.setColor(0.8, 0.2, 0.2)
    love.graphics.rectangle("fill", self.x, self.y, self.size, self.size)
end

function exports.new_enemy()
    local enemy = { size = 40 }

    setmetatable(enemy, { __index = base_cube })

    return enemy
end

return exports
