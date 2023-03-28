local exports = {}

-- This will reload the given package from disk and reload it into memory.
function exports.reload_package(package_name)
    local old = require(package_name)
    package.loaded[package_name] = nil
    local new = require(package_name)
    if (type(new) == "table") then
        for k, v in pairs(new) do
            old[k] = v
        end
        for k, v in pairs(old) do
            if not new[k] then
                old[k] = nil
            end
        end
        package.loaded[package_name] = old
    end
end

local function find_recursive_with_extension(folder, file_tree, extension)
    local files_in_folder = love.filesystem.getDirectoryItems(folder)

    for _, v in ipairs(files_in_folder) do
        local file = folder .. "/" .. v
        local info = love.filesystem.getInfo(file)

        if info then
            if info.type == "file" and v:find(extension .. "$") ~= nil then
                table.insert(file_tree, file)
            elseif info.type == "directory" and v ~= "" then
                find_recursive_with_extension(file, file_tree, extension)
            end
        end
    end

    return file_tree
end

function exports.reload_all_packages(active_scene_name)
    print("")

    -- reload all utilitis
    local utilities = find_recursive_with_extension("utilities", {}, ".lua")
    for _, utility in ipairs(utilities) do
        local package_name = utility:sub(1, -5)
        package_name = package_name:gsub("/", ".")

        print("Reloading package: " .. package_name)
        exports.reload_package(package_name)
    end

    -- then reload all entities
    local entities = find_recursive_with_extension("entities", {}, ".lua")
    for _, entity in ipairs(entities) do
        local package_name = entity:sub(1, -5)
        package_name = package_name:gsub("/", ".")

        print("Reloading package: " .. package_name)
        exports.reload_package(package_name)
    end

    -- then reload all scenes
    local scenes = find_recursive_with_extension("scenes", {}, ".lua")
    for _, scene in ipairs(scenes) do
        local package_name = scene:sub(1, -5)
        package_name = package_name:gsub("/", ".")

        print("Reloading package: " .. package_name)
        exports.reload_package(package_name)

        -- if the scene is the active scene, then we need to reinitialize it
        if package_name == active_scene_name then
            print("Reloading init function for scene: " .. package_name)
            require(package_name).init()
        end
    end

    print("")
end

return exports
