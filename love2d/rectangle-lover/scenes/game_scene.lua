local player_cube = require "entities.player_cube"
local enemy_cube = require "entities.enemy_cube"

local exports = {}

--- @type player_cube
local player = nil

--- @type table<number, enemy_cube>
local enemies = {}

function exports.init()
    PPRINT({
        Hellow = "I don't know",
        World = "Initializing GAME scene",
    })

    player = player_cube.init_player()

    table.insert(enemies, enemy_cube.new_enemy())
end

function exports.update(dt)
    player:update(dt)

    for i, enemy in ipairs(enemies) do
        enemy:update(dt, player)

        if enemy.dead then
            table.remove(enemies, i)
        end
    end
end

function exports.draw()
    for _, enemy in ipairs(enemies) do
        enemy:draw()
    end

    player:draw()
end

return exports
