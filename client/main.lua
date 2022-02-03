local QBCore             = exports['qb-core']:GetCoreObject()
local PlayerData         = {}
local PlayerJob          = {}
local LocalVehicles      = {}
local GlobalVehicles     = {}
local SpawnedVehicles    = false
local isUsingParkCommand = false
local IsDeleting         = false
local OnDuty             = false
local InParking          = false
local Citizenid          = nil
local LastUsedPlate      = nil
local VehicleEntity      = nil
local action             = 'none'

--------------------------------------------Local Functions--------------------------------------------
local function CreateParkDisPlay(vehicleData)
    local owner = string.format(Lang:t("info.owner", {owner = vehicleData.citizenname}))..'\n'
    local model = string.format(Lang:t("info.model", {model = vehicleData.model}))..'\n'
    local plate = string.format(Lang:t("info.plate", {plate = vehicleData.plate}))..'\n'
    return string.format("%s", model..plate..owner)
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
    exports[Config.YourFuelExportName]:SetFuel(entity, vehicleData.vehicle.health.tank)
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
	exports[Config.YourFuelExportName]:SetFuel(VehicleEntity, vehicleData.vehicle.health.tank)
    SetVehicleEngineOn(VehicleEntity, false, false, true)
    if type == 'server' then
		if not Config.ImUsingOtherKeyScript then
        	TriggerEvent('vehiclekeys:client:SetVehicleOwnerToCitizenid', vehicleData.plate, vehicleData.citizenid)
		end
	end
    PrepareVehicle(VehicleEntity, vehicleData)
end

-- this achtion olny runs when you park the vehicle.
local function DoAction(action)
    if action == 'drive' then
		action = nil
		if LastUsedPlate and vehicles[i].plate == LastUsedPlate then
			TaskWarpPedIntoVehicle(PlayerPedId(), VehicleEntity, -1)
			TaskLeaveVehicle(PlayerPedId(), VehicleEntity)
			LastUsedPlate = nil
		end
    end
end

-- Insert Data to table
local function TableInsert(VehicleEntity, vehicleData)
	--LocalVehicles[#LocalVehicles+1] =
    LocalVehicles[#LocalVehicles+1] = {
		entity      = VehicleEntity,
		vehicle     = vehicleData.mods,
		plate       = vehicleData.plate,
		citizenid   = vehicleData.citizenid,
		citizenname = vehicleData.citizenname,
		livery      = vehicleData.vehicle.livery,
		health      = vehicleData.vehicle.health,
		model       = vehicleData.model,
		location    = {
			x = vehicleData.vehicle.location.x,
			y = vehicleData.vehicle.location.y,
			z = vehicleData.vehicle.location.z + 0.5,
			w = vehicleData.vehicle.location.w
		}
    }
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
    if not HideParkedVehicleNames then -- for performes
		local pl = GetEntityCoords(PlayerPedId())
		local displayWhoOwnesThisCar = nil
		for k, vehicle in pairs(LocalVehicles) do
			displayWhoOwnesThisCar = CreateParkDisPlay(vehicle)
			if #(pl - vector3(vehicle.location.x, vehicle.location.y, vehicle.location.z)) < Config.DisplayDistance then
				if PlayerJob == "police" and OnDuty == true then
					Draw3DText(vehicle.location.x, vehicle.location.y, vehicle.location.z - 0.2, displayWhoOwnesThisCar, 0, 0.04, 0.04)
				end
				if PlayerData.citizenid == vehicle.citizenid then
					Draw3DText(vehicle.location.x, vehicle.location.y, vehicle.location.z - 0.2, displayWhoOwnesThisCar, 0, 0.04, 0.04)
				end
			end
		end
    end
end

-- Get the stored vehicle player is in
local function GetPlayerInStoredCar(player)
    local entity = GetVehiclePedIsIn(player)
    local findVehicle = false
    for i = 1, #LocalVehicles do
		if LocalVehicles[i].entity == entity then
			findVehicle = LocalVehicles[i]
			break
		end
    end
    return findVehicle
end

-- Delete single vehicle
local function DeleteLocalVehicle(vehicle)
    if type(LocalVehicles) == 'table' and #LocalVehicles > 0 and LocalVehicles[1] then
		for i = 1, #LocalVehicles do
			if vehicle ~= nil then
				if type(vehicle.plate) and type(LocalVehicles[i].plate) then
					if vehicle.plate == LocalVehicles[i].plate then
						DeleteEntity(LocalVehicles[i].entity)
						table.remove(LocalVehicles, i)
					end
				end
			end
		end
    end
end

-- Spawn local vehicles(server data)
local function SpawnVehicles(vehicles)
    CreateThread(function()
		while IsDeleting do Citizen.Wait(100) end
		if type(vehicles) == 'table' and #vehicles > 0 and vehicles[1] then
			for i = 1, #vehicles, 1 do
				DeleteLocalVehicle(vehicles[i].vehicle)
				LoadEntity(vehicles[i], 'server')
				SetVehicleEngineOn(VehicleEntity, false, false, true)
				FreezeEntityPosition(VehicleEntity, true)
				TableInsert(VehicleEntity, vehicles[i])
				DoAction(action)
			end
		end
    end)
end

-- Spawn single vehicle(client data)
local function SpawnVehicle(vehicleData)
    CreateThread(function()
		if LocalPlayer.state.isLoggedIn then
			while IsDeleting do Wait(100) end
			DeleteLocalVehicle(vehicleData.vehicle)
			LoadEntity(vehicleData, 'client')
			PrepareVehicle(VehicleEntity, vehicleData)
			SetVehicleEngineOn(VehicleEntity, false, false, true)
			FreezeEntityPosition(VehicleEntity, true)
			if vehicleData.citizenid ~= QBCore.Functions.GetPlayerData().citizenid then
				SetVehicleDoorsLocked(VehicleEntity, 2)
			end
			TableInsert(VehicleEntity, vehicleData)
			DoAction(action)
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
			-- Clean memory
			vehicle, distance, driver, tmpModel = nil
		end
    end
    LocalVehicles = {}
    IsDeleting    = false
end

-- Just some help text
local function DisplayHelpText(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end
-------------------------------------------------------------------------------------------------------







---------------------------------------------------Drive-----------------------------------------------
-- Create Vehicle Entity
local function CreateVehicleEntity(vehicle)
    QBCore.Functions.LoadModel(vehicle.props["model"])
    return CreateVehicle(vehicle.props["model"], vehicle.location.x, vehicle.location.y, vehicle.location.z, vehicle.location.w, true)
end

-- Delete the vehicle near the location
local function DeleteNearByVehicle(location)
    local vehicle, distance = QBCore.Functions.GetClosestVehicle(location)
    if distance <= 1 then
        for i = 1, #LocalVehicles do
            if LocalVehicles[i].entity == vehicle then
                table.remove(LocalVehicles, i)
            end
            local tmpModel = GetEntityModel(vehicle)
            SetModelAsNoLongerNeeded(tmpModel)
            DeleteEntity(vehicle)
            tmpModel = nil
        end
    end
end

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
    SetVehicleEngineHealth(VehicleEntity, vehicle.health.engine)
    SetVehicleBodyHealth(VehicleEntity, vehicle.health.body)
    SetVehiclePetrolTankHealth(VehicleEntity, vehicle.health.tank)
    SetVehRadioStation(VehicleEntity, 'OFF')
    SetVehicleDirtLevel(VehicleEntity, 0)
    SetModelAsNoLongerNeeded(vehicle.props["model"])
end

-- Drive 
local function Drive(player, vehicle)
    action = 'drive'
    QBCore.Functions.TriggerCallback("qb-parking:server:drive", function(callback)
        if callback.status then
            QBCore.Functions.DeleteVehicle(vehicle.entity)
            QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(player))
            vehicle = false
            MakeVehicleReadyToDrive(callback.data)
        else
            QBCore.Functions.Notify(callback.message, "error", 5000)
        end
    end, vehicle)
end
-------------------------------------------------------------------------------------------------------





--------------------------------------------------Park-------------------------------------------------

local function ParkCar(player, vehicle)
    TaskLeaveVehicle(player, vehicle)
    for i = 0, 5 do
        SetVehicleDoorShut(vehicle, i, false) -- will close all doors from 0-5
        if Config.SoundWhenCloseDoors then
            PlayVehicleDoorCloseSound(vehicle, i)
        end
    end
    RequestAnimSet("anim@mp_player_intmenu@key_fob@")
    TaskPlayAnim(player, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49, 0, false, false)
    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "lock", 0.3)
    Wait(2000)
    ClearPedTasks(player)
    SetVehicleDoorsLocked(vehicle, 2)
    SetVehicleLights(vehicle, 2)
    Wait(150)
    SetVehicleLights(vehicle, 0)
    Wait(150)
    SetVehicleLights(vehicle, 2)
    Wait(150)
    SetVehicleLights(vehicle, 0)
end

-- Send Email to the player phone
local function SendMail(mail_sender, mail_subject, mail_message)
    if PhoneNotification then
        local coords = GetEntityCoords(PlayerPedId())
        TriggerServerEvent('qb-phone:server:sendNewMail', {
            sender  = mail_sender,
            subject = mail_subject,
            message = mail_message,
            button = {
                enabled = true,
                buttonEvent = "qb-parking:client:setParkedVecihleLocation",
                buttonData = coords
            }
        })
    end
end

-- Get the street name where you are at the moment.
local function GetStreetName()
    local ped       = PlayerPedId()
    local veh       = GetVehiclePedIsIn(ped, false)
    local coords    = GetEntityCoords(PlayerPedId())
    local zone      = GetNameOfZone(coords.x, coords.y, coords.z)
    local zoneLabel = GetLabelText(zone)
    local var       = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local hash      = GetStreetNameFromHashKey(var)
    local street    = nil
    if hash == '' then street = zoneLabel else street = hash..', '..zoneLabel end
    return street
end

-- Save
local function Save(player, vehicle)
    ParkCar(player, vehicle)
    local vehicleProps = QBCore.Functions.GetVehicleProperties(vehicle)
    local displaytext  = GetDisplayNameFromVehicleModel(vehicleProps["model"])
    local carModelName = GetLabelText(displaytext)
    action             = 'park'
    LastUsedPlate      = vehicleProps.plate
    QBCore.Functions.TriggerCallback("qb-parking:server:save", function(callback)
        if callback.status then
            QBCore.Functions.DeleteVehicle(vehicle)
            SendMail(
                Lang:t('mail.sender' , {
                    company   = Lang:t('info.companyName'),
                }),
                Lang:t('mail.subject', {
                    model     = carModelName,
                    plate     = LastUsedPlate,
                }),
                Lang:t('mail.message', {
                    street    = GetStreetName(),
                    company   = Lang:t('info.companyName'),
                    username  = PlayerData.charinfo.firstname,
                    model     = carModelName,
                    plate     = LastUsedPlate,
                })
            )
        else
            QBCore.Functions.Notify(callback.message, "error", 5000)
        end
    end, {
        props       = vehicleProps,
        livery      = GetVehicleLivery(vehicle),
        citizenid   = PlayerData.citizenid,
        plate       = vehicleProps.plate,
        model       = carModelName,
        health      = {engine = GetVehicleEngineHealth(vehicle), body = GetVehicleBodyHealth(vehicle), tank = GetVehiclePetrolTankHealth(vehicle) },
        location    = vector4(GetEntityCoords(vehicle).x, GetEntityCoords(vehicle).y, GetEntityCoords(vehicle).z - 0.5, GetEntityHeading(vehicle)),
    })
end
-------------------------------------------------------------------------------------------------------




-----------------------------------------------Impount-------------------------------------------------
local function ImpoundVehicle(entity)
    for i = 1, #LocalVehicles do
		if entity == LocalVehicles[i].entity then
			QBCore.Functions.TriggerCallback("qb-parking:server:impound", function(callback)
				if callback.status then
					FreezeEntityPosition(LocalVehicles[i].entity, false)
					DeleteEntity(LocalVehicles[i].entity)
					table.remove(LocalVehicles, i)
				end
			end, LocalVehicles[i])
		end
    end
end
-------------------------------------------------------------------------------------------------------



-----------------------------------------------Stolen Vehicle------------------------------------------
local function StolenVehicle(entity)
    for i = 1, #LocalVehicles do
		if entity == LocalVehicles[i].entity then
			QBCore.Functions.TriggerCallback("qb-parking:server:stolen", function(callback)
				if callback.status then
					FreezeEntityPosition(LocalVehicles[i].entity, false)
					table.remove(LocalVehicles, i)
				end
			end, LocalVehicles[i])
		end
    end
end
-------------------------------------------------------------------------------------------------------





------------------------------------------------Commands-----------------------------------------------
RegisterKeyMapping('park', 'Park or Drive', 'keyboard', 'F5') 

RegisterCommand(Config.Command.park, function()
    isUsingParkCommand = true
end, false)

RegisterCommand(Config.Command.parknames, function()
    HideParkedVehicleNames = not HideParkedVehicleNames
    if HideParkedVehicleNames then
        QBCore.Functions.Notify(Lang:t('system.enable', {type = "names"}), "primary", 1500)
    else
        QBCore.Functions.Notify(Lang:t('system.disable', {type = "names"}), "primary", 1500)
    end
end, false)

RegisterCommand(Config.Command.notification, function()
    PhoneNotification = not PhoneNotification
    if PhoneNotification then
        QBCore.Functions.Notify(Lang:t('system.enable', {type = "notifications"}), "primary", 1500)
    else
        QBCore.Functions.Notify(Lang:t('system.disable', {type = "notifications"}), "primary", 1500)
    end
end, false)

-- Admin Only
RegisterCommand(Config.Command.vip, function()
    if IsAdmin(Citizenid) then
        OnlyAllowVipPlayers = not OnlyAllowVipPlayers
        if OnlyAllowVipPlayers then
            QBCore.Functions.Notify(Lang:t('system.parkvip', {type = "vip"}), "primary", 1500)
        else
            QBCore.Functions.Notify(Lang:t('system.freeforall', {type = "freeforall"}), "primary", 1500)
        end
    else
        QBCore.Functions.Notify(Lang:t('system.no_permission'), "primary", 1500)
    end
end, false)

-- Admin Only
RegisterCommand(Config.Command.system, function()
    if IsAdmin(Citizenid) then
        UseParkingSystem = not UseParkingSystem
        if UseParkingSystem then
            QBCore.Functions.Notify(Lang:t('system.enable', {type = "system"}), "primary", 1500)
        else
            QBCore.Functions.Notify(Lang:t('system.disable', {type = "system"}), "primary", 1500)
        end
    else
        QBCore.Functions.Notify(Lang:t('system.no_permission'), "error", 1500)
    end
end, false)
-------------------------------------------------------------------------------------------------------




---------------------------------------------------Events----------------------------------------------
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    Citizenid = PlayerData.citizenid
    PlayerJob  = PlayerData.job
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

RegisterNetEvent('QBCore:Client:SetDuty', function(duty)
    OnDuty = duty
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
    Citizenid = PlayerData.citizenid
end)

RegisterNetEvent("qb-parking:client:refreshVehicles", function(vehicles)
    GlobalVehicles = vehicles
    RemoveVehicles(vehicles)
    Wait(1000)
    SpawnVehicles(vehicles)
    Wait(1000)
end)

RegisterNetEvent("qb-parking:client:addVehicle", function(vehicle)
    SpawnVehicle(vehicle)
end)

RegisterNetEvent("qb-parking:client:deleteVehicle", function(vehicle)
    DeleteLocalVehicle(vehicle)
end)

RegisterNetEvent("qb-parking:client:impoundVehicle",  function(vehicle)
    ImpoundVehicle(vehicle)
end)

RegisterNetEvent("qb-parking:client:stolenVehicle",  function(vehicle)
    StolenVehicle(vehicle)
end)

RegisterNetEvent("qb-parking:client:isUsingParkCommand", function()
    if IsAllowToPark() then
        isUsingParkCommand = true
    end
end)

RegisterNetEvent('qb-parking:client:setParkedVecihleLocation', function(location)
    SetNewWaypoint(location.x, location.y)
    QBCore.Functions.Notify(Lang:t("success.route_has_been_set"), 'success')
end)
-------------------------------------------------------------------------------------------------------




-------------------------------------------------Thread-------------------------------------------------
CreateThread(function()
    PlayerData = QBCore.Functions.GetPlayerData()
    PlayerJob = PlayerData.job
    Citizenid = PlayerData.citizenid
end)

CreateThread(function()
    while true do
		local pl = GetEntityCoords(PlayerPedId())
		if #(pl - vector3(Config.ParkingLocation.x, Config.ParkingLocation.y, Config.ParkingLocation.z)) < Config.ParkingLocation.s then
			InParking = true
			crParking = 'allparking'
		end
		if InParking then
			if not SpawnedVehicles then
				RemoveVehicles(GlobalVehicles)
				TriggerServerEvent("qb-parking:server:refreshVehicles", crParking)
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
    if UseParkingSystem then
		while true do
			local player = PlayerPedId()
			if InParking and IsPedInAnyVehicle(player) then
				local storedVehicle = GetPlayerInStoredCar(player)
				local vehicle = GetVehiclePedIsIn(player)
				if storedVehicle ~= false and IsAllowToPark(Citizenid) then
					DisplayHelpText(Lang:t("info.press_drive_car"))
					if IsControlJustReleased(0, Config.parkingButton) then
						isUsingParkCommand = true
					end
				end
				if isUsingParkCommand then
					isUsingParkCommand = false
					if storedVehicle ~= false then
						Drive(player, storedVehicle)
					else
						if vehicle then
							if IsAllowToPark(Citizenid) then
								if IsThisModelACar(GetEntityModel(vehicle)) or IsThisModelABike(GetEntityModel(vehicle)) or IsThisModelABicycle(GetEntityModel(vehicle)) then
									Save(player, vehicle)
								else
									QBCore.Functions.Notify(Lang:t("info.only_cars_allowd"), "primary", 5000)
								end
							else
								QBCore.Functions.Notify(Lang:t("system.no_permission"), "error", 5000)
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
    if UseParkingSystem and not HideParkedVehicleNames then
        while true do
            DisplayParkedOwnerText()
            Wait(0)
        end
    end
end)
-------------------------------------------------------------------------------------------------------
