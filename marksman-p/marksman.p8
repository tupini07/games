pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
package={loaded={},_c={}}
package._c["managers/savefile"]=function()
SAVE_DATA = {current_level = 1}

local save_data_points = {current_level = 1}

local function load_save_data()
    local set_level = dget(save_data_points.current_level)
    if set_level == nil or set_level == 0 then set_level = 1 end
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

local level_done = false

local show_win_banner = false
local show_lost_banner = false

PLAYER_ORIGINAL_POS_IN_LVL = {x = 0, y = 0}

local function level_reset()
    ARROWS = {}
    PLAYER.x = PLAYER_ORIGINAL_POS_IN_LVL.x
    PLAYER.y = PLAYER_ORIGINAL_POS_IN_LVL.y
    player.reset_for_new_level()
end

local function new_level_init()
    spring.init()
    spikes.init()
    map.replace_entities(SAVE_DATA.current_level)
    camera_utils.focus_section(SAVE_DATA.current_level)
    player.reset_for_new_level()
end

function WIN_LEVEL()
    level_done = true
    show_win_banner = true
end

function LOSE_LEVEL()
    level_done = true
    show_lost_banner = true
end

local level_change_coroutine = nil
local function get_lvl_change_coroutine_status()
    if level_change_coroutine == nil then
        return "dead"
    else
        return costatus(level_change_coroutine)
    end
end

local function level_done_update()
    local lvl_change_status = get_lvl_change_coroutine_status()

    if btnp(5) then
        if lvl_change_status == "running" then
            return
        elseif lvl_change_status == "dead" then
            level_change_coroutine = graphics_utils.execute_in_between_fades(
                                         nil, function()
                    if show_win_banner then
                        SAVE_DATA.current_level = SAVE_DATA.current_level + 1
                        new_level_init()
                    elseif show_lost_banner then
                        level_reset()
                    end

                    show_win_banner = false
                    show_lost_banner = false

                    savefile_manager.persist_save_data()
                end, function()
                    level_done = false
                    pal()
                end)
        end
    end

    if lvl_change_status == "suspended" then coresume(level_change_coroutine) end
end

local function level_win_draw()
    local lvl_cords = map.get_game_space_coords_for_current_lvl()

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
    print("press ❎ to continue")
end

local function level_lost_draw()
    local lvl_cords = map.get_game_space_coords_for_current_lvl()

    local banner_x1 = lvl_cords.x
    local banner_y1 = lvl_cords.y + 48

    local banner_x2 = banner_x1 + 128
    local banner_y2 = banner_y1 + 46

    rectfill(banner_x1, banner_y1, banner_x2, banner_y2, 7)
    print("you died!", banner_x1 + 10, banner_y1 + 10, 5)
    print("press ❎ to try again", banner_x1 + 10, banner_y1 + 20, 5)
end

local function draw_current_lvl()
    local game_space = map.get_game_space_coords_for_current_lvl()

    local base_x = (game_space.x + 128) - 20
    local base_y = game_space.y + 1

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
    map.draw_level_text()
    level_text.draw_current_level_text()
    bullseye.draw()
    arrow.draw_all()
    player.draw()
    map.draw()
    spring.draw()
    spikes.draw()
    particles.draw()
    draw_current_lvl()

    if level_done and show_lost_banner then level_lost_draw() end
    if level_done and show_win_banner then level_win_draw() end
end

return {init = init, update = update, draw = draw}
end
package._c["src/map"]=function()
local bullseye = require("entities/bullseye")
local spring = require("entities/spring")
local spikes = require("entities/spikes")

local sprite_flags = {solid = 0, bullseye = 1, level_text_container = 2}

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

local map = {
    draw_level_text = function()
        local lvl_map_cords = level_to_map_coords(SAVE_DATA.current_level)
        local game_cords = get_game_space_coords_for_current_lvl()
        map(lvl_map_cords.x, lvl_map_cords.y, game_cords.x, game_cords.y, 16, 16,0x4)
    end,
    draw = function()
        local lvl_map_cords = level_to_map_coords(SAVE_DATA.current_level)
        local game_cords = get_game_space_coords_for_current_lvl()
        map(lvl_map_cords.x, lvl_map_cords.y, game_cords.x, game_cords.y, 16, 16,0B11)
    end,
    sprite_flags = sprite_flags,
    cell_has_flag = function(flag, x, y) return fget(mget(x, y), flag) end,
    level_to_map_coords = level_to_map_coords,
    get_game_space_coords_for_current_lvl = get_game_space_coords_for_current_lvl,
    replace_entities = function(current_level)
        local level_block_coords = level_to_map_coords(current_level)

        local level_x2 = level_block_coords.x + 16
        local level_y2 = level_block_coords.y + 16

        for x = level_block_coords.x, level_x2 do
            for y = level_block_coords.y, level_y2 do
                local sprt = mget(x, y)
                if sprt == 3 then
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

                if sprt == 55 then
                    spikes.replace_in_map(x, y, spikes.orientations.down)
                elseif sprt == 71 then
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
    hitbox_x = 0,
    hitbox_y = 0,
    hitbox_h = 0,
    hitbox_w = 0
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

            BULLSEYE.hitbox_w = 6
            BULLSEYE.hitbox_h = 6
        end

        if type == orientations.left then
            BULLSEYE.hitbox_x = BULLSEYE.x + 6
            BULLSEYE.hitbox_y = BULLSEYE.y + 7

        elseif type == orientations.right then
            BULLSEYE.hitbox_x = BULLSEYE.x + 4
            BULLSEYE.hitbox_y = BULLSEYE.y + 7
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
            if s.orientation == orientations.top then
                body.dy = -3
            elseif s.orientation == orientations.bottom then
                body.dy = 3
            elseif s.orientation == orientations.left then
                body.dx = -3
            elseif s.orientation == orientations.right then
                body.dx = 3
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

return {
    --- @param point Vector
    --- @param box_top_left Vector 
    point_in_box = function(point, box_top_left, box_h, box_w)
        local bx1 = box_top_left.x + box_w
        local by1 = box_top_left.y + box_h
        return box_top_left.x < point.x and point.x < bx1 and box_top_left.y <
                   point.y and point.y < by1
    end,
    resolve_box_body_collider = resolve_box_body_collider,
    box_collision = box_collision,
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
        sprtn = 55
    elseif s.orientation == orientations.up then
        sprtn = 71
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
package._c["src/camera"]=function()
local map = require("src/map")

return {
    camera_center = function(x, y, map_tiles_width, map_tiles_height)
        local cam_x = x - 60
        local cam_y = y - 60

        cam_x = mid(0, cam_x, map_tiles_width * 8 - 127)
        cam_y = mid(0, cam_y, map_tiles_height * 8 - 127)

        camera(cam_x, cam_y)
    end,
    focus_section = function(current_level)
        local lvl_cords = map.get_game_space_coords_for_current_lvl()

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
    ddy = 0.12,
    dir = 1,
    is_dead = false,
    collider = {x = 1, y = 0, w = 4, h = 16},
    is_jumping = false,
    changing_bow_dir = false
}

local function change_pl_dir(new_dir)
    assert(new_dir == -1 or new_dir == 1, "invalid player dir")
    PLAYER.dir = new_dir
    if new_dir == 1 then
        PLAYER.collider = {x = 1, y = 0, w = 4, h = 16}
    else
        PLAYER.collider = {x = 2, y = 0, w = 4, h = 16}
    end
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
        if btnp(2) and not PLAYER.is_jumping then PLAYER.dy = -2 end
    end

    -- cap deltas
    PLAYER.dx = math.cap_with_sign(PLAYER.dx, 0, 3)
    PLAYER.dy = math.cap_with_sign(PLAYER.dy, 0, 3)

    -- apply velocity
    PLAYER.x = PLAYER.x + PLAYER.dx
    PLAYER.y = PLAYER.y + PLAYER.dy

    -- apply gravity
    PLAYER.dy = PLAYER.dy + PLAYER.ddy

    -- apply friction
    PLAYER.dx = PLAYER.dx * 0.6
    if abs(PLAYER.dx) < 0.1 then PLAYER.dx = 0 end
end

local function check_floor()
    local bottom_x0 = flr((PLAYER.x + PLAYER.collider.x) / 8)
    local bottom_x1 =
        flr((PLAYER.x + PLAYER.collider.x + PLAYER.collider.w) / 8)
    local bottom_y = flr(
                         (PLAYER.y + PLAYER.collider.x + PLAYER.collider.h - 1) /
                             8)

    local is_bottom_floor = false
    for bx in all({bottom_x0, bottom_x1}) do
        is_bottom_floor = is_bottom_floor or
                              map.cell_has_flag(map.sprite_flags.solid, bx,
                                                bottom_y)
    end

    if is_bottom_floor then
        if PLAYER.is_jumping then
            -- we're landing
            for _ = 1, 5 do
                local displacement = rnd(4) - 4
                particles.make_particle(PLAYER.x + 4 + displacement,
                                        PLAYER.y + 16, -PLAYER.dx * 0.1,
                                        -PLAYER.dy * 0.1, 0, 1, 7, 7)
            end

        end

        PLAYER.is_jumping = false
        PLAYER.y = (bottom_y - 2) * 8
        PLAYER.dy = 0
    else
        PLAYER.is_jumping = true
    end
end

local function check_ceiling()
    local top_x0 = flr((PLAYER.x + PLAYER.collider.x) / 8)
    local top_x1 = flr((PLAYER.x + PLAYER.collider.x + PLAYER.collider.w) / 8)
    local top_y = flr((PLAYER.y + PLAYER.collider.y) / 8)

    for t in all({top_x0, top_x1}) do
        local is_top_ceiling = map.cell_has_flag(map.sprite_flags.solid, t,
                                                 top_y)
        if is_top_ceiling then
            PLAYER.y = (top_y + 1) * 8
            PLAYER.dy = 0
        end
    end
end

local function check_walls()
    -- check that top-{movement-dir} and bottom-{movement-dir} corners
    -- are not colliding
    local side_left = flr((PLAYER.x + PLAYER.collider.x) / 8)
    local side_right = flr((PLAYER.x + PLAYER.collider.x + PLAYER.collider.w) /
                               8)

    local top_y0 = flr((PLAYER.y + PLAYER.collider.y + 2) / 8)
    local top_y1 = flr(
                       (PLAYER.y + PLAYER.collider.y + (PLAYER.collider.h / 2)) /
                           8)
    local top_y2 = flr((PLAYER.y + PLAYER.collider.y + PLAYER.collider.h - 2) /
                           8)
    local tops = {top_y0, top_y1, top_y2}

    -- left side collission
    for t in all(tops) do
        local is_colliding = map.cell_has_flag(map.sprite_flags.solid,
                                               side_left, t)
        if is_colliding then
            PLAYER.dx = 0
            PLAYER.x = (side_right * 8) - PLAYER.collider.x
        end
    end

    -- right side collission
    for t in all(tops) do
        local is_colliding = map.cell_has_flag(map.sprite_flags.solid,
                                               side_right, t)
        if is_colliding then
            PLAYER.dx = 0
            PLAYER.x = (side_left * 8) +
                           (8 - PLAYER.collider.x - PLAYER.collider.w - 1)
        end
    end
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
        if GLOBAL_TIMER % 8 == 0 then
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
        check_walls()
        check_ceiling()
        check_floor()
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
        lifetime = 90,
        is_stuck = false,
        collider = collider
    }

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
        make_floor_walls_colission_dust(a)
    end
end

--- @param a Arrow
local function make_bullseye_colission_dust(a)
    local cv = get_collision_vec(a)
    for _ = 1, 8 do
        local displacement = rnd(4) - 4
        particles.make_particle(cv.x + displacement, cv.y + displacement,
                                -a.dx * 0.1, -a.dy * 0.1, 0, 1,
                                rnd({7, 10, 11}), 7)
    end
end

--- @param a Arrow
local function collide_with_bullseye(a)
    -- if collission_vec is inside the bullseye hitbox then we have a collission
    local collision_vec = get_collision_vec(a)

    local bullseye_hitbox_x2 = BULLSEYE.hitbox_x + BULLSEYE.hitbox_w
    local bullseye_hitbox_y2 = BULLSEYE.hitbox_y + BULLSEYE.hitbox_h

    if collision_vec.x >= BULLSEYE.hitbox_x and collision_vec.x <=
        bullseye_hitbox_x2 and collision_vec.y >= BULLSEYE.hitbox_y and
        collision_vec.y <= bullseye_hitbox_y2 then
        a.is_stuck = true
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
package._c["managers/decorations"]=function()
local map = require("map")

local types = {cloud1 = 1, cloud2 = 2}

local function replace_in_map() end

local function draw_background()
    local lvl_cords = map.get_game_space_coords_for_current_lvl()

    sspr(0, 32, 31, 31, lvl_cords.x + 8, lvl_cords.y + 8, 112, 112)
end

return {
    draw_background = draw_background,
    replace_in_map = replace_in_map,
    types = types
}
end
package._c["map"]=function()
local bullseye = require("entities/bullseye")
local spring = require("entities/spring")
local spikes = require("entities/spikes")

local sprite_flags = {solid = 0, bullseye = 1, level_text_container = 2}

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

local map = {
    draw_level_text = function()
        local lvl_map_cords = level_to_map_coords(SAVE_DATA.current_level)
        local game_cords = get_game_space_coords_for_current_lvl()
        map(lvl_map_cords.x, lvl_map_cords.y, game_cords.x, game_cords.y, 16, 16,0x4)
    end,
    draw = function()
        local lvl_map_cords = level_to_map_coords(SAVE_DATA.current_level)
        local game_cords = get_game_space_coords_for_current_lvl()
        map(lvl_map_cords.x, lvl_map_cords.y, game_cords.x, game_cords.y, 16, 16,0B11)
    end,
    sprite_flags = sprite_flags,
    cell_has_flag = function(flag, x, y) return fget(mget(x, y), flag) end,
    level_to_map_coords = level_to_map_coords,
    get_game_space_coords_for_current_lvl = get_game_space_coords_for_current_lvl,
    replace_entities = function(current_level)
        local level_block_coords = level_to_map_coords(current_level)

        local level_x2 = level_block_coords.x + 16
        local level_y2 = level_block_coords.y + 16

        for x = level_block_coords.x, level_x2 do
            for y = level_block_coords.y, level_y2 do
                local sprt = mget(x, y)
                if sprt == 3 then
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

                if sprt == 55 then
                    spikes.replace_in_map(x, y, spikes.orientations.down)
                elseif sprt == 71 then
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
            end
        end
    end
}

return map
end
package._c["managers/level_text"]=function()
local map = require("src/map")

return {
    draw_current_level_text = function()
        local lvl_pos = map.get_game_space_coords_for_current_lvl()
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
package._c["states/intro_state"]=function()
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
    print_utils.print_centered("v0.4", 30, 6)
end

local function get_selected_menu_item()
    for item in all(menu) do if item.is_selected then return item end end
end

local function update_menu()
    if (btnp(2) or btnp(3)) and #menu > 1 then sfx(0) end

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
        sfx(1)
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
    cls(12)
    sspr(0, 32, 31, 31, 0, 0, 128, 128)
    map(112, 48, 0, 0, 16, 16)

    draw_logo()
    draw_menu()
    print("by dadum", 94, 122, 7)
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

return {
    get_length_of_text = get_length_of_text,
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

GLOBAL_TIMER = 0

function _init()
    save_manager.init()
    state_manager.init()
end

function _update()
    GLOBAL_TIMER = GLOBAL_TIMER + 1
    state_manager.update()
end

function _draw()
    state_manager.draw()
end
__gfx__
00000000333333334444444400111000000000000000000000000000600000000000000060000000600000006666666600006666000000000000000000000000
00000000444444444544555401111000000000000000000000000000073330006000000007333000073330006777777666666776000000000000000000000000
00700700445454544455444401111110000000000000000000000000037333300733300003733330037333306677777777777766000000000000000000000000
0007700044454444454454540aaaa000000000000000000000000000333333330373333033333333333333300677777777777760000000000000000000000000
0007700044544444445445440aaaa00000000000000000007777600000aa5a003333333300aa5a0000aa5a000677777777777760000000000000000000000000
0070070044455444445454440bbbb00000000000000000778887760000aaaa0000aa5a0000aaaa0000aaaa006677777777777766000000000000000000000000
0000000045444454454454540bbbb00000000000000007787778776000aa000000aaaa0000aa000000aa00006776666667777776000000000000000000000000
0000000044444444444444440dddd0000000000000007787888787760333300000aa000003333000033330006666000066666666000000000000000000000000
00000000d5d5d5d5004dd40000000400004444000007887877787876033330000333300003333000033330000000000000000000000000000000000000000000
000000005ddddddd044334400000044000000dd00007878788787876033430000333300003343000033430000000000000000000000000000000000000000000
00000000dd55d5d54400304400000044000003d400078787887878760334300003343000033430000334b0000000000000000000000000000000000000000000
000000005d5d5ddd000030000000033d0000330400078778778788760334300003b430000334b00003b440000000000000000000000000000000000000000000
00000000ddd5d5d5000000000000333d00033004000778878877876003b4b0000344b00003b44000034440000000000000000000000000000000000000000000
000000005d5d55dd00000000000000440000000400007787778874000b4040000b4040000b4040000b4050000000000000000000000000000000000000000000
00000000ddddddd50000000000000440000000000000077888876540004040000050400000405000005000000000000000000000000000000000000000000000
000000005d5d5d5d0000000000000400000000000000007777764004005050000000500000500000000000000000000000000000000000000000000000000000
00000000000000000000500000000000000000000000000000000000000000000040000000040000000004000060060000000400000000000000000000000000
00000000000000000005550000000000000055500000000000000000000000000040000000040000000004000006600000000400000000000000000000000000
00000000000000000000400000000000000004500000000000000000444444446040000006040000060604004444444400000406008888000000800000008000
00000000000000000000400060000050000040500000000000000000000660000640000060640000606064000000000000000460008ee0000000888000888000
00000000000000000000400006444455000400000000000044444444006006000640000060640000606064000000000000000460008220000000088808880000
0000000000000000000040006000005000400000444444440006600000066000604000000604000006060400000000000000040608822e000000888888888000
00000000000000000000700000000000640000000006600000600600006006000040000000040000000004000000000000000400000110000000888080888000
00000000000000000007070000000000060000000060060000066000000660000040000000040000000004000000000000000400000cc0000000088888880000
00000000044444000044444000000000555555555555555555555555444444440000000000577000007750000000000000000900000090000080008000800080
00000000449999dddd99994400000000557575757575757575757575040404040000050000000000000000000000000000000090000900000088888888888880
00000004490000000000009440000000577777777777777777777755090909090000055000577000007750000000000000000099999900900000880088088000
00000044900000000000000944000000557777777777777777777775000000000444455600507000007050000000000000000099999909900000000088000000
00000499000000000000000099400000577777777777777777777755000000000444455600570000007700000000000000000009999099000000000888800000
00004990000000000000000009940000557777777777777777777775000000000000055000507000007050000000000000000009999990000000008800880000
00049000000000000000000000094000577777777777777777777755000000000000050000577000007750000000000000000009999000000000008000080000
04440000000000000000000000004440557777777777777777777775000000000000000000000000000000000000000000000009009000000000088800888000
cccccccccccccccccccccccccccccccc577777777777777777777755000000000000000000000000100000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc557777777777777777777775000000000000000000000000011000100000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc577777777777777777777755000000000000000000000000000000010000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc557777777777777777777775000000000000000000000000011000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc577777777777777777777755000000000000000000000000100000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc557777777777777777777775909090900000000000000000000000110000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc577777777777777777777755404040400000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc557777777777777777777775444444440000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc577777777777777777777755000000000000000055555555000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc557777777777777777777775000000030000000055555555000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc577777777777777777777755000000033000000055555555000000000777000777000000000077700000077700000000
cccccccccccccccccccccccccccccccc557777777777777777777775000000033000000055555555000000007777707777777000000777777777777770000000
cccccccccccccccccccccccccccccccc577777777777777777777755000000333300000055555555000007777777777777777700006777777777777777770000
cccccccccccccccccccccccccccccccc557777777777777777777775000000333300000055555555000077777777777777777770067777777777777777777000
cccccccccccccccccc15cccccccccccc575757575757575757575755000003333330000055555555000777777777777777777777067777777777777777777600
ccccccccccccccc7711117cccccccccc555555555555555555555555000003333330000055555555007777777777777777777776066777777777777777777760
cccccccccccccc7cc55511c7cccccccc000000005555555555555555000033333333000055555555007777777777777777777776006777777777777777777760
cccccccccccccccc7777777ccccccccc000000005555555555555555000033333333000055555555006777777777777777777760006777777777777777777760
cccccccccccccccc115151cccccccccc000000005555555555555555000033333333000055555555000677777777777777777600006777777777777777777600
ccccccccccccccc11511511ccccccccc000000005555555555555555000003333330000055555555000067777777776677766000006777777777777777776000
ccccccccccccccc11111551ccccccccc000008005555555555555555000000333300000055555555000006667766660066600000000667777667777766660000
cccccccccccccc1551151511cccccccc00008a805555555555555555000000022000000055555555000000066600000000000000000067776006777600000000
cccccccccccccc5511111515cccccccc000008005555555555555555000000044000000055555555000000000000000000000000000006660000666000000000
cccc11ccccccc1111155111511cccccc000003005555555555555555000000044000000055555555000000000000000000000000000000000000000000000000
ccc7715ccccc11111511151155cccccc555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
ccc1511ccccc515155151555115ccccc555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
ccc51151ccc55111111111511511cccc555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
cc1115151cc151111151111111115ccc555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
cc1151111c15115151515151155111cc555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
c111111111511551115111151155155c555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
11511115155155151111115115111151555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
11111111111111111151511151515151555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001100000000000000000000000000000000
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001100000000000000000000000000000000
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001100000000000000000000000000000000
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001100000000000000000000000000000000
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001100000000000000000000000000000000
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001100000000000000000000000000000000
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001100000000000000000000000000000000
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001100000043535353535353535363000000
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001100000044545454545454545464000000
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001100000044545454545454545464000000
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001100000045555555555555555565000000
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001100000000000000000000000000000000
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001100758500007585700000000075857585
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001100768646467686710000004676867686
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110101010101010101010101010101010
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
ccccccccccccccccccccccccccccccccccccc4444449999999999999dddddddddddddd99999999999994444444cccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc4444444999cccccccccccccccccccccccccccccccccccccccc9994444444ccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc4444444999cccccccccccccccccccccccccccccccccccccccc9994444444ccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc4444444999cccccccccccccccccccccccccccccccccccccccc9994444444ccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc4444444999cccccccccccccccccccccccccccccccccccccccccccccc9999444444cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc4444444999cccccccccccccccccccccccccccccccccccccccccccccc9999444444cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc4444444999cccccccc777c777c777c7c7cc77c777c777c77cccccccc9999444444cccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccc4449999999ccccccccccc777c7c7c7c7c7c7c7ccc777c7c7c7c7ccccccccccc999999444ccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccc4449999999ccccccccccc7c7c777c77cc77cc777c7c7c777c7c7ccccccccccc999999444ccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccc4449999999ccccccccccc7c7c7c7c7c7c7c7ccc7c7c7c7c7c7c7ccccccccccc999999444ccccccccccccccccccccccccccccc
ccccccccccccccccccccccc4444999999ccccccccccccccc7c7c7c7c7c7c7c7c77cc7c7c7c7c7c7cccccccccccccc9999994444ccccccccccccccccccccccccc
ccccccccccccccccccccccc4444999999cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc9999994444ccccccccccccccccccccccccc
ccccccccccccccccccccccc4444999999ccccccccccccccccccccccc6c6c666ccccc6c6cccccccccccccccccccccc9999994444ccccccccccccccccccccccccc
ccccccccccccccccccccccc4444999999ccccccccccccccccccccccc6c6c6c6ccccc6c6cccccccccccccccccccccc9999994444ccccccccccccccccccccccccc
cccccccccccccccccccc4449999ccccccccccccccccccccccccccccc6c6c6c6ccccc666cccccccccccccccccccccccccccc9999444cccccccccccccccccccccc
cccccccccccccccccccc4449999ccccccccccccccccccccccccccccc666c6c6ccccccc6cccccccccccccccccccccccccccc9999444cccccccccccccccccccccc
cccccccccccccccccccc4449999cccccccccccccccccccccccccccccc6cc666cc6cccc6cccccccccccccccccccccccccccc9999444cccccccccccccccccccccc
ccccccccccccc4444444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4444444444ccccccccccccccc
ccccccccccccc4444444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4444444444ccccccccccccccc
ccccccccccccc4444444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4444444444ccccccccccccccc
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
cccccccccccccccccccccccc55555555555555555555555555555555555555555555555555555555555555555555555555555555cccccccccccccccccccccccc
cccccccccccccccccccccccc55757575757575757575757575757575757575757575757575757575757575757575757575757575cccccccccccccccccccccccc
cccccccccccccccccccccccc57777777777777777777777777777777777777777777777777777777777777777777777777777755cccccccccccccccccccccccc
cccccccccccccccccccccccc55777777777777777777777777777777777777777777777777777777777777777777777777777775cccccccccccccccccccccccc
cccccccccccccccccccccccc57777777777777777777777777777777777777777777777777777777777777777777777777777755cccccccccccccccccccccccc
cccccccccccccccccccccccc55777777777777777777777777777777777777777777777777777777777777777777777777777775cccccccccccccccccccccccc
cccccccccccccccccccccccc57777777777777777777777777777777777777777777777777777777777777777777777777777755cccccccccccccccccccccccc
cccccccccccccccccccccccc55777777777777777777777777777777777777777777777777777777777777777777777777777775cccccccccccccccccccccccc
cccccccccccccccccccccccc57777777777777777777777777777777777777777777777777777777777777777777777777777755cccccccccccccccccccccccc
cccccccccccccccccccccccc55777777777777777777777777777777777777777777777777777777777777777777777777777775cccccccccccccccccccccccc
cccccccccccccccccccccccc57777777775777777007700700770007000700770707000777777077000770777777777777777755cccccccccccccccccccccccc
cccccccccccccccccccccccc55777777775577770766070606077066706606070606066677770767760677077777777777777775cccccccccccccccccccccccc
cccccccccccccccccccccccc57777744445567770677060606067067706706060606007777770677000677067777777777777755cccccccccccccccccccccccc
cccccccccccccccccccccccc55777744445567770677060606067067706706060606066777770677066677067777777777777775cccccccccccccccccccccccc
cccccccccccccccccccccccc57777777775577777007007606067067000706067006000777777077000770767777777777777755cccccccccccccccccccccccc
cccccccccccccccccccccccc55777777775777777766766776767767766676767766766677777767766677677777777777777775cccccccccccccccccccccccc
cccccccccccccccccccccccc57777777777777777777777777777777777777777777777777777777777777777777777777777755cccccccccccccccccccccccc
cccccccccccccccccccccccc55777777777777777777777700770007070777777007000700070007777777777777777777777775cccccccccccccccccccccccc
cccccccccccccccccccccccc57777777777777777777777706070666060677770766060600060666777777777777777777777755cccccccccccccccccccccccc
cccccccccccccccccccccccc55777777777777777777777706060077060677770677000606060077777777777777777777777775cccccccccccccccccccccccc
cccccccccccccccccccccccc57777777777777777777777706060667000677770607060606060667777777777777777777777755cccccccccccccccccccccccc
cccccccccccccccccccccccc55777777777777777777777706060007000677770006060606060007777777777777777777777775cccccccccccccccccccccccc
cccccccccccccccccccccccc57777777777777777777777776767666766677777666767676767666777777777777777777777755cccccccccccccccccccccccc
cccccccccccccccccccccccc55777777777777777777777777777777777777777777777777777777777777777777777777777775cccccccccccccccccccccccc
cccccccccccccccccccccccc57777777777777777777777777777777777777777777777777777777777777777777777777777755cccccccccccccccccccccccc
cccccccccccccccccccccccc55777777777777777777777777777777777777777777777777777777777777777777777777777775cccccccccccccccccccccccc
cccccccccccccccccccccccc57777777777777777777777777777777777777777777777777777777777777777777777777777755cccccccccccccccccccccccc
cccccccccccccccccccccccc55777777777777777777777777777777777777777777777777777777777777777777777777777775cccccccccccccccccccccccc
cccccccccccccccccccccccc57777777777777777777777777777777777777777777777777777777777777777777777777777755cccccccccccccccccccccccc
cccccccccccccccccccccccc55777777777777777777777777777777777777777777777777777777777777777777777777777775cccccccccccccccccccccccc
cccccccccccccccccccccccc57575757575757575757575757575757575757575757575757575757575757575757575757575755cccccccccccccccccccccccc
ccccccccccccccccc111111155555555555555555555555555555555555555555555555555555555555555555555555555555555111ccccccccccccccccccccc
ccccccccccccccccc11111111ccccccccccccccccccccccccccccc11111111111111111111555555555111111111111555511111111ccccccccccccccccccccc
ccccccccccccccccc11111111ccccccccccccccccccccccccccccc11111111111111111111555555555111111111111555511111111ccccccccccccccccccccc
ccccccccccccccccc11111111ccccccccccccccccccccccccccccc11111111111111111111555555555111111111111555511111111ccccccccccccccccccccc
cccccccccccc77777777711115555ccccccccccccccccccccc111111111111111111115555111111111111155551111111155555555ccccccccccccccccccccc
cccccccccccc77777777711115555ccccccccccccccccccccc111111111111111111115555111111111111155551111111155555555ccccccccccccccccccccc
cccccccccccc77777777711115555ccccccccccccccccccccc111111111111111111115555111111111111155551111111155555555ccccccccccccccccccccc
cccccccccccc77777777711115555ccccccccccccccccccccc111111111111111111115555111111111111155551111111155555555ccccccccccccccccccccc
cccccccccccc11111555511111111ccccccccccccccccccccc5555111155551111555555551111555551111555555555555111111115555ccccccccccccccccc
cccccccccccc11111555511111111ccccccccccccccccccccc5555111155551111555555551111555551111555555555555111111115555ccccccccccccccccc
cccccccccccc11131555511111111cccccccccccccccccc3cc5555111155551111555555551111555551111555555555555111131115555cccccccc3cccccccc
cccccccccccc11133555511111111cccccccccccccccccc33c5555111155551111555555551111555551111555555555555111133115555cccccccc33ccccccc
cccccccccccc555331111111155551111cccccccccccc55335555511111111111111111111111111111111111115555111111113355111111111ccc33ccccccc
cccccccccccc553333111111155551111cccccccccccc53333555511111111111111111111111111111111111115555111111133335111111111cc3333cccccc
cccccccccccc553333111111155551111cccccccccccc53333555511111111111111111111111111111111111115555111111133335111111111cc3333cccccc
cccccccccccc533333311111155551111cccccccccccc33333355511111111111111111111111111111111111115555111111333333111111111c333333ccccc
cccccccc11111333333115555111155551111cccccccc333333555111111111111111111115555111111111111111111111113333331111111115333333ccccc
cccccccc11113333333315555111155551111ccccccc33333333551111111111111111111155551111111111111111111111333333331111111133333333cccc
cccccccc11113333333315555111155551111ccccccc33333333551111111111111111111155551111111111111111111111333333331111111133333333cccc
cccccccc11113333333315555111155551111ccccccc33333333551111111111111111111155551111111111111111111111333333331111111133333333cccc
cccccccc11111333333115555111155551111cccccccc333333555111111111111111111115555111111111111111111111113333331111111115333333ccccc
cccccccc111111333355511111111811111118ccc11115333311111111555511115555111155551111155551111558511111113333555551111111333311cccc
cccccccc111111122555511111118a8111118a8cc1111552251111111155551111555511115555111115555111158a811111111225555551111111122111cccc
cccccccc111111144555511111111811111118ccc11115544511111111555511115555111155551111155551111558511111111445555551111111144111cccc
cccccccc111111144555511111111311111113ccc11115544511111111555511115555111155551111155551111553511111111445555551111111144111cccc
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44545454445454544454545444545454445454544454545444545454445454544454545444545454445454544454547774747454447754777477547474777454
44454444444544444445444444454444444544444445444444454444444544444445444444454444444544444445447474757444447574747475747474777444
44544444445444444454444444544444445444444454444444544444445444444454444444544444445444444454447744777444447474777474747474747444
44455444444554444445544444455444444554444445544444455444444554444445544444455444444554444445547474457444447574747475747474757444
45444454454444544544445445444454454444544544445445444454454444544544445445444454454444544544447775777454457774747577745775747454
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444

__gff__
0001010000020200000000000000000000010000000202000000000000000000000000000000000000000000000000000000000004040400000000000000000000000000040404000000000000000000000000000404040000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11000000000000000000000000000011113435353535353535353600000000111100000000000000000000000000001111343535353535353535360000000011110000003435353535353535353536111100000000000000000000000000001111002b0000000000002b00000000001111343535353535353600000000000011
110000000000000000000000000000111144454545454545454546000000001111000000000000000000000000000011114445454545454545454600000000111100000044454545454545454545461111000000000000000000005d5e5f001111005d5e5f000000000000000000001111444545454545454600000000000011
1100005d5e5f0000000000000000001111545555555555555555565a5b5c0011115e5f00000000000000000000390011115455555555555555555600000000111100000044454545454545454545461111000000000000000000006d6e6f001111286d6e6f000000000000000000001111545555555555555600000000000011
1100006d6e6f0000000000000000001111000000000000000000006a6b6c0011116e6f000000000000000000000000111100006a6b6c00000000000000000011113a00004445454545454545454546111100005a5b5c000000000000000000111100000000000000000000000000001111000000000000000000000000000011
1100000000000000000000000000001111005d5e5f00000000000000000000111100000000000000111111111111111111000000000000000000005d5e5f0011110000005455555555555555555556111100006a6b6c0000000000000000001111000000250000005a5b5c000000001111000000000000000000000000000011
1100000000000000000000000000001111006d6e6f00000000000000000000111100000000000000110000000000001111000000000000000000006d6e6f0011111111000000000000000000000000111100000000000000000000000000001111111111111111006a6b6c000039001111000000000000000000000000000011
1100000000000000000000000000001111000000000000000000000000000011110000000000000011000000005a5b111100000000000000000000000000001111110000000000000000000000000011110000000000111111000000000000111100000000000000000000000000001111000000000000000011111111111111
1111115758000003000000390057581111000000000000000000000000390011110000000000002511000000006a6b1111280000000000000000000000000011110000000000000000000000000000111100000000001100110000000000001111000000000000000000002c1111111111000000000000000011373737373711
1111116768000000000000000067681111000000000000000000000000000011110000000011111111000000000000111100000000000000000000000000001111000000000000000000000000000011110000000000110000000000003900111100000000000000000000000000001111000000000000000011003a00000011
1111110101010101010101010101011111000000000000000000000000111111110000000011343535353535353536111100000000000000000000000000001111000000000000000000000000000011110000000000110011000000000000111100000000000000000000000000001111000000000000000011000000000011
11111102020202020202020202020211110000000000000000000000000000111100000000114445454545454545461111000000000000000011111100002c1111000000000000000000000000000011110000000000110011000000001111111100000000000000000000000000001111000000000000000011111111000011
1134353535353535353535353602021111000000000000000000000000000011110300000011444545454545454546111157585758000000390011000000001111000000000000000000000000000011110000000000110011000000000000111100000000000300000000005758001111000300000000000000000000000011
1144454545454545454545454602021111000003000000000000000000000011110000002511545555555555555556111167686768000000000011030000001111000300000000000000000100000011110300000000000011000000000000111100640000000000000000006768001111000000000000000064646400002511
1154555555555555555555555602021111000000000000000000000000000011110101010101010101010101010101111101010101010101010111000000001111000000002500474747470247474711110000474700002511474747474747111101010101010101010101010101011111010101010101010101010101010111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1100001100000000000000000000001111000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
1103001100000000000000000000001111000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
1100001100005a5b5c0000000000001111000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
1111001100006a6b6c0000000000001111000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
1100001100000000000000000000001111000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000011000000000000005d5e5f001111000000000000000000000000390011110300000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
11000011003900000000006d6e6f001111000000000000000000000000000011110000002500000000000000000000111100000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
1100000000000011000000000000001111000000000000000000000000111111111111111100000000000000000000111100000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
1100001111111111000000000000001111000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
1100001100000000000000000000001111000000000000000000000000000011110000000000000000470000470000111100000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
1100001100575857585758575800001111000000000000000000000000000011110000000000000000110000110000111100000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
1100001100676867686768676864641111005758030000250000000000000011110000000000000000113900110000111100000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
1100001101010101010101010101011111006768000000020200000000000011110000000000000000110000110000111100000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
1147471102020202020202020202021111010101010101020201010101010111114747474747474747114747114747111100000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
__sfx__
00050000185501b5502050031000300002d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001e7501e750207502275022750237502475029750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
