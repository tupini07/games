local map = require("map")
local logger = require("utils/logger")
local camera_utils = require("camera")

local segments = {}
local last_update_time

local function add_segment(x, y)
    add(segments, {
        x = x,
        y = y,
        is_head = #segments == 0,
        direction = "e"
    })
end

local function draw_segment(seg)
    local flip_h = seg.direction == "w"
    local flip_v = seg.direction == "s"

    local sprite
    if seg.direction == "e" or seg.direction == "w" then
        if seg.is_head then
            sprite = 2
        else
            sprite = 1
        end
    elseif seg.direction == "n" or seg.direction == "s" then
        if seg.is_head then
            sprite = 3
        else
            sprite = 4
        end
    end

    local cellx = seg.x * 8
    local celly = seg.y * 8

    spr(sprite, cellx, celly, 1, 1, flip_h, flip_v)
end

local function update_segment(seg)
    -- look at current position and direction and calculate next position
    local map_sprite = mget(seg.x, seg.y)
    seg.direction = map.track_direction_transforms(map_sprite, seg.direction)

    if seg.direction == "n" then
        seg.y = seg.y - 1
    elseif seg.direction == "s" then
        seg.y = seg.y + 1
    elseif seg.direction == "w" then
        seg.x = seg.x - 1
    elseif seg.direction == "e" then
        seg.x = seg.x + 1
    end
end

return {
    init = function()
        last_update_time = time()

        for i = 10, 4, -1 do
            add_segment(i, 6)
        end
    end,
    update = function()
        local now_time = time()
        if (now_time - last_update_time) > 0.10 then
            last_update_time = time()

            foreach(segments, update_segment)
        end
    end,
    draw = function()
        local head_x = segments[1].x * 8
        local head_y = segments[1].y * 8

        camera_utils.camera_center(head_x, head_y, 33, 33)
        foreach(segments, draw_segment)
    end
}

