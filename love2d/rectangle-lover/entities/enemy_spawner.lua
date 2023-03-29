local enemy_cube = require "entities.enemy_cube"

---@class enemy_spawner
local exports = {}

local timer = 0


--- Gets a random position around the player to spawn an enemy and adds that enemy to the enemies table
---@param player player_cube
---@param enemies_table table<number, enemy_cube>
function exports.spawn_enemy(player, enemies_table)
    local player_predicted_center_x = player.x + (player.vx * 1.5) + player.size / 2
    local player_predicted_center_y = player.y + (player.vy * 1.5) + player.size / 2

    local size = math.random(player.size - player.size / 2, player.size + player.size * 0.9)

    local angle = math.random(0, 360)
    local distance = math.random(player.size + size, love.graphics.getWidth() * 0.7)

    local x = player_predicted_center_x + math.cos(angle) * distance
    local y = player_predicted_center_y + math.sin(angle) * distance

    table.insert(enemies_table, enemy_cube.new_enemy(x - size / 2, y - size / 2, size))
end

---@param dt number
---@param player player_cube
---@param enemies_table table<number, enemy_cube>
function exports.update(dt, player, enemies_table)
    timer = timer + dt

    if timer > 0.08 then
        exports.spawn_enemy(player, enemies_table)
        timer = 0
    end
end

return exports
