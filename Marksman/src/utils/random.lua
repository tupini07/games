local utils = {
    rndb = function(low, high)
        local difference = high - low + 1
        return flr(rnd(difference) + low)
    end
}

return utils
