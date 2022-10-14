--[[ ===================================================== ]]--
--[[      QBCore Realistic Parking Script by MaDHouSe      ]]--
--[[ ===================================================== ]]--

local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData, LocalVehicles, GlobalVehicles = {}, {}, {}
local UpdateAvailable, SpawnedVehicles, isUsingParkCommand, IsDeleting = false, false, false, false
local InParking, CreateMode, LastUsedPlate, ParkOwnerName, VehicleEntity = false, false, nil, nil, nil
local ParkAction, extraRadius, Cost, ParkTime = 'none', 3, 0, 0


local function CreateParkDisPlay(vehicleData)
    local info, model, owner, plate = nil
    if Config.UseOwnerNames then owner = string.format(Lang:t("info.owner", {owner = vehicleData.citizenname}))..'\n' end
    model = string.format(Lang:t("info.model", {model = vehicleData.modelname}))..'\n'
    plate = string.format(Lang:t("info.plate", {plate = vehicleData.plate}))..'\n'
    if Config.UseOwnerNames then info  = string.format("%s", model..plate..owner) else info  = string.format("%s", model..plate) end    
    return info
end

-- Do Vehicle damage
local function doCarDamage(vehicle, health)
	local engine = health.engine + 0.0
	local body = health.body + 0.0
    if body < 900.0 then
		SmashVehicleWindow(vehicle, 0)
		SmashVehicleWindow(vehicle, 1)
		SmashVehicleWindow(vehicle, 2)
		SmashVehicleWindow(vehicle, 3)
		SmashVehicleWindow(vehicle, 4)
		SmashVehicleWindow(vehicle, 5)
		SmashVehicleWindow(vehicle, 6)
		SmashVehicleWindow(vehicle, 7)
	end
	if body < 800.0 then
		SetVehicleDoorBroken(vehicle, 0, true)
		SetVehicleDoorBroken(vehicle, 1, true)
		SetVehicleDoorBroken(vehicle, 2, true)
		SetVehicleDoorBroken(vehicle, 3, true)
		SetVehicleDoorBroken(vehicle, 4, true)
		SetVehicleDoorBroken(vehicle, 5, true)
		SetVehicleDoorBroken(vehicle, 6, true)
	end
	if engine < 700.0 then
		SetVehicleTyreBurst(vehicle, 1, false, 990.0)
		SetVehicleTyreBurst(vehicle, 2, false, 990.0)
		SetVehicleTyreBurst(vehicle, 3, false, 990.0)
		SetVehicleTyreBurst(vehicle, 4, false, 990.0)
	end
	if engine < 500.0 then
		SetVehicleTyreBurst(vehicle, 0, false, 990.0)
		SetVehicleTyreBurst(vehicle, 5, false, 990.0)
		SetVehicleTyreBurst(vehicle, 6, false, 990.0)
		SetVehicleTyreBurst(vehicle, 7, false, 990.0)
	end
    SetVehicleEngineHealth(vehicle, engine)
    SetVehicleBodyHealth(vehicle, body)
end

-- Create parked vehicle blips
local function CreateParkedBlip(label, location)
    local blip = nil
    if Config.UseParkingBlips then
        blip = AddBlipForCoord(location.x, location.y, location.z)
        SetBlipSprite(blip, 545)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.6)
        SetBlipAsShortRange(blip, true)
        SetBlipColour(blip, 25)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(label)
        EndTextCommandSetBlipName(blip)
    end
    return blip
end

-- Set No Collission between 2 entities
local function NoColission(entity, location)
    local vehicle, distance = QBCore.Functions.GetClosestVehicle(vector3(location.x, location.y, location.z))
    if distance <= 1 then
        SetEntityNoCollisionEntity(entity, vehicle, true)
    end
end

-- Set fuel
local function SetFuel(vehicle, fuel)
	if type(fuel) == 'number' and fuel >= 0 and fuel <= 100 then
		SetVehicleFuelLevel(vehicle, fuel + 0.0)
		DecorSetFloat(vehicle, "_FUEL_LEVEL", GetVehicleFuelLevel(vehicle))
	end
end


local function PrepareVehicle(entity, vehicleData)
    -- Add Vehicle On Ground Properly
    RequestCollisionAtCoord(vehicleData.vehicle.location.x, vehicleData.vehicle.location.y, vehicleData.vehicle.location.z)
    SetVehicleOnGroundProperly(entity)
    SetEntityAsMissionEntity(entity, true, true)
    SetEntityInvincible(entity, true)
    SetEntityHeading(vehicle, vehicleData.vehicle.location.w)
    SetVehicleLivery(entity, vehicleData.vehicle.livery)
    SetVehicleEngineHealth(entity, vehicleData.vehicle.health.engine)
    SetVehicleBodyHealth(entity, vehicleData.vehicle.health.body)
    SetVehiclePetrolTankHealth(entity, vehicleData.vehicle.health.tank)
    SetVehRadioStation(entity, 'OFF')
    SetVehicleDirtLevel(entity, 0)
    QBCore.Functions.SetVehicleProperties(entity, vehicleData.vehicle.props)
    SetVehicleEngineOn(entity, false, false, true)
    SetModelAsNoLongerNeeded(vehicleData.vehicle.props["model"])
end

-- Load Entity
local function LoadEntity(vehicleData, type)
	QBCore.Functions.LoadModel(vehicleData.vehicle.props["model"])
    VehicleEntity = CreateVehicle(vehicleData.vehicle.props["model"], vehicleData.vehicle.location.x, vehicleData.vehicle.location.y, vehicleData.vehicle.location.z - 0.1, vehicleData.vehicle.location.w, false)
    QBCore.Functions.SetVehicleProperties(VehicleEntity, vehicleData.vehicle.props)
    SetVehicleEngineOn(VehicleEntity, false, false, true)
    SetVehicleDoorsLocked(VehicleEntity, 2)
    PrepareVehicle(VehicleEntity, vehicleData)
end

-- trailer offset position
local function trailerOffset(vehicle)
    local vehicleProps = QBCore.Functions.GetVehicleProperties(vehicle)
    local displaytext  = GetDisplayNameFromVehicleModel(vehicleProps["model"])
    local offset = 0.0
    if Config.Trailers[displaytext] then offset = Config.Trailers[displaytext].offset end
    return offset
end

local function CreateTargetEntityMenu(entity)
    exports['qb-target']:AddTargetEntity(entity, {
        options = {
            {
                type = "client",
                event = "mh-parking:client:unparking",
                icon = "fas fa-car",
                label = "Unpark Vehicle",
            },
            {
                type = "client",
                event = "mh-parking:client:parking",
                icon = "fas fa-car",
                label = "Park Vehicle",
            }
        },
        distance = Config.InteractDistance
    })
end
local function IsVehicleAlreadyListed(plate)
    local isListed = false
    for i = 1, #LocalVehicles do
        if LocalVehicles[i].plate == plate then
            isListed = true
            break
        end
    end
    return isListed
end

-- Spawn 
local function TableInsert(entity, data, warp)
    if not IsVehicleAlreadyListed(data.plate) then
        local tmpBlip = nil
        if data.citizenid == QBCore.Functions.GetPlayerData().citizenid then	
            if Config.UseParkingBlips then
                tmpBlip = CreateParkedBlip(Lang:t('system.parked_blip_info',{modelname = data.modelname}), data.vehicle.location)
            end
            TriggerEvent('mh-parking:client:addkey', data.plate, data.citizenid)
            CreateTargetEntityMenu(entity)
        end
        LocalVehicles[#LocalVehicles+1] = {
            entity      = entity,
            vehicle     = data.mods,
            plate       = data.plate,
            fuel        = data.fuel,
            body        = data.body,
            engine      = data.engine,
            oil         = data.oil, 
            citizenid   = data.citizenid,
            citizenname = data.citizenname,
            livery      = data.vehicle.livery,
            health      = data.vehicle.health,
            model       = data.model,
            modelname   = data.modelname,
            location    = data.vehicle.location,
            blip        = tmpBlip,
            isGrounded  = false
        }
    end
end

-- Draw 3d text on screen
local function Draw3DText(x, y, z, textInput, fontId, scaleX, scaleY)
    local p     = GetGameplayCamCoords()
    local dist  = #(p - vector3(x, y, z))
    local scale = (1 / dist) * 20
    local fov   = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    SetTextScale(scaleX * scale, scaleY * scale)
    SetTextFont(fontId)
    SetTextProportional(1)
    SetTextColour(250, 250, 250, 255)
    SetTextDropshadow(1, 1, 1, 1, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(textInput)
    SetDrawOrigin(x, y, z + 2, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

--Display Parked Owner Text
local function DisplayParkedOwnerText()
    if Config.UseParkedVehicleNames then -- for performes
		local pl = GetEntityCoords(PlayerPedId())
		local displayWhoOwnesThisCar = nil
		for k, vehicle in pairs(LocalVehicles) do
			if #(pl - vector3(vehicle.location.x, vehicle.location.y, vehicle.location.z)) < Config.ParkedNamesViewDistance then
                displayWhoOwnesThisCar = CreateParkDisPlay(vehicle)
                Draw3DText(vehicle.location.x, vehicle.location.y, vehicle.location.z + 0.2, displayWhoOwnesThisCar, 0, 0.04, 0.04)
			end
		end
    end
end

-- Get the stored vehicle player is in
local function GetPlayerInStoredCar(player)
    local entity = GetVehiclePedIsIn(player)
    local findVehicle = false
    for i = 1, #LocalVehicles do
        if LocalVehicles[i].entity and LocalVehicles[i].entity == entity then
            findVehicle = LocalVehicles[i]
            break
        end
    end
    return findVehicle
end

-- Get the stored vehicle player is in
local function GetParkeddCar(vehicle)
    local findVehicle = false
    for i = 1, #LocalVehicles do
        if LocalVehicles[i].entity and LocalVehicles[i].entity == vehicle then
            findVehicle = LocalVehicles[i]
            break
        end
    end
    return findVehicle
end

-- Delete single vehicle
local function DeleteLocalVehicle(vehicle)
    IsDeleting = true
    if type(LocalVehicles) == 'table' and #LocalVehicles > 0 and LocalVehicles[1] then
		for i = 1, #LocalVehicles do
            if type(vehicle.plate) ~= 'nil' and type(LocalVehicles[i]) ~= 'nil' and type(LocalVehicles[i].plate) ~= 'nil' then
				if vehicle.plate == LocalVehicles[i].plate then
					DeleteEntity(LocalVehicles[i].entity)
                    table.remove(LocalVehicles, i)
				end
			end
		end
    end
    IsDeleting = false
end

local function UnparkVehicle(plate)
    IsDeleting = true
    if type(LocalVehicles) == 'table' and #LocalVehicles > 0 and LocalVehicles[1] then
		for i = 1, #LocalVehicles do
            if type(LocalVehicles[i].plate) ~= 'nil' then
				if plate == LocalVehicles[i].plate then
                    table.remove(LocalVehicles, i)
				end
			end
		end
    end
    IsDeleting = false
end

-- Spawn local vehicles(server data)
local function SpawnVehicles(vehicles)
    CreateThread(function()
		while IsDeleting do Citizen.Wait(100) end
		if type(vehicles) == 'table' and #vehicles > 0 and vehicles[1] then
			for i = 1, #vehicles, 1 do
                SetEntityCollision(vehicles[i].vehicle, false, true)
                SetEntityVisible(vehicles[i].vehicle, false, 0)
                if Config.UseSpawnDelay then Wait(Config.DeleteDelay) end
				DeleteLocalVehicle(vehicles[i].vehicle)
				LoadEntity(vehicles[i], 'server')
				SetVehicleEngineOn(VehicleEntity, false, false, true)
				doCarDamage(VehicleEntity, vehicles[i].vehicle.health)
				TableInsert(VehicleEntity, vehicles[i])
                if Config.UseSpawnDelay then Wait(Config.FreezeDelay) end
				FreezeEntityPosition(VehicleEntity, true)
			end
		end
    end)
end

-- Spawn single vehicle(client data)
local function SpawnVehicle(vehicleData)
    CreateThread(function()
		if LocalPlayer.state.isLoggedIn then
			while IsDeleting do Wait(100) end
            SetEntityCollision(vehicleData.vehicle, false, true)
            SetEntityVisible(vehicleData.vehicle, false, 0)
            if Config.UseSpawnDelay then Wait(Config.DeleteDelay) end
			DeleteLocalVehicle(vehicleData.vehicle)
			LoadEntity(vehicleData, 'client')
			PrepareVehicle(VehicleEntity, vehicleData)
			SetVehicleEngineOn(VehicleEntity, false, false, true)
			doCarDamage(VehicleEntity, vehicleData.vehicle.health)
			TableInsert(VehicleEntity, vehicleData)
            if Config.UseSpawnDelay then Wait(Config.FreezeDelay) end
			FreezeEntityPosition(VehicleEntity, true)
		end
    end)
end

-- remove all Vehicles
local function RemoveVehicles(vehicles)
    IsDeleting = true
    if type(vehicles) == 'table' and #vehicles > 0 and vehicles[1] then
		for i = 1, #vehicles, 1 do
			local vehicle, distance = QBCore.Functions.GetClosestVehicle(vehicles[i].vehicle.location)
			if NetworkGetEntityIsLocal(vehicle) and distance < 1 then
				local driver = GetPedInVehicleSeat(vehicle, -1)
				if not DoesEntityExist(driver) or not IsPedAPlayer(driver) then
					local tmpModel = GetEntityModel(vehicle)
					SetModelAsNoLongerNeeded(tmpModel)
					DeleteEntity(vehicle)
					Citizen.Wait(300)
				end
			end
			vehicle, distance, driver, tmpModel = nil
		end
    end
    LocalVehicles = {}
    IsDeleting = false
end

-- Just some help text
local function DisplayHelpText(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- Delete the vehicle near the location
local function DeleteNearByVehicle(location)
    IsDeleting = true
    local vehicle, distance = QBCore.Functions.GetClosestVehicle(location)
    if distance <= 1 then
        for i = 1, #LocalVehicles do
            if LocalVehicles[i].entity == vehicle then table.remove(LocalVehicles, i) end
            local tmpModel = GetEntityModel(vehicle)
            SetModelAsNoLongerNeeded(tmpModel)
            DeleteEntity(vehicle)
            tmpModel = nil
        end
    end
    IsDeleting = false
end

local function CreateVehicleEntity(vehicle)
    QBCore.Functions.LoadModel(vehicle.props.model)
    return CreateVehicle(vehicle.props.model, vehicle.location.x, vehicle.location.y, vehicle.location.z, vehicle.location.w, true)
end

-- Drive 
-- Make vehicle ready to drive
local function MakeVehicleReadyToDrive(vehicle)
    -- Delete the local entity first
    DeleteNearByVehicle(vector3(vehicle.location.x, vehicle.location.y, vehicle.location.z))
    local VehicleEntity = CreateVehicleEntity(vehicle)
    TaskWarpPedIntoVehicle(PlayerPedId(), VehicleEntity, -1)
    QBCore.Functions.SetVehicleProperties(VehicleEntity, vehicle.props)
    -- Add Vehicle On Ground Properly
    RequestCollisionAtCoord(vehicle.location.x, vehicle.location.y, vehicle.location.z)
    SetVehicleOnGroundProperly(VehicleEntity)
    FreezeEntityPosition(VehicleEntity, false)
    SetVehicleLivery(VehicleEntity, vehicle.livery)
    SetVehRadioStation(VehicleEntity, 'OFF')
    SetVehicleDirtLevel(VehicleEntity, 0)
    SetVehicleFuelLevel(VehicleEntity, vehicle.fuel)
    SetModelAsNoLongerNeeded(vehicle.props.model)
	doCarDamage(VehicleEntity, vehicle.health)
	SetFuel(VehicleEntity, vehicle.fuel)
end

-- Drive 

local function Drive(player, vehicle, warp)
    QBCore.Functions.TriggerCallback("mh-parking:server:drive", function(callback)
        if callback.status then
            QBCore.Functions.DeleteVehicle(vehicle.entity)
            QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(player))
	        if Config.UseParkingBlips then RemoveBlip(vehicle.blip) end
            MakeVehicleReadyToDrive(callback.vehicle)
            vehicle = false
            CreateTargetEntityMenu(callback.entity)
            QBCore.Functions.Notify(callback.message, "success", 5000)
        else
            QBCore.Functions.Notify(callback.message, "error", 5000)
        end
    end, vehicle)
end

-- Park
local function Park(player, vehicle, warp)
    if warp then
        SetVehicleEngineOn(vehicle, false, false, true)
        TaskLeaveVehicle(player, vehicle)
    end
    RequestAnimSet("anim@mp_player_intmenu@key_fob@")
    TaskPlayAnim(player, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49, 0, false, false)
    Wait(2000)
    ClearPedTasks(player)
    SetVehicleLights(vehicle, 2)
    Wait(150)
    SetVehicleLights(vehicle, 0)
    Wait(150)
    SetVehicleLights(vehicle, 2)
    Wait(150)
    SetVehicleLights(vehicle, 0)
    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "lock", 0.2)
end

-- Get the street name where you are at the moment.
local function GetStreetName(entity)
    return GetStreetNameFromHashKey(GetStreetNameAtCoord(GetEntityCoords(entity).x, GetEntityCoords(entity).y, GetEntityCoords(entity).z))
end

-- Get Real Model Name Config.lua to add more
local function GetRealModel(vehicle)
    local vehicleProps = QBCore.Functions.GetVehicleProperties(vehicle)
    local currentModel = GetDisplayNameFromVehicleModel(vehicleProps["model"])
    if Config.Trailers[currentModel] then
        currentModel = Config.Trailers[currentModel].model
    end
    if Config.Vehicles[currentModel] then
        currentModel = Config.Vehicles[currentModel].model
    end
    return currentModel
end

-- Save
local function Save(player, vehicle, warp)
    Park(player, vehicle, warp)
    local props = QBCore.Functions.GetVehicleProperties(vehicle)
    if props then
        local displaytext = GetDisplayNameFromVehicleModel(props.model)
        local carModelName = GetLabelText(displaytext)
        local offset = trailerOffset(vehicle)
        local currenModel = GetRealModel(vehicle)
        QBCore.Functions.TriggerCallback("mh-parking:server:save", function(callback)
            if callback.status then
                QBCore.Functions.DeleteVehicle(vehicle)
                QBCore.Functions.Notify(callback.message, "success", 1000)
            else
                QBCore.Functions.Notify(callback.message, "error", 5000)
            end
        end, {
            props     = props,
            livery    = GetVehicleLivery(vehicle),
            citizenid = QBCore.Functions.GetPlayerData().citizenid,
            plate     = props.plate,
            fuel      = GetVehicleFuelLevel(vehicle),
            body      = GetVehicleBodyHealth(vehicle),
            engine    = GetVehicleEngineHealth(vehicle),
            oil       = GetVehicleOilLevel(vehicle),
            model     = props.model,
            modelname = carModelName,
            cost      = Cost,
            parktime  = ParkTime,
            parking   = GetStreetName(vehicle),
            health    = {engine = GetVehicleEngineHealth(vehicle), body = GetVehicleBodyHealth(vehicle), tank = GetVehiclePetrolTankHealth(vehicle) },
            location  = vector4(GetEntityCoords(vehicle).x, GetEntityCoords(vehicle).y, GetEntityCoords(vehicle).z - offset, GetEntityHeading(vehicle)),
            coords    = vector4(GetEntityCoords(vehicle).x, GetEntityCoords(vehicle).y, GetEntityCoords(vehicle).z - offset, GetEntityHeading(vehicle)),
        }) 
    end
end

local function IsNotReservedPosition(coords)
    local freeSpot = true
    ParkTime = 0
    Cost = 0
    if Config.UseOnlyPreCreatedSpots then freeSpot = false end
    for _, data in pairs(Config.ReservedParkList) do
        if #(coords - data.coords) <= tonumber(data.radius) then
            if Config.IgnoreJobs[PlayerData.job.name] and PlayerData.job.onduty then
                freeSpot = true
                QBCore.Functions.Notify(Lang:t('success.parked'), "success", 5000)
            else
                if data.parktype == 'nopark' then
                    freeSpot = false
                else
                    if data.parktype == 'prived' then
                        if PlayerData.citizenid ~= data.citizenid then
                            freeSpot = false
                            QBCore.Functions.Notify(Lang:t('system.already_reserved'), "error", 5000)
                        else
                            freeSpot = true
                        end
                    end
                    if data.parktype == 'job' then
                        if not Config.IgnoreJobs[PlayerData.job.name] and not PlayerData.job.onduty then
                            freeSpot = false
                            QBCore.Functions.Notify(Lang:t('system.already_reserved'), "error", 5000)
                        else
                            freeSpot = true
                        end
                    end
                    if data.parktype == 'paid' then
                        Cost = data.cost
                        ParkTime = data.parktime
                        freeSpot = true
                    end
                    if data.parktype == 'free' then
                        freeSpot = true
                    end
                    ParkOwnerName = data.name
                end
            end
        end
    end
    if not freeSpot then
        QBCore.Functions.Notify(Lang:t('info.not_allowed_to_park'), "error", 5000)
    end

   return freeSpot
end

local function DrawParkedLocation(coords)
    if Config.UseParkedLocationNames then
        if Config.UseOnlyPreCreatedSpots then
            for _, data in pairs(Config.ReservedParkList) do
                if Config.BuildMode then 
                    extraRadius = tonumber(data.radius) + tonumber(50)
                else
                    extraRadius = tonumber(data.radius) + tonumber(25) 
                end
                if #(coords - data.coords) < tonumber(extraRadius) then
                    if data.marker then
                        local vehicle, distance = QBCore.Functions.GetClosestVehicle(data.coords)
                        local r, g, b = 0, 0, 0
                        if data.parktype == 'paid' then
                            r, g, b = Config.ParkColours['blue'].r, Config.ParkColours['blue'].g, Config.ParkColours['blue'].b
                            if vehicle and distance <= 1 then
                                r, g, b = Config.ParkColours['green'].r, Config.ParkColours['green'].g, Config.ParkColours['green'].b
                            end
                        elseif data.parktype == 'prived' then
                            if PlayerData.citizenid == data.citizenid then
                                r, g, b = Config.ParkColours['green'].r, Config.ParkColours['green'].g, Config.ParkColours['green'].b
                            else
                                r, g, b = Config.ParkColours['red'].r, Config.ParkColours['red'].g, Config.ParkColours['red'].b
                            end
                        elseif data.parktype == 'job' then
                            if Config.IgnoreJobs[PlayerData.job.name] and PlayerData.job.onduty then
                                r, g, b = Config.ParkColours['orange'].r, Config.ParkColours['orange'].g, Config.ParkColours['orange'].b
                            else
                                r, g, b = Config.ParkColours['black'].r, Config.ParkColours['black'].g, Config.ParkColours['black'].b
                            end
                        else
                            if data.parktype == 'free' then
                                r, g, b = Config.ParkColours['white'].r, Config.ParkColours['white'].g, Config.ParkColours['white'].b
                                if vehicle and distance <= 1 then
                                    r, g, b = Config.ParkColours['green'].r, Config.ParkColours['green'].g, Config.ParkColours['green'].b
                                end
                            end
                        end
                        DrawMarker(2, data.markcoords.x, data.markcoords.y, data.markcoords.z + 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15,r, g, b, 222, false, false, false, true, false, false, false)
                        if data.parktype ~= 'free' then
                            if data.parktype ~= 'nopark' and data.parktype ~= 'paid' then
                                Draw3DText(data.markcoords.x, data.markcoords.y, data.markcoords.z - 1.3, "~y~Reserved~s~", 0, 0.04, 0.04)
                            end
                            if PlayerData.citizenid ~= data.citizenid then
                                Draw3DText(data.markcoords.x, data.markcoords.y, data.markcoords.z - 1.4, "~y~".. data.display.."~s~", 0, 0.04, 0.04)
                            else
                                Draw3DText(data.markcoords.x, data.markcoords.y, data.markcoords.z - 1.4, "~b~".. data.display.."~s~", 0, 0.04, 0.04)
                            end
                        else
                            if data.parktype == 'free' then
                                Draw3DText(data.markcoords.x, data.markcoords.y, data.markcoords.z - 1.3, "~y~".. data.display.."~s~", 0, 0.04, 0.04)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Check Distance To Force Vehicle to the Ground
local function CheckDistanceToForceGrounded(distance)
    if type(LocalVehicles) == 'table' and #LocalVehicles > 0 and LocalVehicles[1] then
        for i = 1, #LocalVehicles do
            if type(LocalVehicles[i]) ~= 'nil' and type(LocalVehicles[i].entity) ~= 'nil' then
                local tmp = LocalVehicles[i]
                if DoesEntityExist(LocalVehicles[i].entity) then

                    local offset = trailerOffset(LocalVehicles[i].entity)
                    if GetVehicleWheelSuspensionCompression(LocalVehicles[i].entity) == 0 then
                        SetEntityCoords(tmp.entity, tmp.location.x, tmp.location.y, tmp.location.z - offset)
                        SetVehicleOnGroundProperly(tmp.entity)
                        LocalVehicles[i].isGrounded = true
                    end

                    if #(GetEntityCoords(PlayerPedId()) - vector3(tmp.location.x, tmp.location.y, tmp.location.z)) < 150 then
                        if not tmp.isGrounded then
                            SetEntityCoords(tmp.entity, tmp.location.x, tmp.location.y, tmp.location.z - offset)
                            SetVehicleOnGroundProperly(tmp.entity)
                            LocalVehicles[i].isGrounded = true
                        end
                    else
                        LocalVehicles[i].isGrounded = false
                    end

                    if Config.DebugMode then
                        if not tmp.isGrounded then
                            print("Parking Force Grounded - Plate ("..tmp.plate..") Model ("..tmp.modelname ..") Grounded ("..tostring(LocalVehicles[i].isGrounded)..") ")
                        else
                            print("Parking can\'t force a vehicle to the ground at this moment. (No vehicle neerby)")
                        end
                    end
                end
            end
        end
        Wait(5000)
    end
end

-- Build Mode Create State
local function CreateState()
    if Config.BuildMode then
        local currentVehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
        local markerCoords = GetOffsetFromEntityInWorldCoords(currentVehicle, 0.0, 2.5 , -1.0)
        DrawMarker(2, markerCoords.x, markerCoords.y, markerCoords.z + 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 0, 255, 26, 126, false, false, false, true, false, false, false)
        DrawMarker(27, markerCoords.x, markerCoords.y, markerCoords.z , 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 0, 0, 200, false, false, false, true, false, false, false)
		DrawMarker(1, markerCoords.x, markerCoords.y, markerCoords.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 0, 0, 200, false, false, false, true, false, false, false)
    end
end

-- NUI Menu
local function closeNUI()
    SetNuiFocus(false, false)
    SendNUIMessage({type = "newParkSetup", enable = false})
    Wait(10)
end

local function hideNUI()
    SetNuiFocus(false, false)
    SendNUIMessage({type = "hide"})
    Wait(1)
end

local function openNUI()
    SetNuiFocus(true, true)
    SendNUIMessage({type = "newDoorSetup", enable = true})
    Wait(1)
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local id = GetPlayerServerId(PlayerId())
    PlayerData = QBCore.Functions.GetPlayerData()
    TriggerServerEvent("mh-parking:server:onjoin", id, PlayerData.citizenid)
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
    PlayerData = data
end)

-- Command
RegisterKeyMapping(Config.Command.park, Lang:t('system.park_or_drive'), 'keyboard', Config.KeyParkBindButton) 
RegisterCommand(Config.Command.park, function()
    isUsingParkCommand = true
end, false)

RegisterNUICallback('newParkLocation', function(data, cb)
    closeNUI()
    cb('ok')
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
    local offset = 2.5
    local markerOffset = GetOffsetFromEntityInWorldCoords(vehicle, 0, offset, 0)
    Wait(200)
    TriggerServerEvent('mh-parking:server:AddNewParkingSpot', QBCore.Functions.GetPlayerData().source, data, markerOffset)
end)

RegisterNetEvent("mh-parking:client:openmenu", function(source)
    openNUI()
    SendNUIMessage({type = "newParkSetup", enable = true})
end)

RegisterNetEvent("mh-parking:client:closemenu", function(source)
    hideNUI()
    SendNUIMessage({type = "hide", enable = false})
end)

RegisterNUICallback('close', function(data, cb)
    closeNUI()
    cb('ok')
end)

-- Events
RegisterNetEvent("mh-parking:client:addVehicle", function(vehicle) 
    SpawnVehicle(vehicle) 
end)

RegisterNetEvent("mh-parking:client:deleteVehicle", function(vehicle) 
    DeleteLocalVehicle(vehicle) 
end)

RegisterNetEvent("mh-parking:client:unparkVehicle", function(plate) 
    UnparkVehicle(plate) 
end)

RegisterNetEvent("mh-parking:client:refreshVehicles", function(vehicles)
    GlobalVehicles = vehicles
    RemoveVehicles(vehicles)
    Wait(1000)
    SpawnVehicles(vehicles)
    Wait(1000)
end)

RegisterNetEvent("mh-parking:client:unparking", function()
    local vehicle, distance = QBCore.Functions.GetClosestVehicle(GetEntityCoords(PlayerPedId())) 
    if distance <= 5.0 then
        Drive(PlayerPedId(), GetParkeddCar(vehicle), false)
    else
        QBCore.Functions.Notify(Lang:t("system.to_far_from_vehicle"), "error", 2000)
    end
end)

RegisterNetEvent("mh-parking:client:parking", function()
    local vehicle, distance = QBCore.Functions.GetClosestVehicle(GetEntityCoords(PlayerPedId()))
    if distance <= 5.0 then
        if IsNotReservedPosition(GetEntityCoords(vehicle)) then
            Save(PlayerPedId(), vehicle, false)
        end
    else
        QBCore.Functions.Notify(Lang:t("system.to_far_from_vehicle"), "error", 2000)
    end
end)

RegisterNetEvent('mh-parking:client:setParkedVecihleLocation', function(location)
    SetNewWaypoint(location.x, location.y)
    QBCore.Functions.Notify(Lang:t("success.route_has_been_set"), 'success')
end)

RegisterNetEvent('mh-parking:client:addkey', function(plate, citizenid)
    if QBCore.Functions.GetPlayerData().citizenid == citizenid then
        TriggerServerEvent(Config.KeyScriptTrigger, plate) 
    end
end)

-- Server To Client Events
RegisterNetEvent('mh-parking:client:newParkConfigAdded', function(parkname, data)
    Config.ReservedParkList[parkname] = data
    QBCore.Functions.Notify("New park configuration is addedd to the park list.", 'success')
end)

RegisterNetEvent("mh-parking:client:GetUpdate", function(state)
    UpdateAvailable = state
    if UpdateAvailable then print(Lang:t('system.update')) end
end)

RegisterNetEvent("mh-parking:client:park", function(state)
    isUsingParkCommand = true
end)

RegisterNetEvent("mh-parking:client:useparknames", function(state)
    Config.UseParkedVehicleNames = not Config.UseParkedVehicleNames
end)

RegisterNetEvent("mh-parking:client:useparkspotnames", function(state)
    Config.UseParkedLocationNames = not Config.UseParkedLocationNames
end)

RegisterNetEvent("mh-parking:client:usenotification", function(state)
    Config.PhoneNotification = not Config.PhoneNotification
end)

RegisterNetEvent("mh-parking:client:buildmode", function(state)
    Config.BuildMode = not Config.BuildMode
end)

-- Threads
CreateThread(function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

CreateThread(function()
    while true do
        InParking = true
        if InParking then
            if not SpawnedVehicles then
                RemoveVehicles(GlobalVehicles)
                TriggerServerEvent("mh-parking:server:refreshVehicles", 'allparking')
                SpawnedVehicles = true
                Wait(2000)
            end
        else
            if SpawnedVehicles then
                RemoveVehicles(GlobalVehicles)
                SpawnedVehicles = false
            end
        end
        Wait(0)
    end
end)

CreateThread(function()
    if Config.UseParkingSystem then
		while true do
            local position = nil
			local player = PlayerPedId()
            CreateState()
            if IsPedInAnyVehicle(player) then
                position = GetEntityCoords(GetVehiclePedIsIn(player))
            else
                position = GetEntityCoords(player)
            end
            DrawParkedLocation(position)
			if IsPedInAnyVehicle(player) then
				local storedVehicle = GetPlayerInStoredCar(player)
				local vehicle = GetVehiclePedIsIn(player)
                local plate = QBCore.Functions.GetPlate(vehicle)
				if storedVehicle ~= false then
					DisplayHelpText(Lang:t("info.press_drive_car"))
					if IsControlJustReleased(0, Config.ParkingButton) then
						isUsingParkCommand = true
					end
				end
				if isUsingParkCommand then
					isUsingParkCommand = false
					if storedVehicle ~= false then
						Drive(player, storedVehicle, true)
					else
						if vehicle then
                            local speed = GetEntitySpeed(vehicle)
                            local vehicleCoords = GetEntityCoords(vehicle)
                            if speed > 0.9 then
                                QBCore.Functions.Notify(Lang:t("info.stop_car"), 'error', 1500)
                            elseif IsThisModelACar(GetEntityModel(vehicle)) or IsThisModelABike(GetEntityModel(vehicle)) or IsThisModelABicycle(GetEntityModel(vehicle)) or IsThisModelAPlane(GetEntityModel(vehicle)) or IsThisModelABoat(GetEntityModel(vehicle)) or IsThisModelAHeli(GetEntityModel(vehicle)) then
                                if IsNotReservedPosition(vehicleCoords) then
                                    Save(PlayerPedId(), vehicle, true)
                                end
                            end
						end
					end
				end
			else
				isUsingParkCommand = false
			end
			Wait(0)
		end
    end
end)

CreateThread(function()
    if Config.UseParkingSystem and Config.UseParkedVehicleNames then
        while true do
            DisplayParkedOwnerText()
            Wait(0)
        end
    end
end)

CreateThread(function()
    while true do
        CheckDistanceToForceGrounded(Config.ForceGroundedDistane)
        Wait(Config.ForceGroundenInMilSec)
    end
end)
