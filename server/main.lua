-- ═══════════════════════════════════════════════════════════ --
--          MH-PARKING – 100% Statebag by MaDHouSe79           --
-- ═══════════════════════════════════════════════════════════ --
local parkedVehicles = {}
local hasSpawned = false

local function GiveKeysIfOwnerOnline(plate)
    if not plate then return end
    plate = plate:gsub("^%s*(.-)%s*$", "%1"):upper()
    local ownerCitizenId = nil
    local result = Database.GetVehicleData(plate)
    if not result then return end
    ownerCitizenId = result.citizenid or result.owner
    if not ownerCitizenId then return end
    local players = GetPlayers()
    for _, srcStr in pairs(players) do
        local src = tonumber(srcStr)
        local Player = nil
        if GetResourceState('qb-core') == 'started' or GetResourceState('qbx_core') == 'started' then
            Player = exports['qb-core']:GetPlayer(src) or exports.qbx_core.GetPlayer(src)
        elseif GetResourceState('es_extended') == 'started' then
            Player = exports['es_extended']:getSharedObject().GetPlayerFromId(src)
        end
        if Player then
            local playerId = Player.PlayerData.citizenid or Player.identifier or Player.PlayerData.identifier
            if playerId == ownerCitizenId then GiveKeys(src, plate, false) end
        end
    end
end

local function GetVehicleType(hash)
    local vehType = "automobile"
    if SV_Config.Vehicles[hash] and SV_Config.Vehicles[hash].type then vehType = SV_Config.Vehicles[hash].type end
    return vehType
end

local function RemoveVehicle(netid)
    if (netid > 0 and netid < 65535) then
        for plate, vehicle in pairs(parkedVehicles) do
            if vehicle.netid ~= nil and vehicle.netid == netid then
                local state = Entity(vehicle.entity).state
                state.isParked = false
                state.citizenid = nil
                state.plate = nil
                state.isClamped = nil
                state.steerangle = nil
                state.parkedPos = nil                
                TriggerClientEvent('mh-parking:syncParked', -1, vehicle.netid, false, nil, false)
                parkedVehicles[plate] = nil
                break
            end
        end
    end
end

local function SpawnVehicles(src)
    if hasSpawned then return end
    if src == nil then src = -1 end
    hasSpawned = true
    parkedVehicles = {}
    local vehicles = Database.GetVehicles()
    if #vehicles >= 1 then
        for _, vehicle in pairs(vehicles) do
            if vehicle.plate and parkedVehicles[vehicle.plate] == nil then
                local location = json.decode(vehicle.location)
                local mods = json.decode(vehicle.mods)
                DeleteVehicleAtcoords(vector3(location.x, location.y, location.z))
                Wait(100)
                local hash = GetHashKey(vehicle.vehicle)
                local vehType = GetVehicleType(hash)
                local entity = CreateVehicleServerSetter(hash, vehType, location.x, location.y, location.z + 0.07, location.h)
                while not DoesEntityExist(entity) do Wait(0) end
                local netid = SafeNetId(entity)
                local state = Entity(entity).state
                state.isParked = true
                state.citizenid = vehicle.citizenid
                state.plate = vehicle.plate
                state.isClamped = vehicle.isClamped == 1 and true or false
                state.steerangle = tonumber(vehicle.steerangle)
                state.parkedPos = {x = location.x, y = location.y, z = location.z, h = location.h}
                parkedVehicles[vehicle.plate] = {entity = entity, netid = netid}
                TriggerClientEvent('mh-parking:syncParked', src, tonumber(netid), true, location, mods, tonumber(vehicle.steerangle))
                GiveKeysIfOwnerOnline(vehicle.plate)
            end
        end
    end
end

local function CanSave(src)
    local defaultMax = SV_Config.DefaultMaxParking
    local totalParked = Database.GetPlayerVehicles(src)
    if SV_Config.UseAsVip then defaultMax = Database.GetMaxParking(src) end
    if type(totalParked) == 'table' and #totalParked >= defaultMax then return false end
    return true
end

CreateCallback("mh-parking:server:GetVehicles", function(source, cb)
    local src = source
    local citizenid = GetIdentifier(src)
    local result = Database.GetPlayerVehicles(src)
    local state = result.state or result.stored
    result.state = state
    cb({status = true, data = result})
end)

RegisterNetEvent('mh-parking:onjoin', function()
    local src = source
    local players = GetPlayers()
    if #players == 1 then if not hasSpawned then SpawnVehicles() end end
    Wait(500)
    local citizenid = GetIdentifier(src)
    local vehicles = Database.GetVehiclesForCitizenid(citizenid)
    if #vehicles >= 1 then for _, vehicle in pairs(vehicles) do  GiveKeysIfOwnerOnline(vehicle.plate) end end
    Wait(1000)
    TriggerClientEvent('mh-parking:onjoin', src, {status = true, config = SV_Config})
end)

RegisterNetEvent('mh-parking:autoUnpark', function(netId)
    local src = source
    if not netId or netId <= 0 then return end
    local veh = NetworkGetEntityFromNetworkId(netId)
    if not veh or not DoesEntityExist(veh) or not NetworkGetEntityOwner(veh) then return end
    local plate = GetVehicleNumberPlateText(veh):gsub("^%s*(.-)%s*$", "%1"):upper()
    local isOwner = Database.IsVehicleOwned(src, plate)
    if isOwner then
        local state = Entity(veh).state
        if state.isClamped == true then return end
        if state.isParked then
            Database.UnparkVehicle(plate)
            state.isParked = false
            state.parkedPos = nil
            local data = Database.GetVehicleData(plate)
            if data ~= nil and data.mods ~= nil then
                local mods = json.decode(data.mods)
                TriggerClientEvent('mh-parking:syncParked', -1, netId, false, nil, mods)
                lib.notify(src, { type = 'success', description = Lang:t('vehicle.unparked') })
            end
        end
    else
        lib.notify(src, { type = 'error', description = Lang:t('info.not_the_owner')})
    end
end)

RegisterNetEvent('mh-parking:autoPark', function(netId, steerangle, street, mods, fuel, body, engine)
    local src = source    
    if not netId or netId <= 0 then return end
    local veh = NetworkGetEntityFromNetworkId(netId)
    if not veh or not DoesEntityExist(veh) or not NetworkGetEntityOwner(veh) then return end
    local plate = GetVehicleNumberPlateText(veh):gsub("^%s*(.-)%s*$", "%1"):upper()
    if Database.IsVehicleOwned(src, plate) then
        if Database.IsPlayerAVip(src) then
            local canSave = CanSave(src)
            if canSave then
                local coords = GetEntityCoords(veh)
                local heading = GetEntityHeading(veh)
                local state = Entity(veh).state
                if not state.isParked then
                    Database.ParkVehicle(plate, {x=coords.x, y=coords.y, z=coords.z, h=heading}, steerangle, street, mods, fuel, body, engine)
                    state.isParked = true
                    state.parkedPos = {x=coords.x, y=coords.y, z=coords.z, h=heading}
                    state.steerangle = tonumber(steerangle)
                    local data = Database.GetVehicleData(plate)
                    if data ~= nil and data.mods ~= nil then
                        local mods = json.decode(data.mods)
                        TriggerClientEvent('mh-parking:syncParked', -1, netId, true, state.parkedPos, mods)
                        lib.notify(src, { type = 'success', description = Lang:t('vehicle.parked') })
                    end
                end
            end
        else
            lib.notify(src, { type = 'error', description = Lang:t('info.not_a_vip')})
        end
    else
        lib.notify(src, { type = 'error', description = Lang:t('info.not_the_owner')})
    end
end)

RegisterNetEvent('mh-parking:server:AllPlayersLeaveVehicle', function(vehicleNetID, players)
    if players ~= nil and #players >= 1 then
        local vehicle = NetworkGetEntityFromNetworkId(vehicleNetID)
        if DoesEntityExist(vehicle) then
            for i = 1, #players, 1 do
                TriggerClientEvent('mh-parking:client:leaveVehicle', players[i].playerId, {vehicleNetID = vehicleNetID, playerId = players[i].playerId})
            end
        end
    end
end)

RegisterNetEvent('mh-parking:server:toggleClamp', function(netid, state)
    local src = source
    if IsPolice(src) or IsAdmin(src) then
        local veh = NetworkGetEntityFromNetworkId(netid)
        if DoesEntityExist(veh) then
            if Entity(veh).state then
                local txt = nil
                if state then
                    Entity(veh).state.isClamped = true
                    lib.notify(src, { type = 'success', description = Lang:t('info.wheel_clamp_added', {fine = SV_Config.ClampFine})})
                else
                    Entity(veh).state.isClamped = false 
                    lib.notify(src, { type = 'success', description = Lang:t('info.wheel_clamp_deleted')})
                end
                Wait(100)
                TriggerClientEvent('mh-parking:syncWheelClamp', -1, netid)
            end
        end
    end
end)

RegisterNetEvent('mh-parking:impound', function(plate)
    local src = source
    if parkedVehicles[plate] and parkedVehicles[plate].netid ~= false and parkedVehicles[plate].entity ~= false then
        RemoveVehicle(parkedVehicles[plate].netid)
        Database.ImpoundVehicle(plate, SV_Config.ImpoundPrice)
        lib.notify(src, { type = 'success', description = "Vehicle Impounded"})
    end  
end)

RegisterNetEvent('police:server:Impound', function(plate, fullImpound, price, body, engine, fuel)
    local src = source
    if IsPolice(src) or IsAdmin(src) then
        if parkedVehicles[plate] and parkedVehicles[plate].netid ~= false and parkedVehicles[plate].entity ~= false then
            RemoveVehicle(parkedVehicles[plate].netid)
            Database.ImpoundVehicle(plate, price)
        end
    end
end)

local function ParkingTimeCheckLoop()
    if SV_Config.UseTimerPark then
        local result = Database.GetVehicles()
        if result ~= nil then
            for k, v in pairs(result) do
                local total = os.time() - v.time
                if v.parktime > 0 and total > v.parktime then
                    print("[MH Parking] - [Time Parking Limit Detection] - Vehicle with plate: ^2" .. v.plate .. "^7 has been auto impound by the police.")
                    local cost = (math.floor(((os.time() - v.time) / SV_Config.PayTimeInSecs) * SV_Config.ParkPrice))
                    if parkedVehicles[v.plate] and parkedVehicles[v.plate].netid ~= false and parkedVehicles[v.plate].entity ~= false then
                        RemoveVehicle(parkedVehicles[v.plate].netid)
                    end
                    PoliceImpound(v.plate, true, cost, v.body, v.engine, v.fuel)
                end
            end
        end
    end
    SetTimeout(10000, ParkingTimeCheckLoop)
end

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    Wait(5000)
    ParkingTimeCheckLoop()
end)