pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
package={loaded={},_c={}}
package._c["managers/savefile"]=function()
SAVE_DATA = {current_level = 1}

local save_data_points = {current_level = 1}

local function load_save_data()
    local set_level = dget(save_data_points.current_level)
    if set_level == nil or set_level == 0 or set_level >= 24 then
        set_level = 1
    end
    SAVE_DATA.current_level = set_level
end

return {
    init = function()
        cartdata("dadum_marksman")
        load_save_data()
    end,
    load_save_data = load_save_data,
    persist_save_data = function()
        dset(save_data_points.current_level, SAVE_DATA.current_level)
    end
}
end
package._c["managers/state"]=function()
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
    local act_to_perform = act_map[GAME_STATE.current_state]
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
            [GAME_STATES_ENUM.end_game_state] = end_game_state.update
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
end
package._c["states/game_state"]=function()
local map = require("src/map")
local camera_utils = require("src/camera")
local graphics_utils = require("utils/graphics")

local player = require("entities/player")
local arrow = require("entities/arrow")
local bullseye = require("entities/bullseye")
local spring = require("entities/spring")
local spikes = require("entities/spikes")

local decorations = require("managers/decorations")
local savefile_manager = require("managers/savefile")
local particles = require("managers/particles")
local level_text = require("managers/level_text")

local banner_countdown = 10
local level_done = false

local show_win_banner = false
local show_lost_banner = false

PLAYER_ORIGINAL_POS_IN_LVL = {x = 0, y = 0}

local function level_reset()
    arrow.clear()
    PLAYER.x = PLAYER_ORIGINAL_POS_IN_LVL.x
    PLAYER.y = PLAYER_ORIGINAL_POS_IN_LVL.y
    player.reset_for_new_level()
    show_win_banner = false
    show_lost_banner = false
end

local function new_level_init()
    arrow.clear()
    banner_countdown = 10
    spring.init()
    spikes.init()
    decorations.init()
    map.replace_entities(SAVE_DATA.current_level)
    camera_utils.focus_section(SAVE_DATA.current_level)
    player.reset_for_new_level()
    show_win_banner = false
    show_lost_banner = false
end

local function finish_game()
    graphics_utils.fade_all_immediately()
    SWITCH_GAME_STATE(GAME_STATES_ENUM.end_game_state)
    level_done = false
    show_win_banner = false
    show_lost_banner = false
end

function WIN_LEVEL()
    level_done = true
    show_win_banner = true
end

function LOSE_LEVEL()
    level_done = true
    show_lost_banner = true
end

local level_change_coroutine_registered = false

local function level_done_update()
    if btnp(5) then
        if show_win_banner and SAVE_DATA.current_level == 23 then
            -- player has just completed last elevel
            finish_game()
        else
            if not level_change_coroutine_registered then
                level_change_coroutine_registered = true
                add(COROUTINES,
                    graphics_utils.execute_in_between_fades(nil, function()
                    if show_win_banner then
                        SAVE_DATA.current_level = SAVE_DATA.current_level + 1
                        -- go to new level
                        new_level_init()
                    elseif show_lost_banner then
                        level_reset()
                    end

                    savefile_manager.persist_save_data()
                end, function()
                    level_done = false
                    level_change_coroutine_registered = false
                    pal()
                end))
            end
        end
    end
end

local function level_win_draw()
    local lvl_cords = camera_utils.get_game_space_coords_for_current_lvl()

    local banner_x1 = lvl_cords.x
    local banner_y1 = lvl_cords.y + 48

    local banner_x2 = banner_x1 + 127
    local banner_y2 = banner_y1 + 46

    rectfill(banner_x1, banner_y1, banner_x2, banner_y2, 7)

    local line_x1 = banner_x1 + 3
    local line_y1 = banner_y1 + 3

    local line_x2 = banner_x2 - 3
    local line_y2 = banner_y2 - 3

    rect(line_x1, line_y1, line_x2, line_y2, 6)
    pset(line_x1 - 1, line_y1 - 1, 6)
    pset(line_x2 + 1, line_y1 - 1, 6)
    pset(line_x1 - 1, line_y2 + 1, 6)
    pset(line_x2 + 1, line_y2 + 1, 6)

    print("good job!\n", banner_x1 + 14, banner_y1 + 14, 5)
    print("press ❎ to continue", banner_x1 + 14, banner_y1 + 26, 5)
end

local function level_lost_draw()
    local lvl_cords = camera_utils.get_game_space_coords_for_current_lvl()

    local banner_x1 = lvl_cords.x
    local banner_y1 = lvl_cords.y + 48

    local banner_x2 = banner_x1 + 127
    local banner_y2 = banner_y1 + 46

    rectfill(banner_x1, banner_y1, banner_x2, banner_y2, 7)

    local line_x1 = banner_x1 + 3
    local line_y1 = banner_y1 + 3

    local line_x2 = banner_x2 - 3
    local line_y2 = banner_y2 - 3

    rect(line_x1, line_y1, line_x2, line_y2, 6)
    pset(line_x1 - 1, line_y1 - 1, 6)
    pset(line_x2 + 1, line_y1 - 1, 6)
    pset(line_x1 - 1, line_y2 + 1, 6)
    pset(line_x2 + 1, line_y2 + 1, 6)

    print("you died!\n", banner_x1 + 14, banner_y1 + 14, 8)
    print("press ❎ to try again", banner_x1 + 14, banner_y1 + 26, 5)
end

local function draw_current_lvl()
    local game_space = camera_utils.get_game_space_coords_for_current_lvl()

    local base_x = (game_space.x + 128) - 20
    local base_y = game_space.y + 1

    -- level indicator container
    sspr(88, 0, 16, 8, base_x, base_y, 19, 13)

    local pos = base_x + 3 * (4 - #("" .. SAVE_DATA.current_level))

    print(SAVE_DATA.current_level, pos, base_y + 4, 5)
end

local function init()
    particles.init()
    player.init()
    new_level_init()
end

local function update()
    particles.update()
    decorations.update()
    if not level_done then
        player.update()
        arrow.update_all()
        spring.update()
    else
        level_done_update()
    end
end

local function draw()
    cls(12)

    decorations.draw_background()
    map.draw_level_decorations()
    level_text.draw_current_level_text()
    bullseye.draw()
    arrow.draw_all()
    player.draw()
    map.draw()
    spring.draw()
    spikes.draw()
    decorations.draw_decorations()
    particles.draw()
    draw_current_lvl()

    if level_done and show_lost_banner then
        if banner_countdown > 0 then
            banner_countdown = banner_countdown - 1
        else
            level_lost_draw()
        end
    end
    if level_done and show_win_banner then
        if banner_countdown > 0 then
            banner_countdown = banner_countdown - 1
        else
            level_win_draw()
        end
    end
end

return {init = init, update = update, draw = draw}
end
package._c["src/map"]=function()
local bullseye = require("entities/bullseye")
local spring = require("entities/spring")
local spikes = require("entities/spikes")
local decorations = require("managers/decorations")
local camera = require("src/camera")

local sprite_flags = {solid = 0, bullseye = 1, level_text_container = 2}

local function cell_has_flag(flag, x, y) return fget(mget(x, y), flag) end

local function is_solid(x, y)
    return cell_has_flag(sprite_flags.solid, flr(x / 8), flr(y / 8))
end

local function is_solid_area(x, y, w, h)
    return is_solid(x, y) or is_solid(x + w, y) or is_solid(x, y + h) or
               is_solid(x + w, y + h) or is_solid(x, y + h / 2) or
               is_solid(x + w, y + h / 2)
end

local map = {
    draw_level_decorations = function()
        local lvl_map_cords = camera.level_to_map_coords(SAVE_DATA.current_level)
        local game_cords = camera.get_game_space_coords_for_current_lvl()
        -- draw level text
        map(lvl_map_cords.x, lvl_map_cords.y, game_cords.x, game_cords.y, 16,
            16, 0x4)
        -- draw sprites without flags
        map(lvl_map_cords.x, lvl_map_cords.y, game_cords.x, game_cords.y, 16,
            16, 0x0)
    end,
    draw = function()
        local lvl_map_cords = camera.level_to_map_coords(SAVE_DATA.current_level)
        local game_cords = camera.get_game_space_coords_for_current_lvl()
        map(lvl_map_cords.x, lvl_map_cords.y, game_cords.x, game_cords.y, 16, 16, 0B11)
    end,
    sprite_flags = sprite_flags,
    cell_has_flag = cell_has_flag,
    is_solid_area = is_solid_area,
    replace_entities = function(current_level)
        local level_block_coords = camera.level_to_map_coords(current_level)

        local level_x2 = level_block_coords.x + 16
        local level_y2 = level_block_coords.y + 16

        for x = level_block_coords.x, level_x2 do
            for y = level_block_coords.y, level_y2 do
                local sprt = mget(x, y)
                if sprt == 3 or sprt == 4 then
                    mset(x, y, 0)
                    PLAYER.x = x * 8
                    PLAYER.y = y * 8
                    PLAYER_ORIGINAL_POS_IN_LVL.x = x * 8
                    PLAYER_ORIGINAL_POS_IN_LVL.y = y * 8
                end

                if sprt == 57 then
                    bullseye.replace_in_map(x, y, bullseye.orientation.left)
                elseif sprt == 58 then
                    bullseye.replace_in_map(x, y, bullseye.orientation.right)
                end

                if sprt == 13 then
                    spikes.replace_in_map(x, y, spikes.orientations.down)
                elseif sprt == 14 then
                    spikes.replace_in_map(x, y, spikes.orientations.up)
                end

                if sprt == 37 then
                    spring.replace_in_map(x, y, spring.orientations.top)
                elseif sprt == 40 then
                    spring.replace_in_map(x, y, spring.orientations.right)
                elseif sprt == 43 then
                    spring.replace_in_map(x, y, spring.orientations.bottom)
                elseif sprt == 44 then
                    spring.replace_in_map(x, y, spring.orientations.left)
                end

                decorations.replace_in_map(x, y, sprt)
            end
        end
    end
}

return map
end
package._c["entities/bullseye"]=function()
--- @type Bullseye
BULLSEYE = {
    x = 0,
    y = 0,
    orientation = 1,
    sprite_x = 0,
    sprite_y = 0,
    hitbox_x = 9,
    hitbox_y = 9,
    hitbox_r = 3
}

local orientations = {left = 1, right = 2}

return {
    orientation = orientations,
    replace_in_map = function(mapx, mapy, type)
        mset(mapx, mapy, 0)
        mset(mapx + 1, mapy, 0)
        mset(mapx, mapy + 1, 0)
        mset(mapx + 1, mapy + 1, 0)

        BULLSEYE.x = mapx * 8
        BULLSEYE.y = mapy * 8

        BULLSEYE.orientation = type
        if type == orientations.left or type == orientations.right then
            BULLSEYE.sprite_x = 40
            BULLSEYE.sprite_y = 0

            BULLSEYE.hitbox_r = 5
        end

        if type == orientations.left then
            BULLSEYE.hitbox_x = BULLSEYE.x + 9
            BULLSEYE.hitbox_y = BULLSEYE.y + 10

        elseif type == orientations.right then
            BULLSEYE.hitbox_x = BULLSEYE.x + 6
            BULLSEYE.hitbox_y = BULLSEYE.y + 10
        end
    end,

    draw = function()
        sspr(BULLSEYE.sprite_x, BULLSEYE.sprite_y, 16, 16, BULLSEYE.x,
             BULLSEYE.y, 16, 16, BULLSEYE.orientation == orientations.right)
    end
}
end
package._c["entities/spring"]=function()
local physics_utils = require("utils/physics")

--- @type Spring[]
SPRINGS = {}

local orientations = {left = 1, right = 2, top = 3, bottom = 4}

local function replace_in_map(mapx, mapy, orientation)
    --- @type BoxCollider
    local collider

    if orientation == orientations.top then
        collider = {x = 0, y = 4, h = 4, w = 8}
    elseif orientation == orientations.bottom then
        collider = {x = 0, y = 0, h = 4, w = 8}
    elseif orientation == orientations.left then
        collider = {x = 4, y = 0, h = 8, w = 4}
    elseif orientation == orientations.right then
        collider = {x = 0, y = 0, h = 8, w = 4}
    end

    mset(mapx, mapy, 0)
    add(SPRINGS, {
        x = mapx * 8,
        y = mapy * 8,
        state = 0,
        orientation = orientation,
        collider = collider
    })
end

--- @param s Spring
local function draw_spring(s)
    local base_sprite
    local flip_v = false
    local flip_h = false
    if s.orientation == orientations.top then
        base_sprite = 37
    elseif s.orientation == orientations.bottom then
        base_sprite = 37
        flip_v = true
    elseif s.orientation == orientations.right then
        base_sprite = 40
    elseif s.orientation == orientations.left then
        base_sprite = 40
        flip_h = true
    end

    spr(base_sprite + s.state, s.x, s.y, 1, 1, flip_h, flip_v)
end

--- @param s Spring
local function update_spring(s)
    if s.state > 0 and GLOBAL_TIMER % 3 == 0 then s.state = s.state - 1 end
end

--- if body is colliding with spring then spring it!
--- @param body BoxPhysicsBody
--- @return boolean if the body was springed or not
local function try_spring_body(body)
    for s in all(SPRINGS) do
        local is_colliding = physics_utils.box_collision(
                                 physics_utils.resolve_box_body_collider(s),
                                 physics_utils.resolve_box_body_collider(body))

        if is_colliding then
            s.state = 2
            sfx(26)
            if s.orientation == orientations.top then
                body.dy = -3.7
            elseif s.orientation == orientations.bottom then
                body.dy = 3.7
            elseif s.orientation == orientations.left then
                body.dx = -3.7
            elseif s.orientation == orientations.right then
                body.dx = 3.7
            end
            return
        end
    end
end

return {
    orientations = orientations,
    replace_in_map = replace_in_map,
    try_spring_body = try_spring_body,
    init = function() SPRINGS = {} end,
    draw = function() foreach(SPRINGS, draw_spring) end,
    update = function() foreach(SPRINGS, update_spring) end
}
end
package._c["utils/physics"]=function()
local math = require("utils/math")

--- @param collider_1 BoxCollider
--- @param collider_2 BoxCollider
local function box_collision(collider_1, collider_2)
    return collider_1.x < collider_2.x + collider_2.w and collider_2.x <
               collider_1.x + collider_1.w and collider_1.y < collider_2.y +
               collider_2.h and collider_2.y < collider_1.y + collider_1.h
end

--- @param box_body BoxPhysicsBody
--- @return BoxCollider
local function resolve_box_body_collider(box_body)
    return {
        x = box_body.x + box_body.collider.x,
        y = box_body.y + box_body.collider.y,
        w = box_body.collider.w,
        h = box_body.collider.h
    }
end

---@param c BoxCollider
---@param circx number
---@param circy number
---@param circr number
local function is_box_collider_in_circle(c, circx, circy, circr)
    local circ_center = {x = circx, y = circy}
    local box_corners = {
        {x = c.x, y = c.y}, {x = c.x + c.w, y = c.y}, {x = c.x, y = c.y + c.h},
        {x = c.x + c.w, y = c.y + c.h}
    }

    for corner in all(box_corners) do
        if math.vector_distance(corner, circ_center) <= circr then
            return true
        end
    end

    return false
end

return {
    resolve_box_body_collider = resolve_box_body_collider,
    is_box_collider_in_circle = is_box_collider_in_circle,
    box_collision = box_collision,
    --- @param point Vector
    --- @param box_top_left Vector 
    point_in_box = function(point, box_top_left, box_h, box_w)
        local bx1 = box_top_left.x + box_w
        local by1 = box_top_left.y + box_h
        return box_top_left.x < point.x and point.x < bx1 and box_top_left.y <
                   point.y and point.y < by1
    end,
    --- @param box_body BoxPhysicsBody
    --- @param mapx number mapx cell top left x cord
    --- @param mapy number mapx cell top left y cord
    is_body_colliding_with_map_tile = function(box_body, mapx, mapy)
        local is_cell_solid = fget(mget(mapx, mapy), 0)
        if not is_cell_solid then return false end

        local game_x = mapx * 8
        local game_y = mapy * 8

        return box_collision(resolve_box_body_collider(box_body),
                             {x = game_x, y = game_y, h = 8, w = 8})

    end
}
end
package._c["utils/math"]=function()
local math = {
    cap_with_sign = function(number, low, high)
        return sgn(number) * mid(low, abs(number), high)
    end,
    vector_distance = function(vec1, vec2)
        return sqrt((vec2.x - vec1.x) ^ 2 + (vec2.y - vec1.y) ^ 2)
    end,
    vector_magnitude = function(vec) return sqrt((vec.x) ^ 2 + (vec.y) ^ 2) end,
    get_nearest = function(num, ...)
        local options = {...}
        local nearest = options[1]
        local nearest_difference = abs(num - options[1])

        for opt in all(options) do
            local opt_difference = abs(num - opt)
            if opt_difference < nearest_difference then
                nearest = opt
                nearest_difference = opt_difference
            end
        end

        return nearest
    end
}

return math
end
package._c["entities/spikes"]=function()
local physics_utils = require("utils/physics")

--- @type Spike[]
SPIKES = {}

local orientations = {down = 1, up = 2}

local function replace_in_map(mapx, mapy, orientation)
    mset(mapx, mapy, 0)

    --- @type BoxCollider
    local collider

    if orientation == orientations.down then
        collider = {x = 0, y = 0, h = 3, w = 8}
    elseif orientation == orientations.up then
        collider = {x = 0, y = 5, h = 3, w = 8}
    end

    add(SPIKES, {
        x = mapx * 8,
        y = mapy * 8,
        orientation = orientation,
        collider = collider
    })
end

---@param s Spike
local function draw_spike(s)
    local sprtn
    if s.orientation == orientations.down then
        sprtn = 13
    elseif s.orientation == orientations.up then
        sprtn = 14
    end

    spr(sprtn, s.x, s.y)
end

return {
    orientations = orientations,
    replace_in_map = replace_in_map,
    init = function() SPIKES = {} end,
    draw = function() foreach(SPIKES, draw_spike) end
}
end
package._c["managers/decorations"]=function()
local camera = require("src/camera")

local types = {cloud1 = 1, cloud2 = 2}
local decoration_entities = {}

local function check_cloud_sprites(mapx, mapy, top_left_sprite)
    local tl = top_left_sprite
    local tc = tl + 1
    local tr = tc + 1
    local bl = tl + 16
    local bc = bl + 1
    local br = bc + 1

    return mget(mapx, mapy) == tl and mget(mapx + 1, mapy) == tc and
               mget(mapx + 2, mapy) == tr and mget(mapx, mapy + 1) == bl and
               mget(mapx + 1, mapy + 1) == bc and mget(mapx + 2, mapy + 1) == br
end

local function create_cloud_entity(mapx, mapy, cloud_type)
    mset(mapx, mapy, 0)
    mset(mapx + 1, mapy, 0)
    mset(mapx + 2, mapy, 0)
    mset(mapx, mapy + 1, 0)
    mset(mapx + 1, mapy + 1, 0)
    mset(mapx + 2, mapy + 1, 0)

    local c = {x = mapx * 8, y = mapy * 8, type = cloud_type}

    add(COROUTINES, cocreate(function()
        local has_moved = false
        local last_x_move = 0
        local last_y_move = 0
        local frames_to_wait = 34 + flr(rnd(10))
        while true do
            ::top_loop::
            while GLOBAL_TIMER % frames_to_wait ~= 0 do yield() end

            if has_moved then
                c.x = c.x - last_x_move
                c.y = c.y - last_y_move
                has_moved = false
                goto top_loop
            end

            last_x_move = flr(rnd(2)) - 1
            last_y_move = flr(rnd(2)) - 1

            c.x = c.x + last_x_move
            c.y = c.y + last_y_move
            has_moved = true

            yield()
        end
    end))

    function c:update() end

    function c:draw()
        if self.type == types.cloud1 then
            sspr(72, 32, 24, 16, self.x, self.y)
        else
            sspr(96, 32, 24, 16, self.x, self.y)
        end
    end

    add(decoration_entities, c)
end

local function add_grass(mapx, mapy)
    local g = {x = mapx * 8, y = (mapy - 1) * 8, state = 0}

    function g:update()
        if GLOBAL_TIMER % 35 == 0 then self.state = (self.state + 1) % 3 end
    end

    function g:draw() spr(27 + self.state, self.x, self.y) end

    add(decoration_entities, g)
end

local function replace_in_map(mapx, mapy, sprtn)
    if check_cloud_sprites(mapx, mapy, 73) then
        create_cloud_entity(mapx, mapy, types.cloud1)
    end

    if check_cloud_sprites(mapx, mapy, 76) then
        create_cloud_entity(mapx, mapy, types.cloud2)
    end

    if sprtn == 1 then add_grass(mapx, mapy) end
end

local function draw_background()
    local lvl_cords = camera.get_game_space_coords_for_current_lvl()

    sspr(0, 32, 31, 31, lvl_cords.x + 8, lvl_cords.y + 8, 112, 112)
end

local function draw_decorations()
    for e in all(decoration_entities) do e:draw() end
end

local function update() for e in all(decoration_entities) do e:update() end end

return {
    init = function() decoration_entities = {} end,
    update = update,
    draw_decorations = draw_decorations,
    draw_background = draw_background,
    replace_in_map = replace_in_map
}
end
package._c["src/camera"]=function()
--- @return Vector
local function level_to_map_coords(level_num)
    -- first we get 0 indexed coordinates for the "block" which 
    -- is the level

    local cell_idx = level_num - 1
    -- 4 rows of levels in map
    local mapy = flr(cell_idx / 8)

    --  8 levels per row
    local mapx = cell_idx % 8

    local mx = max(0, (mapx * 16))
    local my = max(0, (mapy * 16))

    return {x = mx, y = my}
end

--- @return Vector
local function get_game_space_coords_for_current_lvl()
    local lvl_map_coords = level_to_map_coords(SAVE_DATA.current_level)

    return {x = lvl_map_coords.x * 8, y = lvl_map_coords.y * 8}
end

return {
    level_to_map_coords = level_to_map_coords,
    get_game_space_coords_for_current_lvl = get_game_space_coords_for_current_lvl,
    camera_center = function(x, y, map_tiles_width, map_tiles_height)
        local cam_x = x - 60
        local cam_y = y - 60

        cam_x = mid(0, cam_x, map_tiles_width * 8 - 127)
        cam_y = mid(0, cam_y, map_tiles_height * 8 - 127)

        camera(cam_x, cam_y)
    end,
    focus_section = function(current_level)
        local lvl_cords = get_game_space_coords_for_current_lvl()

        camera(lvl_cords.x, lvl_cords.y)
    end
}
end
package._c["utils/graphics"]=function()
-- Node: this table was generated from http://kometbomb.net/pico8/fadegen.html
local fadeTable = {
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {1, 1, 129, 129, 129, 129, 129, 129, 129, 129, 0, 0, 0, 0, 0},
    {2, 2, 2, 130, 130, 130, 130, 130, 128, 128, 128, 128, 128, 0, 0},
    {3, 3, 3, 131, 131, 131, 131, 129, 129, 129, 129, 129, 0, 0, 0},
    {4, 4, 132, 132, 132, 132, 132, 132, 130, 128, 128, 128, 128, 0, 0},
    {5, 5, 133, 133, 133, 133, 130, 130, 128, 128, 128, 128, 128, 0, 0},
    {6, 6, 134, 13, 13, 13, 141, 5, 5, 5, 133, 130, 128, 128, 0},
    {7, 6, 6, 6, 134, 134, 134, 134, 5, 5, 5, 133, 130, 128, 0},
    {8, 8, 136, 136, 136, 136, 132, 132, 132, 130, 128, 128, 128, 128, 0},
    {9, 9, 9, 4, 4, 4, 4, 132, 132, 132, 128, 128, 128, 128, 0},
    {10, 10, 138, 138, 138, 4, 4, 4, 132, 132, 133, 128, 128, 128, 0},
    {11, 139, 139, 139, 139, 3, 3, 3, 3, 129, 129, 129, 0, 0, 0},
    {12, 12, 12, 140, 140, 140, 140, 131, 131, 131, 1, 129, 129, 129, 0},
    {13, 13, 141, 141, 5, 5, 5, 133, 133, 130, 129, 129, 128, 128, 0},
    {14, 14, 14, 134, 134, 141, 141, 2, 2, 133, 130, 130, 128, 128, 0},
    {15, 143, 143, 134, 134, 134, 134, 5, 5, 5, 133, 133, 128, 128, 0}
}

local function fade(i)
    for c = 0, 15 do
        if flr(i + 1) >= 16 then
            pal(c, 0, 1)
        else
            pal(c, fadeTable[c + 1][flr(i + 1)], 1)
        end
    end
end

local function fade_all_immediately() fade(16) end

local function complete_fade_coroutine()
    local fader = 0
    while fader <= 16 do
        fade(fader)
        fader = fader + 1
        yield()
    end
end

local function complete_unfade_coroutine()
    local fader = 17
    while fader >= 0 do
        fade(fader)
        fader = fader - 1
        yield()
    end
end

local function execute_in_between_fades(fn_before, fn_in_between, fn_after)
    return cocreate(function()
        if fn_before ~= nil then fn_before() end

        local fade_routine = cocreate(complete_fade_coroutine)
        while costatus(fade_routine) ~= "dead" do
            coresume(fade_routine)
            yield()
        end

        if fn_in_between ~= nil then fn_in_between() end

        local unfade_routine = cocreate(complete_unfade_coroutine)
        while costatus(unfade_routine) ~= "dead" do
            coresume(unfade_routine)
            yield()
        end

        if fn_after ~= nil then fn_after() end
    end)
end

return {
    fade = fade,
    fade_all_immediately = fade_all_immediately,
    complete_fade_coroutine = complete_fade_coroutine,
    complete_unfade_coroutine = complete_unfade_coroutine,
    execute_in_between_fades = execute_in_between_fades
}
end
package._c["entities/player"]=function()
local map = require("src/map")

local math = require("utils/math")
local physics_utils = require("utils/physics")

local bow = require("entities/bow")
local spring = require("entities/spring")

local particles = require("managers/particles")

PLAYER = {
    x = 0,
    y = 0,
    dx = 0,
    dy = 0,
    ddy = 0.17,
    dir = 1,
    is_dead = false,
    collider = {x = 1, y = 0, w = 4, h = 15},
    is_jumping = false,
    changing_bow_dir = false
}

local player_stepping_anim_left_foot = true

local function change_pl_dir(new_dir)
    assert(new_dir == -1 or new_dir == 1, "invalid player dir")
    PLAYER.dir = new_dir
    if new_dir == 1 then
        PLAYER.collider = {x = 1, y = 0, w = 4, h = 15}
    else
        PLAYER.collider = {x = 2, y = 0, w = 4, h = 15}
    end
end

local function is_player_on_ground()
    local pl_c = physics_utils.resolve_box_body_collider(PLAYER)
    return map.is_solid_area(pl_c.x, pl_c.y + PLAYER.dy + 1, pl_c.w, pl_c.h)
end

local function move_player()
    local jumping_mod = 0.55
    if not PLAYER.is_jumping then jumping_mod = 1 end
    if not PLAYER.changing_bow_dir then
        if btn(0) then
            PLAYER.dx = PLAYER.dx - 1 * jumping_mod
        elseif btn(1) then
            PLAYER.dx = PLAYER.dx + 1 * jumping_mod
        end
        if btnp(2) and not PLAYER.is_jumping then PLAYER.dy = -2.3 end
    end

    -- cap deltas
    PLAYER.dx = math.cap_with_sign(PLAYER.dx, 0, 3)
    PLAYER.dy = math.cap_with_sign(PLAYER.dy, 0, 4)

    -- apply velocity

    -- horizontal
    local pl_c = physics_utils.resolve_box_body_collider(PLAYER)
    if not map.is_solid_area(pl_c.x + PLAYER.dx, pl_c.y, pl_c.w, pl_c.h) then
        PLAYER.x = PLAYER.x + PLAYER.dx
    else
        PLAYER.dx = 0
    end

    -- vertical
    if not map.is_solid_area(pl_c.x, pl_c.y + PLAYER.dy, pl_c.w, pl_c.h) then
        PLAYER.y = PLAYER.y + PLAYER.dy

    else
        PLAYER.dy = 0
    end

    if is_player_on_ground() then
        if PLAYER.is_jumping then
            -- then we're landing
            sfx(21)
            for _ = 1, 5 do
                local displacement = rnd(4) - 4
                particles.make_particle(PLAYER.x + 4 + displacement,
                                        PLAYER.y + 16, -PLAYER.dx * 0.1,
                                        -PLAYER.dy * 0.1, 0, 1, 7, 7)
            end
        end
        PLAYER.is_jumping = false

        if abs(PLAYER.dx) > 0 and GLOBAL_TIMER % 6 == 0 then sfx(20) end
    else
        PLAYER.is_jumping = true
    end

    -- apply gravity
    PLAYER.dy = PLAYER.dy + PLAYER.ddy

    -- apply friction
    PLAYER.dx = PLAYER.dx * 0.5
    if abs(PLAYER.dx) < 0.1 then PLAYER.dx = 0 end
end

local function check_spikes()
    local resolved_player_collider = physics_utils.resolve_box_body_collider(
                                         PLAYER)
    for s in all(SPIKES) do
        local spike_resolved_collider = physics_utils.resolve_box_body_collider(
                                            s)
        local is_colliding = physics_utils.box_collision(
                                 resolved_player_collider,
                                 spike_resolved_collider)
        if is_colliding then
            sfx(19)
            -- draw puff particles, smoke and fire
            for _ = 1, 25 do
                local px = PLAYER.x + flr(rnd(8))
                local py = PLAYER.y + flr(rnd(16))
                local xv = rnd(0) - 0.5
                local lifetime = 10 + flr(rnd(10))
                particles.make_particle(px, py, xv, -1, 0, 1, rnd({5, 6, 7}),
                                        lifetime)
            end

            for _ = 1, 5 do
                local px = PLAYER.x + flr(rnd(8))
                local py = PLAYER.y + 10 + flr(rnd(6))
                local xv = rnd(0) - 0.5
                particles.make_particle(px, py, xv, -1, 0, 1, rnd({8, 9, 10}), 7)
            end

            PLAYER.is_dead = true
            LOSE_LEVEL()
            return
        end
    end
end

local function change_bow_direction()
    if btn(4) then
        PLAYER.changing_bow_dir = true
        local left = btn(0)
        local right = btn(1)
        local up = btn(2)
        local down = btn(3)

        local initial_bow_dir = BOW.dir

        -- first check corners
        -- see bow.lua for map of directions
        if up and left then
            change_pl_dir(-1)
            bow.change_dir(4)
        elseif up and right then
            change_pl_dir(1)
            bow.change_dir(2)
        elseif down and left then
            change_pl_dir(-1)
            bow.change_dir(6)
        elseif down and right then
            change_pl_dir(1)
            bow.change_dir(8)
        elseif up then
            change_pl_dir(1)
            bow.change_dir(3)
        elseif right then
            change_pl_dir(1)
            bow.change_dir(1)
        elseif down then
            change_pl_dir(1)
            bow.change_dir(7)
        elseif left then
            change_pl_dir(-1)
            bow.change_dir(5)
        end

        if initial_bow_dir ~= BOW.dir then sfx(22) end
    else
        PLAYER.changing_bow_dir = false
    end
end

local function draw_player()
    local flip_x = PLAYER.dir == -1

    local function draw_pl_sprite(sprt_x)
        sspr(sprt_x, 0, 8, 16, PLAYER.x, PLAYER.y, 8, 16, flip_x)
    end

    if PLAYER.is_jumping then
        draw_pl_sprite(80)
    elseif PLAYER.dx == 0 then
        -- idle
        draw_pl_sprite(56)
    else
        if player_stepping_anim_left_foot then
            draw_pl_sprite(64)
        else
            draw_pl_sprite(72)
        end
    end
end

return {
    init = function()
        -- player = {x = 5 * 8, y = 11 * 8} 
        bow.init()
    end,
    reset_for_new_level = function()
        change_pl_dir(1)
        PLAYER.dx = 0
        PLAYER.dy = 0
        PLAYER.is_dead = false
        BOW.x = PLAYER.x
        BOW.y = PLAYER.y + 4
        if SAVE_DATA.current_level == 1 then
            -- aim forward for first level
            bow.change_dir(1)
        else
            bow.change_dir(7)
        end

    end,
    update = function()
        if PLAYER.is_dead then return end

        change_bow_direction()
        move_player()
        check_spikes()
        spring.try_spring_body(PLAYER)

        bow.update()
    end,
    draw = function()
        if PLAYER.is_dead then return end

        draw_player()
        bow.draw()
    end
}

end
package._c["entities/bow"]=function()
local arrows = require("entities/arrow")

--[[
directions:
  4   3   2
  5  bow  1
  6   7   8
--]]

BOW = {x = 0, y = 0, dir = 1}

local function fire_arrow()
    local arrow_dir = (BOW.dir - 1) / 8
    -- 0.25 is up 
    -- 0.75 is down
    if btnp(5) then arrows.fire_arrow(BOW.x, BOW.y, 5, arrow_dir) end
end

return {
    change_dir = function(dir) BOW.dir = dir end,
    init = function()
        BOW.x = PLAYER.x
        BOW.y = PLAYER.y + 4
    end,
    update = function()
        BOW.x = PLAYER.x
        BOW.y = PLAYER.y + 4

        fire_arrow()
    end,
    draw = function()
        local srpn = 19
        if BOW.dir == 1 or BOW.dir == 5 then
            srpn = 19
        elseif BOW.dir == 3 or BOW.dir == 7 then
            srpn = 18
        else
            srpn = 20
        end

        local flip_x = BOW.dir == 4 or BOW.dir == 5 or BOW.dir == 6
        local flip_y = BOW.dir == 6 or BOW.dir == 7 or BOW.dir == 8

        spr(srpn, BOW.x, BOW.y, 1, 1, flip_x, flip_y)
    end
}
end
package._c["entities/arrow"]=function()
local math = require("utils/math")
local map = require("src/map")
local spring = require("entities/spring")
local physics_utils = require("utils/physics")

local particles = require("managers/particles")

--- @type Arrow[]
ARROWS = {}

local function fire_arrow(x, y, force, angle)
    local dx = cos(angle) * force
    local dy = sin(angle) * force

    --- @type BoxCollider
    local collider = {x = 0, y = 0, h = 0, w = 0}

    --- @type Arrow
    local a = {
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        lifetime = 140,
        is_stuck = false,
        collider = collider
    }

    sfx(23)
    add(ARROWS, a)
end

--- @param a Arrow
local function get_clamped_arrow_dir(a)
    local angle = atan2(a.dx, a.dy)

    -- see quadrant in bow.lua
    local segment = math.get_nearest(angle, 1, 0.11, 0.25, 0.38, 0.5, 0.63,
                                     0.75, 0.86)
    local directions_map = {
        [1] = 1,
        [0.11] = 2,
        [0.25] = 3,
        [0.38] = 4,
        [0.5] = 5,
        [0.63] = 6,
        [0.75] = 7,
        [0.86] = 8
    }

    return directions_map[segment]
end

--- @param a Arrow
--- @return Vector
local function get_collision_vec(a)
    local arrow_dir = get_clamped_arrow_dir(a)

    local collision_x
    local collision_y

    if arrow_dir == 1 then
        collision_x = a.x + 5
        collision_y = a.y + 4
    elseif arrow_dir == 2 then
        collision_x = a.x + 5
        collision_y = a.y + 3
    elseif arrow_dir == 3 then
        collision_x = a.x + 4
        collision_y = a.y + 3
    elseif arrow_dir == 4 then
        collision_x = a.x + 3
        collision_y = a.y + 3
    elseif arrow_dir == 5 then
        collision_x = a.x + 3
        collision_y = a.y + 4
    elseif arrow_dir == 6 then
        collision_x = a.x + 3
        collision_y = a.y + 5
    elseif arrow_dir == 7 then
        collision_x = a.x + 4
        collision_y = a.y + 5
    elseif arrow_dir == 8 then
        collision_x = a.x + 5
        collision_y = a.y + 5
    end

    return {x = collision_x, y = collision_y}
end

--- @param a Arrow
local function make_floor_walls_colission_dust(a)
    local cv = get_collision_vec(a)
    for _ = 1, 5 do
        local displacement = rnd(4) - 4
        particles.make_particle(cv.x + displacement, cv.y + displacement,
                                -a.dx * 0.1, -a.dy * 0.1, 0, 1, rnd({5, 6, 7}),
                                7)
    end
end

--- Gets the direction of the arrow clamped to one of the 8 cardinal directions
--- @param a Arrow
local function collide_with_floor_walls(a)
    -- we want to check if the 1/3 nearest to the sprite limit in the direction in which
    -- the arrow is moving, is colliding with a wall or floor (a collidable sprite). If yes
    -- then stop arrow
    local collision_vec = get_collision_vec(a)

    local is_colliding_with_solid = map.cell_has_flag(map.sprite_flags.solid,
                                                      flr(collision_vec.x / 8),
                                                      flr(collision_vec.y / 8))

    -- if collision point lies in a "solid" map tile then stop movement
    if is_colliding_with_solid then
        local angle = atan2(a.dx, a.dy)
        a.x = a.x - cos(angle) * 3
        a.y = a.y - sin(angle) * 3

        a.is_stuck = true
        sfx(24)
        make_floor_walls_colission_dust(a)
    end
end

--- @param a Arrow
local function make_bullseye_colission_dust(a)
    local cv = get_collision_vec(a)
    for _ = 1, 10 do
        local displacement = rnd(4) - 4
        local x_speed = -a.dx * 0.05
        local y_speed = -a.dy * 0.1 - rnd(0.2)
        particles.make_particle(cv.x + displacement, cv.y + displacement,
                                x_speed, y_speed, 0, 1, rnd({7, 10, 11}), 7)
    end
end

--- @param a Arrow
local function collide_with_bullseye(a)
    local resolved_arrow_c = physics_utils.resolve_box_body_collider(a)

    local is_colliding = physics_utils.is_box_collider_in_circle(
                             resolved_arrow_c, BULLSEYE.hitbox_x,
                             BULLSEYE.hitbox_y, BULLSEYE.hitbox_r)

    if is_colliding then
        a.is_stuck = true
        sfx(25)
        make_bullseye_colission_dust(a)
        WIN_LEVEL()
    end
end

--- @param a Arrow
local function update_collider(a)
    local arrow_dir = get_clamped_arrow_dir(a)
    if arrow_dir == 1 then
        a.collider = {x = 6, y = 3, w = 2, h = 3}
    elseif arrow_dir == 2 then
        a.collider = {x = 4, y = 1, w = 3, h = 3}
    elseif arrow_dir == 3 then
        a.collider = {x = 3, y = 0, w = 3, h = 2}
    elseif arrow_dir == 4 then
        a.collider = {x = 1, y = 1, w = 3, h = 3}
    elseif arrow_dir == 5 then
        a.collider = {x = 0, y = 3, w = 2, h = 3}
    elseif arrow_dir == 6 then
        a.collider = {x = 1, y = 4, w = 3, h = 3}
    elseif arrow_dir == 7 then
        a.collider = {x = 3, y = 6, w = 3, h = 2}
    elseif arrow_dir == 8 then
        a.collider = {x = 4, y = 4, w = 3, h = 3}
    end
end

local function make_trail(a)
    if rnd(1) < 0.8 then return end
    local collision_vec = get_collision_vec(a)
    local diffx = (collision_vec.x - a.x)
    local diffy = (collision_vec.y - a.y)

    local colors = {7, 8, 9}
    particles.make_pixel_particle(a.x + diffy, a.y + diffx, 0, 0, 0.01,
                                  rnd(colors), 7)
end

--- @param a Arrow
local function update_arrow(a)
    if a.lifetime == 0 then
        del(ARROWS, a)
        return
    else
        a.lifetime = a.lifetime - 1
    end

    if a.is_stuck then return end

    a.y = a.y + a.dy
    a.x = a.x + a.dx

    -- apply gravity
    a.dy = a.dy + 0.12

    update_collider(a)
    collide_with_floor_walls(a)
    collide_with_bullseye(a)
    make_trail(a)
    spring.try_spring_body(a)
end

--- @param a Arrow
local function draw_arrow(a)
    local arrow_dir = get_clamped_arrow_dir(a)

    local sprtn

    if arrow_dir == 1 or arrow_dir == 5 then
        sprtn = 35
    elseif arrow_dir == 3 or arrow_dir == 7 then
        sprtn = 34
    else
        sprtn = 36
    end

    local flip_x = arrow_dir == 4 or arrow_dir == 5 or arrow_dir == 6
    local flip_y = arrow_dir == 6 or arrow_dir == 7 or arrow_dir == 8

    spr(sprtn, a.x, a.y, 1, 1, flip_x, flip_y)
end

return {
    clear = function() ARROWS = {} end,
    update_all = function() foreach(ARROWS, update_arrow) end,
    draw_all = function() foreach(ARROWS, draw_arrow) end,
    fire_arrow = fire_arrow
}
end
package._c["managers/particles"]=function()
PARTICLES = {}

local function make_circle_particle(x, y, dx, dy, dyy, size, c, lifetime)
    local p = {
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        dyy = dyy,
        c = c,
        size = size,
        lifetime = lifetime
    }

    function p:update()
        if self.lifetime == 0 then del(PARTICLES, self) end
        self.lifetime = self.lifetime - 1

        self.x = self.x + self.dx
        self.y = self.y + self.dy
        self.dy = self.dy + self.dyy
    end

    function p:draw() circfill(self.x, self.y, self.size, self.c) end

    add(PARTICLES, p)
end

local function make_pixel_particle(x, y, dx, dy, dyy, c, lifetime)
    local p = {
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        dyy = dyy,
        c = c,
        size = 1,
        lifetime = lifetime
    }

    function p:update()
        if self.lifetime == 0 then del(PARTICLES, self) end
        self.lifetime = self.lifetime - 1

        self.x = self.x + self.dx
        self.y = self.y + self.dy
        self.dy = self.dy + self.dyy
    end

    function p:draw() pset(self.x, self.y, self.c) end

    add(PARTICLES, p)
end

return {
    make_pixel_particle = make_pixel_particle,
    make_particle = make_circle_particle,
    init = function() PARTICLES = {} end,
    update = function() for p in all(PARTICLES) do p:update() end end,
    draw = function() for p in all(PARTICLES) do p:draw() end end
}
end
package._c["managers/level_text"]=function()
local camera = require("src/camera")

return {
    draw_current_level_text = function()
        local lvl_pos = camera.get_game_space_coords_for_current_lvl()
        if SAVE_DATA.current_level == 1 then
            print("move with ⬅️➡️⬇️⬆️", 17, 103, 5)
            print("fire arrows with ❎")
        end

        if SAVE_DATA.current_level == 2 then
            print("use ⬅️➡️⬇️⬆️", 143, 12, 5)
            print("while pressing 🅾️")
            print("to aim")
        end

        if SAVE_DATA.current_level == 3 then
            print("springs will", 314, 88, 5)
            print("take you where")
            print("you need to go")
        end

        if SAVE_DATA.current_level == 4 then
            print("springs also work", 398, 14, 5)
            print("on arrows!")
        end

        if SAVE_DATA.current_level == 5 then
            print("be careful with", lvl_pos.x + 37, 13, 5)
            print("spikes. if you touch")
            print("them you will")
            print("spontaneously")
            print("combust")
        end

        if SAVE_DATA.current_level == 8 then
            cursor(lvl_pos.x + 12, 14)
            color(5)
            print("lets test your")
            print("reflexes")
        end
    end
}
end
package._c["states/title_state"]=function()
local print_utils = require("utils/print")
local savefile = require("managers/savefile")
local graphics_utils = require("utils/graphics")

local menu = {}

local function init()
    menu = {}
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
    print_utils.print_centered("v1.0", 30, 6)
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

        graphics_utils.fade_all_immediately()
        add(COROUTINES, cocreate(graphics_utils.complete_unfade_coroutine))
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
end
package._c["utils/print"]=function()
local function get_length_of_text(text) return #text * 4 end

local function print_centered_with_backdrop(text, y, text_color, backdrop_color)
    if text_color == nil then text_color = 7 end
    if backdrop_color == nil then backdrop_color = 0 end

    local text_x = 64 - get_length_of_text(text) / 2

    print(text, text_x + 1, y + 1, backdrop_color)
    print(text, text_x, y, text_color)
end

local menu_item_bobbing = false

local function wrap_text_at_size(text, max_width)
    local end_text = ""
    local tokens = split(text, " ")

    local current_line = ""
    for t in all(tokens) do
        local line_size = #current_line * 4
        local token_size = #t * 4

        -- check if new token plus space is more than width
        if line_size + token_size + 4 > max_width then
            end_text = end_text .. "\n" .. current_line
            current_line = ""
        end

        current_line = current_line .. " " .. t
    end

    end_text = end_text .. "\n" .. current_line
    return end_text
end

local function print_text_with_outline(text, x, y, text_color, bg_color)
    if text_color == nil then text_color = 7 end
    if bg_color == nil then bg_color = 0 end

    for _x = -1, 1 do
        -- print outline on x dim
        for _y = -1, 1 do
            -- and outline on y dim
            print(text, _x + x, _y + y, bg_color)
        end
    end
    print(text, x, y, text_color)
end

local function print_centered_text_with_outline(text, y, text_color, bg_color)
    local text_x = 64 - get_length_of_text(text) / 2
    print_text_with_outline(text, text_x, y, text_color, bg_color)
end

return {
    get_length_of_text = get_length_of_text,
    wrap_text_at_size = wrap_text_at_size,
    print_text_with_outline = print_text_with_outline,
    print_centered_text_with_outline = print_centered_text_with_outline,
    print_centered = function(text, y, color)
        if color == nil then color = 7 end
        local text_x = 64 - get_length_of_text(text) / 2
        print(text, text_x, y, color)
    end,
    print_menu_item = function(text, y, is_selected)
        print_centered_with_backdrop(text, y, 0, 6)
        if is_selected then
            local selector_x = (64 - get_length_of_text(text) / 2) - 10

            if GLOBAL_TIMER % 13 == 0 then
                menu_item_bobbing = not menu_item_bobbing
            end

            if menu_item_bobbing then selector_x = selector_x - 1 end

            sspr(65, 25, 7, 6, selector_x, y)
        end
    end,
    print_centered_with_backdrop = print_centered_with_backdrop
}
end
package._c["states/intro_state"]=function()
local decorations = require("managers/decorations")
local print_utils = require("utils/print")

local is_start_text_on = false

local function init() end

local function update()
    if GLOBAL_TIMER % 30 == 0 then is_start_text_on = not is_start_text_on end

    if btnp(5) then SWITCH_GAME_STATE(GAME_STATES_ENUM.gameplay_state) end
end

local function draw_intro_text()
    color(5)
    print("hear ye! hear ye!", 32, 16)

    local wrapped_text = print_utils.wrap_text_at_size(
                             "the most prestigious archery competition is now open to all that can string a bow. he who completes every stage will have an assured place among the queen's own marksmen",
                             11 * 8)
    cursor(19, 22)
    print(wrapped_text)

    -- for off text
    local start_fg_c = 7
    local start_bg_c = 5

    if is_start_text_on then
        start_fg_c = 5
        start_bg_c = 7
    end

    print_utils.print_centered_text_with_outline("press ❎ to start", 89,
                                                 start_fg_c, start_bg_c)
end

local function draw()
    cls(12)
    sspr(0, 32, 31, 31, 0, 0, 128, 128)
    map(96, 48, 0, 0, 16, 16)

    draw_intro_text()
end

return {init = init, update = update, draw = draw}
end
package._c["states/end_game_state"]=function()
local print_utils = require("utils/print")
local savefile = require("managers/savefile")
local graphics_utils = require("utils/graphics")

local function init()
    camera()
    add(COROUTINES, cocreate(graphics_utils.complete_unfade_coroutine))
end

local function update()
    if btnp(5) then
        SAVE_DATA.current_level = 1
        savefile.persist_save_data()
        SWITCH_GAME_STATE(GAME_STATES_ENUM.title_state)
    end
end

local function draw_text()
    color(5)

    local wrapped_text = print_utils.wrap_text_at_size(
                             "what an honor! for your exceptional skill and dexterity, you've been named the princess' personal marksman.",
                             11 * 8)
    cursor(18, 16)
    print(wrapped_text)

    -- for off text
    local start_fg_c = 7
    local start_bg_c = 5

    print_utils.print_text_with_outline("thanks for playing ♥", 5 * 8,
                                        13.5 * 8, start_fg_c, start_bg_c)
    print_utils.print_text_with_outline("press ❎ to restart", 5.5 * 8, 14.5 * 8,
                                        start_fg_c, start_bg_c)
end

local function draw()
    cls(12)
    sspr(0, 32, 31, 31, 0, 0, 128, 128)
    map(80, 48, 0, 0, 16, 16)

    draw_text()
end

return {init = init, update = update, draw = draw}
end
package._c["managers/coroutines"]=function()
COROUTINES = {}

local function update_cors()
    for c in all(COROUTINES) do
        local status = costatus(c)
        if status == "suspended" then
            coresume(c)
        elseif status == "dead" then
            del(COROUTINES, c)
        end
    end
end

return {update = update_cors}
end
function require(p)
local l=package.loaded
if (l[p]==nil) l[p]=package._c[p]()
if (l[p]==nil) l[p]=true
return l[p]
end
-- Marksman
-- by Dadum

local save_manager = require("managers/savefile")
local state_manager = require("managers/state")
local coroutine_manager = require("managers/coroutines")

GLOBAL_TIMER = 0

function _init()
    music(0)
    save_manager.init()
    state_manager.init()
end

function _update()
    GLOBAL_TIMER = GLOBAL_TIMER + 1
    state_manager.update()
    coroutine_manager.update()
end

function _draw()
    state_manager.draw()
end
__gfx__
00000000333333334444444400111000000000000000000000000000600000000000000060000000600000006666666600006666444444440000000000000000
00000000444444444544555401111000000000000000000000000000073330006000000007333000073330006777777666666776070707070000000003333330
00700700445454544455444401111110000000000000000000000000037333300733300003733330037333306677777777777766090909090000000003777730
0007700044454444454454540aaaa000000000000000000000000000333333330373333033333333333333300677777777777760000000000000000003733730
0007700044544444445445440aaaa00000000000000000007777600000aa5a003333333300aa5a0000aa5a000677777777777760000000000000000003773730
0070070044455444445454440bbbb00000000000000000778887760000aaaa0000aa5a0000aaaa0000aaaa006677777777777766000000009090909000377300
0000000045444454454454540bbbb00000000000000007787778776000aa000000aaaa0000aa000000aa00006776666667777776000000007070707000033000
0000000044444444444444440dddd0000000000000007787888787760333300000aa000003333000033330006666000066666666000000004444444400004000
00000000d5d5d5d5004dd40000000400004444000007887877787876033330000333300003333000033330000000000000000000000000000000000000000000
000000005ddddddd044334400000044000000dd00007878788787876033430000333300003343000033430000000000000000000000000000000000000000000
00000000dd55d5d54400304400000044000003d400078787887878760334300003343000033430000334b0000000000000000000000000000000000000000000
000000005d5d5ddd000030000000033d0000330400078778778788760334300003b430000334b00003b440000000000000000000000000000000000000000000
00000000ddd5d5d5000000000000333d00033004000778878877876003b4b0000344b00003b44000034440000000000000000000000000000000000000000000
000000005d5d55dd00000000000000440000000400007787778874000b4040000b4040000b4040000b4050000000000000000000000000000060000000000000
00000000ddddddd50000000000000440000000000000077888876540004040000050400000405000005000000000000000000000000000000007330000904409
000000005d5d5d5d000000000000040000000000000000777776400400505000000050000050000000000000030b030000300b00003030b0033373000044a944
00000000000000000000500000000000000000000000000000000000000000000070000000070000000007000060060000000700000000000033333000488884
000000000000000000055500000000000000555000000000000000000000000000400000000400000000040000066000000004000000000000aa5a000054ee85
000000000000000000004000000000000000045000000000000000007444444760400000060400000606040074444447000004060000000003aaaa0000042284
000000000000000000004000600000500000405000000000000000000006600006400000606400006060640000000000000004600000000033333340000e2288
0000000000000000000040000644445500040000000000007444444700600600064000006064000060606400000000000000046000000000333bb33d00411144
00000000000000000000400060000050004000007444444700066000000660006040000006040000060604000000000000000406000000003bb44b0404515144
0000000000000000000070000000000064000000000660000060060000600600004000000004000000000400000000000000040000000000b040400404444446
00000000000000000007070000000000060000000060060000066000000660000070000000070000000007000000000000000700000000000540504005444466
00000000044444000044444000000000666666665555555566666666000000000000000000577000007750000000000000000000000000000000000000000000
00000000449999dddd99994400000000666575757575757575757666000000000000050000000000000000000000000000000000000000000000000003333330
00000004490000000000009440000000666777777777777777777666000000000000055000577000007750000000000000000000000000000000000003777730
00000044900000000000000944000000657777777777777777777776000000000444455600507000007050000000000000000000000000000000000003733730
00000499000000000000000099400000677777777777777777777756000008000444455600570000007700000000000000000000000000000000000003773730
0000499000000000000000000994000065777777777777777777777600008a800000055000507000007050000000000000000000000000000000000003737730
00049000000000000000000000094000677777777777777777777756000008000000050000577000007750000000000000000000000000000000000003773730
04440000000000000000000000004440657777777777777777777776000003000000000000000000000000000000000000000000000000000000000003733730
cccccccccccccccccccccccccccccccc577777777777777777777755000000000000000000000000000000000000000000000000000000000000000003737730
cccccccccccccccccccccccccccccccc557777777777777777777775000000030000000000000000000000000000000000000000000000000000000003777730
cccccccccccccccccccccccccccccccc577777777777777777777755000000033000000000000000077700077700000000007770000007770000000000377300
cccccccccccccccccccccccccccccccc557777777777777777777775000000033000000000000000777770777777700000077777777777777000000000037300
cccccccccccccccccccccccccccccccc577777777777777777777755000000333300000000000777777777777777770000677777777777777777000000043000
cccccccccccccccccccccccccccccccc557777777777777777777775000000333300000000007777777777777777777006777777777777777777700000044000
cccccccccccccccccccccccccccccccc577777777777777777777755000003333330000000077777777777777777777706777777777777777777760000044000
cccccccccccccccccccccccccccccccc557777777777777777777775000003333330000000777777777777777777777606677777777777777777776000044000
cccccccccccccccccccccccccccccccc677777777777777777777756000033333333000000777777777777777777777600677777777777777777776000000000
cccccccccccccccccccccccccccccccc657777777777777777777776000033333333000000677777777777777777776000677777777777777777776000000000
cccccccccccccccccccccccccccccccc677777777777777777777756000033333333000000067777777777777777760000677777777777777777760000000000
cccccccccccccccccccccccccccccccc657777777777777777777776000003333330000000006777777777667776600000677777777777777777600000000000
cccccccccccccccccccccccccccccccc677777777777777777777756000000333300000000000666776666006660000000066777766777776666000000000000
cccccccccccccccccccccccccccccccc666777777777777777777666000000022000000000000006660000000000000000006777600677760000000000000000
cccccccccccccccccc15cccccccccccc666757575757575757575666000000044000000000000000000000000000000000000666000066600000000000000000
ccccccccccccccc7711117cccccccccc666666665555555566666666000000044000000000000000000000000000000000000000000000000000000000000000
cccccccccccccc7cc55511c7cccccccc770070077007770007007007700777000770007007700707007070000000000000000000000000000000000000000000
cccccccccccccccc7777777ccccccccc700707070707000070070707070070700707070707070707070707000000000000000000000000000000000000000000
cccccccccccccccc115151cccccccccc700707070707700070077707700070000707077707070707070007000000000000000000000000000000000000000000
ccccccccccccccc11511511ccccccccc770070077007770700070707070070700770070707700070070007000000000000000000000000000000000000000000
ccccccccccccccc11111551ccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccc1551151511cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccc5511111515cccccccc070700707077707077000077707070777077707770770077707007077707770070070077707007077700000000000000
cccc11ccccccc1111155111511cccccc707070707070000070070007007770700070007000777070707707070007000707070070707707070000000000000000
ccc7715ccccc11111511151155cccccc700070707007707070000007007070770007707700707070707077077000770777070070707077077000000000000000
ccc1511ccccc515155151555115ccccc700070070077707077070007007070777077707770770077707007077707770707077077707007077700000000000000
ccc51151ccc55111111111511511cccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc1115151cc151111151111111115ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc1151111c15115151515151155111cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c111111111511551115111151155155c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11511115155155151111115115111151000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111151511151515151000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
110000000000000000110000b20000111100d0d0d093001100000000000000111100000000000000000000000000001111000000000000000000000011000011
110000000000000000000000000000111100a3b2b2b2b2b2b2b2b2b2b2b2c2111100000000000000000000000000001111000000000000000000000000000011
110000000000000000110000930000111111000000000011000094a4b400001111000000000011111111000000000011110094a4b40000000000000011000011
110000000000000000000000000000111100005252525252525252525200c21111000000000000c4d4e400000000001111000000000000000000000000000011
110011111111111100520000000000111100000000111100000095a5b5000011110000000011000000b2110000000011110095a5b50000000000000011000011
110000111111111111111111000000111111111111111111111111111100c21111000000000000c5d5e500000000001111000000000000000000000000000011
110000000000001100110011111111111111000000000000000000000000001111000000118200520000c2110000001111000000c4d4e4000000730011000011
110000d0d0b2d0d0d0b2d0d0000000111182b2b2b2b2b2b2b2b2b2b2b200c2111100000000000000000000000000001111000000000000000000000000000011
1100000000000000000000000000001111f0c4d4e494a4b4c4d4e400000000111100001182000011118200001100001111000000c5d5e5000000110011000011
110000000000000000000000000000111182005252525252525252525252c2111100000000000000000000000000001111000000000000000000000000000011
1100000000000000000000c4d4e400111111c5d5e595a5b5c5d5e5c4d4e4f3111100001182c21100a30000c21100001111000000000000000000110011000011
110000000000000000000000001100111182001111111111111111111111111111000094a4b40000000094a4b400001111000000000000000000000000000011
115200e0e0000000000000c5d5e500111100005200001100001100c5d5e5f4111100001182001100000000001100001111000000000000001100110011000011
11000000000000000000000000110011118200b2b2b2b2b2b2b2b2b2b2b2c21111000095a5b50000000095a5b500001111000000000000000000000000000011
11111111111100001111000000000011111100110000000000000094a4b41111110000001100001111520011000000111100000000f000001100110011930011
110000000000000000000000001100111182525252525252525252525200c2111100000000000000000000000000001111000000000000000000000000000011
1100000000000000000000000010001111f0000000000000c4d4e495a5b511111100000000110000001111000000001111003000001100001100110011000011
113000000000000000000000001100111111111111111111111111111100c2111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000010201011111100000094a4b4c5d5e500520000111100000000001100000000000000001111000000001100001100110000000011
1100005200e0005252e0e000521100111182b2b2b2b2b2b2b2b2b2b2b200c2111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000001020202011110030000095a5b5001100001100001111000000000000000000000000000011110011000011000011001100e0000011
111111111111111111111111111100111182005252525252525252525252c2111100000000000000000000000000001111000000000000000000000000000011
11000030000000748400102020202011110000000000110000000000000000111100003000007484007484000000001111001100001100001100110011000011
11000000000000000000000000000011118200111111111111111111111111111100748430000000009300748400001111000000000000000000000000000011
11007300730000758510202020202011111111110000000000000000000000111100000000007585007585000000001111001100001100001100110011000011
1100a300000000000000000000000011118200b2b2b2b2b2b2b2b2b2b20030111100758500737373730000758500001111000000000000000000000000000011
1110101010101010102020202020201111e0e0e0e0e0e0e0e0e0e0e0e0e0e0111110101010101010101010101010101111e011e0e011e0e011e011e011e0e011
110000e0e0e0e0e0e0e0e0e0e0e05211118252525252525252525252520000111110101010101010101010101010101111000000000000000000000000000011
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
110000000000000000000000000000110094a4b40000000000000000c4d4e4000000435353535353535353535363000000000000000000000000000000000000
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
110000000000000000000000000000110095435353535353535353535363e50000004454545454545454545454640000000000000000000000000000c4d4e400
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
110000000000000000000000000000110000445454545454545454545464000000004454545454545454545454640000000000000000000000000000c5d5e500
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
1100000000000000000000000000001100004454545454545454545454640000000044545454545454545454546400000094a4b4000000000000000000000000
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
1100000000000000000000000000001100004454545454545454545454640000000044545454545454545454546400000095a5b5000000000000000000000000
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011000044545454545454545454546400000000445454545454545454545464000000000000000000000000000000000000
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011000045555555555555555555556500000000445454545454545454545464000000000000000000000000000000000000
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011000000000000000000000000000000000000445454545454545454545464000000000043535353535353535363000000
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
110000000000000000000000000000110000000000000000000000f300f100000000445454545454545454545464000000000044545454545454545464000000
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
1100000000000000000000000000001100000000007484f300e100f473f273f00000445454545454545454545464000000000044545454545454545464000000
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
1100000000000000000000000000001100000000007585f400e27310101010100000445454545454545454545464000000000045555555555555555565000000
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
1100000000000000000000000000001100007484f010101010101020202020200000455555555555555555555565000000000000000000000000000000007484
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
1100000000000000000000000000001100f07585102020202020202020202020000000000000000000000000000000007484700000b1b173b173d1d173d17585
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011731010102020202020202020202020200000000000000000000000000000000075857173731010101010101010101010
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111102020202020202020202020202020200000000000000000000000000000000010101010102020202020202020202020
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc4444444444444444cccccccccccccc4444444444444444cccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc4444444444444444cccccccccccccc4444444444444444cccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc4444444444444444cccccccccccccc4444444444444444cccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccc4444449999999999999dddddddddddddd99999999999994444444cccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccc4444449999999999999dddddddddddddd99999999999994444444cccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccc4444449999999999999dddddddddddddd99999999999994444444cccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccc4444449999999999999dddddddddddddd99999999999994444444cccccccccc777cccccc777cccccccccccccccc
ccccccccccccccccccccccccccccccccc4444444999cccccccccccccccccccccccccccccccccccccccc9994444444cccccc77777777777777ccccccccccccccc
ccccccccccccccccccccccccccccccccc4444444999cccccccccccccccccccccccccccccccccccccccc9994444444ccccc677777777777777777cccccccccccc
ccccccccccccccccccccccccccccccccc4444444999cccccccccccccccccccccccccccccccccccccccc9994444444cccc67777777777777777777ccccccccccc
cccccccccccccccccccccccccccccc4444444999cccccccccccccccccccccccccccccccccccccccccccccc9999444444c677777777777777777776cccccccccc
cccccccccccccccccccccccccccccc4444444999cccccccccccccccccccccccccccccccccccccccccccccc9999444444c6677777777777777777776ccccccccc
cccccccccccccccccccccccccccccc4444444999cccccccc777c777c777c7c7cc77c777c777c77cccccccc9999444444cc677777777777777777776ccccccccc
ccccccccccccccccccccccccccc4449999999ccccccccccc777c7c7c7c7c7c7c7ccc777c7c7c7c7ccccccccccc99999944477777777777777777776ccccccccc
ccccccccccccccccccccccccccc4449999999ccccccccccc7c7c777c77cc77cc777c7c7c777c7c7ccccccccccc9999994447777777777777777776cccccccccc
ccccccccccccccccccccccccccc4449999999ccccccccccc7c7c7c7c7c7c7c7ccc7c7c7c7c7c7c7ccccccccccc999999444777777777777777776ccccccccccc
ccccccccccccccccccccccc4444999999ccccccccccccccc7c7c7c7c7c7c7c7c77cc7c7c7c7c7c7cccccccccccccc99999944447766777776666cccccccccccc
ccccccccccccccccccccccc4444999999cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc999999444476cc67776cccccccccccccccc
ccccccccccccccccccccccc4444999999ccccccccccccccccccccccc6c6c66cccccc666cccccccccccccccccccccc99999944446cccc666ccccccccccccccccc
ccccccccccccccccccccccc4444999999ccccccccccccccccccccccc6c6cc6cccccc6c6cccccccccccccccccccccc9999994444ccccccccccccccccccccccccc
cccccccccccccccccccc4449999ccccccccccccccccccccccccccccc6c6cc6cccccc6c6cccccccccccccccccccccccccccc9999444cccccccccccccccccccccc
cccccccccccccccccccc4449999ccccccccccccccccccccccccccccc666cc6cccccc6c6cccccccccccccccccccccccccccc9999444cccccccccccccccccccccc
ccccccccccccccccc7774449999cccccccccccccccccccccccccccccc6cc666cc6cc666cccccccccccccccccccccccccccc9999444cccccccccccccccccccccc
ccccccccccccc4444444444777777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4444444444ccccccccccccccc
ccccccccccccc44444444447777777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4444444444ccccccccccccccc
cccccccccccc7444444444477777777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4444444444ccccccccccccccc
ccccccccccc777777777777777777777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc7777777777777777777776cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc7777777777777777777776cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc677777777777777777776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccc6777777777777777776cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc67777777776677766ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccc666776666cc666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccc666cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc777c777c777cc77cc77cccccc77777cccccc777cc77cccccc77c777c7ccc777cc77c777ccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc7c7c7c7c7ccc7ccc7ccccccc77c7c77cccccc7cc7c7ccccc7ccc7ccc7ccc7ccc7cccc7cccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc777c77cc77cc777c777ccccc777c777cccccc7cc7c7ccccc777c77cc7ccc77cc7cccc7cccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc7ccc7c7c7ccccc7ccc7ccccc77c7c77cccccc7cc7c7ccccccc7c7ccc7ccc7ccc7cccc7cccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc7ccc7c7c777c77cc77ccccccc77777ccccccc7cc77cccccc77cc777c777c777cc77cc7cccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc111155555ccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc111155555ccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc111155555ccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc111155555ccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77777777111111111111111117777ccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77777777111111111111111117777ccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccc66666666555555555555555555555555555555555555555555555555555555555555555566666666cccccccccccccccccccccccc
cccccccccccccccccccccccc66657575757575757575757575757575757575757575757575757575757575757575757575757666cccccccccccccccccccccccc
cccccccccccccccccccccccc66677777777777777777777777777777777777777777777777777777777777777777777777777666cccccccccccccccccccccccc
cccccccccccccccccccccccc65777777777777777777777777777777777777777777777777777777777777777777777777777776cccccccccccccccccccccccc
cccccccccccccccccccccccc67777777777777777777777777777777777777777777777777777777777777777777777777777756cccccccccccccccccccccccc
cccccccccccccccccccccccc65777777777777777777777777777777777777777777777777777777777777777777777777777776cccccccccccccccccccccccc
cccccccccccccccccccccccc67777777777777777777777777777777777777777777777777777777777777777777777777777756cccccccccccccccccccccccc
cccccccccccccccccccccccc65777777777777777777777777777777777777777777777777777777777777777777777777777776cccccccccccccccccccccccc
cccccccccccccccccccccccc57777777777777777777777777777777777777777777777777777777777777777777777777777755cccccccccccccccccccccccc
cccccccccccccccccccccccc55777777777777777777777777777777777777777777777777777777777777777777777777777775cccccccccccccccccccccccc
cccccccccccccccccccccccc57777777777777777757777700770007070777777007000700070007777777777777777777777755cccccccccccccccccccccccc
cccccccccccccccccccccccc55777777777777777755777706070666060677770766060600060666777777777777777777777775cccccccccccccccccccccccc
cccccccccccccccccccccccc57777777777777444455677706060077060677770677000606060077777777777777777777777755cccccccccccccccccccccccc
cccccccccccccccccccccccc55777777777777444455677706060667000677770607060606060667777777777777777777777775cccccccccccccccccccccccc
cccccccccccccccccccccccc57777777777777777755777706060007000677770006060606060007777777777777777777777755cccccccccccccccccccccccc
cccccccccccccccccccccccc55777777777777777757777776767666766677777666767676767666777777777777777777777775cccccccccccccccccccccccc
cccccccccccccccccccccccc57777777777777777777777777777777777777777777777777777777777777777777777777777755cccccccccccccccccccccccc
cccccccccccccccccccccccc55777777777777777777777777777777777777777777777777777777777777777777777777777775cccccccccccccccccccccccc
cccccccccccccccccccccccc57777777777777777777777777777777777777777777777777777777777777777777777777777755cccccccccccccccccccccccc
cccccccccccccccccccccccc55777777777777777777777777777777777777777777777777777777777777777777777777777775cccccccccccccccccccccccc
cccccccccccccccccccccccc57777777777777777777777777777777777777777777777777777777777777777777777777777755cccccccccccccccccccccccc
cccccccccccccccccccccccc55777777777777777777777777777777777777777777777777777777777777777777777777777775cccccccccccccccccccccccc
cccccccccccccccccccccccc57777777777777777777777777777777777777777777777777777777777777777777777777777755cccccccccccccccccccccccc
cccccccccccccccccccccccc55777777777777777777777777777777777777777777777777777777777777777777777777777775cccccccccccccccccccccccc
cccccccccccccccccccccccc67777777777777777777777777777777777777777777777777777777777777777777777777777756cccccccccccccccccccccccc
cccccccccccccccccccccccc65777777777777777777777777777777777777777777777777777777777777777777777777777776cccccccccccccccccccccccc
cccccccccccccccccccccccc67777777777777777777777777777777777777777777777777777777777777777777777777777756cccccccccccccccccccccccc
cccccccccccccccccccccccc65777777777777777777777777777777777777777777777777777777777777777777777777777776cccccccccccccccccccccccc
cccccccccccccccccccccccc67777777777777777777777777777777777777777777777777777777777777777777777777777756cccccccccccccccccccccccc
cccccccccccccccccccccccc66677777777777777777777777777777777777777777777777777777777777777777777777777666cccccccccccccccccccccccc
cccccccccccccccccccccccc66675757575757575757575757575757575757575757575757575757575757575757575757575666cccccccccccccccccccccccc
ccccccccccccccccc111111166666666555555555555555555555555555555555555555555555555555555555555555566666666111ccccccccccccccccccccc
ccccccccccccccccc11111111ccccccccccccccccccccccccccccc11111111111111111111555555555111111111111555511111111ccccccccccccccccccccc
ccccccccccccccccc11111111ccccccccccccccccccccccccccccc11111111111111111111555555555111111111111555511111111cccccccccccc3cccccccc
ccccccccccccccccc11111111ccccccccccccccccccccccccccccc11111111111111111111555555555111111111111555511111111cccccccccccc33ccccccc
cccccccccccc77777777711115555ccccccccccccccccccccc111111111111111111115555111111111111155551111111155555555cccccccccccc33ccccccc
cccccccccccc77777777711115555ccccccccccccccccccccc111111111111111111115555111111111111155551111111155555555ccccccccccc3333cccccc
cccccccccccc77777777711115555ccccccccccccccccccccc111111111111111111115555111111111111155551111111155555555ccccccccccc3333cccccc
cccccccccccc77777777711115555ccccccccccccccccccccc111111111111111111115555111111111111155551111111155555555cccccccccc333333ccccc
cccccccccccc11111555511111111ccccccccccccccccccccc5555111155551111555555551111555551111555555555555111111115555cccccc333333ccccc
cccccccccccc11116555511111111ccccccccccccccccccccc5555111155551111555555551111555551111555555555555111111115555ccccc33333333cccc
ccccccc3cccc11111733311111111ccccccccccccccccccccc5555111155551111555555551111555551111555555555555111111115555ccccc33333333cccc
ccccccc33ccc11111373333111111ccccccccccccccccccccc5555111155551111555555551111555551111555555555555111111115555ccccc33333333cccc
ccccccc33ccc555533333333155551111cccccccccccc55555555511111111111111111111111111111111111115555111111115555111111111c333333ccccc
cccccc3333cc555551aa5a11155551111cccccccccccc55555555511111118111111111111111811111111111115555111111815555111111111cc3333cccccc
cccccc3333cc555551aaaa11155551111cccccccccccc5555555551111118a811111111111118a81111111111115555111118a85555111111111ccc22ccccccc
ccccc333333c555551aa1111155551111cccccccccccc55555555511111118111111111111111811111111111115555111111815555111111111ccc44ccccccc
ccccc33333311111133335555111155551111cccccccc1111155551111111311111111111155531111111111111111111111131111111111111155544ccccccc
cccc333333331111133335555111155551111ccc3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
cccc333333331111133435555111155551111ccc4444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
cccc333333331111133435555111155551111ccc4454545444545454445454544454545444545454445454544454545444545454445454544454545444545454
ccccc33333311111133435555111155551111ccc4445444444454444444544444445444444454444444544444445444444454444444544444445444444454444
cccccc333311111113b4b11111111811111118cc4454774474577447775447447457744777544774447447744757447474544444445444444454444444544444
ccccccc2211111111b45411111118a8111118a8c4445744747475747444574474747574474755747474757474747574747455444444554444445544444455444
ccccccc4411111111545411111111811111118cc4544745747474757754474577747745475444757477747574747475447444454454444544544445445444454
ccccccc4411111111555511111111311111113cc4444774474477447774744474747474474744774474747744474474447444444444444444444444444444444
33333333333333333333333333333333333333334444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444544555445445554454455544544555445445554454455544544555445445554454455544544555445445554
44545454445454544454545444545454445454544455474744757477747577444477747474777477747774774477747447577747775574474477747447577744
44454444444544444445444444454444444544444544747475747474454474574547547775745474457454777574747747475457454757574574747747475454
44544444445444444454444444544444445444444454754474747547747475444457457474774547747745747474757477577544775777474474757477577544
44455444444554444445544444455444444554444454744474575477747477474457547474777477747774774477747447577747775757477477747447577744
45444454454444544544445445444454454444544544545445445454454454544544545445445454454454544544545445445454454454544544545445445454
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444

__gff__
0001010000020200000000000000000000010000000202000000000000000000000000000000000000000000000000000000000004040400000000000000000000000000040404000000000000000000000000000404040000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1100000000000000000000000000001111000000000000000000000000000011113a0d0d0d0d0d0d0d0d0d0d0d0d0d11113435353535353535353600000000111100000034353535353535353535361111000000000000000000000000000011110000000000000000002b000000001111343535353535353600000000000011
1100000000000000000000000000001111003a0000000000000000000000001111000000000000000000000000000011114445454545454545454600000000111100000044454545454545454545461111000000000000000000004c4d4e00111100000000000000000000000000001111444545454545454600000000000011
110000494a4b000000000000000000111100000000000000000000000000001111000000000000000000000000000011115455555555555555555600000000111100000044454545454545454545461111000000000000000000005c5d5e001111000000494a4b0000001100000000111154555555555555560000494a4b0011
110000595a5b000000000000000000111100000000000000000000000000001111000000000101010000000000000011110000595a5b00000000000000000011113a0000444545454545454545454611110000494a4b0000000000000000001111000000595a5b0000001100000000111100000000000000000000595a5b0011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000004c4d4e001111000000545555555555555555555611110000595a5b003f00000000000000111128000000000000000011000000001111000000000000000000000000000011
11003f00000000000000000000000011110000000000000000002500000000111100000000000000000000000000001111000000000000000000005c5d5e001111111100000000000000000000000011110000000000004f000000000000001111000000000000000000110000002c1111004c4d4e0000000000000000000011
11004f0000000000000000000000001111010101010101010000010000002511110000000000000000000000000000111128000000000000000000000000001111110000000000000000000000000011110000000000111111000000000000111128000000000000002c11003a00001111005c5d5e0000000011111111111111
11111147480000030000003900474811110000000000000000000000000001111100000000000000002525000000001111000000000000000000000000000011110000000000000000000000000000111100000000001100110000000000001111000000250000000000110000000011110000000000000000110d0d0d0d0d11
11111157580000000000000000575811110000000000000000000000000000111100000000002500010101000000001111000000000000000000003f00000011110000000000000000000000000000111100000000001100000000000039001111111111111100002c1111111111111111000000000000000011003a00000011
1111110101010101010101010101011111000300000000000000000001000011110000000000010000000000000000111100000000000000002c114f0000001111000000000000000000000000000011110000000000110011000000000000111100000000000000000000000000001111000000000000000011000000000011
11111102020202020202020202020211110000000000000000000101000000111100000000010000000000000000001111000000000000000000111100002c1111000000000000000000000000000011110000000000110011000000001111111100000000000000000000000000001111000000000000000011111111000011
11343535353535353535353536020211110101010101010000000000002500111103000101000000000000000000001111474847483a0000000011000000001111000000000000000000000000000011110000000000110011000000000000111100004748000000000000000003001111003f00030000000000000000000011
11444545454545454545454546020211110000000000000000000000001100111100010000000000000000000000001111575857580000003700110300000011110003000000000000000001000000111103000000000000110000000000001111003757580f0000000037373700001111004f00000000000037373700002511
11545555555555555555555556020211110e0e0e0e0e0e0e25250e0e0e110e1111010e0e0e0e0e0e0e0e0e0e0e0e0e1111010101010101010101110000000011110000000025000e0e0e0e020e0e0e111100000e0e000025110e0e0e0e0e0e111101010101010101010101010101011111010101010101010101010101010111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
110000110000000000000000000000111100000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000111100000000002b0000001100000000111100000000000000110000000000001111000000000000000000002b0000001111003a00000000002b00000000000011
11030011000000000000000000000011110000000000000000004c4d4e0000111100494a4b0000000000000000000011110000000000000000000000000000111100494a4b0000000000110000000011110000494a4b000011000000000000111100004c4d4e00000000000000000011110000000000000000002c1100002c11
110000110000494a4b000000000000111100494a4b00000000005c5d5e0000111100595a5b0000000000000000000011110000494a4b000000000000000000111100595a5b0000000000000000000011110000595a5b000011000000003900111100005c5d5e0000000001013739001111111111111100003737371111282c11
111100110000595a5b000000000000111100595a5b000000000000000000001111000000000000000000004c4d4e0011110000595a5b0000000000000000001111000000000000000000113a00002c11110000000000000011000000000000111128000000000000250002020100001111000000112800001111111111110011
110000110000000000000000000000111100000000000000000000000000001111000000000000000000005c5d5e00111100000000000000000000000e39001111000000000025000000110000000011110000000000000011000000000000111100110000002c111111111111111111110000000000002c1100000011110011
11000011000000000000004c4d4e001111000000000000000000000000390011110000000000000000000000000000111100000000000000000000001100001111000000004c454b00001111111111111100000000000000110000000000001111111100000000002b2b2b2b2b2b2b1111280000112800000000000000000011
110000110039000f0000005c5d5e00111100000000000000000000000000001111030000000000000000000000000011110000000000000000000000110e0e1111000000005c5a5b00000000000000111100000000000000000000000000001111000000000000000000000000002c111100002c112800001128002c11110011
11000000000000110000000000000011110000000000000000000000001111111100000025000000000000000000001111000000000000000025000011111111110000000000000000000000000000111100000300000000000000000000001111280011000000000025252525252511112800001100002c1111002c11110011
110000111111111100000000000000111100000000000000000000000000001111111111110000000000000000000011110000000000110000110000000000111100000025000000000000000000001111000000000000000000000000000011110000112800000000111111111111111100002c112800251128001111110011
11000011000000000000000000000011110000000000000000000000000000111100000000000000000e00000e0000111100000000000000000000000000001111111111111111111111110000000011111111111111000000000000000000111100000000000000000000000000001111000000110000111111002c11110011
11000011004748474847484748000011110000000000000000000000000000111100000000000000001100001100001111000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111373737250100000000000000000011110000111128002c1128001111110011
11000011005758575857585758373711110047480300002500003f00003f001111000000000000000011390011000011110003000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011110101010102003f000003004748001111000011111100001111002c11110011
11000011010101010101010101010111110057580000000202004f00004f0011110000000000000000110000110000111100000025000e0e0e0e0e0e0e0e0e111103000000000000000000000000001111000000000000000000000000000011110202020202004f000000005758001111030000000000000000000000000011
110e0e1102020202020202020202021111010101010101020201010101010111110e0e0e0e0e0e0e0e110e0e110e0e11110101010101111111111111111111111100000e0e00000e0e00000e00250011110e0e0e0e0e0e0e0e0e0e0e0e0e0e111102020202020101010101010101011111000000000000000000000000000011
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
__sfx__
1c1000000702507025070250702513000000000702507025070250702513100001001310013100131001310007025070250702507025071000010007025070250702507025071000010007100071000710013000
1d1000000002500025000250002507000000000002500025000250002507000000000700007000070000700000025000250002500025070000000000025000250002500025070000000007000071000710013000
01100000020250202502025020250700000000020250202502025020250700000000070000700007000070000b0250b0250b0250b02507000000000b0250b0250b0250b025070000000007100071000710013000
011000000c023000003c6230000024623246003c623246000c0230c0233c6230000024623246003c623246000c023000003c6230c02324623246000c023246003c623000000c0230000024623246000c02324600
011000000c013000003c6130000024613246003c613246000c0130c0133c6130000024613246003c613246000c013000003c6130c01324613246000c0132460024013240130c01320013200130c0131c0130c013
451000001c5211c5221a0001a5211c5221c5221f5211f52217521175221752217522000000000000000000001a5211a5221c5211c5221f5211f52221521215222352123522235222352221521215222152221522
451000001e5221e5221e5221e5221f5211f5221f5221f5221c5241c5221c5221c525000000000000000000000000000000215221f52221522215221f5221f5221e5221c5221e5211e5221c5211c5221a5211a522
451000001e5221e5221e5221e522215212152221522215222352123522245212452226525285252352223522235222352500000270002452223522245222452221522215221f5211f5221e5211e5221c5211c522
451000001f5221f5221f5221f5221e5211c5211a52118521135211352213522135221352213522135221352207135061350713507135071350613507135071353710037100301003710037100301003710037100
451000001c5211c5221a0001a5211c5221c5221f5211f522175211752217522175220000000000000000000023521235222352223522215212152221522215221f5211f5221f5221f5221e5211e5221e5221e522
45100000215221f52221522215221f5221e5221f5221f5221e5221c5221e5221e5221c5221a5221c5221c5221252513525155251352515525175251552517525185251a5251c5251a5251c5251f5251e5251c525
451000001e5221e5221e5221e5222152121522215222152228521265222852224502285222652228522245022352224522235222352221521215221f5211f5221e5211e5221f5211f5221e5211e5221c5211c522
450800200e5350e5350e5320e5350e5320e5350e5320e5350e5000e5000c5000c5000e5350e5350e5320e5350e5320e5350e5320e535000000000000000000000000000000000000000024121181210c12100121
011000000c0230c0130c013000002462324613246130000000000000000000000000246232461324613000000c0230c0130c0230c0132462324613246130000000000000000000000000246230c0230c0130c023
7d1000000b035170351703517035230351703517035170350b0350b0351703517035230351703517035170350b035170351703517035230351703517035170350b0350b035170351703523035170351703517035
7d100000060351203512035120351e035120351203512035060350603512035120351e035120351203512035060351203512035120351e035120351203512035060350603512035120351e035120351203512035
011000000c0130c0133c6120000024613246133c612246000c0130c0133c6120000024613246133c612246000c0130c0133c6120c01324613246130c013246003c612000000c0130c01324613246130c0130c013
000500000d5501b5502050031000300002d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001e7501e750207502275022750237502475029750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001f6701c6701967016670136700f6700c67009660066600566004650026500265001650016400364001630006200000000000000000000000000000000000000000000000000000000000000000000000
000200000417001660016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000517006170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001364000000116000000025200252000050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000111500f1300d1200d12009120081200010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000200000c16009160001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
00040000270502a050220502d05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000004050080700d0700907003060080600907000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000180001d00022000270002b0002e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 00424344
00 00044344
01 00030549
00 0103064a
00 02030744
00 00040844
00 00030944
00 01030a44
00 02030b44
00 000d0c4d
00 00030e49
00 01030f4a
00 02030e44
00 00040c44
00 00100e49
00 01100f4a
00 02100e44
02 000d0c4d

