local print_utils = require("utils/print")
local savefile = require("managers/savefile")
local decorations = require("managers/decorations")

local menu = {}

local function init()
    local is_there_progress = SAVE_DATA.current_level ~= 1

    if is_there_progress then
        add(menu, {
            text = "continue (" .. SAVE_DATA.current_level .. ")",
            action = "continue",
            is_selected = false
        })
    end

    add(menu, {text = "new game", action = "new_game", is_selected = false})

    menu[1].is_selected = true
end

local function draw_menu()
    print_utils.print_centered("press ❎ to select", 53, 7)
    local starting_y = 74
    for menu_item in all(menu) do
        print_utils.print_menu_item(menu_item.text, starting_y,
                                    menu_item.is_selected)
        starting_y = starting_y + 7
    end
end

local function draw_logo()
    sspr(0, 24, 32, 8, 10, 12, 106, 26)
    print_utils.print_centered("marksman", 24, 7)
    print_utils.print_centered("v0.6", 30, 6)
end

local function get_selected_menu_item()
    for item in all(menu) do if item.is_selected then return item end end
end

local function update_menu()
    if (btnp(2) or btnp(3)) and #menu > 1 then sfx(17) end

    if btnp(2) then
        for i, item in ipairs(menu) do
            if item.is_selected then
                item.is_selected = false
                local top_i = i - 1
                if top_i <= 0 then
                    menu[#menu].is_selected = true
                else
                    menu[top_i].is_selected = true
                end
                break
            end
        end
    elseif btnp(3) then
        for i, item in ipairs(menu) do
            if item.is_selected then
                item.is_selected = false
                local bottom_i = i + 1
                if bottom_i > #menu then
                    menu[1].is_selected = true
                else
                    menu[bottom_i].is_selected = true
                end
                break
            end
        end
    end

    if btnp(5) then
        sfx(18)
        local selected_item = get_selected_menu_item()
        if selected_item.action == "continue" then
            SWITCH_GAME_STATE(GAME_STATES_ENUM.gameplay_state)
        elseif selected_item.action == "new_game" then
            SAVE_DATA.current_level = 1
            savefile.persist_save_data()
            SWITCH_GAME_STATE(GAME_STATES_ENUM.intro_state)
        end

    end
end

local function draw()
    cls(12)
    sspr(0, 32, 31, 31, 0, 0, 128, 128)
    map(112, 48, 0, 0, 16, 16)

    draw_logo()
    draw_menu()

    -- draw copyright
    sspr(32, 48, 82, 10, 44, 116)
end

local function update() update_menu() end

return {init = init, update = update, draw = draw}
