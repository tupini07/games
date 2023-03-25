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

return exports