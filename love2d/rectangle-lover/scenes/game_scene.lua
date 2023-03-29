local scene_names = require "scenes.scene_names"
local game_tracking = require "utilities.game_tracking"
local enemy_spawner = require "entities.enemy_spawner"

-- import entities
local player_cube = require "entities.player_cube"

--- @type player_cube
local player = nil

--- @type table<number, enemy_cube>
local enemies = {}


--------------------
-- Private functions

local function draw_score()
    -- draw draw black rectangle underneath
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 13, 15, 100, 25)

    -- draw score with white text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. string.format("%.2f", game_tracking.score), 20, 20)
end

--------------------
-- Public functions

local exports = {}

function exports.init()
    PPRINT({
        Hellow = "I don't know",
        World = "Initializing GAME scene",
    })

    enemies = {}
    player = player_cube.init_player()
    game_tracking.score = 0
end

function exports.update(dt)
    player:update(dt)

    if #enemies == 0 then
        -- populate initial enemies
        for _ = 1, 30 do
            enemy_spawner.spawn_enemy(player, enemies)
        end
    end

    for i, enemy in ipairs(enemies) do
        enemy:update(dt, player)

        if enemy.dead then
            table.remove(enemies, i)
        end
    end

    if player.size < 1 then
        SWITCH_TO_SCENE(scene_names.game_over_scene_name)
    end

    game_tracking.score = game_tracking.score + dt

    enemy_spawner.update(dt, player, enemies)
end

function exports.draw()
    for _, enemy in ipairs(enemies) do
        enemy:draw()
    end

    player:draw()

    draw_score()
end

return exports
