-- This might not be required if VSCode's Love2d integration works fine.
-- love = require "lib.love-api"

local hot_reload = require "lib.hot_reload"
local inspect = require "lib.inspect"

--------------------
-- setup scenes we know about

local scene_names = require "scenes.scene_names"

local intro_scene = require "scenes.intro_scene"
local game_scene = require "scenes.game_scene"
local game_over_scene = require "scenes.game_over_scene"

local current_scene_name = "NOTHING"

local scene_table = {
    [scene_names.intro_scene_name] = intro_scene,
    [scene_names.game_scene_name] = game_scene,
    [scene_names.game_over_scene_name] = game_over_scene,
}


--------------------
-- configure globals

-- switch to a scene with the given name
function SWITCH_TO_SCENE(scene_name)
    print("Switching to scene: " .. scene_name)
    if scene_name[current_scene_name] then
        scene_table[current_scene_name].exit()
    end

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
    SWITCH_TO_SCENE(scene_names.intro_scene_name)
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

function love.keypressed(key)
    if "f5" == key then
        hot_reload.reload_all_packages(current_scene_name)
    end
end
