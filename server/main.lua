

local hasSpawned = false
local parkedVehicles = {}

local function isAdmin(src)
    if IsPlayerAceAllowed(src, 'admin') or IsPlayerAceAllowed(src, 'command') then return true end
    return false
end

local function GetClosestVehicle(coords)
    local vehicles = GetGamePool('CVehicle')
    local closestDistance = -1
    local closestVehicle = -1
    for i = 1, #vehicles, 1 do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = #(vehicleCoords - coords)
        if closestDistance == -1 or closestDistance > distance then
            closestVehicle = vehicles[i]
            closestDistance = distance
        end
    end
    return closestVehicle, closestDistance
end

local function DeleteVehicleAtcoords(coords)
	local closestVehicle, closestDistance = GetClosestVehicle(coords)
	if closestVehicle ~= -1 and closestDistance <= 2.0 then
		DeleteEntity(closestVehicle)
		while DoesEntityExist(closestVehicle) do
			DeleteEntity(closestVehicle)
			Wait(50)
		end
	end
end

local function AddVehicle(data)
    if parkedVehicles[data.plate] then return false end
    if not parkedVehicles[data.plate] then parkedVehicles[data.plate] = {} end
    parkedVehicles[data.plate] = {
        fullname = data.fullname,
        owner = data.owner, 
        netid = data.netid,
        entity = data.vehicle,
        mods = data.mods,
        hash = data.hash,
        plate = data.plate, 
        model = data.model,
        fuel = data.fuel,
        body = data.body,
        engine = data.engine,
        steerangle = data.steerangle,
        location = data.location
    }
    TriggerClientEvent('mh-parking:client:AddVehicle', -1, {netid = data.netid, data = parkedVehicles[data.plate]})
end

local function RemoveVehicle(netid)
    for i = 1, #parkedVehicles, 1 do
        if parkedVehicles[i].netid == netid then
            parkedVehicles[i] = nil
            break
        end
    end
end

local function PrepareVehicles()
    parkedVehicles = {}
    local vehicles = nil
    if Config.Framework == 'esx' then
		vehicles = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE stored = ?", {3})
		vehicles.state = vehicles.stored
	elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
		vehicles = MySQL.Sync.fetchAll("SELECT * FROM player_vehicles WHERE state = ?", {3})
	end

    for k, vehicle in pairs(vehicles) do
        if not parkedVehicles[vehicle.plate] then
            parkedVehicles[vehicle.plate] = {}
            local target = GetPlayerDataByCitizenId(vehicle.citizenid)
            local fullname = target.PlayerData.charinfo.firstname .. ' ' .. target.PlayerData.charinfo.lastname
            parkedVehicles[vehicle.plate] = {
                netid = false,
                entity = false,
                fullname = fullname,
                owner = vehicle.citizenid, 
                hash = vehicle.hash,
                plate = vehicle.plate, 
                model = vehicle.vehicle,
                fuel = vehicle.fuel,
                body = vehicle.body,
                engine = vehicle.engine,
                street = vehicle.street,
                steerangle = tonumber(vehicle.steerangle),
                mods = json.decode(vehicle.mods),
                location = json.decode(vehicle.location)
            }
        end
    end
end

local function SpawnVehicles(src)
    hasSpawned = true
    parkedVehicles = {}
    local vehicles = nil
	if Config.Framework == 'esx' then
		vehicles = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE stored = ?", {3})
		vehicles.state = vehicles.stored
	elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
		vehicles = MySQL.Sync.fetchAll("SELECT * FROM player_vehicles WHERE state = ?", {3})
	end
    for k, vehicle in pairs(vehicles) do
        if not parkedVehicles[vehicle.plate] then
            parkedVehicles[vehicle.plate] = {}
            local coords = json.decode(vehicle.location)
            DeleteVehicleAtcoords(vector3(coords.x, coords.y, coords.z))
            Wait(100)
            local mods = json.decode(vehicle.mods)
            local entity = CreateVehicle(mods.model, coords.x, coords.y, coords.z, coords.h, true, true)
            while not DoesEntityExist(entity) do Wait(0) end
            local netid = NetworkGetNetworkIdFromEntity(entity)
            SetVehicleNumberPlateText(entity, vehicle.plate)
            local target = GetPlayerDataByCitizenId(vehicle.citizenid)
            local fullname = target.PlayerData.charinfo.firstname .. ' ' .. target.PlayerData.charinfo.lastname
            parkedVehicles[vehicle.plate] = {
                fullname = fullname,
                owner = vehicle.citizenid, 
                netid = netid,
                entity = entity,
                mods = mods,
                hash = vehicle.hash,
                plate = vehicle.plate, 
                model = vehicle.vehicle,
                fuel = vehicle.fuel,
                body = vehicle.body,
                engine = vehicle.engine,
                street = vehicle.street,
                steerangle = tonumber(vehicle.steerangle) + 0.0,
                location = coords
            }
        end
    end
end

AddEventHandler('onResourceStop', function(resource) 
    if resource == GetCurrentResourceName() then
        hasSpawned = false
        for i = 1, #parkedVehicles, 1 do
            if DoesEntityExist(parkedVehicles[i].entity) then
                DeleteEntity(parkedVehicles[i].entity)
                parkedVehicles[i] = nil
            end
        end
        parkedVehicles = {}
    end
end)

AddEventHandler('onResourceStart', function(resource) 
    if resource == GetCurrentResourceName() then 
        --SpawnVehicles(false)
    end 
end)

RegisterNetEvent("mh-parking:server:OnJoin", function()
    local src = source
    local players = GetPlayers()
    if #players <= 1 then 
        if not hasSpawned then
            hasSpawned = true
            SpawnVehicles(src)
            TriggerClientEvent("mh-parking:client:Onjoin", src, {status = true, vehicles = parkedVehicles})
        end
    elseif #players > 1 then
        if parkedVehicles ~= nil and #parkedVehicles >= 1 then
            TriggerClientEvent("mh-parking:client:Onjoin", src, {status = true, vehicles = parkedVehicles})
        end
    end
end)

RegisterNetEvent('mh-parking:server:setVehLockState', function(vehNetId, state)
    SetVehicleDoorsLocked(NetworkGetEntityFromNetworkId(vehNetId), state)
end)

CreateCallback("mh-parking:server:IsAdmin", function(source, cb)
    local src = source
    if isAdmin(src) then
	    cb({status = true, isadmin = true})
    else
        cb({status = false, isadmin = false})
    end
end)

CreateCallback("mh-parking:server:GetVehicles", function(source, cb)
    local src = source
	local citizenid = GetCitizenId(src)
	local result = nil
	if Config.Framework == 'esx' then
		result = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE owner = ? AND stored = ? ORDER BY id ASC", { citizenid, 3 })
		result.state = result.stored
	elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
		result = MySQL.Sync.fetchAll("SELECT * FROM player_vehicles WHERE citizenid = ? AND state = ? ORDER BY id ASC", { citizenid, 3 })
	end
	cb({status = true, data = result})
end)

RegisterNetEvent("mh-parking:server:RemoveVehicle", function(netid, plate)
    local vehicle = NetworkGetEntityFromNetworkId(netid)
    if DoesEntityExist(vehicle) then 
        if RemoveVehicle(netid) then
            TriggerClientEvent('mh-parking:client:RemoveVehicle', -1, netid)
            DeleteEntity(vehicle)
        end
    end
end)

RegisterNetEvent("mh-parking:server:EnteringVehicle", function(netid, seat)
    local src = source
	if seat == -1 then
        local vehicle = NetworkGetEntityFromNetworkId(netid)
        if DoesEntityExist(vehicle) then
            local Player = GetPlayer(src)
            local citizenid = GetCitizenId(src)
            local plate = GetVehicleNumberPlateText(vehicle)
            local result = nil
            if Config.Framework == 'esx' then
                result = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE citizenid = ? AND plate = ? AND stored = ?", { citizenid, plate, 3})[1]
            elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
                result = MySQL.Sync.fetchAll("SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ? AND state = ?", { citizenid, plate, 3})[1]
            end
            if result ~= nil and result.plate == plate and result.citizenid == Player.PlayerData.citizenid then
                MySQL.Async.execute('UPDATE player_vehicles SET state = ?, location = ? WHERE plate = ?', { 0, nil, plate })
                RemoveVehicle(netid)
                TriggerClientEvent('mh-parking:client:ToggleFreezeVehicle', -1, {netid = netid, owner = result.citizenid})
                TriggerClientEvent('mh-parking:client:RemoveVehicle', -1, {netid = netid})
                print("Enter Vehicle "..netid..' / '..seat..' / '..result.citizenid)
            end
        end
	end
end)

RegisterNetEvent('mh-parking:server:LeftVehicle', function(netid, seat, plate, location, steerangle, fuel, street) 
    local src = source
	if seat == -1 then
        local vehicle = NetworkGetEntityFromNetworkId(netid)
        if DoesEntityExist(vehicle) then
            local citizenid = GetCitizenId(src)
            local result = nil
            if Config.Framework == 'esx' then
                result = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE citizenid = ? AND plate = ? AND stored = ?", { citizenid, plate, 0})[1]
            elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
                result = MySQL.Sync.fetchAll("SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ? AND state = ?", { citizenid, plate, 0})[1]
            end
            if result ~= nil and result.plate == plate and result.citizenid == citizenid then
                local mods = json.encode(result.mods)
                local coords = json.decode(result.location)
                local target = GetPlayerDataByCitizenId(result.citizenid)
                local fullname = target.PlayerData.charinfo.firstname .. ' ' .. target.PlayerData.charinfo.lastname
                parkedVehicles[result.plate] = {
                    fullname = fullname,
                    owner = result.citizenid, 
                    netid = netid,
                    entity = vehicle,
                    hash = result.hash,
                    plate = result.plate, 
                    model = result.vehicle,
                    fuel = fuel,
                    body = result.body,
                    engine = result.engine,
                    steerangle = tonumber(result.steerangle),
                    mods = mods,
                    street = result.street,
                    location = location
                }
                if Config.Framework == 'esx' then
                    MySQL.Async.execute('UPDATE owned_vehicles SET stored = ?, location = ?, steerangle = ?, fuel = ? WHERE plate = ?', { 3, json.encode(location), tonumber(steerangle), fuel, result.plate})
                elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
                    MySQL.Async.execute('UPDATE player_vehicles SET state = ?, location = ?, steerangle = ?, fuel = ? WHERE plate = ?', { 3, json.encode(location), tonumber(steerangle), fuel, result.plate})
                end
                TriggerClientEvent('mh-parking:client:AddVehicle', -1, {netid = netid, data = parkedVehicles[result.plate]})
                TriggerClientEvent('mh-parking:client:ToggleFreezeVehicle', -1, {netid = netid, owner = result.citizenid})
                print("Left Vehicle "..netid..' / '..seat..' / '..steerangle..' / '..result.citizenid)
            end
        end
    end
end)

RegisterNetEvent('mh-parking:server:AllPlayersLeaveVehicle', function(vehicleNetID, players) 
    if players ~= nil and #players >= 1 then
        local vehicle = NetworkGetEntityFromNetworkId(vehicleNetID)
        if DoesEntityExist(vehicle) then
            for i = 1, #players, 1 do
                TriggerClientEvent('mh-parking:client:leaveVehicle', players[i].playerId, {vehicleNetID = vehicleNetID, playerId = players[i].playerId} )
            end
        end
    end
end)

RegisterNetEvent('mh-parking:server:CreatePark', function(input)
    local src = source
    if isAdmin(src) then
        local citizenid = GetCitizenId(input.id)
        local path = GetResourcePath(GetCurrentResourceName())
        path = path:gsub('//', '/') .. '/shared/configs/' .. string.gsub(input.name, ".lua", "") .. '.lua'
        local file = io.open(path, 'a+')
        local count = #Config.PrivedParking + 1
        local label = '\nConfig.PrivedParking['..count..'] = {\n'..    
        '    id = ' .. count .. ',\n'..
        '    citizenid = "' .. citizenid .. '",\n'..
        '    label = "' .. input.label .. '",\n'..  
        '    name = "' .. input.name ..'",\n'..
        '    street = "' .. input.street .. '",\n'..      
        '    coords = vector4(' .. input.coords.x .. ', ' .. input.coords.y .. ', ' .. input.coords.z .. ', ' .. input.heading .. '),\n'..   
        '    size = { width = 1.5, length = 4.0 },\n'..     
        '    job = ' .. input.job .. ',\n'..     
        '}\n'
        file:write(label)
        file:close()
        local data = {
            id = count,
            citizenid = citizenid,
            label = input.label,
            name = input.name,
            street = input.street,
            coords = vector4(input.coords.x, input.coords.y, input.coords.z, input.heading),
            size = { width = 1.5, length = 4.0 },
            job = input.job,
        }
        Config.PrivedParking[count] = data
        TriggerClientEvent('mh-parking:client:reloadZones', -1, {state = true, zoneid = count, data = Config.PrivedParking})
    else
        print("not a admin")
    end
end)

-- User Commands
AddCommand("togglesteerangle", 'Toggle steer angle on or off', {}, true, function(source, args)
    local src = source
    TriggerClientEvent('mh-parking:client:toggleSteerAngle', src)
end)

AddCommand("toggleparktext", 'Toggle park text on or off', {}, true, function(source, args)
    local src = source
    TriggerClientEvent('mh-parking:client:toggleParkText', src)
end)

AddCommand("parkmenu", 'Open Park Systen Menu', {}, true, function(source, args)
    local src = source
    TriggerClientEvent('mh-parking:client:OpenParkMenu', src, {status = true})
end)

-- Admin Commands
AddCommand('toggledebugpoly', 'Toggle Debug Poly On/Off', {}, false, function(source, args)
    TriggerClientEvent('mh-parking:client:TogglDebugPoly', -1)
end, 'admin')

AddCommand('deletepark', 'Delete Parked', { {name = "zoneid", info = "zone id"}, { name = "filename", help = "filename"} }, false, function(source, args)
    local src = source
    local zoneid, filename = nil, nil
    if args[1] ~= nil then zoneid = tonumber(args[1]) end
    if args[2] ~= nil then filename = tostring(args[2]) end
    if zoneid ~= nil and filename ~= nil then
        local path = GetResourcePath(GetCurrentResourceName())
        path = path:gsub('//', '/') .. '/shared/configs/'..filename..'.lua'
        local file = io.open(path, "r")
        if file ~= nil then
            file:close()
            os.remove(path)
        end
        if Config.PrivedParking[zoneid] then
            Config.PrivedParking[zoneid] = nil
            TriggerClientEvent('mh-parking:client:reloadZones', -1, {state = false, zoneid = zoneid, data = Config.PrivedParking})
        end
    end
end, 'admin')

AddCommand('createpark', 'Create parked', { {name = "id", info = "player id"}, { name = "filename", help = "filename"}, { name = "job", help = "job"}, { name = "label", help = "label"} }, false, function(source, args)
    local src = source
    local id, name, job, label = nil, nil, nil, nil
    if args[1] ~= nil then id = args[1] end
    if args[2] ~= nil then name = args[2] end
	if args[3] ~= nil then job = args[3] end
	if args[4] ~= nil then label = args[4] end
	if args[5] ~= nil then label = label.." "..args[5] end
	if args[6] ~= nil then label = label.." "..args[6] end
	if args[7] ~= nil then label = label.." "..args[7] end
    if id ~= nil and name ~= nil and label ~= nil then
	    TriggerClientEvent('mh-parking:client:CreatePark', src, {id = id, name = name, job = job, label = label})
    end
end, 'admin')