return {
    log = function(msg)
        printh(msg, "game_log")
    end,
    assert = function(condition, msg)
        assert(condition, msg)
    end
}
