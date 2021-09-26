local game_state = require("states/game_state")
local intro_state = require("states/intro_state")

GAME_STATE = {}
GAME_STATES_ENUM = {intro_state = 1, gameplay_state = 2}

function SWITCH_GAME_STATE(new_state)
    if new_state ~= GAME_STATE.current_state then
        GAME_STATE.current_state = new_state
        if new_state == GAME_STATES_ENUM.intro_state then
            intro_state.init()
        elseif new_state == GAME_STATES_ENUM.gameplay_state then
            game_state.init()
        end
    end
end

local function act_for_current_state(act_map)
    local act_to_perform = act_map[GAME_STATE.current_state]
    act_to_perform()
end

return {
    GAME_STATES_ENUM = GAME_STATES_ENUM,
    SWITCH_GAME_STATE = SWITCH_GAME_STATE,
    init = function() SWITCH_GAME_STATE(GAME_STATES_ENUM.intro_state) end,
    update = function()
        act_for_current_state({
            [GAME_STATES_ENUM.intro_state] = intro_state.update,
            [GAME_STATES_ENUM.gameplay_state] = game_state.update
        })
    end,
    draw = function()
        act_for_current_state({
            [GAME_STATES_ENUM.intro_state] = intro_state.draw,
            [GAME_STATES_ENUM.gameplay_state] = game_state.draw
        })
    end
}