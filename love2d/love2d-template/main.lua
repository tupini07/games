require "globals"
input = require("input")

-- mobile = false
-- if love.system.getOS() == 'iOS' or love.system.getOS() == 'Android' then
--   mobile = true
-- end
if love.system.getOS() == 'iOS' or love.system.getOS() == 'Android' then
    love.window.setFullscreen(true)
end

function love.load()
    if arg[#arg] == "vsc_debug" then
        print("Opening debug socket...")
        require("lldebugger").start()
    end

    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setColor(0, 0, 0)
end

---@param dt number
function love.update(dt)
    if DEBUG then
        require("lib.lurker").update()
    end

    input.update()

    left_click = input.was_mouse_just_pressed(1)
    if left_click then
        print(left_click.x)
    end

    if love.keyboard.isDown("q") then
        love.event.quit()
    end

    -- ewrok
    input.after_update()
end

function love.draw()
    love.graphics.clear(0.83, 0.8, 0.8)

    love.graphics.print("This text is not black because of the line below", 100, 100)
    love.graphics.setColor(255, 0, 0)
    love.graphics.print("This text is red", 100, 200)
end

function love.mousepressed(x, y, button, istouch)
    input.mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
    input.mousereleased(x, y, button, istouch)
end

function love.keypressed(key)
    input.keypressed(key)
end

function love.keyreleased(key)
    input.keyreleased(key)
end

function love.focus(f)
    if not f then
        print("LOST FOCUS")
    else
        print("GAINED FOCUS")
    end
end

function love.quit()
    print("Thanks for playing! Come back soon!")
end
