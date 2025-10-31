-- [[ ===================================================== ]] --
-- [[              MH Park System by MaDHouSe79             ]] --
-- [[ ===================================================== ]] --
local zones = {}
local zonesBlips = {}
local parkedBlips = {}
local parkedVehicles = {}
local isEnteringVehicle = false
local isInVehicle = false
local isAdmin = false
local currentVehicle = nil
local currentSeat = nil
local currentPlate = nil
local inparkzone = false
local parkLabel = nil
local parkCoords = nil
local parkOwner = nil
local parkZoneId = nil
--
local currentTrailer = nil
local isRampDown = false
local isPlatformDown = false
local selectedVehicle = nil
local currentTrailer = nil
local currentBoat = nil
local trailerLoad = {}
--
local IsUsingParkCommand = false
local display3DText = Config.Display3DText
local saveSteeringAngle = Config.SaveSteeringAngle
local useDebugPoly = Config.UseDebugPoly
--
local disableNeedByPumpModels = {
    ['prop_vintage_pump'] = true,
    ['prop_gas_pump_1a'] = true,
    ['prop_gas_pump_1b'] = true,
    ['prop_gas_pump_1c'] = true,
    ['prop_gas_pump_1d'] = true,
    ['prop_gas_pump_old2'] = true,
    ['prop_gas_pump_old3'] = true
}

local function DeleteZones()
    for k, zone in pairs(zones) do
        if zone ~= nil then zone:destroy() end
    end
    zones = {}

    for k, blip in pairs(zonesBlips) do
        if DoesBlipExist(blip) then RemoveBlip(blip) end
    end
    zonesBlips = {}
end

local function RemoveParkBlip(zoneid)
    for k, blip in pairs(zonesBlips) do
        if DoesBlipExist(blip) and blip == Config.PrivedParking[zoneid].blip then
            Config.PrivedParking[zoneid].blip = nil
            RemoveBlip(blip)
            blip = nil
            break
        end
    end
end

local function CreateZoneBlipCircle(coords, text, color, sprite)
    local blip = AddBlipForCoord(coords)
    SetBlipHighDetail(blip, true)
    SetBlipSprite(blip, sprite)
    SetBlipScale(blip, 0.7)
    SetBlipColour(blip, color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandSetBlipName(blip)
    zonesBlips[#parkedBlips + 1] = blip
    return blip
end

local function LoadZone()
    if Config.UsePrivedParking then
        DeleteZones()
        Wait(1000)
        if type(Config.PrivedParking) == 'table' and #Config.PrivedParking >= 1 then
            for i = 1, #Config.PrivedParking, 1 do
                if Config.PrivedParking[i] ~= nil then
                    local data = Config.PrivedParking[i]
                    zones[#zones + 1] = BoxZone:Create(vector3(data.coords.x, data.coords.y, data.coords.z), data.size.length, data.size.width, {
                        name = data.id .. "_parkzone",
                        offset = {0.0, 0.0, 0.0},
                        scale = {data.size.width, data.size.width, data.size.width},
                        heading = data.coords.w,
                        debugPoly = useDebugPoly
                    })
                    Config.PrivedParking[i].blip = CreateZoneBlipCircle(data.coords, "parking Lot", 2, 225)
                end
            end
        end
    end
end

local function AddBoatToTrailer(vehicle, trailer, leave)
    if not IsVehicleAttachedToTrailer(vehicle) and Config.TrailerBoats[GetEntityModel(vehicle)] then
        local rotation = GetEntityRotation(trailer)
        local plate = GetPlate(trailer)
        if Config.ParkTrailersWithLoad then trailerLoad[plate] = {hash = GetEntityModel(vehicle), mods = GetVehicleProperties(vehicle), plate = GetPlate(vehicle)} end
        AttachEntityToEntity(vehicle, trailer, 20, 0.0, -1.05, 0.30, rotation.x, rotation.y, rotation.z, false, false, true, false, 20, true)
        SetEntityCanBeDamaged(vehicle, false)
        if leave == nil then leave = true end
        if leave then TaskLeaveVehicle(PlayerPedId(), vehicle, 1) end
    end
end

local function DeleteVehicleAtcoords(coords)
    local closestVehicle, closestDistance = GetClosestVehicle(coords)
    if closestVehicle ~= -1 and closestDistance <= 2.0 then
        SetEntityAsMissionEntity(closestVehicle, true, true)
        DeleteEntity(closestVehicle)
        while DoesEntityExist(closestVehicle) do
            DeleteEntity(closestVehicle)
            Wait(50)
        end
    end
end

local function GetPedVehicleSeat(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    for i = -2, GetVehicleMaxNumberOfPassengers(vehicle) do
        if (GetPedInVehicleSeat(vehicle, i) == ped) then return i end
    end
    return -2
end

local function DoesPlateExist(plate)
    for i = 1, #parkedVehicles, 1 do
        if parkedVehicles[i].plate == plate then return true end
    end
    return false
end

local function DeleteparkedVehicles()
    for i = 1, #parkedVehicles, 1 do parkedVehicles[i] = nil end
    parkedVehicles = {}
end

local function CreateBlipCircle(coords, text, radius, color, sprite)
    local blip = nil
    if Config.DebugBlipForRadius then
        blip = AddBlipForRadius(coords, radius)
        SetBlipHighDetail(blip, true)
        SetBlipColour(blip, color)
        SetBlipAlpha(blip, 128)
    end
    blip = AddBlipForCoord(coords)
    SetBlipHighDetail(blip, true)
    SetBlipSprite(blip, sprite)
    SetBlipScale(blip, 0.7)
    SetBlipColour(blip, color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandSetBlipName(blip)
    parkedBlips[#parkedBlips + 1] = blip
end

local function DeleteAllBlips()
    for k, blip in pairs(parkedBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
            blip = nil
        end
    end
    parkedBlips = {}
end

local function CreateBlips()
    if Config.UseUnableParkingBlips then
        for k, zone in pairs(Config.NoParkingLocations) do
            CreateBlipCircle(zone.coords, 'Unable to park', zone.radius, zone.color, zone.sprite)
        end
    end
    if Config.UseParkingLotsOnly then
        for k, zone in pairs(Config.AllowedParkingLots) do
            if Config.UseParkingLotsBlips then
                CreateBlipCircle(zone.coords, 'Parking lot', zone.radius, zone.color, zone.sprite)
            end
        end
    end
end

local function BlinkVehiclelights(vehicle)
    local ped = PlayerPedId()
    local model = 'prop_cuff_keys_01'
    LoadAnimDict('anim@mp_player_intmenu@key_fob@')
    LoadModel(model)
    local object = CreateObject(model, 0, 0, 0, true, true, true)
    while not DoesEntityExist(object) do Wait(1) end
    AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, 57005), 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    TaskPlayAnim(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 8.0, -8.0, -1, 52, 0, false, false, false)
    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "lock", 0.2)
    SetVehicleLights(vehicle, 2)
    Wait(150)
    SetVehicleLights(vehicle, 0)
    Wait(150)
    SetVehicleLights(vehicle, 2)
    Wait(150)
    SetVehicleLights(vehicle, 0)
    if IsEntityPlayingAnim(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3) then
        DeleteObject(object)
        StopAnimTask(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 8.0)
    end
end

local function LeaveVehicle(data)
    local vehicle = NetToVeh(data.vehicleNetID)
    if DoesEntityExist(vehicle) then
        TaskLeaveVehicle(PlayerPedId(), vehicle, 1)
    end
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
        if Config.OnlyAutoParkWhenEngineIsOff then
            local engineIsOn = GetIsVehicleEngineRunning(vehicle)
            if not engineIsOn then TriggerServerEvent('mh-parking:server:AllPlayersLeaveVehicle', VehToNet(vehicle), players) end
        else
            TriggerServerEvent('mh-parking:server:AllPlayersLeaveVehicle', VehToNet(vehicle), players)
        end
    end
end

local function CreateParkedBlip(data)
    local name = "unknow"
    local brand = "unknow"
    for k, vehicle in pairs(Config.Vehicles) do
        if vehicle.model == data.model then
            name = vehicle.name
            brand = vehicle.brand
            break
        end
    end
    local blip = AddBlipForCoord(data.location.x, data.location.y, data.location.z)
    SetBlipSprite(blip, 545)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.6)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, 25)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(name .. " " .. brand)
    EndTextCommandSetBlipName(blip)
    return blip
end

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
                    title = Lang:t('info.close'),
                    icon = "fa-solid fa-stop",
                    description = '',
                    arrow = false,
                    onSelect = function()
                    end
                }
                lib.registerContext({id = 'parkMenu', title = "MH Parking V2", icon = "fa-solid fa-warehouse", options = options})
                lib.showContext('parkMenu')
            else
                Notify(Lang:t('info.no_vehicles_parked'), "error", 5000)
            end
        end
    end)
end

local function IsCloseByPrivedParkingLot(coords)
    for k, v in pairs(Config.PrivedParking) do
        if v.citizenid ~= PlayerData.citizenid then
            local distance = GetDistance(coords, v.coords)
            if (distance < v.size.width) or (distance < v.size.length) then return true end
        end
    end
    return false
end

local function IsCloseByStationPump(coords)
    for hash in pairs(disableNeedByPumpModels) do
        local pump = GetClosestObjectOfType(coords.x, coords.y, coords.z, 10.0, hash, false, true, true)
        if pump ~= 0 then return true end
    end
    return false
end

local function IsCloseByCoords(coords)
    for k, v in pairs(Config.NoParkingLocations) do
        if GetDistance(coords, v.coords) < v.radius then
            if v.job == nil then
                return true
            elseif v.job ~= nil and v.job ~= PlayerData.job.name then
                return true
            end
        end
    end
    return false
end

local function IsCloseByParkingLot(coords)
    for k, v in pairs(Config.AllowedParkingLots) do
        if GetDistance(coords, v.coords) < v.radius then return true end
    end
    return false
end

local function AllowToPark(coords)
    local allow = true
    if IsCloseByStationPump(coords) then
        allow = false
    else
        if IsCloseByCoords(coords) then
            allow = false
        else
            if Config.UseParkingLotsOnly then
                if not IsCloseByParkingLot(coords) then
                    if Config.UsePrivedParking then
                        if IsCloseByPrivedParkingLot(coords) then
                            allow = false
                        end
                    else
                        allow = false
                    end
                end
            else
                if Config.UsePrivedParking then
                    if IsCloseByPrivedParkingLot(coords) then
                        allow = false
                    end
                else
                    allow = false
                end
            end
        end
    end
    return allow
end

local function DisPlayVehicle3DText(owner, model, brand, plate, coords)
    local txt = ""
    if Config.DisplayVehicleOwner or Config.DisplayToPolicePlayers then txt = txt .. "Owner: ~y~" .. owner .. "~s~\n" end
    if Config.DisplayVehicleBrand or Config.DisplayToPolicePlayers then txt = txt .. "Brand: ~o~" .. brand .. "~s~\n" end
    if Config.DisplayVehicleModel or Config.DisplayToPolicePlayers then txt = txt .. "Model: ~b~" .. model .. "~s~\n" end
    if Config.DisplayVehiclePlate or Config.DisplayToPolicePlayers then txt = txt .. "Plate: ~g~" .. plate .. "~s~\n" end
    if Config.DisplayToAllPlayers then
        Draw3DText(coords.x, coords.y, coords.z, txt, 0, 0.04, 0.04)
    else
        if Config.DisplayToPolicePlayers then
            if (PlayerData.job.type == 'leo' and PlayerData.job.onduty) and (PlayerData.citizenid ~= owner) then
                Draw3DText(coords.x, coords.y, coords.z, txt, 0, 0.04, 0.04)
            end
        end
        if PlayerData.citizenid == owner then
            Draw3DText(coords.x, coords.y, coords.z, txt, 0, 0.04, 0.04)
        end
    end
end

local function IsVehicleNotParked(plate)
    for i = 1, #parkedVehicles, 1 do
        if parkedVehicles[i] ~= nil and parkedVehicles[i].plate == plate then
            return true
        end
    end
    return false
end

local function RemoveFromTrailer(vehicle)
    if IsEntityAttached(vehicle) then
        DetachEntity(vehicle, true, true)
    end
end

local function LoadTarget()
    if GetResourceState("qb-target") ~= 'missing' then
        for k, v in pairs(Config.TrailerBoats) do
            exports['qb-target']:AddTargetModel(v.model, {
                options = {{
                    type = "client",
                    event = "mh-parking:client:GetInVehicle",
                    icon = "fas fa-car",
                    label = Lang:t('info.get_in_vehicle'),
                    action = function(entity)
                        GetInVehicle(entity)
                    end,
                    canInteract = function(entity, distance, data)
                        if currentTrailer == -1 then return false end
                        return true
                    end
                }, {
                    type = "client",
                    event = "",
                    icon = "fas fa-car",
                    label = "Remove From Trailer",
                    action = function(entity)
                        RemoveFromTrailer(entity)
                    end,
                    canInteract = function(entity, distance, data)
                        if not IsEntityAttached(entity) then return false end
                        if currentTrailer == -1 then return false end
                        return true
                    end
                }},
                distance = 15.0
            })
        end
        for k, v in pairs(Config.Trailers) do
            exports['qb-target']:AddTargetModel(v.model, {
                options = {{
                    type = "client",
                    event = "",
                    icon = "fas fa-car",
                    label = 'Ramp Down',
                    action = function(entity)
                        SetVehicleDoorOpen(entity, 5, false)
                        currentTrailer = entity
                        isRampDown = true
                    end,
                    canInteract = function(entity, distance, data)
                        if isRampDown then return false end
                        return true
                    end
                }, {
                    type = "client",
                    event = "",
                    icon = "fas fa-car",
                    label = 'Ramp Up',
                    action = function(entity)
                        SetVehicleDoorShut(entity, 5, true)
                        currentTrailer = entity
                        isRampDown = false
                    end,
                    canInteract = function(entity, distance, data)
                        if not isRampDown then return false end
                        return true
                    end
                }, {
                    type = "client",
                    event = "mh-parking:client:togglePlatform",
                    icon = "fas fa-car",
                    label = "Platform Up",
                    action = function(entity)
                        isPlatformDown = false
                        currentTrailer = entity
                        SetVehicleDoorShut(entity, 4, false)
                    end,
                    canInteract = function(entity, distance, data)
                        if isRampDown then return false end
                        if not isPlatformDown then return false end
                        return true
                    end
                }, {
                    type = "client",
                    event = "mh-parking:client:togglePlatform",
                    icon = "fas fa-car",
                    label = 'Platform Down',
                    action = function(entity)
                        currentTrailer = entity
                        isPlatformDown = true
                        SetVehicleDoorOpen(entity, 4, false)
                    end,
                    canInteract = function(entity, distance, data)
                        if not isRampDown then return false end
                        if isPlatformDown then return false end
                        return true
                    end
                }},
                distance = 5.0
            })
        end
        for k, v in pairs(Config.Vehicles) do
            exports['qb-target']:AddTargetModel(v.model, {
                options = {{
                    type = "client",
                    event = "",
                    icon = "fas fa-car",
                    label = Lang:t('info.get_in_vehicle'),
                    action = function(entity)
                        GetInVehicle(entity)
                    end,
                    canInteract = function(entity, distance, data)
                        if selectedVehicle == nil then return false end
                        return true
                    end
                }, {
                    type = "client",
                    event = "",
                    icon = "fas fa-car",
                    label = Lang:t('info.select_vehicle'),
                    action = function(entity)
                        selectedVehicle = entity
                    end,
                    canInteract = function(entity, distance, data)
                        if selectedVehicle ~= nil then return false end
                        return true
                    end
                }},
                distance = 15.0
            })
        end
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        PlayerData = {}
        isLoggedIn = false
        DeleteAllBlips()
        DeleteparkedVehicles()
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        LoadZone()
        TriggerCallback('mh-parking:server:IsAdmin', function(result) isAdmin = result.isadmin end)
        TriggerServerEvent('mh-parking:server:OnJoin')
    end
end)

RegisterNetEvent(OnPlayerUnload)
AddEventHandler(OnPlayerUnload, function()
    PlayerData = {}
    isLoggedIn = false
    DeleteZones()
end)

RegisterNetEvent(OnPlayerLoaded)
AddEventHandler(OnPlayerLoaded, function()
    LoadZone()
    TriggerCallback('mh-parking:server:IsAdmin', function(result) isAdmin = result.isadmin end)
    TriggerServerEvent('mh-parking:server:OnJoin')
end)

RegisterNetEvent('mh-parking:client:OpenParkMenu', function(data)
    if data.status then
        GetVehicleMenu()
    end
end)

RegisterNetEvent('mh-parking:client:leaveVehicle', function(data)
    LeaveVehicle(data)
end)

RegisterNetEvent('mh-parking:client:ToggleFreezeVehicle', function(data)
    local vehicle = NetworkGetEntityFromNetworkId(data.netid)
    if DoesEntityExist(vehicle) then
        if data.owner == PlayerData.citizenid then
            FreezeEntityPosition(vehicle, false)
            return
        else
            FreezeEntityPosition(vehicle, true)
            return
        end
    end
end)

RegisterNetEvent('mh-parking:client:AddVehicle', function(result)
    local vehicle = NetworkGetEntityFromNetworkId(result.data.netid)
    if DoesEntityExist(vehicle) then
        SetEntityAsMissionEntity(vehicle, true, true)
        SetFuel(vehicle, result.data.fuel + 0.0)
        SetVehicleSteeringAngle(vehicle, result.data.steerangle + 0.0)
        SetEntityInvincible(result.data.entity, true)
        parkedVehicles[#parkedVehicles + 1] = {
            owner = result.data.owner,
            fullname = result.data.fullname,
            netid = result.data.netid,
            entity = result.data.entity,
            mods = result.data.mods,
            hash = result.data.hash,
            plate = result.data.plate,
            model = result.data.model,
            fuel = result.data.fuel,
            body = result.data.body,
            engine = result.data.engine,
            steerangle = result.data.steerangle,
            location = result.data.location,
            blip = CreateParkedBlip(result.data)
        }
        if PlayerData.citizenid == result.data.owner then
            local last = Config.DebugBlipForRadius
            if last then Config.DebugBlipForRadius = false end
            BlinkVehiclelights(vehicle)
            Config.DebugBlipForRadius = last
        end
    end
end)

RegisterNetEvent('mh-parking:client:RemoveVehicle', function(data)
    local netid = data.netid
    for i = 1, #parkedVehicles, 1 do
        local vehicle = NetworkGetEntityFromNetworkId(netid)
        if DoesEntityExist(vehicle) then
            local plate = GetVehicleNumberPlateText(vehicle)
            if parkedVehicles[i].plate == plate then
                SetEntityInvincible(vehicle, false)
                if PlayerData.citizenid == parkedVehicles[i].owner then BlinkVehiclelights(parkedVehicles[i].entity) end
                if parkedVehicles[i].blip ~= nil then
                    if DoesBlipExist(parkedVehicles[i].blip) then
                        RemoveBlip(parkedVehicles[i].blip)
                        parkedVehicles[i].blip = nil
                    end
                end
                table.remove(parkedVehicles, i)
                break
            end
        end
    end
end)

RegisterNetEvent('mh-parking:client:KeepEngineOnWhenAbandoned', function(netid)
    local vehicle = NetToVeh(netid)
    if DoesEntityExist(vehicle) then
        SetVehRadioStation(vehicle, 'OFF')
        SetVehicleKeepEngineOnWhenAbandoned(vehicle, true)
    end
end)

RegisterNetEvent('mh-parking:client:Onjoin', function(data)
    PlayerData = GetPlayerData()
    isLoggedIn = true
    LoadTarget()
    CreateBlips()
    if data.status == true then
        local vehicles = data.vehicles
        for k, v in pairs(vehicles) do
            while not NetworkDoesEntityExistWithNetworkId(v.netid) do Wait(0) end
            if NetworkDoesEntityExistWithNetworkId(v.netid) then
                NetworkRequestControlOfNetworkId(v.netid)
                local vehicle = NetworkGetEntityFromNetworkId(v.netid)
                if DoesEntityExist(vehicle) then
                    local plate = GetPlate(vehicle)
                    SetEntityAsMissionEntity(vehicle, true, true)
                    SetVehicleProperties(vehicle, v.mods)
                    SetVehicleSteeringAngle(vehicle, v.steerangle + 0.0)
                    DoVehicleDamage(vehicle, v.body, v.engine)
                    SetFuel(vehicle, v.fuel + 0.0)
                    if v.owner == PlayerData.citizenid then SetClientVehicleOwnerKey(plate, vehicle) end
                    local coords = GetEntityCoords(vehicle)
                    local heading = GetEntityHeading(vehicle)
                    SetVehicleKeepEngineOnWhenAbandoned(vehicle, true)
                    if v.trailerdata ~= nil and v.trailerdata ~= false then
                        while not NetworkDoesEntityExistWithNetworkId(v.trailerdata.netid) do Wait(0) end
                        if NetworkDoesEntityExistWithNetworkId(v.trailerdata.netid) then
                            local trailer = NetToVeh(v.trailerdata.netid)
                            if DoesEntityExist(trailer) then
                                SetEntityAsMissionEntity(trailer, true, true)
                                RequestCollisionAtCoord(v.trailerdata.coords.x, v.trailerdata.coords.y, v.trailerdata.coords.z)
                                SetVehicleOnGroundProperly(trailer)
                                SetEntityCoords(trailer, v.trailerdata.coords.x, v.trailerdata.coords.y, coords.z - 1.5, v.trailerdata.heading)
                                SetEntityHeading(trailer, v.trailerdata.heading)
                                SetVehicleDirtLevel(trailer, 0)
                                if Config.ParkTrailersWithLoad then
                                    if v.trailerdata.load ~= nil then
                                        while not NetworkDoesEntityExistWithNetworkId(v.trailerdata.load.netid) do Wait(0) end
                                        if NetworkDoesEntityExistWithNetworkId(v.trailerdata.load.netid) then
                                            local entity_load = NetToVeh(v.trailerdata.load.netid)
                                            if DoesEntityExist(entity_load) then
                                                local boat_plate = GetPlate(entity_load)
                                                if v.owner == PlayerData.citizenid then SetClientVehicleOwnerKey(boat_plate, entity_load) end
                                                SetVehicleProperties(entity_load, v.trailerdata.load.mods)
                                                local rotation = GetEntityRotation(trailer)
                                                if not IsEntityAttached(entity_load) then AddBoatToTrailer(entity_load, trailer, false) end
                                                SetEntityCanBeDamaged(entity_load, false)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            local exist = DoesPlateExist(v.plate)
            if not exist then
                parkedVehicles[#parkedVehicles + 1] = {
                    owner = v.owner,
                    fullname = v.fullname,
                    netid = v.netid,
                    entity = v.entity,
                    mods = v.mods,
                    hash = v.hash,
                    plate = v.plate,
                    model = v.model,
                    brand = v.brand,
                    fuel = v.fuel,
                    body = v.body,
                    engine = v.engine,
                    steerangle = v.steerangle,
                    location = v.location,
                    blip = CreateParkedBlip(v),
                    trailerdata = v.trailerdata
                }
                if Config.UseTarget then
                    if Config.TargetScript == "qb-target" then
                        exports['qb-target']:AddTargetEntity(vehicle, {
                            options = {{
                                name = "car",
                                type = "server",
                                icon = "fas fa-car",
                                label = "Unpark Vehicle",
                                action = function(entity)
                                    TriggerServerEvent('mh-parking:server:EnteringVehicle', VehToNet(entity), -1, GetPlate(entity))
                                end,
                                canInteract = function(entity)
                                    if not IsVehicleNotParked(GetPlate(entity)) then return false end
                                    if v.owner ~= PlayerData.citizenid then return false end
                                    return true
                                end
                            }},
                            distance = 3.0
                        })
                    elseif Config.TargetScript == "ox_target" then
                        exports.ox_target:addLocalEntity(vehicle, {
                            {
                                name = "car",
                                icon = "fas fa-car",
                                label = "Unpark Vehicle",
                                onSelect = function(data)
                                    TriggerServerEvent('mh-parking:server:EnteringVehicle', VehToNet(data.entity), -1, GetPlate(data.entity))
                                end,
                                canInteract = function(entity)
                                    if not IsVehicleNotParked(GetPlate(entity)) then return false end
                                    if v.owner ~= PlayerData.citizenid then return false end
                                    return true
                                end,
                            }
                        })
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('mh-parking:client:unparking', function(vehicle, plate)
    local ped = PlayerPedId()
    currentPlate = GetPlate(vehicle)
    local netid = VehToNet(vehicle)
    TriggerServerEvent('mh-parking:server:EnteringVehicle', netid, -1, currentPlate)
end)

RegisterNetEvent('mh-parking:client:parking', function()

end)

RegisterNetEvent('mh-parking:client:TogglDebugPoly', function(data)
    isAdmin = false
    TriggerCallback('mh-parking:server:IsAdmin', function(result)
        useDebugPoly = not useDebugPoly
        if result.status and result.isadmin then
            isAdmin = true
            local txt = ""
            if useDebugPoly then txt = "enable" else txt = "disable" end
            Notify("Polyzone debug is now " .. txt)
        end
        LoadZone()
    end)
end)

RegisterNetEvent('mh-parking:client:toggleParkText', function()
    display3DText = not display3DText
    local txt = nil
    if display3DText then txt = "enable" else txt = "disable" end
    Notify("Parked vehicle text is now " .. txt, "success", 5000)
end)

RegisterNetEvent('mh-parking:client:toggleSteerAngle', function()
    saveSteeringAngle = not saveSteeringAngle
    local txt = nil
    if saveSteeringAngle then txt = "enable" else txt = "disable" end
    Notify("Steer angle save is now " .. txt, "success", 5000)
end)

RegisterNetEvent('mh-parking:client:reloadZones', function(data)
    if Config.PrivedParking[data.zoneid] then
        RemoveParkBlip(data.zoneid)
        Config.PrivedParking[data.zoneid] = nil
    end
    Config.PrivedParking = data.list
    inparkzone = false
    Wait(100)
    LoadZone()
end)

RegisterNetEvent('mh-parking:client:CreatePark', function(data)
    TriggerCallback('mh-parking:server:IsAdmin', function(result)
        if result.status and result.isadmin then
            if data.id ~= nil and data.name ~= nil and data.label ~= nil then
                local data = {id = data.id, name = data.name, job = data.job, label = data.label, street = GetStreetName(GetEntityCoords(PlayerPedId())), coords = GetEntityCoords(PlayerPedId()), heading = GetEntityHeading(PlayerPedId())}
                useDebugPoly = true
                TriggerServerEvent('mh-parking:server:CreatePark', data)
            end
        end
    end)
end)

CreateThread(function()
    while true do
        Wait(math.random(5000, 10000))
        if isLoggedIn then
            local vehicle = GetVehiclePedIsUsing(PlayerPedId())
            if vehicle ~= nil or vehicle ~= -1 then
                if GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
                    local data = {netid = VehToNet(vehicle), plate = GetPlate(vehicle), location = GetEntityCoords(vehicle), heading = GetEntityHeading(vehicle)}
                    TriggerServerEvent('mh-parking:server:LastDriveLocation', data)
                end
            end
        end
    end
end)

-- Create Zone info
CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn and Config.UsePrivedParking then
            for k, zone in pairs(zones) do
                zone:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside, point)
                    local id = string.sub(zone.name, 1, 1)
                    if Config.PrivedParking[tonumber(id)] then
                        local data = Config.PrivedParking[tonumber(id)]
                        if isPointInside then
                            if Config.UsePrivedParking and not inparkzone then
                                inparkzone = true
                                parkZoneId = string.sub(zone.name, 1, 1)
                                parkOwner = data.citizenid
                                parkCoords = data.coords
                                local adminTxt = ""
                                if isAdmin then
                                    adminTxt = "~w~Zone ID: ~o~" .. parkZoneId .. "\n~w~Filename: ~o~" .. data.name .. "~w~\n"
                                end
                                local street = "~w~Street: ~b~" .. data.street .. "\n"
                                parkLabel = adminTxt .. street .. "Owned by: ~g~" .. data.label .. "~w~\n"
                            end
                        else
                            if Config.UsePrivedParking and inparkzone then
                                inparkzone = false
                                parkZoneId = nil
                                parkOwner = nil
                                parkCoords = nil
                                parkLabel = nil
                            end
                        end
                    end
                end)
            end
        end
        Wait(sleep)
    end
end)

-- Draw Zone info
CreateThread(function()
    while true do
        local sleep = 100
        if isLoggedIn and Config.UsePrivedParking then
            if inparkzone and parkZoneId ~= nil then
                sleep = 0
                Draw3DText(parkCoords.x, parkCoords.y, parkCoords.z, parkLabel, 0, 0.04, 0.04)
            end
        end
        Wait(sleep)
    end
end)

-- Draw Park 3D Text info
CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn and display3DText and not isInVehicle then
            local playerCoords = GetEntityCoords(GetPlayerPed(-1))
            local txt1, txt2 = "", ""
            for i = 1, #parkedVehicles, 1 do
                if parkedVehicles[i] ~= nil then
                    if NetworkDoesEntityExistWithNetworkId(parkedVehicles[i].netid) then
                        local vehicle = NetToVeh(parkedVehicles[i].netid)
                        if DoesEntityExist(vehicle) then
                            local entityCoords = GetEntityCoords(vehicle)
                            local distance = GetDistance(playerCoords, entityCoords)
                            if distance < Config.DisplayDistance then
                                local owner, plate, model, brand = parkedVehicles[i].fullname, parkedVehicles[i].plate, nil, nil
                                for k, vehicle in pairs(Config.Vehicles) do
                                    if vehicle.model == parkedVehicles[i].model then
                                        model, brand = vehicle.name, vehicle.brand
                                        break
                                    end
                                end
                                if model ~= nil and brand ~= nil then
                                    sleep = 0
                                    DisPlayVehicle3DText(owner, model, brand, plate, entityCoords)
                                end
                                if parkedVehicles[i].trailerdata ~= nil and parkedVehicles[i].trailerdata ~= false then
                                    local trailer_entity = NetToVeh(parkedVehicles[i].trailerdata.netid)
                                    if DoesEntityExist(trailer_entity) then
                                        local data = parkedVehicles[i].trailerdata
                                        if data.model ~= nil and data.brand ~= nil then
                                            local trailer_coords = parkedVehicles[i].trailerdata.coords
                                            local trailer_plate = parkedVehicles[i].trailerdata.plate
                                            sleep = 0
                                            DisPlayVehicle3DText(owner, data.model, data.brand, trailer_plate, trailer_coords)
                                        end
                                    end
                                end
                            elseif distance > Config.DisplayDistance then
                                sleep = 1000
                            end
                        end
                    end  
                end
            end
        end
        Wait(sleep)
    end
end)

-- Set Steering Angle to save when parking the vehicle.
CreateThread(function()
    local angle, speed = 0.0, 0.0
    while true do
        Wait(0)
        if isLoggedIn and saveSteeringAngle then
            local veh = GetVehiclePedIsUsing(PlayerPedId())
            if DoesEntityExist(veh) then
                local tangle = GetVehicleSteeringAngle(veh)
                if tangle > 10.0 or tangle < -10.0 then angle = tangle end
                speed = GetEntitySpeed(veh)
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                if speed < 0.1 and DoesEntityExist(vehicle) and not GetIsTaskActive(PlayerPedId(), 151) and
                    not GetIsVehicleEngineRunning(vehicle) then
                    SetVehicleSteeringAngle(vehicle, angle)
                end
            end
        end
    end
end)

-- Park logic
CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn then
            local ped = PlayerPedId()
            if Config.UseAutoPark then
                sleep = 100
                if not isInVehicle and not IsPlayerDead(PlayerId()) then
                    if DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not isEnteringVehicle then
                        currentVehicle = GetVehiclePedIsTryingToEnter(ped)
                        currentSeat = GetSeatPedIsTryingToEnter(ped)
                        isEnteringVehicle = true
                        currentPlate = GetPlate(currentVehicle)
                        local netid = VehToNet(currentVehicle)
                        if currentVehicle ~= selectedVehicle and currentVehicle ~= currentBoat then
                            TriggerServerEvent('mh-parking:server:EnteringVehicle', netid, currentSeat)
                        end
                    elseif not DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not IsPedInAnyVehicle(ped, true) and
                        isEnteringVehicle then
                        isEnteringVehicle = false
                    elseif IsPedInAnyVehicle(ped, false) then
                        isEnteringVehicle = false
                        isInVehicle = true
                        currentVehicle = GetVehiclePedIsUsing(ped)
                        currentSeat = GetPedVehicleSeat(ped)
                        currentPlate = GetPlate(currentVehicle)
                        local netid = VehToNet(currentVehicle)
                        TriggerServerEvent('mh-parking:server:EnteredVehicle', netid, currentSeat)
                    end
                elseif isInVehicle and not IsPlayerDead(PlayerId()) then
                    if not IsPedInAnyVehicle(ped, false) then
                        local vehicle = GetVehiclePedIsIn(ped, true)
                        if vehicle ~= selectedVehicle and vehicle ~= currentBoat then
                            local plate = GetPlate(vehicle)
                            local netid = VehToNet(vehicle)
                            local steerangle = GetVehicleSteeringAngle(vehicle) + 0.0
                            local coords = GetEntityCoords(vehicle)
                            local heading = GetEntityHeading(vehicle)
                            local street = GetStreetName(coords)
                            local fuel = GetFuel(vehicle)
                            local location = {x = coords.x, y = coords.y, z = coords.z, h = heading}
                            local canSave = true
                            local allowToPark = AllowToPark(coords)
                            if allowToPark then
                                if Config.OnlyAutoParkWhenEngineIsOff then
                                    local engineIsOn = GetIsVehicleEngineRunning(vehicle)
                                    if engineIsOn then canSave = false end
                                end
                            else
                                canSave = false
                            end
                            if canSave then
                                local trailerdata = nil
                                if Config.ParkWithTrailers then
                                    local hasTrailer, trailer = GetVehicleTrailerVehicle(vehicle)
                                    if hasTrailer then
                                        local tplate = GetPlate(trailer)
                                        if not Config.ParkTrailersWithLoad then trailerLoad[tplate] = nil end
                                        trailerdata = {
                                            model = Config.Trailers[GetEntityModel(trailer)].model,
                                            brand = Config.Trailers[GetEntityModel(trailer)].brand,
                                            hash = GetEntityModel(trailer),
                                            coords = GetEntityCoords(trailer),
                                            heading = GetEntityHeading(trailer),
                                            mods = GetVehicleProperties(trailer),
                                            load = trailerLoad[tplate]
                                        }
                                        trailerLoad[tplate] = nil
                                    end
                                    FreezeEntityPosition(trailer, true)
                                end
                                AllPlayersLeaveVehicle(vehicle)
                                Citizen.Wait(2500)
                                TriggerServerEvent('mh-parking:server:LeftVehicle', netid, currentSeat, plate, location, steerangle, street, fuel, trailerdata)
                                SetVehicleEngineOn(vehicle, false, false, true)
                            end
                        end
                        isEnteringVehicle = false
                        isInVehicle = false
                        currentVehicle = 0
                        currentSeat = 0
                        Citizen.Wait(2500)
                        SetVehicleEngineOn(vehicle, false, false, true)
                    elseif not IsPedInAnyVehicle(ped, false) and not IsPlayerDead(PlayerId()) then
                        isEnteringVehicle = false
                        isInVehicle = false
                        currentVehicle = 0
                        currentSeat = 0
                    end
                end
            elseif not Config.UseAutoPark then
                if IsPedInAnyVehicle(ped) then
                    local vehicle = GetVehiclePedIsIn(ped, false)
                    if vehicle ~= 0 then
                        local isDriver = (GetPedInVehicleSeat(vehicle, -1) == ped)
                        if isDriver then
                            sleep = 0
                            local storedVehicle = GetPlayerInParkedVehicle(vehicle)
                            if storedVehicle ~= false then
                                DisplayHelpText(Lang:t("info.press_drive_car", {key = Config.KeyBindButton}))
                                if IsControlJustReleased(0, Config.ParkButton) then
                                    IsUsingParkCommand = true
                                end
                            end
                            if IsUsingParkCommand then
                                IsUsingParkCommand = false
                                if storedVehicle ~= false then
                                    SetPedIntoVehicle(ped, vehicle, -1)
                                    TriggerServerEvent('mh-parking:server:EnteringVehicle', storedVehicle.netid, -1, storedVehicle.plate)
                                    storedVehicle = nil
                                    sleep = 2000
                                else
                                    local vehicle = GetVehiclePedIsIn(ped, false)
                                    local speed = GetEntitySpeed(vehicle)
                                    if speed > 0.1 then
                                        Notify(Lang:t("info.stop_car"), "primary", 5000)
                                    else
                                        local hasAccess = isVehicleAllowedToPark(vehicle)
                                        if hasAccess then
                                            local canSave = true
                                            local coords = GetEntityCoords(vehicle)
                                            if AllowToPark(coords) then
                                                if Config.OnlyAutoParkWhenEngineIsOff then
                                                    local engineIsOn = GetIsVehicleEngineRunning(vehicle)
                                                    if engineIsOn then canSave = false end
                                                end
                                            else
                                                canSave = false
                                            end
                                            if canSave then
                                                AllPlayersLeaveVehicle(vehicle)
                                                TaskLeaveVehicle(ped, vehicle, 0)
                                                Wait(2000)
                                                local netid = VehToNet(vehicle)
                                                local seat = GetPedVehicleSeat(ped)
                                                local plate = GetPlate(vehicle)
                                                local heading = GetEntityHeading(vehicle)
                                                local location = {x = coords.x, y = coords.y, z = coords.z, h = heading}
                                                local steerangle = GetVehicleSteeringAngle(vehicle) + 0.0
                                                local street = GetStreetName(vehicle)
                                                local fuel = GetFuel(vehicle)
                                                TriggerServerEvent('mh-parking:server:LeftVehicle', netid, -1, plate, location, steerangle, street, fuel)
                                                isInVehicle = false
                                                currentVehicle = 0
                                                currentSeat = 0
                                                sleep = 2000
                                            end
                                        else
                                            Notify(Lang:t("info.only_cars_allowd"), "primary", 5000)
                                        end
                                    end
                                end
                            end
                        end
                    end
                else
                    IsUsingParkCommand = false
                end
            end
        end
        Wait(sleep)
    end
end)

-- Disable Parked Vehicles Collision
CreateThread(function()
    while true do
        Wait(0)
        if isLoggedIn and Config.DisableParkedVehiclesCollision then
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            if vehicle ~= nil and vehicle ~= 0 then
                for k, v in pairs(parkedVehicles) do
                    local distance = GetDistance(GetEntityCoords(PlayerPedId()), v.location)
                    if distance < 10 then
                        SetEntityNoCollisionEntity(v.entity, vehicle, true)
                        SetEntityNoCollisionEntity(vehicle, v.entity, true)
                    end
                end
            end
        end
    end
end)

-- Add boat on a boat trailer
CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn and selectedVehicle ~= nil then
            local hasTrailer, trailer = GetVehicleTrailerVehicle(selectedVehicle)
            if hasTrailer then
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                if vehicle ~= -1 and trailer ~= vehicle and trailer ~= selectedVehicle then
                    sleep = 0
                    if IsEntityTouchingEntity(vehicle, trailer) then
                        DisplayHelpText(Lang:t('info.press_to_attach'))
                    end
                    if GetEntityModel(trailer) == 524108981 then -- baot trailer
                        if IsControlJustPressed(0, 38) then
                            selectedVehicle = nil
                            isEnteringVehicle = false
                            isInVehicle = false
                            currentVehicle = 0
                            currentSeat = 0
                            AddBoatToTrailer(vehicle, trailer, true)
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)
