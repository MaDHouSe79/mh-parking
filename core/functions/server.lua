function Trim(value)
    if not value then return nil end
    return (string.gsub(value, '^%s*(.-)%s*$', '%1'))
end

function Round(value, numDecimalPlaces)
    if not numDecimalPlaces then return math.floor(value + 0.5) end
    local power = 10 ^ numDecimalPlaces
    return math.floor((value * power) + 0.5) / (power)
end

function SafeNetId(entity)
    if not entity or not DoesEntityExist(entity) then return nil end
    local netId = NetworkGetNetworkIdFromEntity(entity)
    return (netId > 0 and netId < 65535) and netId or nil
end

function Notify(src, msg, type)
    TriggerClientEvent('mh-parking:notify', src, msg, type)
end

function GetPlate(vehicle)
    if vehicle == 0 then return end
    return Trim(GetVehicleNumberPlateText(vehicle))
end

function GetDistance(pos1, pos2)
    if pos1 ~= nil and pos2 ~= nil then
        return #(vector3(pos1.x, pos1.y, pos1.z) - vector3(pos2.x, pos2.y, pos2.z))
    end
end

function GetClosestVehicle(coords)
    local vehicles = GetGamePool('CVehicle')
    local closestDistance = -1
    local closestVehicle = -1
    for i = 1, #vehicles do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = #(vehicleCoords - coords)
        if closestDistance == -1 or closestDistance > distance then
            closestVehicle = vehicles[i]
            closestDistance = distance
        end
    end
    return closestVehicle, closestDistance
end

function DeleteVehicleAtcoords(coords)
    local closestVehicle, closestDistance = GetClosestVehicle(coords)
    if closestVehicle ~= -1 and closestDistance <= 2.0 then
        DeleteEntity(closestVehicle)
        while DoesEntityExist(closestVehicle) do
            DeleteEntity(closestVehicle)
            Wait(0)
        end
    end
end

local function GetVehicleByPlate(plate)
    if not plate or plate == "" then return nil end
    plate = string.upper(tostring(plate)):gsub("%s+", "")
    local vehicles = GetAllVehicles()
    for _, veh in ipairs(vehicles) do
        if DoesEntityExist(veh) then
            local vehPlate = GetPlate(veh)
            vehPlate = string.upper(tostring(vehPlate)):gsub("%s+", "")
            if vehPlate == plate then return veh end
        end
    end
    return nil
end

function GiveKeys(src, plate)
    src = tonumber(src)
    if not src or not plate then return false end
    plate = string.upper(tostring(plate)):gsub("%s+", "")
    local realVehicle = GetVehicleByPlate(plate)
    if realVehicle ~= nil then
        if GetResourceState('qbx_vehiclekeys') == 'started' then 
            local sessionId = Entity(realVehicle).state.sessionId or exports.qbx_core:CreateSessionId(realVehicle)
            local keys = Player(src).state.keysList or {}
            keys[sessionId] = true
            Entity(realVehicle).state.owner = GetIdentifier(src)
            Player(src).state:set('keysList', keys, true)
            return true
        elseif GetResourceState('qs-vehiclekeys') == 'started' then 
            exports['qs-vehiclekeys']:GiveKeys(plate, GetDisplayNameFromVehicleModel(GetEntityModel(realVehicle)), true)
            return true
        end
    else
        if GetResourceState('qb-vehiclekeys') == 'started' then 
            local Player = GetPlayer(src)
            local keys = Player.PlayerData.metadata["vehicleKeys"] or {}
            keys[plate] = true
            Player.Functions.SetMetaData("vehicleKeys", keys)
            return true 
        elseif GetResourceState('esx_vehiclekeys') == 'started' then 
            TriggerEvent('esx_vehiclekeys:server:giveKey', plate, src)
            return true 
        elseif GetResourceState('qb-keys') == 'started' then 
            exports['qb-keys']:GiveKey(src, plate)
            return true 
        elseif GetResourceState('Renewed-Vehiclekeys') == 'started' then 
            exports['Renewed-Vehiclekeys']:addKey(plate)
            return true 
        elseif GetResourceState('vehicles_keys') == 'started' then 
            exports["vehicles_keys"]:giveVehicleKeysToPlayerId(src, plate, "owned")
            return true 
        elseif GetResourceState('wasabi_carlock') == 'started' then 
            exports.wasabi_carlock:GiveKey(src, plate)
            return true 
        end
    end
    return false
end

function PoliceImpound(plate, fullImpound, price, body, engine, fuel)
    TriggerEvent("police:server:Impound", plate, fullImpound, price, body, engine, fuel)
    -- if you have your own police script than add your impound trigger here.
end
