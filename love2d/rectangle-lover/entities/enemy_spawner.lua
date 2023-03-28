local enemy_cube = require "entities.enemy_cube"

---@class enemy_spawner
local exports = {}

local timer = 0


--- Gets a random position around the player to spawn an enemy and adds that enemy to the enemies table
---@param player any
---@param enemies_table any
local function spawn_enemy(player, enemies_table)
    local x = player.x + math.random(-100, 100)
    local y = player.y + math.random(-100, 100)
    local size = math.random(10, 30)

    table.insert(enemies_table, enemy_cube.new_enemy(x, y, size))
end

---@param dt number
---@param player player_cube
---@param enemies_table table<number, enemy_cube>
function exports.update(dt, player, enemies_table)
    exports.timer = exports.timer + dt

    if timer > 1 then
        spawn_enemy(player, enemies_table)
        exports.timer = 0
    end
end

return exports
