local camera = require("src/camera")

local types = {cloud1 = 1, cloud2 = 2}
local decoration_entities = {}
local decoration_coroutines = {}

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

    add(decoration_coroutines, cocreate(function()
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

local function update()
    for e in all(decoration_entities) do e:update() end

    for c in all(decoration_coroutines) do
        local status = costatus(c)
        if status == "suspended" then
            coresume(c)
        elseif status == "dead" then
            del(decoration_coroutines, c)
        end
    end
end

return {
    init = function() decoration_entities = {} end,
    update = update,
    draw_decorations = draw_decorations,
    draw_background = draw_background,
    replace_in_map = replace_in_map
}
