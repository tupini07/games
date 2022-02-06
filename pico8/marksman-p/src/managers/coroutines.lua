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
