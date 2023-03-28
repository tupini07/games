local scene_names = require "scenes.scene_names"
local game_tracking = require "utilities.game_tracking"

local exports = {}

function exports.init()
    PPRINT({
        Hellow = "I don't know",
        World = "Initializing Game Over scene",
        score = game_tracking.score,
    })
end

function exports.update(dt)
    if love.mouse.isDown(1) then
        SWITCH_TO_SCENE(scene_names.game_scene_name)
    end
end

function exports.draw()
    love.graphics.setColor(0, 0.4, 0.2)
    love.graphics.print("Game Over! Click to begin again!", 30, 30)
    love.graphics.print("Score: " .. game_tracking.score, 30, 40)
end

return exports
