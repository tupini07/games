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
