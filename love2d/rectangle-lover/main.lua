-- This might not be required if VSCode's Love2d integration works fine.
-- love = require "lib.love-api"

local utils = require "lib.utils"
local inspect = require "lib.inspect"

--------------------
-- setup scenes we know about

local intro_scene = require "scenes.intro_scene"
local game_scene = require "scenes.game_scene"

local current_scene_name = intro_scene.name

local scene_table = {
    [intro_scene.name] = intro_scene,
    [game_scene.name] = game_scene,
}


--------------------
-- configure globals

-- switch to a scene with the given name
function SWITCH_TO_SCENE(scene_name)
    current_scene_name = scene_name
    scene_table[current_scene_name].init()
end

-- pretty printing
function PPRINT(what)
    print(inspect(what))
end

-- mobile = false
-- if love.system.getOS() == 'iOS' or love.system.getOS() == 'Android' then
--   mobile = true
-- end
if love.system.getOS() == 'iOS' or love.system.getOS() == 'Android' then
    love.window.setFullscreen(true)
end


--------------------
-- setup love callbacks

local is_focused = true

function love.load()
    -- initially setup intro scene as first scene
    current_scene_name = intro_scene.name
    intro_scene.init()
end

function love.draw()
    love.graphics.clear(0.83, 0.8, 0.8)

    scene_table[current_scene_name].draw()
end

function love.update(dt)
    -- pause everything if we're not focused
    if not is_focused then
        love.timer.sleep(0.3)
        return
    end

    scene_table[current_scene_name].update(dt)
end

function love.mousefocus(focus)
    is_focused = focus
end

function love.keypressed(key, scancode, isrepeat)
    if "f5" == key then
        utils.reload_package(current_scene_name)
        scene_table[current_scene_name].init()
    end
end
