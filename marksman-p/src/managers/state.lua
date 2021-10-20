local game_state = require("states/game_state")
local title_state = require("states/title_state")
local intro_state = require("states/intro_state")
local end_game_state = require("states/end_game_state")

GAME_STATE = {}
GAME_STATES_ENUM = {
    title_state = 1,
    intro_state = 2,
    gameplay_state = 3,
    end_game_state = 4
}

function SWITCH_GAME_STATE(new_state)
    if new_state ~= GAME_STATE.current_state then
        GAME_STATE.current_state = new_state
        if new_state == GAME_STATES_ENUM.title_state then
            title_state.init()
        elseif new_state == GAME_STATES_ENUM.intro_state then
            intro_state.init()
        elseif new_state == GAME_STATES_ENUM.gameplay_state then
            game_state.init()
        elseif new_state == GAME_STATES_ENUM.end_game_state then
            end_game_state.init()
        end
    end
end

local function act_for_current_state(act_map)
    local act_to_perform = act_map[GAME_STATES_ENUM.end_game_state]
    act_to_perform()
end

return {
    GAME_STATES_ENUM = GAME_STATES_ENUM,
    SWITCH_GAME_STATE = SWITCH_GAME_STATE,
    init = function() SWITCH_GAME_STATE(GAME_STATES_ENUM.title_state) end,
    update = function()
        act_for_current_state({
            [GAME_STATES_ENUM.title_state] = title_state.update,
            [GAME_STATES_ENUM.intro_state] = intro_state.update,
            [GAME_STATES_ENUM.gameplay_state] = game_state.update,
            [GAME_STATES_ENUM.end_game_state] = game_state.update
        })
    end,
    draw = function()
        act_for_current_state({
            [GAME_STATES_ENUM.title_state] = title_state.draw,
            [GAME_STATES_ENUM.intro_state] = intro_state.draw,
            [GAME_STATES_ENUM.gameplay_state] = game_state.draw,
            [GAME_STATES_ENUM.end_game_state] = end_game_state.draw
        })
    end
}
