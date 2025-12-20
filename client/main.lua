-- ═══════════════════════════════════════════════════════════ --
--          MH-PARKING – 100% Statebag by MaDHouSe79           --
-- ═══════════════════════════════════════════════════════════ --
local config = nil
local isLoggedIn = false
local parkedCache = {}
local blipCache = {}
local wasInVehicle = false
local currentVehicle = nil

local function LoadThemeFromINI() return Config.Themes[Config.DefaultTheme] end

local function SetVehicleWaypoit(coords)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = GetDistance(playerCoords, coords)
    if distance < 200 then
        Notify(Lang:t('info.no_waipoint', {distance = Round(distance, 2)}), "error", 5000)
    elseif distance > 200 then
        SetNewWaypoint(coords.x, coords.y)
    end
end

local function OpenParkingMenu()
    TriggerCallback("mh-parking:server:GetVehicles", function(result)
        if result.status then
            local theme = LoadThemeFromINI()
            local options = {}
            local identifier  = GetIdentifier()
            local isOwner = false
            for _, v in pairs(result.data) do
                isOwner = v.citizenid ~= nil and identifier == v.citizenid and true or false
                table.insert(options, {
                    owner = v.citizenid,
                    vehicle = v.vehicle,
                    plate = v.plate,
                    street = v.street,
                    fuel = v.fuel,
                    engine = math.floor(v.engine),
                    body = math.floor(v.body),
                    class = config.Vehicles[GetHashKey(v.vehicle)].class,
                    coords = json.decode(v.location),
                    parktime = v.parktime,
                    overtime = v.overtime,
                })
            end
            SetNuiFocus(true, true)
            SendNUIMessage({action = "open", type = "parked", vehicles = options, hour = GetClockHours(), theme = theme, isOwner = isOwner})
        end
    end)
end
function convertTime(time)
    local days = math.floor(time / 86400)
    local hours = math.floor(math.fmod(time, 86400) / 3600)
    local minutes = math.floor(math.fmod(time, 3600) / 60)
    local seconds = math.floor(math.fmod(time, 60))
    return days, hours, minutes, seconds
end 

local function OpenInfoMenu(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then return end
    if config.Vehicles[GetEntityModel(vehicle)] then
        local identifier  = GetIdentifier()
        local state = Entity(vehicle).state
        local isParked = state.isParked
        local identifier  = GetIdentifier()
        local isOwner = state.citizenid ~= nil and GetIdentifier() == state.citizenid and true or false
        local isClamped = state.isClamped
        local data = {
            model = config.Vehicles[GetEntityModel(vehicle)].model,
            body = math.floor(GetVehicleBodyHealth(vehicle)),
            engine = math.floor(GetVehicleEngineHealth(vehicle)),
            fuel = math.floor(GetVehicleFuelLevel(vehicle)),
            oil = math.floor(GetVehicleOilLevel(vehicle)),
            temp = math.floor(GetVehicleEngineTemperature(vehicle)),
            plate = GetPlate(vehicle),
            displayName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)),
            class = GetLabelText("VEH_CLASS_"..GetVehicleClass(vehicle)),
        }
        local isPolice = IsPolice()
        TriggerCallback("mh-parking:server:GetVehicleParkTime", function(result)
            local time = 0
            local parktime = 0
            local currentTime = 0
            if result.status then
                parktime = result.parktime
                time = result.time
                currentTime = result.currentTime
            end
            local isOverTime = false
            local overtime = currentTime - time

            if overtime < currentTime then
                print("Binnen de parkeer tijd")
            else
                isOverTime = true
                print("Buiten de parkeer tijd")
            end
            

            local overtime_days, overtime_hours, overtime_min, overtime_sec = convertTime(overtime) 
            local parktime_days, parktime_hours, parktime_min, parktime_sec = convertTime(parktime)

            local parkTime = parktime_hours..":"..parktime_min..":"..parktime_sec
            local overTime = overtime_hours..":"..overtime_min..":"..overtime_sec

            local theme = LoadThemeFromINI()
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = "open", 
                type = "info", 
                vehicle = data, 
                hour = GetClockHours(), 
                theme = theme, 
                isPolice = isPolice, 
                isClamped = isClamped, 
                isOwner = isOwner, 
                isParked = isParked,
                isOverTime = isOverTime,
                parktime = parkTime,
                overtime = overTime,
            })
        end, data.plate)

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
    if (netId > 0 and netId < 65535) then
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

RegisterKeyMapping(Config.Command, "Open PlayerBaord NUI", 'keyboard', Config.Keybind)
RegisterCommand(Config.Command, function() OpenParkingMenu() end)
RegisterCommand(Config.ResetHudCommand, function() SendNUIMessage({action = "resetHudPos"}) end)
RegisterNetEvent('mh-parking:openparkmenu', function() OpenParkingMenu() end)

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

RegisterNetEvent('mh-parking:infomenu', function(vehicle)
    OpenInfoMenu(vehicle)
end)

RegisterNetEvent('mh-parking:notify', function(msg, type)
    Notify(msg, type)
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
                                    local engine = GetVehicleEngineHealth(currentVehicle)
                                    local body = GetVehicleBodyHealth(currentVehicle)
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

RegisterNUICallback("park", function(data, cb)
    local vehicle, distance = GetClosestVehicle(GetEntityCoords(PlayerPedId()))
    if vehicle ~= -1 and distance ~= -1 then
        local netid = SafeNetId(vehicle)
        local steerangle = GetVehicleSteeringAngle(vehicle) 
        local street = GetStreetName(GetEntityCoords(PlayerPedId()))
        local fuel = GetVehicleFuelLevel(vehicle)
        local engine = GetVehicleEngineHealth(vehicle)
        local body = GetVehicleBodyHealth(vehicle)
        local mods = GetVehicleProperties(vehicle)
        BlinkVehiclelights(vehicle) 
        SetVehicleEngineOn(vehicle, false, false, false)                                    
        TriggerServerEvent('mh-parking:autoPark', netid, steerangle, street, mods, fuel, body, engine) 
    end
    cb('ok')
end)

RegisterNUICallback("unpark", function(data, cb)
    local vehicle, distance = GetClosestVehicle(GetEntityCoords(PlayerPedId()))
    if vehicle ~= -1 and distance ~= -1 then
        if DoesEntityExist(vehicle) then
            local netid = SafeNetId(vehicle)
            SetNetworkIdExistsOnAllMachines(netid, true)
            BlinkVehiclelights(vehicle)
            TriggerServerEvent('mh-parking:autoUnpark', netid)
        end
    end
    cb('ok')
end)

RegisterNUICallback("giveKeys", function(data, cb)
    TriggerServerEvent('mh-parking:givekey', data.plate)
    cb('ok')
end)

RegisterNUICallback("impoundVehicle", function(data, cb)
    local isPolice = IsPolice()
    if isPolice then
        local vehicle, distance = GetClosestVehicle(GetEntityCoords(PlayerPedId()))
        if vehicle ~= -1 and distance ~= -1 and distance < 3.5 then
            local plate = GetPlate(vehicle)
            TriggerServerEvent('mh-parking:impound', plate)
            SetEntityAsMissionEntity(vehicle, true, true)
            DeleteEntity(vehicle)
            lib.notify({title = "Impound", description = "Voertuig " .. plate .. " in beslag genomen", type = "success"})
        end
    else
        print("No no, you are not a police dumpass...")
    end
    cb('ok')
end)

RegisterNUICallback("setWheelClamp", function(data, cb)
    local isPolice = IsPolice()
    if isPolice then
        local vehicle, distance = GetClosestVehicle(GetEntityCoords(PlayerPedId()))
        if vehicle ~= -1 and distance ~= -1 and distance < 3.5 then
            local netid = SafeNetId(vehicle)
            if data.action == "add" then
                TriggerServerEvent("mh-parking:server:toggleClamp", SafeNetId(vehicle), true)
            elseif data.action == "remove" then
                TriggerServerEvent("mh-parking:server:toggleClamp", SafeNetId(vehicle), false)
            end
        end
    else
        print("No no, you are not a police dumpass...")
    end
    cb('ok')
end)

RegisterNUICallback('setWaypoint', function(data, cb)
    SetVehicleWaypoit(data.coords)
    cb('ok')
end)

RegisterNUICallback("close", function(_, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

-- open menu nui
RegisterNUICallback("saveHudPos", function(data, cb) 
    SetResourceKvp("mh_parking_hud_pos", json.encode({x = data.x, y = data.y})); cb("ok") 
end)

CreateThread(function()
    Wait(500)
    local saved = GetResourceKvpString("mh_parking_hud_pos")
    if saved then
        local pos = json.decode(saved)
        SendNUIMessage({action = "setHudPos", x = pos.x, y = pos.y})
    end
end)