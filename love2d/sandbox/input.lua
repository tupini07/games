local tablex = require("libs.batteries.tablex")

---@type KeyConstant[]
local just_pressed_keys = {}

local input_handler = {}

---@param keycode KeyConstant
function input_handler.keypressed(keycode)
    tablex.add_value(just_pressed_keys, keycode)
end

---@param keycode KeyConstant
function input_handler.keyreleased(keycode)
end

function input_handler.update()
end

function input_handler.after_update()
    just_pressed_keys = {}
end

---@param keycode KeyConstant
function input_handler.was_key_just_pressed(keycode)
    return tablex.contains_value(just_pressed_keys, keycode)
end

return input_handler
