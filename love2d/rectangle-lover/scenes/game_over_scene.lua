local scene_names = require "scenes.scene_names"
local game_tracking = require "utilities.game_tracking"

local exports = {}

local final_score_font = love.graphics.newFont("assets/arial.ttf", 60)
local is_mouse_continuous_press = false

function exports.init()
    PPRINT({
        Hellow = "I don't know",
        World = "Initializing Game Over scene",
        score = game_tracking.score,
    })

    -- e.g. this can be true on mobile. Touch == mouse down when
    -- coming here from the game scene
    is_mouse_continuous_press = love.mouse.isDown(1)
end

function exports.update(dt)
    -- don't want to switch if mouse hasn't been lifted yet
    if is_mouse_continuous_press then
        is_mouse_continuous_press = love.mouse.isDown(1)
    end

    if not is_mouse_continuous_press and love.mouse.isDown(1) then
        SWITCH_TO_SCENE(scene_names.game_scene_name)
    end
end

function exports.draw()
    love.graphics.clear(0.3, 0.3, 0.3)

    -- draw banner
    love.graphics.setColor(0.4, 0.2, 0.2)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 100)

    love.graphics.setColor(0.8, 0.8, 0.9)
    love.graphics.print("Game Over! Click to begin again!", 30, 30)
    love.graphics.print("Press 'r' to restart", 30, 50)

    -- print a big score in the center of the screen
    local score = string.format("%.2fs", game_tracking.score)
    local width = final_score_font:getWidth(score)
    local height = final_score_font:getHeight()
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()

    -- use font
    local default_font = love.graphics.getFont()
    love.graphics.setFont(final_score_font)
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.print(score, screen_width / 2 - width / 2 + 2, screen_height / 2 - height / 2 + 2)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(score, screen_width / 2 - width / 2, screen_height / 2 - height / 2)

    love.graphics.setFont(default_font)

end

function exports.exit()
end

return exports
