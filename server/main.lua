local hasSpawned = false
local parkedVehicles = {}

local function IfPlayerIsVIPGetMaxParking(src)
	local Player = GetPlayer(src)
	local citizenid = GetCitizenId(src)
	local max = Config.Maxparking
	if Player then
		local data = nil
		if Config.Framework == 'esx' then
			data = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = ?", { citizenid })[1]
		elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
			data = MySQL.Sync.fetchAll("SELECT * FROM players WHERE citizenid = ?", { citizenid })[1]
		end
		if data ~= nil and data.parkvip == 1 then
			max = data.parkmax
		end
	end
	return max
end

local function CanSave(src)
    local canSave = true
    local defaultMax = Config.DefaultMaxParking
    local totalParked = nil
    local citizenid = GetCitizenId(src)
    if Config.Framework == 'esx' then
        totalParked = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE owner = ? AND stored = ?", { citizenid, 3 })
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        totalParked = MySQL.Sync.fetchAll("SELECT * FROM player_vehicles WHERE citizenid = ? AND state = ?", { citizenid, 3 })
    end
    if Config.UseAsVip then defaultMax = IfPlayerIsVIPGetMaxParking(src) end
    if type(totalParked) == 'table' and #totalParked >= defaultMax then
        canSave = false
    end
    return canSave
end

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

local function RemoveVehicle(netid)
    for i = 1, #parkedVehicles, 1 do
        if parkedVehicles[i].netid == netid then
            parkedVehicles[i] = nil
            break
        end
    end
end

local function SpawnVehicles(src)
    hasSpawned = true
    parkedVehicles = {}
    local vehicles = nil
	if Config.Framework == 'esx' then
		vehicles = MySQL.query.await("SELECT * FROM owned_vehicles WHERE stored = ?", {3})
		vehicles.state = vehicles.stored
	elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
		vehicles = MySQL.query.await("SELECT * FROM player_vehicles WHERE state = ?", {3})
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
		result = MySQL.query.await("SELECT * FROM owned_vehicles WHERE owner = ? AND stored = ? ORDER BY id ASC", { citizenid, 3 })
		result.state = result.stored
	elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
		result = MySQL.query.await("SELECT * FROM player_vehicles WHERE citizenid = ? AND state = ? ORDER BY id ASC", { citizenid, 3 })
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
                result = MySQL.query.await("SELECT * FROM owned_vehicles WHERE citizenid = ? AND plate = ? AND stored = ?", { citizenid, plate, 3})[1]
            elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
                result = MySQL.query.await("SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ? AND state = ?", { citizenid, plate, 3})[1]
            end
            if result ~= nil and result.plate == plate and result.citizenid == Player.PlayerData.citizenid then
                MySQL.Async.execute('UPDATE player_vehicles SET state = ?, location = ? WHERE plate = ?', { 0, nil, plate })
                RemoveVehicle(netid)
                if GetResourceState("mh-vehiclekeyitem") ~= 'missing' then
                    exports['mh-vehiclekeyitem']:AddItem(src, plate, netid)
                end
                TriggerClientEvent('mh-parking:client:ToggleFreezeVehicle', -1, {netid = netid, owner = result.citizenid})
                TriggerClientEvent('mh-parking:client:RemoveVehicle', -1, {netid = netid})
                print("Enter Vehicle "..netid..' / '..seat..' / '..result.citizenid)
            end
        end
	end
end)

RegisterNetEvent('mh-parking:server:LeftVehicle', function(netid, seat, plate, location, steerangle, street, fuel) 
    local src = source
	if seat == -1 then
        local vehicle = NetworkGetEntityFromNetworkId(netid)
        if DoesEntityExist(vehicle) then
            local citizenid = GetCitizenId(src)
            local result = nil
            local owner = nil
            if Config.Framework == 'esx' then
                result = MySQL.query.await("SELECT * FROM owned_vehicles WHERE owner = ? AND plate = ? AND stored = ?", { citizenid, plate, 0})[1]
                owner = result.owner
            elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
                result = MySQL.query.await("SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ? AND state = ?", { citizenid, plate, 0})[1]
                owner = result.citizenid
            end
            if result ~= nil and result.plate == plate and owner == citizenid then
                local canSave = CanSave(src)
                if canSave then
                    local mods = json.encode(result.mods)
                    local coords = json.decode(result.location)
                    local target = GetPlayerDataByCitizenId(owner)
                    local fullname = target.PlayerData.charinfo.firstname .. ' ' .. target.PlayerData.charinfo.lastname
                    parkedVehicles[result.plate] = {
                        fullname = fullname,
                        owner = owner, 
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
                else
                    Notify(src, Lang:t('info.limit_parking', {limit=defaultMax}, "error", 5000))
                end
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
        TriggerClientEvent('mh-parking:client:reloadZones', -1, {zoneid = count, list = Config.PrivedParking})
    else
        print("not a admin")
    end
end)

AddEventHandler('entityCreated', function(entity)
    if GetEntityType(entity) == 2 then
        local netid = NetworkGetNetworkIdFromEntity(entity)
        TriggerClientEvent('mh-parking:client:KeepEngineOnWhenAbandoned', -1, netid)
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
AddCommand("addparkvip", 'Add player as vip', {}, true, function(source, args)
	local src, amount, targetID = source, Config.Maxparking, -1
	if args[1] and tonumber(args[1]) > 0 then targetID = tonumber(args[1]) end
	if args[2] and tonumber(args[2]) > 0 then amount = tonumber(args[2]) end
	if targetID ~= -1 then
		local Player = GetPlayer(targetID)
		if Player then
			if Config.Framework == 'esx' then
				MySQL.Async.execute("UPDATE users SET parkvip = ?, parkmax = ? WHERE owner = ?", { 1, amount, Player.identifier })
				if targetID ~= src then Notify(targetID, 'player add as vip', "success", 10000) end
				Notify(src, 'is added as vip', "success", 10000)
			elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
				MySQL.Async.execute("UPDATE players SET parkvip = ?, parkmax = ? WHERE citizenid = ?", { 1, amount, Player.PlayerData.citizenid })
				if targetID ~= src then Notify(targetID, 'player add as vip', "success", 10000) end
				Notify(src, 'is added as vip', "success", 10000)
			end
		end
	end
end, 'admin')

AddCommand("removeparkvip", 'Remove player as vip', {}, true, function(source, args)
	local src, targetID = source, -1
	if args[1] and tonumber(args[1]) > 0 then targetID = tonumber(args[1]) end
	if targetID ~= -1 then
		local Player = GetPlayer(targetID)
		if Player then
			if Config.Framework == 'esx' then
				MySQL.Async.execute("UPDATE users SET parkvip = ?, parkmax = ? WHERE owner = ?", { 0, 0, Player.identifier })
				Notify(src, 'player removed as vip', "success", 10000)
			elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
				MySQL.Async.execute("UPDATE players SET parkvip = ?, parkmax = ? WHERE citizenid = ?", { 0, 0, Player.PlayerData.citizenid })
				Notify(src, 'player removed as vip', "success", 10000)
			end
		end
	end
end, 'admin')

AddCommand("parkresetall", 'reset all players', {}, true, function(source, args)
    if Config.Framework == 'esx' then
        MySQL.Async.execute('UPDATE owned_vehicles SET stored = ?, location = ?, street = ?, parktime = ?, time = ?', { 1, nil, nil, 0, 0 })
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        MySQL.Async.execute('UPDATE player_vehicles SET state = ?, location = ?, street = ?, parktime = ?, time = ?', { 1, nil, nil, 0, 0 })
    end
end, 'admin')

AddCommand("parkresetplayer", 'reset a player', {}, true, function(source, args)
    if args ~= nil and args[1] ~= nil and type(args[1]) == 'number' then
        local id = tonumber(args[1])
        local target = GetPlayer(id)
        local citizenid = GetCitizenId(id)
        if Config.Framework == 'esx' then
             MySQL.Async.execute('UPDATE owned_vehicles SET stored = ?, location = ?, street = ?, parktime = ?, time = ? WHERE owner = ?', { 1, nil, nil, 0, 0, citizenid })
        elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
            MySQL.Async.execute('UPDATE player_vehicles SET state = ?, location = ?, street = ?, parktime = ?, time = ? WHERE citizenid = ?', { 1, nil, nil, 0, 0, citizenid })           
        end
    end
end, 'admin')

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
            if Config.PrivedParking[zoneid] then
                table.remove(Config.PrivedParking, zoneid)
            end             
            os.remove(path)
            TriggerClientEvent('mh-parking:client:reloadZones', -1, {zoneid = zoneid, list = Config.PrivedParking})
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


------------------------------------------------------------------------------------
RegisterNetEvent('police:server:Impound', function(plate, fullImpound, price, body, engine, fuel)
    local src = source
    if parkedVehicles[plate] and parkedVehicles[plate].netid ~= false and parkedVehicles[plate].entity ~= false then
        RemoveVehicle(parkedVehicles[plate].netid)
        TriggerClientEvent('mh-parking:client:RemoveVehicle', -1, {
            netid = parkedVehicles[plate].netid,
            entity = parkedVehicles[plate].entity,
            owner = parkedVehicles[plate].owner,
            plate = parkedVehicles[plate].plate
        })                    
    end
end)

local function ParkingTimeCheckLoop()
    if Config.UseTimerPark then
        local result = nil
        if Config.Framework == 'esx' then
            result = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE stored = 3", {})
        elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
            result = MySQL.Sync.fetchAll("SELECT * FROM player_vehicles WHERE state = 3", {})
        end
        if result ~= nil then
            for k, v in pairs(result) do
                local total = os.time() - v.time
                if v.parktime > 0 and total > v.parktime then
                    print("[MH Parking] - [Time Limit Detection] - Vehicle with plate: ^2" .. v.plate .. "^7 has been impound by the police.")
                    if parkedVehicles[v.plate] and parkedVehicles[v.plate].netid ~= false and parkedVehicles[v.plate].entity ~= false then
                        RemoveVehicle(parkedVehicles[v.plate].netid)
                        TriggerClientEvent('mh-parking:client:RemoveVehicle', -1, {
                            netid = parkedVehicles[v.plate].netid,
                            entity = parkedVehicles[v.plate].entity,
                            owner = parkedVehicles[v.plate].owner,
                            plate = parkedVehicles[v.plate].plate
                        })                    
                    end
                    local cost = (math.floor(((os.time() - v.time) / Config.PayTimeInSecs) * Config.ParkPrice))
                    PoliceImpound(v.plate, true, cost, v.body, v.engine, v.fuel) 
                end
            end
        end
    end
    SetTimeout(10000, ParkingTimeCheckLoop)
end
ParkingTimeCheckLoop()