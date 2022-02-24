--[[ ===================================================== ]]--
--[[      QBCore Realistic Parking Script by MaDHouSe      ]]--
--[[ ===================================================== ]]--

local QBCore             = exports['qb-core']:GetCoreObject()
local PlayerData         = {}
local LocalVehicles      = {}
local GlobalVehicles     = {}
local UpdateAvailable    = false
local SpawnedVehicles    = false
local isUsingParkCommand = false
local IsDeleting         = false
local OnDuty             = false
local InParking          = false
local LastUsedPlate      = nil
local VehicleEntity      = nil
local action             = 'none'
local ParkOwnerName      = nil

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    TriggerServerEvent("qb-parking:server:refreshVehicles", 'allparking')
end)
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    PlayerJob = job
end)
RegisterNetEvent('QBCore:Client:SetDuty', function(duty)
    OnDuty = duty
end)
RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
    PlayerData = data
end)

local function CreateParkDisPlay(vehicleData, type)
    local info, model, owner, plate = nil
    local viewType = ""
    if type == 'police'  then if Config.DisplayPlayerAndPolice then viewType = Lang:t('info.police_info')..'\n'  end end
    if type == 'citizen' then if Config.DisplayPlayerAndPolice then viewType = Lang:t('info.citizen_info')..'\n' end end
    owner = string.format(Lang:t("info.owner", {owner = vehicleData.citizenname}))..'\n'
    model = viewType .. string.format(Lang:t("info.model", {model = vehicleData.modelname}))..'\n'
    plate = string.format(Lang:t("info.plate", {plate = vehicleData.plate}))..'\n'
    info  = string.format("%s", model..plate..owner)
    return info
end

-- Do Vehicle damage
local function doCarDamage(vehicle, health)
	local engine = health.engine + 0.0
	local body = health.body + 0.0
    Wait(100)
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
	if body < 700.0 then
		SetVehicleDoorBroken(vehicle, 0, true)
		SetVehicleDoorBroken(vehicle, 1, true)
		SetVehicleDoorBroken(vehicle, 2, true)
		SetVehicleDoorBroken(vehicle, 3, true)
		SetVehicleDoorBroken(vehicle, 4, true)
		SetVehicleDoorBroken(vehicle, 5, true)
		SetVehicleDoorBroken(vehicle, 6, true)
	end
	if engine < 600.0 then
		SetVehicleTyreBurst(vehicle, 1, false, 990.0)
		SetVehicleTyreBurst(vehicle, 2, false, 990.0)
		SetVehicleTyreBurst(vehicle, 3, false, 990.0)
		SetVehicleTyreBurst(vehicle, 4, false, 990.0)
	end
	if engine < 400.0 then
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

local function SetFuel(vehicle, fuel)
	if type(fuel) == 'number' and fuel >= 0 and fuel <= 100 then
		SetVehicleFuelLevel(vehicle, fuel + 0.0)
		DecorSetFloat(vehicle, "_FUEL_LEVEL", GetVehicleFuelLevel(vehicle))
	end
end

local function PrepareVehicle(entity, vehicleData)
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
local function LoadEntity(vehicleData)
	QBCore.Functions.LoadModel(vehicleData.vehicle.props["model"])
    VehicleEntity = CreateVehicle(vehicleData.vehicle.props["model"], vehicleData.vehicle.location.x, vehicleData.vehicle.location.y, vehicleData.vehicle.location.z - 0.1, vehicleData.vehicle.location.w, false)
    QBCore.Functions.SetVehicleProperties(VehicleEntity, vehicleData.vehicle.props)
    SetVehicleEngineOn(VehicleEntity, false, false, true)
    SetVehicleDoorsLocked(VehicleEntity, 2)
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
local function TableInsert(entity, data)
    local blip = nil
    if PlayerData.citizenid == data.citizenid then
        if Config.UseParkingBlips then
            blip = CreateParkedBlip(Lang:t('info.parked_blip_info',{modelname = data.modelname}), data.vehicle.location)
        end
        TriggerEvent('qb-parking:client:addkey', data.plate, data.citizenid) 
    end
    LocalVehicles[#LocalVehicles+1] = {
		entity      = entity,
		vehicle     = data.mods,
		plate       = data.plate,
        fuel        = data.fuel,
		citizenid   = data.citizenid,
		citizenname = data.citizenname,
		livery      = data.vehicle.livery,
		health      = data.vehicle.health,
		model       = data.model,
        modelname   = data.modelname,
        parkedBlip  = blip,
		location    = {
			x = data.vehicle.location.x,
			y = data.vehicle.location.y,
			z = data.vehicle.location.z,
			w = data.vehicle.location.w
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
    if UseParkedVehicleNames then -- for performes
		local pl = GetEntityCoords(PlayerPedId())
		local displayWhoOwnesThisCar = nil
		for k, vehicle in pairs(LocalVehicles) do
			if #(pl - vector3(vehicle.location.x, vehicle.location.y, vehicle.location.z)) < Config.DisplayDistance then
				if PlayerData.job.name == "police" and PlayerData.job.onduty then
                    displayWhoOwnesThisCar = CreateParkDisPlay(vehicle, 'police')
					Draw3DText(vehicle.location.x, vehicle.location.y, vehicle.location.z + 0.2, displayWhoOwnesThisCar, 0, 0.04, 0.04)
                else
                    if PlayerData.citizenid == vehicle.citizenid then
                        displayWhoOwnesThisCar = CreateParkDisPlay(vehicle, 'citizen')
                        Draw3DText(vehicle.location.x, vehicle.location.y, vehicle.location.z + 0.2, displayWhoOwnesThisCar, 0, 0.04, 0.04)
                    end
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
        if LocalVehicles[i].entity and LocalVehicles[i].entity == entity then
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
            if type(vehicle.plate) ~= 'nil' and type(LocalVehicles[i]) ~= 'nil' and type(LocalVehicles[i].plate) ~= 'nil' then
				if vehicle.plate == LocalVehicles[i].plate then
					DeleteEntity(LocalVehicles[i].entity)
                    table.remove(LocalVehicles, i)
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
                SetEntityCollision(vehicles[i].vehicle, false, true)
                SetEntityVisible(vehicles[i].vehicle, false, 0)
                if Config.UseSpawnDelay then Wait(Config.DeleteDelay) end
				DeleteLocalVehicle(vehicles[i].vehicle)
				LoadEntity(vehicles[i])
				SetVehicleEngineOn(VehicleEntity, false, false, true)
				doCarDamage(VehicleEntity, vehicles[i].vehicle.health)
				
                if vehicles[i].citizenid ~= PlayerData.citizenid then
                    SetVehicleDoorsLocked(VehicleEntity, 2)
                end

                TableInsert(VehicleEntity, vehicles[i])
				DoAction(action)
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
			LoadEntity(vehicleData)
			PrepareVehicle(VehicleEntity, vehicleData)
			SetVehicleEngineOn(VehicleEntity, false, false, true)
			doCarDamage(VehicleEntity, vehicleData.vehicle.health)

			if vehicleData.citizenid ~= PlayerData.citizenid then
				SetVehicleDoorsLocked(VehicleEntity, 2)
			end

			TableInsert(VehicleEntity, vehicleData)
			DoAction(action)
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
    IsDeleting    = false
end

-- Just some help text
local function DisplayHelpText(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

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
    DeleteNearByVehicle(vector3(vehicle.location.x, vehicle.location.y, vehicle.location.z))
    local VehicleEntity = CreateVehicleEntity(vehicle)
    TaskWarpPedIntoVehicle(PlayerPedId(), VehicleEntity, -1)
    QBCore.Functions.SetVehicleProperties(VehicleEntity, vehicle.props)
    RequestCollisionAtCoord(vehicle.location.x, vehicle.location.y, vehicle.location.z)
    SetVehicleOnGroundProperly(VehicleEntity)
    FreezeEntityPosition(VehicleEntity, false)
    SetVehicleLivery(VehicleEntity, vehicle.livery)
    SetVehRadioStation(VehicleEntity, 'OFF')
    SetVehicleDirtLevel(VehicleEntity, 0)
    SetVehicleFuelLevel(VehicleEntity, vehicle.fuel)
    SetModelAsNoLongerNeeded(vehicle.props["model"])
	doCarDamage(VehicleEntity, vehicle.health)
	SetFuel(VehicleEntity, vehicle.fuel)
end

-- Drive 
local function Drive(player, vehicle)
    action = 'drive'
    QBCore.Functions.TriggerCallback("qb-parking:server:drive", function(callback)
        if callback.status then
            QBCore.Functions.DeleteVehicle(vehicle.entity)
            QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(player))
            DeleteLocalVehicle(vehicle)
            if Config.UseParkingBlips then
                RemoveBlip(vehicle.parkedBlip)
            end
            vehicle = false
            MakeVehicleReadyToDrive(callback.data)
        else
            QBCore.Functions.Notify(callback.message, "error", 5000)
        end
    end, vehicle)
end

-- Park
local function ParkCar(player, vehicle)
    SetVehicleEngineOn(vehicle, false, false, true)
    TaskLeaveVehicle(player, vehicle)
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
        fuel        = GetVehicleFuelLevel(vehicle),
        model       = displaytext,
        modelname   = carModelName,
        health      = {engine = GetVehicleEngineHealth(vehicle), body = GetVehicleBodyHealth(vehicle), tank = GetVehiclePetrolTankHealth(vehicle) },
        location    = vector4(GetEntityCoords(vehicle).x, GetEntityCoords(vehicle).y, GetEntityCoords(vehicle).z, GetEntityHeading(vehicle)),
    })
end

-- Impound/Stolen/UnPark
local function ActionVehicle(plate, action)
    for i = 1, #LocalVehicles do
        if LocalVehicles[i].plate == plate then
            QBCore.Functions.TriggerCallback("qb-parking:server:vehicle_action", function(callback)
                if callback.status then
                    FreezeEntityPosition(LocalVehicles[i].entity, false)
                    if action == 'impound' then
                        DeleteEntity(LocalVehicles[i].entity)
                    end
                    table.remove(LocalVehicles, i)
                end
            end, LocalVehicles[i].plate, action)
        end
    end
end

-- blacklistedSports
local function IsNotBlackListedPosition(position)
    local freeSpot = true
    for i = 1, #Config.BlackListedPositions do
        if #(position - Config.BlackListedPositions[i].coords) < Config.BlackListedPositions[i].radius then
            if PlayerData.citizenid ~= nil then
                if PlayerData.citizenid ~= Config.BlackListedPositions[i].citizenid then
                    freeSpot = false
                end
            else
                freeSpot = false
            end
            ParkOwnerName = Config.BlackListedPositions[i].name
        end
    end
    return freeSpot
end

-- Commands
RegisterKeyMapping('park', Lang:t('system.park_or_drive'), 'keyboard', 'F5') 

RegisterCommand(Config.Command.park, function()
    isUsingParkCommand = true
end, false)

RegisterCommand(Config.Command.parknames, function()
    UseParkedVehicleNames = not UseParkedVehicleNames
    if UseParkedVehicleNames then
        QBCore.Functions.Notify(Lang:t('system.enable', {type = "names"}), "success", 1500)
    else
        QBCore.Functions.Notify(Lang:t('system.disable', {type = "names"}), "error", 1500)
    end
end, false)

RegisterCommand(Config.Command.notification, function()
    PhoneNotification = not PhoneNotification
    if PhoneNotification then
        QBCore.Functions.Notify(Lang:t('system.enable', {type = "notifications"}), "success", 1500)
    else
        QBCore.Functions.Notify(Lang:t('system.disable', {type = "notifications"}), "error", 1500)
    end
end, false)

-- Events
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

RegisterNetEvent("qb-parking:client:impound",  function(plate)
    ActionVehicle(plate, 'impound')
end)

RegisterNetEvent("qb-parking:client:stolen",  function(plate)
    local tmpPlate = plate 
    ActionVehicle(plate, 'stolen')
end)

RegisterNetEvent("qb-parking:client:unpark", function(plate)
    ActionVehicle(plate, 'unpark')
end)

RegisterNetEvent('qb-parking:client:setParkedVecihleLocation', function(location)
    SetNewWaypoint(location.x, location.y)
    QBCore.Functions.Notify(Lang:t("success.route_has_been_set"), 'success')
end)

RegisterNetEvent('qb-parking:client:addkey', function(plate, citizenid)
    if PlayerData.citizenid == citizenid then 
        TriggerEvent('vehiclekeys:client:SetOwner', plate) 
    end
end)

RegisterNetEvent("qb-parking:client:GetUpdate", function(state)
    UpdateAvailable = state
    if UpdateAvailable then
        print("There is a update for qb-parking")
    end
end)

-- Threads
CreateThread(function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

CreateThread(function()
	while not IsDeleting do
		if #LocalVehicles ~= 0 then
			for i = 1, #LocalVehicles do
                if type(LocalVehicles[i]) ~= 'nil' and type(LocalVehicles[i].entity) ~= 'nil' then
                    if DoesEntityExist(LocalVehicles[i].entity) and type(LocalVehicles[i].isGrounded) == 'nil' then
		                if #(GetEntityCoords(PlayerPedId()) - vector3(Config.ParkingLocation.x, Config.ParkingLocation.y, Config.ParkingLocation.z)) < Config.PlaceOnGroundRadius then
                            SetEntityCoords(LocalVehicles[i].entity, LocalVehicles[i].location.x, LocalVehicles[i].location.y, LocalVehicles[i].location.z)
                            SetVehicleOnGroundProperly(LocalVehicles[i].entity)
                            SetVehicleFuelLevel(LocalVehicles[i].entity)
                            LocalVehicles[i].isGrounded = true
                        end
                    end
                end
            end
		end
		Wait(1000)
	end
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
				if storedVehicle ~= false then
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
                            local speed = GetEntitySpeed(vehicle)
                            if speed > Config.MinSpeedToPark then
                                QBCore.Functions.Notify(Lang:t("info.stop_car"), 'error', 1500)
							elseif IsThisModelACar(GetEntityModel(vehicle)) or IsThisModelABike(GetEntityModel(vehicle)) or IsThisModelABicycle(GetEntityModel(vehicle)) then
                                local vehicleCoords = GetEntityCoords(vehicle)
                                if IsNotBlackListedPosition(vehicleCoords) then
                                    Save(player, vehicle)
                                    QBCore.Functions.Notify(Lang:t("success.parked"), 'success', 1000)
                                else
                                    QBCore.Functions.Notify(Lang:t('system.already_reserved',{name = ParkOwnerName}), "error", 5000)
                                    ParkOwnerName = nil
                                end
							else
								QBCore.Functions.Notify(Lang:t("info.only_cars_allowd"), "error", 5000)
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