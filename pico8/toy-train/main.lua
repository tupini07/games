local map = require("map")
local train = require("train")
local logger = require("utils/logger")

function _init()
    train.init()
end

function _update()
    train.update()
end

function _draw()
    cls()
    map.draw()
    train.draw()
end
