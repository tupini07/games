local scene_names = require "scenes.scene_names"

local exports = {}

function exports.init()
    PPRINT({
        Hellow = "I don't know",
        World = "Initializing intro scene",
    })
end

function exports.update(dt)
    if love.mouse.isDown(1) then
        SWITCH_TO_SCENE(scene_names.game_scene_name)
    end
end

function exports.draw()
    local x = 400
    local y = 300

    local mx, my = love.mouse.getPosition()
    if mx then
        x = mx
    end

    if my then
        y = my
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Hellssso World!", x - 40, y - 5)

    love.graphics.setColor(0, 0.4, 0.2)
    love.graphics.print("Click to begin!", 30, 30)
end

function exports.exit()
end

return exports
