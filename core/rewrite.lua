local function RewriteVehicleFile()
    local path = GetResourcePath(GetCurrentResourceName())
    path = path:gsub('//', '/') .. '/vehicles.lua'
    os.remove(path)
    local count = #Config.PrivedParking + 1
    local display = true
    local file = io.open(path, 'a+')
    local label = 'Config.Vehicles = {\n'

    label = label ..'\n    --- Compacts (0)\n'
    for k, v in pairs(Framework.Shared.Vehicles) do
        if v.category == "compacts" then
            label = label ..'    ['..GetHashKey(v.model)..'] = { model = "'..v.model..'", name = "'..v.name..'", brand = "'..v.brand..'", category = "'..v.category..'", type = "'..v.type..'", shop = "'..v.shop..'", price = "'..v.price..'" },\n'
        end
    end

    label = label ..'\n    --- Sedans (1)\n'
    for k, v in pairs(Framework.Shared.Vehicles) do
        if v.category == "sedans" then
            label = label ..'    ['..GetHashKey(v.model)..'] = { model = "'..v.model..'", name = "'..v.name..'", brand = "'..v.brand..'", category = "'..v.category..'", type = "'..v.type..'", shop = "'..v.shop..'", price = "'..v.price..'" },\n'
        end
    end

    label = label ..'\n    --- SUV (2)\n'
    for k, v in pairs(Framework.Shared.Vehicles) do
        if v.category == "suvs" then
            label = label ..'    ['..GetHashKey(v.model)..'] = { model = "'..v.model..'", name = "'..v.name..'", brand = "'..v.brand..'", category = "'..v.category..'", type = "'..v.type..'", shop = "'..v.shop..'", price = "'..v.price..'" },\n'
        end
    end

    label = label ..'\n    --- Coupes (3)\n'
    for k, v in pairs(Framework.Shared.Vehicles) do
        if v.category == "coupes" then
            label = label ..'    ['..GetHashKey(v.model)..'] = { model = "'..v.model..'", name = "'..v.name..'", brand = "'..v.brand..'", category = "'..v.category..'", type = "'..v.type..'", shop = "'..v.shop..'", price = "'..v.price..'" },\n'
        end
    end

    label = label ..'\n    --- Muscle (4)\n'
    for k, v in pairs(Framework.Shared.Vehicles) do
        if v.category == "muscle" then
            label = label ..'    ['..GetHashKey(v.model)..'] = { model = "'..v.model..'", name = "'..v.name..'", brand = "'..v.brand..'", category = "'..v.category..'", type = "'..v.type..'", shop = "'..v.shop..'", price = "'..v.price..'" },\n'
        end
    end

    label = label ..'\n    --- Sports Classic (5)\n'
    for k, v in pairs(Framework.Shared.Vehicles) do
        if v.category == "sportsclassics" then
            label = label ..'    ['..GetHashKey(v.model)..'] = { model = "'..v.model..'", name = "'..v.name..'", brand = "'..v.brand..'", category = "'..v.category..'", type = "'..v.type..'", shop = "'..v.shop..'", price = "'..v.price..'" },\n'
        end
    end

    label = label ..'\n    --- Sports (6)\n'
    for k, v in pairs(Framework.Shared.Vehicles) do
        if v.category == "sports" then
            label = label ..'    ['..GetHashKey(v.model)..'] = { model = "'..v.model..'", name = "'..v.name..'", brand = "'..v.brand..'", category = "'..v.category..'", type = "'..v.type..'", shop = "'..v.shop..'", price = "'..v.price..'" },\n'
        end
    end

    label = label ..'\n    --- Super (7)\n'
    for k, v in pairs(Framework.Shared.Vehicles) do
        if v.category == "super" then
            label = label ..'    ['..GetHashKey(v.model)..'] = { model = "'..v.model..'", name = "'..v.name..'", brand = "'..v.brand..'", category = "'..v.category..'", type = "'..v.type..'", shop = "'..v.shop..'", price = "'..v.price..'" },\n'
        end
    end

    label = label ..'\n    --- Motorcycles (8)\n'
    for k, v in pairs(Framework.Shared.Vehicles) do
        if v.category == "motorcycles" then
            label = label ..'    ['..GetHashKey(v.model)..'] = { model = "'..v.model..'", name = "'..v.name..'", brand = "'..v.brand..'", category = "'..v.category..'", type = "'..v.type..'", shop = "'..v.shop..'", price = "'..v.price..'" },\n'
        end
    end

    label = label ..'\n    --- Off-Road (9)\n'
    for k, v in pairs(Framework.Shared.Vehicles) do
        if v.category == "offroad" then
            label = label ..'    ['..GetHashKey(v.model)..'] = { model = "'..v.model..'", name = "'..v.name..'", brand = "'..v.brand..'", category = "'..v.category..'", type = "'..v.type..'", shop = "'..v.shop..'", price = "'..v.price..'" },\n'
        end
    end

    label = label ..'\n    --- Industrial (10)\n'
    for k, v in pairs(Framework.Shared.Vehicles) do
        if v.category == "industrial" then
            label = label ..'    ['..GetHashKey(v.model)..'] = { model = "'..v.model..'", name = "'..v.name..'", brand = "'..v.brand..'", category = "'..v.category..'", type = "'..v.type..'", shop = "'..v.shop..'", price = "'..v.price..'" },\n'
        end
    end

    label = label ..'\n    --- Utility (11)\n'
    for k, v in pairs(Framework.Shared.Vehicles) do
        if v.category == "utility" then
            label = label ..'    ['..GetHashKey(v.model)..'] = { model = "'..v.model..'", name = "'..v.name..'", brand = "'..v.brand..'", category = "'..v.category..'", type = "'..v.type..'", shop = "'..v.shop..'", price = "'..v.price..'" },\n'
        end
    end
    
    label = label ..'\n    --- Vans (12)\n'
    for k, v in pairs(Framework.Shared.Vehicles) do
        if v.category == "vans" then
            label = label ..'    ['..GetHashKey(v.model)..'] = { model = "'..v.model..'", name = "'..v.name..'", brand = "'..v.brand..'", category = "'..v.category..'", type = "'..v.type..'", shop = "'..v.shop..'", price = "'..v.price..'" },\n'
        end
    end

    label = label ..'\n    --- Cycles (13)\n'
    for k, v in pairs(Framework.Shared.Vehicles) do
        if v.category == "cycles" then
            label = label ..'    ['..GetHashKey(v.model)..'] = { model = "'..v.model..'", name = "'..v.name..'", brand = "'..v.brand..'", category = "'..v.category..'", type = "'..v.type..'", shop = "'..v.shop..'", price = "'..v.price..'" },\n'
        end
    end

    label = label ..'\n    --- Boats (14)\n'
    for k, v in pairs(Framework.Shared.Vehicles) do
        if v.category == "boats" then
            label = label ..'    ['..GetHashKey(v.model)..'] = { model = "'..v.model..'", name = "'..v.name..'", brand = "'..v.brand..'", category = "'..v.category..'", type = "'..v.type..'", shop = "'..v.shop..'", price = "'..v.price..'" },\n'
        end
    end

    label = label ..'\n    --- Helicopters (15)\n'
    for k, v in pairs(Framework.Shared.Vehicles) do
        if v.category == "helicopters" then
            label = label ..'    ['..GetHashKey(v.model)..'] = { model = "'..v.model..'", name = "'..v.name..'", brand = "'..v.brand..'", category = "'..v.category..'", type = "'..v.type..'", shop = "'..v.shop..'", price = "'..v.price..'" },\n'
        end
    end

    label = label ..'\n    --- Planes (16)\n'
    for k, v in pairs(Framework.Shared.Vehicles) do
        if v.category == "planes" then
            label = label ..'    ['..GetHashKey(v.model)..'] = { model = "'..v.model..'", name = "'..v.name..'", brand = "'..v.brand..'", category = "'..v.category..'", type = "'..v.type..'", shop = "'..v.shop..'", price = "'..v.price..'" },\n'
        end
    end

    label = label ..'\n    --- Service (17)\n'
    for k, v in pairs(Framework.Shared.Vehicles) do
        if v.category == "service" then
            label = label ..'    ['..GetHashKey(v.model)..'] = { model = "'..v.model..'", name = "'..v.name..'", brand = "'..v.brand..'", category = "'..v.category..'", type = "'..v.type..'", shop = "'..v.shop..'", price = "'..v.price..'" },\n'
        end
    end

    label = label ..'\n    --- Emergency (18)\n'
    for k, v in pairs(Framework.Shared.Vehicles) do
        if v.category == "emergency" then
            label = label ..'    ['..GetHashKey(v.model)..'] = { model = "'..v.model..'", name = "'..v.name..'", brand = "'..v.brand..'", category = "'..v.category..'", type = "'..v.type..'", shop = "'..v.shop..'", price = "'..v.price..'" },\n'
        end
    end

    label = label ..'\n    --- Military (19)\n'
    for k, v in pairs(Framework.Shared.Vehicles) do
        if v.category == "military" then
            label = label ..'    ['..GetHashKey(v.model)..'] = { model = "'..v.model..'", name = "'..v.name..'", brand = "'..v.brand..'", category = "'..v.category..'", type = "'..v.type..'", shop = "'..v.shop..'", price = "'..v.price..'" },\n'
        end
    end

    label = label ..'\n    --- Commercial (20)\n'
    for k, v in pairs(Framework.Shared.Vehicles) do
        if v.category == "commercial" then
            label = label ..'    ['..GetHashKey(v.model)..'] = { model = "'..v.model..'", name = "'..v.name..'", brand = "'..v.brand..'", category = "'..v.category..'", type = "'..v.type..'", shop = "'..v.shop..'", price = "'..v.price..'" },\n'
        end
    end

    label = label ..'\n    --- Open Wheel (22)\n'
    for k, v in pairs(Framework.Shared.Vehicles) do
        if v.category == "openwheel" then
            label = label ..'    ['..GetHashKey(v.model)..'] = { model = "'..v.model..'", name = "'..v.name..'", brand = "'..v.brand..'", category = "'..v.category..'", type = "'..v.type..'", shop = "'..v.shop..'", price = "'..v.price..'" },\n'
        end
    end

    label = label ..'}'
    file:write(label)
    file:close()
end
RewriteVehicleFile()