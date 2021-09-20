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
    print("welcome to marksman!")
    print("press ❎ to continue")

    print("\ntodo:")
    print("- springs!")
    print("- lvl selection menu")
    print("  - maybe right after intro?")
    print("     (continue or choose level)") 
    print("- nicer win panel")
    print("- nicer player sprite")
    print("- background")
    print("- sfx")
    print("- music?")
    print("- more levels")
    print("- level intro / symbolizer")
    print("- build script: replace upper\n    case with symbols")
end

return {init = init, update = update, draw = draw}
