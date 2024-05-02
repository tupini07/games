local tablex = require("lib.batteries.tablex")

---@type KeyConstant[]
local just_pressed_keys = {}

---@alias MouseButton
---| '1' # Left mouse button
---| '2' # Right mouse button

---@class MousePress
---@field x number
---@field y number
---@field button MouseButton
---@field istouch boolean

---@type MousePress[]
local mouse_presses = {}

local input_handler = {}

---@param keycode KeyConstant
function input_handler.keypressed(keycode)
    tablex.add_value(just_pressed_keys, keycode)
end

---@param keycode KeyConstant
function input_handler.keyreleased(keycode)
end

function input_handler.mousepressed(x, y, button, istouch)
    mouse_presses[button] = {
        x = x,
        y = y,
        button = button,
        istouch = istouch
    }
end

function input_handler.mousereleased(x, y, button, istouch)
end

function input_handler.update()
end

function input_handler.after_update()
    just_pressed_keys = {}
    mouse_presses = {}
end

---@param keycode KeyConstant
function input_handler.was_key_just_pressed(keycode)
    return tablex.contains_value(just_pressed_keys, keycode)
end

---@param button MouseButton
---@return MousePress?
function input_handler.was_mouse_just_pressed(button)
    local existing_value = mouse_presses[button] 
    return existing_value
end

return input_handler
