-- local state_manager = require("states/state_manager")
local function init() end

local function update()
    if btnp(5) then
        SWITCH_GAME_STATE(GAME_STATES_ENUM.gameplay_state)
        -- state_manager.switch_state(state_manager.states.gameplay_state)
    end
end

local function draw()
    cls(2)
    print("welcome to {game}")
    print("Press ❎ to continue")
end

return {init = init, update = update, draw = draw}
