SAVE_DATA = {current_level = 1}

local save_data_points = {current_level = 1}

local function load_save_data()
    SAVE_DATA.current_level = dget(save_data_points.current_level)
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
