local mathx = require("libs.batteries.mathx")

local material_selector = {
    selected_idx = 3
}

local num_materials = 10

function material_selector:update()
    if input.was_key_just_pressed("a") then
        material_selector.selected_idx = mathx.wrap(material_selector.selected_idx + 1, 0, num_materials)
    end
end

function material_selector:draw()
    love.graphics.setColor(0.2, 0.4, 0.6, 1)
    for i = 0, (num_materials - 1) do
        love.graphics.rectangle("line", 5 + 31 * i, 25, 25, 25)

        if i == material_selector.selected_idx then
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(0.9, 0.5, 0.8, 1)
            love.graphics.setLineWidth(3)
            love.graphics.rectangle("line", 5 + 31 * i, 25, 25, 25)
            love.graphics.setColor(r, g, b, a)
        end
    end
end

return material_selector
