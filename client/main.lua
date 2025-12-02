-- ═══════════════════════════════════════════════════════════ --
--          MH-PARKING – 100% Statebag by MaDHouSe79           --
-- ═══════════════════════════════════════════════════════════ --
local config = nil
local isLoggedIn = false
local parkedCache = {}
local blipCache = {}
local wasInVehicle = false
local currentVehicle = nil

local function SetVehicleWaypoit(coords)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = GetDistance(playerCoords, coords)
    if distance < 200 then
        Notify(Lang:t('info.no_waipoint', {distance = Round(distance, 2)}), "error", 5000)
    elseif distance > 200 then
        SetNewWaypoint(coords.x, coords.y)
    end
end

local function GetVehicleMenu()
    TriggerCallback("mh-parking:server:GetVehicles", function(result)
        if result.status then
            if result.data ~= nil then
                local num = 0
                local options = {}
                for k, v in pairs(result.data) do
                    if v.state == 3 then
                        num = num + 1
                        local coords = json.decode(v.location)
                        options[#options + 1] = {
                            id = num,
                            title = FirstToUpper(v.vehicle) .. " " .. v.plate .. " is parked",
                            icon = "nui://mh-parking/core/images/" .. v.vehicle .. ".png",
                            description = Lang:t('info.street', {street = v.street}) .. '\n' .. Lang:t('info.fuel', {fuel = v.fuel}) .. '\n' .. Lang:t('info.engine', {engine = v.engine}) .. '\n' .. Lang:t('info.body', {body = v.body}) .. '\n' .. Lang:t('info.click_to_set_waypoint'),
                            arrow = false,
                            onSelect = function()
                                SetVehicleWaypoit(coords)
                            end
                        }
                    end
                end
                num = num + 1
                options[#options + 1] = {
                    id = num,
                    title = 'close',
                    icon = "fa-solid fa-stop",
                    description = '',
                    arrow = false,
                    onSelect = function()
                    end
                }
                lib.registerContext({id = 'parkMenu', title = "MH Parking Pro", icon = "fa-solid fa-warehouse", options = options})
                lib.showContext('parkMenu')
            else
                Notify(Lang:t('info.no_vehicles_parked'), "error", 5000)
            end
        end
    end)
end

local function OpenInfoMenu(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then return end
    if config.Vehicles[GetEntityModel(vehicle)] then
        local model       = config.Vehicles[GetEntityModel(vehicle)].model
        local body        = math.floor(GetVehicleBodyHealth(vehicle))
        local engine      = math.floor(GetVehicleEngineHealth(vehicle))
        local tank        = math.floor(GetVehicleFuelLevel(vehicle))
        local oil         = math.floor(GetVehicleOilLevel(vehicle))
        local temp        = math.floor(GetVehicleEngineTemperature(vehicle))
        local plate       = GetPlate(vehicle)
        local modelHash   = GetEntityModel(vehicle)
        local displayName = GetDisplayNameFromVehicleModel(modelHash)
        local class       = GetVehicleClass(vehicle)
        local className   = GetLabelText("VEH_CLASS_"..class)
        local bodyColor   = body > 700 and 'green' or body > 400 and 'yellow' or 'red'
        local engineColor = engine > 700 and 'green' or engine > 400 and 'yellow' or 'red'
        local tankColor   = tank > 50 and 'green' or tank > 20 and 'yellow' or 'red'
        local tmpIcon     = temp > 90 and 'temperature-high' or 'temperature-half'
        local oilIcon     = oil > 5 and 'blue' or 'orange'
        local bodyIcon    = body > 700 and 'shield' or body > 400 and 'shield-halved' or 'shield-crack'
        local engineIcon  = engine > 700 and 'engine' or engine > 400 and 'engine-warning' or 'fire-flame-curved'
        local tankIcon    = tank > 50 and 'gas-pump' or tank > 20 and 'fill-drip' or 'fill'
        local tmpEngineIcon = temp > 95 and 'red' or temp > 80 and 'orange' or 'blue'
        local options = {}
        options[#options + 1] = {
            title = displayName:upper(),
            description = className .. ' • ' .. plate,
            icon = 'car',
            iconColor = '#ff4444',
            metadata = {
                {label = '💸 Price', value = config.Vehicles[modelHash].price and ('$%s'):format(config.Vehicles[modelHash].price:reverse():gsub('(...)', '%1.'):reverse()) or 'Unknown'},
                {label = '⚡ Class', value = className},
            }
        }
        local state = Entity(vehicle).state
        local owner = GetIdentifier()
        if owner == state.citizenid then
            options[#options + 1] = {title = Lang:t("vehicle.body_damage"),   description = body..'/1000',   progress = body/10,   icon = bodyIcon,   colorScheme = bodyColor}
            options[#options + 1] = {title = Lang:t("vehicle.engine_damage"), description = engine..'/1000', progress = engine/10, icon = engineIcon, colorScheme = engineColor}
            options[#options + 1] = {title = Lang:t("vehicle.fuel_level"),    description = tank..'%',       progress = tank,      icon = tankIcon,   colorScheme = tankColor}
            options[#options + 1] = {title = Lang:t("vehicle.oil_level"),     description = oil.."fL",       progress = oil,       icon = 'oil-can',  colorScheme = oilIcon}
            options[#options + 1] = {title = Lang:t("vehicle.engine_temp"),   description = temp..'°C',                            icon = tmpIcon,    colorScheme = tmpEngineIcon}            
        end
        lib.registerContext({id = 'mh_parkinfo_epic', title = "🚗 "..Lang:t("vehicle.info"), menu = 'mh_parkinfo_epic', canClose = true, options = options})
        lib.showContext('mh_parkinfo_epic')
    end
end

local function DeleteParkedBlip(plate)
    if DoesBlipExist(parkedCache[plate].blip) then 
        RemoveBlip(parkedCache[plate].blip) 
    end
end

local function DeleteParkedBlips()
    for k, blip in pairs(blipCache) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
            blip = nil
        end
    end
    blipCache = {}
end

local function CreateParkedBlip(entity, data)
    if not config.Vehicles[data.hash] then return nil end
    local model = config.Vehicles[data.hash].model or "unknow"
    local brand = config.Vehicles[data.hash].brand or "unknow"
    local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
    SetBlipSprite(blip, 545)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.6)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, 25)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Lang:t('blip.label', {model = model, plate = data.plate}))
    EndTextCommandSetBlipName(blip)
    return blip
end

local function SyncParked(netId, isParked, pos, mods, steerangle)
    while config == nil do Wait(10) end
    while not NetworkDoesNetworkIdExist(netId) do Wait(10) end
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or not DoesEntityExist(vehicle) then return end
    local plate = GetVehicleNumberPlateText(vehicle):gsub("^%s*(.-)%s*$", "%1"):upper()
    if mods ~= nil or mods ~= false then SetVehicleProperties(vehicle, mods) end
    SetVehicleKeepEngineOnWhenAbandoned(vehicle, true)
    SetNetworkIdCanMigrate(netId, false)
    SetNetworkIdExistsOnAllMachines(netId, true)
    local state = Entity(vehicle).state
    if netId >= 1 then
        if isParked then
            if not parkedCache[plate] then
                parkedCache[plate] = {vehicle = vehicle, pos = pos, plate = plate}
                if steerangle == nil or steerangle == false then steerangle = 0.0 end
                SetVehicleSteeringAngle(vehicle, steerangle + 0.0) 
                if GetIdentifier() == state.citizenid then
                    local data = {hash = GetEntityModel(vehicle), plate = plate, coords = pos}
                    parkedCache[plate].blip = CreateParkedBlip(vehicle, data)
                end
                SetVehicleEngineOn(vehicle, false, false, true)
                state.steerangle = steerangle
                state.isParked = true
                state.parkedPos = pos
                if state.isClamped == true then
                    local model = GetHashKey(config.ClampProp)
                    local clamp = CreateObject(model, 0.0, 0.0, 0.0, true, false, false)
                    while not DoesEntityExist(clamp) do Wait(0) end
                    local netId = ObjToNet(clamp)
                    SetNetworkIdCanMigrate(netId, false)
                    SetNetworkIdExistsOnAllMachines(netId, true)
                    state.clamp_netid = netId
                    parkedCache[plate].clamp_netid = netId
                    AttachEntityToEntity(clamp, vehicle, GetEntityBoneIndexByName(vehicle, 'wheel_lf'), config.ClampOffset.x, config.ClampOffset.y, config.ClampOffset.z, config.ClampOffset.rx, config.ClampOffset.ry, config.ClampOffset.rz, false, false, false, false, 0, true)
                    SetEntityAsMissionEntity(clamp, true, true)
                end
            end
        else
            if state.isClamped then return end
            state.steerangle = 0
            state.isParked = false
            state.parkedPos = nil
            DeleteParkedBlip(plate)
            parkedCache[plate] = nil
        end
        return
    else
        return
    end
end

local function LeaveVehicle(data)
    while not NetworkDoesNetworkIdExist(data.vehicleNetID) do Wait(10) end
    local vehicle = SafeNetId(data.vehicleNetID)
    if DoesEntityExist(vehicle) then TaskLeaveVehicle(PlayerPedId(), vehicle, 1) end
end

local function GetAllPlayersInVehicle(vehicle)
    local pedsincar = {}
    local numPas = GetVehicleModelNumberOfSeats(GetEntityModel(vehicle))
    for i = -1, numPas, 1 do
        if not IsVehicleSeatFree(vehicle, i) then
            local ped = GetPedInVehicleSeat(vehicle, i)
            if IsPedAPlayer(ped) then
                pedsincar[#pedsincar + 1] = {playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped)), seat = i}
            end
        end
    end
    return pedsincar
end

local function AllPlayersLeaveVehicle(vehicle)
    if DoesEntityExist(vehicle) then
        local players = GetAllPlayersInVehicle(vehicle)
        if config.OnlyAutoParkWhenEngineIsOff then
            local engineIsOn = GetIsVehicleEngineRunning(vehicle)
            if not engineIsOn then TriggerServerEvent('mh-parking:server:AllPlayersLeaveVehicle', SafeNetId(vehicle), players) end
        else
            TriggerServerEvent('mh-parking:server:AllPlayersLeaveVehicle', SafeNetId(vehicle), players)
        end
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    isLoggedIn = false
    DeleteParkedBlips()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    TriggerServerEvent('mh-parking:onjoin')
end)

RegisterNetEvent(OnPlayerUnload)
AddEventHandler(OnPlayerUnload, function()
    isLoggedIn = false
    DeleteParkedBlips()
end)

RegisterNetEvent(OnPlayerLoaded)
AddEventHandler(OnPlayerLoaded, function()
    TriggerServerEvent('mh-parking:onjoin')
end)

RegisterNetEvent('mh-parking:client:leaveVehicle', function(data)
    LeaveVehicle(data)
end)

RegisterNetEvent('mh-parking:openparkmenu', function()
    GetVehicleMenu()
end)

RegisterNetEvent('mh-parking:syncParked', function(netId, isParked, pos, mods, steerangle)
    while config == nil do Wait(10) end
    while not NetworkDoesNetworkIdExist(netId) do Wait(10) end
    SyncParked(netId, isParked, pos, mods, steerangle)
end)

RegisterNetEvent('mh-parking:syncWheelClamp', function(netId)
    while not NetworkDoesNetworkIdExist(netId) do Wait(0) end
    local vehicle = NetToVeh(netId)
    if DoesEntityExist(vehicle) then
        local plate = GetPlate(vehicle)
        if parkedCache[plate] then
            local state = Entity(vehicle).state
            if state.isClamped == true then
                local model = GetHashKey(config.ClampProp)
                local clamp = CreateObject(model, 0.0, 0.0, 0.0, true, false, false)
                while not DoesEntityExist(clamp) do Wait(0) end
                local netId = ObjToNet(clamp)
                SetNetworkIdCanMigrate(netId, false)
                SetNetworkIdExistsOnAllMachines(netId, true)
                parkedCache[plate].clamp_netid = netId
                AttachEntityToEntity(clamp, vehicle, GetEntityBoneIndexByName(vehicle, 'wheel_lf'), config.ClampOffset.x, config.ClampOffset.y, config.ClampOffset.z, config.ClampOffset.rx, config.ClampOffset.ry, config.ClampOffset.rz, false, false, false, false, 0, true)
                SetEntityAsMissionEntity(clamp, true, true)
                FreezeEntityPosition(vehicle, true)
                SetVehicleUndriveable(vehicle, true)  
            elseif state.isClamped == false then
                if parkedCache[plate].clamp_netid ~= nil then
                    while not NetworkDoesNetworkIdExist(parkedCache[plate].clamp_netid) do Wait(0) end
                    local clamp = NetToObj(parkedCache[plate].clamp_netid)
                    if DoesEntityExist(clamp) then DeleteObject(clamp); DeleteEntity(clamp) end
                    FreezeEntityPosition(vehicle, false)
                    SetVehicleUndriveable(vehicle, false)
                end
            end
        end
    end
end)

RegisterNetEvent('mh-parking:onjoin', function(data)
    if data and data.status == true then
        config = data.config
        isLoggedIn = true
    end
end)

RegisterNetEvent('mh-parking:infomenu', function()
    local closestVehicle, closestDistance = GetClosestVehicle(GetEntityCoords(PlayerPedId()))
    if closestVehicle ~= -1 and closestDistance ~= -1 and closestDistance < 3.0 then OpenInfoMenu(closestVehicle) end
end)

AddEventHandler('entityCreated', function(entity)
    if not DoesEntityExist(entity) then return end
    local entityType = GetEntityType(entity)
    if entityType == 2 then SetVehicleKeepEngineOnWhenAbandoned(entity, true) end
end)

CreateThread(function()
    local angle, speed = 0.0, 0.0
    while true do
        while config == nil do Wait(10) end
        local sleep = 1000
        if isLoggedIn and config.UseSteerAnlgeParking then
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)
            if DoesEntityExist(veh) and GetPedInVehicleSeat(veh, -1) == ped then
                local tangle = GetVehicleSteeringAngle(veh)
                if math.abs(tangle) > 10.0 then angle = tangle end
                speed = GetEntitySpeed(veh)
                if speed < 0.5 and not GetIsVehicleEngineRunning(veh) then
                    sleep = 0
                    SetVehicleSteeringAngle(veh, angle)
                else
                    sleep = 250
                end
            else
                sleep = 500
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        Wait(500)
        while config == nil do Wait(1000) end
        if isLoggedIn then
            local ped = PlayerPedId()
            local inVeh = IsPedInAnyVehicle(ped, false)
            local veh = inVeh and GetVehiclePedIsIn(ped, false) or nil
            if inVeh and not wasInVehicle and veh and GetPedInVehicleSeat(veh, -1) == ped then
                currentVehicle = veh
                wasInVehicle   = true
                local plate = GetVehicleNumberPlateText(veh):gsub("^%s*(.-)%s*$", "%1"):upper()
                if parkedCache[plate] then
                    local state = Entity(veh).state
                    if state.isClamped then return Notify("You can't unpart, you have a wheel clamp...", "error") end
                    local netId = -1
                    CreateThread(function()
                        repeat
                            Wait(100)
                            netId = SafeNetId(veh)
                        until netId and netId > 0 and netId < 65535 and NetworkDoesNetworkIdExist(netId)
                        if netId ~= -1 then
                            SetNetworkIdExistsOnAllMachines(netId, true)
                            TriggerServerEvent('mh-parking:autoUnpark', netId) 
                        end
                    end)
                end
            elseif not inVeh and wasInVehicle and currentVehicle then
                local speed = GetEntitySpeed(currentVehicle) / 3.6
                if speed == 0.0 then
                    CreateThread(function()
                        local waited = 0
                        local maxWait = 3000
                        repeat
                            Wait(100)
                            waited = waited + 100
                            if DoesEntityExist(currentVehicle) then
                                local netId = SafeNetId(currentVehicle)
                                if netId and netId > 0 and netId < 65535 and NetworkDoesNetworkIdExist(netId) then
                                    SetNetworkIdExistsOnAllMachines(netId, true)
                                    local canSave = true
                                    if config.onlyAutoParkWhenEngineIsOff and GetIsVehicleEngineRunning(currentVehicle) then canSave = false end
                                    local steerangle = GetVehicleSteeringAngle(currentVehicle) 
                                    local street = GetStreetName(GetEntityCoords(ped))
                                    local fuel = GetVehicleFuelLevel(currentVehicle)
                                    local engine = GetVehicleEngineHealth(veh)
                                    local body = GetVehicleBodyHealth(veh)
                                    local mods = GetVehicleProperties(currentVehicle)
                                    local blinklichts = currentVehicle
                                    if canSave then
                                        currentVehicle = nil
                                        wasInVehicle = false
                                        AllPlayersLeaveVehicle(blinklichts)
                                        Citizen.Wait(2500)
                                        BlinkVehiclelights(blinklichts) 
                                        SetVehicleEngineOn(blinklichts, false, false, false)                                    
                                        TriggerServerEvent('mh-parking:autoPark', netId, steerangle, street, mods, fuel, body, engine) 
                                        blinklichts = nil
                                    elseif not canSave then
                                        currentVehicle = nil
                                        wasInVehicle = false
                                        Wait(5000)
                                        SetVehicleEngineOn(blinklichts, false, false, false)   
                                    end
                                    break
                                end
                            end
                        until waited >= maxWait or not DoesEntityExist(currentVehicle)
                    end)
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(5000)
        while config == nil do Wait(1000) end
        if isLoggedIn then
            local pedCoords = GetEntityCoords(PlayerPedId())
            local vehicles = GetGamePool('CVehicle')
            for _, vehicle in ipairs(vehicles) do
                if DoesEntityExist(vehicle) then
                    local dist = #(GetEntityCoords(vehicle) - pedCoords)
                    if dist < (config.distance or 500.0) then
                        local plate = GetVehicleNumberPlateText(vehicle):gsub("^%s*(.-)%s*$", "%1"):upper()
                        local state = Entity(vehicle).state
                        if state.isParked and state.parkedPos then
                            if not parkedCache[plate] then
                                parkedCache[plate] = {vehicle = vehicle, pos = state.parkedPos}
                                SetVehicleEngineOn(vehicle, false, false, true)
                                SetVehicleUndriveable(vehicle, true)
                                SetEntityInvincible(vehicle, true)
                                SetVehicleDoorsLocked(vehicle, 2)
                            end
                        elseif not state.isParked then
                            if state.isClamped then return end
                            if parkedCache[plate] then 
                                DeleteParkedBlip(plate)
                                parkedCache[plate] = nil 
                            end
                            SetVehicleUndriveable(vehicle, false)
                            SetEntityInvincible(vehicle, false)
                        end
                    end
                end
            end
            -- clear
            for plate, data in pairs(parkedCache) do
                if not DoesEntityExist(data.vehicle) then
                    DeleteParkedBlip(plate)
                    parkedCache[plate] = nil
                end
            end
        end
    end
end)    