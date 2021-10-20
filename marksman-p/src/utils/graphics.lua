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
