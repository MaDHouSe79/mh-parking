-- [[ ===================================================== ]] --
-- [[               MH Parking V2 by MaDHouSe79             ]] --
-- [[ ===================================================== ]] --
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
	if closestVehicle ~= -1 and closestDistance ~= -1 and closestDistance <= 2.0 then
		DeleteEntity(closestVehicle)
		while DoesEntityExist(closestVehicle) do
			DeleteEntity(closestVehicle)
			Wait(0)
		end
	end
end

local function GetPlayerFullNameFromCitizenid(citizenid)
    local fullname = false
    if Config.Framework == 'esx' then
		local char = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = ?", {citizenid})[1]
		if char and fullname == false then fullname = char.firstname .. ' ' .. char.lastname end
	elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        local player = MySQL.Sync.fetchAll("SELECT * FROM players WHERE citizenid = ?", {citizenid})[1]
        if player ~= nil and fullname == false then
            local info = json.decode(player.charinfo)
            fullname = info.firstname .." "..info.lastname
        end 
	end

    return fullname
end

local function RemoveVehicles()
    for i = 1, #parkedVehicles, 1 do
        if parkedVehicles[i].entity ~= nil and DoesEntityExist(parkedVehicles[i].entity) then
            DeleteEntity(parkedVehicles[i].entity)
            parkedVehicles[i] = nil
            break
        end
    end
    parkedVehicles = {}
end

local function RemoveVehicle(netid)
    for i = 1, #parkedVehicles, 1 do
        local vehicle = NetworkGetEntityFromNetworkId(parkedVehicles[i].netid)
        if DoesEntityExist(vehicle) then
            if parkedVehicles[i].entity == vehicle then
                parkedVehicles[i] = nil
                break
            end
        end
    end
end

local function PrepeareVehicles()
    RemoveVehicles()
    Wait(1000)
    local vehicles = nil
    if Config.Framework == 'esx' then
        vehicles = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE stored = 3")
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        vehicles = MySQL.Sync.fetchAll("SELECT * FROM player_vehicles WHERE state = 3")
    end
    for k, vehicle in pairs(vehicles) do
        if not parkedVehicles[vehicle.plate] then
            local owner = nil
            if vehicle.citizenid ~= nil then
                owner = vehicle.citizenid
            elseif vehicle.identifier ~= nil then
                owner = vehicle.identifier
            end
            local fullname = GetPlayerFullNameFromCitizenid(vehicle.citizenid)
            local coords = json.decode(vehicle.location)
            local mods = json.decode(vehicle.mods)
            parkedVehicles[vehicle.plate] = {
                owner = owner,
                fullname = fullname,
                netid = nil,
                entity = nil,
                mods = mods,
                hash = vehicle.hash,
                plate = vehicle.plate, 
                model = vehicle.vehicle,
                fuel = vehicle.fuel,
                body = vehicle.body,
                engine = vehicle.engine,
                steerangle = tonumber(vehicle.steerangle) + 0.0,
                location = coords,
                blip = false,
                parked = true,
            }
        end
    end  
end

local function SpawnVehicles(src)
    PrepeareVehicles()
    Wait(1000)
    for k, v in pairs(parkedVehicles) do
        if parkedVehicles[v.plate] then
            local coords = parkedVehicles[v.plate].location
            DeleteVehicleAtcoords(vector3(coords.x, coords.y, coords.z))
            local model = parkedVehicles[v.plate].model
            local entity = CreateVehicle(model, coords.x, coords.y, coords.z, coords.h, true, true)
            local zoek = true
            local count = 20
            while zoek do
                if not DoesEntityExist(entity) then 
                    count = count - 1
                elseif DoesEntityExist(entity) then 
                    zoek = false
                end
                if count <= 0 then zoek = false end
                Wait(100)
            end
            local netid = NetworkGetNetworkIdFromEntity(entity)
            SetVehicleNumberPlateText(entity, v.plate)
            parkedVehicles[v.plate].netid = netid
            parkedVehicles[v.plate].entity = entity
        end
    end
    TriggerClientEvent("mh-parking:client:Onjoin", src, {data = parkedVehicles})
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
    if not hasSpawned then
        hasSpawned = true
        SpawnVehicles(src)
        TriggerClientEvent("mh-parking:client:Onjoin", src, {data = parkedVehicles})  
    else
        if parkedVehicles ~= nil and #parkedVehicles >= 1 then
            TriggerClientEvent("mh-parking:client:Onjoin", src, {data = parkedVehicles})             
        end
    end
end)

RegisterNetEvent('mh-parking:server:setVehLockState', function(vehNetId, state)
    SetVehicleDoorsLocked(NetworkGetEntityFromNetworkId(vehNetId), state)
end)

RegisterNetEvent("mh-parking:server:EnteringVehicle", function(netid, seat, plate)
    local src = source
	if seat == -1 then
        local vehicle = NetworkGetEntityFromNetworkId(netid)
        if DoesEntityExist(vehicle) then
            local citizenid = GetCitizenId(src)
            local result = nil
            local owner = nil
            if Config.Framework == 'esx' then
                result = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE owner = ? AND plate = ?", { citizenid, plate})[1]
                if result ~= nil then owner = result.owner end
            elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
                result = MySQL.Sync.fetchAll("SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ?", { citizenid, plate})[1]
                if result ~= nil then owner = result.citizenid end
            end
            if result ~= nil and result.plate == plate and owner ~= nil then
                if owner == citizenid then
                    if Config.Framework == 'esx' then
                        MySQL.Async.execute('UPDATE owned_vehicles SET stored = ?, location = ?, street = ?, steerangle = ? WHERE owner = ? AND plate = ?', { 0, nil, nil, 0, citizenid, plate })
                    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
                        MySQL.Async.execute('UPDATE player_vehicles SET state = ?, location = ?, street = ?, steerangle = ? WHERE citizenid = ? AND plate = ?', { 0, nil, nil, 0, citizenid, plate })
                    end
                    RemoveVehicle(netid)
                    TriggerClientEvent('mh-parking:client:RemoveVehicle', -1, {netid = netid, owner = citizenid, entity = vehicle, plate = plate})
                end
            end
        end
	end
end)

RegisterNetEvent('mh-parking:server:LeftVehicle', function(netid, seat, plate, location, steerangle, street) 
    local src = source
	if seat == -1 then
        local vehicle = NetworkGetEntityFromNetworkId(netid)
        if DoesEntityExist(vehicle) then
            local citizenid = GetCitizenId(src)
            local result = nil
            local owner = nil
            if Config.Framework == 'esx' then
                result = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE owner = ? AND plate = ? AND stored = ?", { citizenid, plate, 0})[1]
                if result ~= nil and result.owner ~= nil then owner = result.owner end
            elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
                result = MySQL.Sync.fetchAll("SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ? AND state = ?", { citizenid, plate, 0})[1]
                if result ~= nil and result.citizenid ~= nil then owner = result.citizenid end
            end
            if result ~= nil and result.plate == plate and owner ~= nil then
                if owner == citizenid then 
                    local canSave = CanSave(src)
                    if canSave then
                        local mods = json.encode(result.mods)
                        local fullname = GetPlayerFullNameFromCitizenid(owner)
                        parkedVehicles[plate] = { 
                            owner = owner,
                            fullname = fullname,
                            netid = netid,
                            entity = vehicle,
                            mods = mods,
                            hash = result.hash,
                            plate = plate, 
                            model = result.vehicle,
                            fuel = result.fuel,
                            body = result.body,
                            engine = result.engine,
                            steerangle = result.steerangle,
                            location = location,
                            blip = false,
                        }
                        local parktime = Config.MaxParkTime
                        local time = os.time()
                        if Config.Framework == 'esx' then
                            MySQL.Async.execute('UPDATE owned_vehicles SET stored = ?, location = ?, steerangle = ?, street = ?, parktime = ?, time = ? WHERE owner = ? AND plate = ?', { 3, json.encode(location), tonumber(steerangle), street, parktime, time, citizenid, plate})
                        elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
                            MySQL.Async.execute('UPDATE player_vehicles SET state = ?, location = ?, steerangle = ?, street = ?, parktime = ?, time = ? WHERE citizenid = ? AND plate = ?', { 3, json.encode(location), tonumber(steerangle), street, parktime, time, citizenid, plate})
                        end    
                        TriggerClientEvent("mh-parking:client:AddVehicle", -1, {status = true, data = parkedVehicles[plate]})
                    else
                        Notify(src, Lang:t('info.limit_parking', {limit=defaultMax}, "error", 5000))
                    end                
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

-- Callbacks
CreateCallback("mh-parking:server:GetParkedVehicles", function(source, cb)
	cb(parkedVehicles)
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

-- Police Impound
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