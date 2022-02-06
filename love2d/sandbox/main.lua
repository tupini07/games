local luaReload = require("libs.lua_reload")
luaReload.Inject()

local batteries = require("libs.batteries")

local material_selector = require("material_selector")
local user_controller = require("user_controller")

input = require("input")

MATERIALS = {
    {
        color = {0.2, 0.5, 0.7},
        size = 3
    }
}

function love.load()
    if arg[#arg] == "-debug" then
        require("mobdebug").start()
    end

    love.graphics.setDefaultFilter("nearest", "nearest")

    MOUSE_CIRCLE = {
        visible = false,
        x = 0,
        y = 0,
        radius = 10
    }

    ENTITIES = {}

    batteries.tablex.push(ENTITIES, material_selector)
end

function love.keypressed(key, scancode, isrepeat)
    input.keypressed(key)
end

function love.keyreleased(key, scancode)
    input.keyreleased(key)
end

function love.wheelmoved(x, y)
    if not MOUSE_CIRCLE.visible then
        return
    end

    local get_new_value = function(offset)
        local resize_speed = 3

        local mathx = batteries.mathx
        local max_radius = love.graphics.getWidth() / 2
        return mathx.clamp(MOUSE_CIRCLE.radius + offset * resize_speed, 0, max_radius)
    end

    if y < 0 then
        -- wheel moved up
        MOUSE_CIRCLE.radius = get_new_value(-1)
    elseif y > 0 then
        -- wheel moved down
        MOUSE_CIRCLE.radius = get_new_value(1)
    end
end

function love.update(dt)
    luaReload.Monitor()
    input.update()

    if love.keyboard.isDown("q") then
        love.event.quit()
    end


    for _, entity in ipairs(ENTITIES) do
        entity:update(dt)
    end

    user_controller:update()

    input.after_update()
end

function love.draw()
    love.graphics.clear(0.7, 1, 0.7, 1)
    love.graphics.setColor(0.5, 0.5, 0.3, 0.5)

    if MOUSE_CIRCLE.visible then
        love.graphics.circle("fill", MOUSE_CIRCLE.x, MOUSE_CIRCLE.y, MOUSE_CIRCLE.radius)
    end

    for _, entity in ipairs(ENTITIES) do
        entity:draw()
    end

    love.graphics.print("hi!")
end
