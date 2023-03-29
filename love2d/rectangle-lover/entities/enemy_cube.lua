local scene_names = (require "scenes.scene_names")
local easing_functions = require "utilities.easing_functions"

local exports = {}

---@class enemy_cube
local base_cube = {
    x = 0,
    y = 0,
    size = 0,
    is_smaller_than_player = false,
    dead = false,
    grace_timer = 0,
}


---@param enemy enemy_cube
---@param player_cube player_cube
---@return boolean
local function is_colliding_with_player(enemy, player_cube)
    -- does AABB collision
    local x1 = enemy.x
    local y1 = enemy.y
    local w1 = enemy.size
    local h1 = enemy.size

    local x2 = player_cube.x
    local y2 = player_cube.y
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
    self.is_smaller_than_player = self.size < player_cube.size

    local prev_size = self.size
    self.size = self.size - self.size * easing_functions.ease_out_circ(self.size / 140) * dt

    -- collapse size if necessary
    if self.size < 5 then
        self.dead = true
        return
    end

    -- for a short while after spawning, don't collide with player
    self.grace_timer = self.grace_timer - dt

    -- adjust position so we shrink towards center
    self.x = self.x + (prev_size - self.size) / 2
    self.y = self.y + (prev_size - self.size) / 2

    if self.grace_timer < 0 and is_colliding_with_player(self, player_cube) then
        if not self.is_smaller_than_player then
            SWITCH_TO_SCENE(scene_names.game_over_scene_name)
        else
            player_cube.size = player_cube.size + self.size / 2
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

    -- draw lines around the cube
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.x, self.y, self.size, self.size)
end

---@param x number
---@param y number
---@param size number
---@return enemy_cube
function exports.new_enemy(x, y, size)
    local enemy = {
        x = x,
        y = y,
        size = size,
        grace_timer = 0.2
    }
    enemy = setmetatable(enemy, { __index = base_cube })
    return enemy
end

return exports
