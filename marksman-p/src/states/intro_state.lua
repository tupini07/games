local print_utils = require("utils/print")
local savefile = require("managers/savefile")

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

local function show_todo()
    rectfill(10, 32, 117, 120, 7)
    color(0)
    print("\ntodo:", 12, 34)
    print("- nicer win panel")
    print("- sfx")
    print("- music?")
    print("- more levels")
    print("- apply clipping to arrows")
end

local function draw_menu()
    local starting_y = 42
    for menu_item in all(menu) do
        print_utils.print_menu_item(menu_item.text, starting_y,
                                    menu_item.is_selected)
        starting_y = starting_y + 7
    end
end

local function get_selected_menu_item()
    for item in all(menu) do if item.is_selected then return item end end
end

local function update_menu()
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
        local selected_item = get_selected_menu_item()
        if selected_item.action == "continue" then
            -- waste tokens
        elseif selected_item.action == "new_game" then
            SAVE_DATA.current_level = 1
            savefile.persist_save_data()
        end

        SWITCH_GAME_STATE(GAME_STATES_ENUM.gameplay_state)
    end
end

local function draw()
    cls(2)
    color(7)
    print_utils.print_centered("marksman", 10)
    print_utils.print_centered("v0.4", 16)
    print_utils.print_centered("press ❎ to select", 22)

    draw_menu()
    -- show_todo()
end

local function update() update_menu() end

return {init = init, update = update, draw = draw}
