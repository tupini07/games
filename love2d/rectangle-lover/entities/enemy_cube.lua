local scene_names = (require "scenes.scene_names")

local exports = {}

---@class enemy_cube
local base_cube = { x = 0, y = 0, size = 0, is_smaller_than_player = false, dead = false }


---@param enemy enemy_cube
---@param player_cube player_cube
---@return boolean
local function is_colliding_with_player(enemy, player_cube)
    -- does AABB collision
    local x1 = enemy.x
    local y1 = enemy.y
    local w1 = enemy.size
    local h1 = enemy.size

    local x2 = player_cube.x - player_cube.size / 2
    local y2 = player_cube.y - player_cube.size / 2
    local w2 = player_cube.size
    local h2 = player_cube.size

    return x1 < x2 + w2 and
        x1 + w1 > x2 and
        y1 < y2 + h2 and
        y1 + h1 > y2
end

---@param dt number
---@param player_cube player_cube
function base_cube:update(dt, player_cube)
    self.x = self.x + 1 * dt

    self.is_smaller_than_player = self.size < player_cube.size

    if is_colliding_with_player(self, player_cube) then
        print("colliding!")

        if not self.is_smaller_than_player then
            SWITCH_TO_SCENE(scene_names.game_over_scene_name)
        else
            -- TODO: remove enemy and increase player size
            self.dead = true
        end
    end
end

function base_cube:draw()
    if self.is_smaller_than_player then
        love.graphics.setColor(0.4, 0.4, 0.6)
    else
        love.graphics.setColor(0.8, 0.2, 0.2)
    end

    love.graphics.rectangle("fill", self.x, self.y, self.size, self.size)
end

---@return enemy_cube
function exports.new_enemy()
    local enemy = { size = 40 }
    enemy = setmetatable(enemy, { __index = base_cube })
    return enemy
end

return exports
