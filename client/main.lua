local QBCore             = exports['qb-core']:GetCoreObject()
local PlayerData         = {}
local LocalVehicles      = {}
local GlobalVehicles     = {}
local Citizenid          = 0
local UpdateAvailable    = false
local SpawnedVehicles    = false
local isUsingParkCommand = false
local IsDeleting         = false
local OnDuty             = false
local InParking          = false
local LastUsedPlate      = nil
local VehicleEntity      = nil
local action             = 'none'

----------------------------------------------Net Event----------------------------------------------
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    PlayerJob = job
end)
RegisterNetEvent('QBCore:Client:SetDuty', function(duty)
    OnDuty = duty
end)
RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
    PlayerData = data
    Citizenid = PlayerData.citizenid
end)


--------------------------------------------Local Functions--------------------------------------------

local function GetStreetName()
    local ped       = PlayerPedId()
    local coords    = GetEntityCoords(PlayerPedId())
    local zone      = GetNameOfZone(coords.x, coords.y, coords.z)
    local zoneLabel = GetLabelText(zone)
    local var       = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local hash      = GetStreetNameFromHashKey(var)
    local street    = nil
    if hash == '' then street = zoneLabel else street = hash..', '..zoneLabel end
    return street
end

local function CreateParkDisPlay(vehicleData)
    local info, model, owner, plate = nil
    local viewType = ""
    owner = string.format(Lang:t("info.owner", {owner = vehicleData.citizenname}))..'\n'
    model = string.format(Lang:t("info.model", {model = vehicleData.model}))..'\n'
    plate = string.format(Lang:t("info.plate", {plate = vehicleData.plate}))..'\n'
    info  = string.format("%s", model..plate..owner)
    return info
end

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

local function SetFuel(vehicle, fuel)
	if type(fuel) == 'number' and fuel >= 0 and fuel <= 100 then
		SetVehicleFuelLevel(vehicle, fuel + 0.0)
		DecorSetFloat(vehicle, "_FUEL_LEVEL", GetVehicleFuelLevel(vehicle))
	end
end


-- Load Entity
local function Spawn(vehicleData)
	QBCore.Functions.LoadModel(vehicleData.vehicle.props["model"])
    VehicleEntity = CreateVehicle(vehicleData.vehicle.props["model"], vehicleData.vehicle.location.x, vehicleData.vehicle.location.y, vehicleData.vehicle.location.z - 0.5, vehicleData.vehicle.location.w, false)
    QBCore.Functions.SetVehicleProperties(VehicleEntity, vehicleData.vehicle.props)
    SetVehicleEngineOn(VehicleEntity, false, false, true)

    if QBCore.Functions.GetPlayerData().citizenid ~= vehicleData.citizenid then
        SetVehicleDoorsLocked(VehicleEntity, 2)
    end

    SetVehicleNumberPlateText(VehicleEntity, vehicleData.plate)
    SetEntityAsMissionEntity(VehicleEntity, true, true)
    RequestCollisionAtCoord(vehicleData.vehicle.location.x, vehicleData.vehicle.location.y, vehicleData.vehicle.location.z)
    SetVehicleOnGroundProperly(VehicleEntity)
    SetEntityInvincible(VehicleEntity, true)
    SetEntityHeading(VehicleEntity, vehicleData.vehicle.location.w)
    SetVehicleLivery(VehicleEntity, vehicleData.vehicle.livery)
    SetVehicleEngineHealth(VehicleEntity, vehicleData.vehicle.health.engine)
    SetVehicleBodyHealth(VehicleEntity, vehicleData.vehicle.health.body)
    SetVehiclePetrolTankHealth(VehicleEntity, vehicleData.vehicle.health.tank)
    SetModelAsNoLongerNeeded(vehicleData.vehicle.props["model"])
    SetVehRadioStation(VehicleEntity, 'OFF')
    SetVehicleDirtLevel(VehicleEntity, 0)
	doCarDamage(VehicleEntity, vehicleData.vehicle.health)
    SetFuel(VehicleEntity, vehicleData.fuel)


    Wait(100)
    FreezeEntityPosition(VehicleEntity, true)
    LocalVehicles[#LocalVehicles + 1] = {
		entity      = VehicleEntity,
		vehicle     = vehicleData.mods,
		plate       = vehicleData.plate,
        fuel        = vehicleData.fuel,
		citizenid   = vehicleData.citizenid,
		citizenname = vehicleData.citizenname,
		livery      = vehicleData.vehicle.livery,
		health      = vehicleData.vehicle.health,
		model       = vehicleData.model,  
		location    = {
			x = vehicleData.vehicle.location.x,
			y = vehicleData.vehicle.location.y,
			z = vehicleData.vehicle.location.z,
			w = vehicleData.vehicle.location.w
		},
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
                    displayWhoOwnesThisCar = CreateParkDisPlay(vehicle)
					Draw3DText(vehicle.location.x, vehicle.location.y, vehicle.location.z - 0.2, displayWhoOwnesThisCar, 0, 0.04, 0.04)
                else
                    if PlayerData.citizenid == vehicle.citizenid then
                        displayWhoOwnesThisCar = CreateParkDisPlay(vehicle)
                        Draw3DText(vehicle.location.x, vehicle.location.y, vehicle.location.z - 0.2, displayWhoOwnesThisCar, 0, 0.04, 0.04)
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
                    SetEntityCollision(vehicle, false, true)
                    SetEntityVisible(vehicle, false, 0)
					DeleteEntity(LocalVehicles[i].entity)
                    table.remove(LocalVehicles, i)
				end
			end
		end
    end
end

local function DeleteLocal(vehicle)
    if type(LocalVehicles) == 'table' and #LocalVehicles > 0 and LocalVehicles[1] then
		for i = 1, #LocalVehicles do
            if type(vehicle.plate) ~= 'nil' and type(LocalVehicles[i]) ~= 'nil' and type(LocalVehicles[i].plate) ~= 'nil' then
				if vehicle.plate == LocalVehicles[i].plate then
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
				DeleteLocalVehicle(vehicles[i].vehicle)
                Wait(10)
				Spawn(vehicles[i])
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
            Wait(10)
			Spawn(vehicleData)
		end
    end)
end

-- Remove all Vehicles
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
    IsDeleting = false
end

-- Just some help text
local function DisplayHelpText(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end


---------------------------------------------------Drive-----------------------------------------------
local function Drive(player, vehicle)
    QBCore.Functions.TriggerCallback("qb-parking:server:drive", function(callback)
        if callback.status then
            DeleteLocal(vehicle)
            local player = PlayerPedId()
            local tmpVehicle = GetVehiclePedIsIn(player)
            --SetEntityInvincible(tmpVehicle, false)
            doCarDamage(tmpVehicle, vehicle.health)
	        SetFuel(tmpVehicle, callback.fuel)
            vehicle = false
            FreezeEntityPosition(tmpVehicle, false)
            Wait(100)
            SetVehicleEngineOn(tmpVehicle, true, true, true)
            VehicleEntity = nil
        else
            QBCore.Functions.Notify(callback.message, "error", 5000)
        end
    end, vehicle)
end


--------------------------------------------------Park-------------------------------------------------
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
    --SetEntityVisible(vehicle, false, 0)
    --SetEntityCollision(vehicle, false, false)
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


-- Save Vehicle to Database
local function Save(player, vehicle)
    ParkCar(player, vehicle)
    local vehicleProps = QBCore.Functions.GetVehicleProperties(vehicle)
    local displaytext  = GetDisplayNameFromVehicleModel(vehicleProps["model"])
    local carModelName = GetLabelText(displaytext)
    LastUsedPlate      = vehicleProps.plate
    QBCore.Functions.TriggerCallback("qb-parking:server:save", function(callback)
        if callback.status then
            SetEntityNoCollisionEntity(vehicle, callback.vehicle, true)
            SetEntityVisible(vehicle, false, 0)
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
        model       = carModelName,
        health      = {engine = GetVehicleEngineHealth(vehicle), body = GetVehicleBodyHealth(vehicle), tank = GetVehiclePetrolTankHealth(vehicle) },
        location    = vector4(GetEntityCoords(vehicle).x, GetEntityCoords(vehicle).y, GetEntityCoords(vehicle).z, GetEntityHeading(vehicle)),
    })
end

---------------------------------------Impound/Stolen/UnPark-------------------------------------------
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

------------------------------------------------Commands-----------------------------------------------
RegisterKeyMapping('park', Lang:t('system.park_or_drive'), 'keyboard', 'F5') 

RegisterCommand(Config.Command.park, function()
    isUsingParkCommand = true
end, false)

RegisterCommand(Config.Command.parknames, function()
    UseParkedVehicleNames = not UseParkedVehicleNames
    if UseParkedVehicleNames then
        QBCore.Functions.Notify(Lang:t('system.enable', {type = "names"}), "success", 1500)
    end
    if not UseParkedVehicleNames then
        QBCore.Functions.Notify(Lang:t('system.disable', {type = "names"}), "error", 1500)
    end
end, false)

RegisterCommand(Config.Command.notification, function()
    UsePhoneNotification = not UsePhoneNotification
    if UsePhoneNotification then
        QBCore.Functions.Notify(Lang:t('system.enable', {type = "notifications"}), "success", 1500)
    end
    if not PhoneNotification then
        QBCore.Functions.Notify(Lang:t('system.disable', {type = "notifications"}), "error", 1500)
    end
end, false)

---------------------------------------------------Events----------------------------------------------
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

-------------------------------------------------Thread-------------------------------------------------
CreateThread(function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

CreateThread(function()
	while not IsDeleting do
		for i = 1, #LocalVehicles do
            if type(LocalVehicles[i]) ~= 'nil' and type(LocalVehicles[i].entity) ~= 'nil' then
                if DoesEntityExist(LocalVehicles[i].entity) and type(LocalVehicles[i].isGrounded) == 'nil' then
                    if GetDistanceBetweenCoords(GetEntityCoords(LocalVehicles[i].entity), GetEntityCoords(GetPlayerPed(-1))) < Config.RefreshGroundedRadius then
                        SetEntityCoords(LocalVehicles[i].entity, LocalVehicles[i].location.x, LocalVehicles[i].location.y, LocalVehicles[i].location.z)
                        SetVehicleOnGroundProperly(LocalVehicles[i].entity)
                        LocalVehicles[i].isGrounded = true                        
                        --print("Update vehicle position")
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
		if #(pl - vector3(232.11, -770.14, 0.0)) < 99999099.0 then
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
						    if speed > 0.9 then
                                QBCore.Functions.Notify(Lang:t("info.stop_car"), "error", 2000)
                            elseif IsThisModelACar(GetEntityModel(vehicle)) or IsThisModelABike(GetEntityModel(vehicle)) or IsThisModelABicycle(GetEntityModel(vehicle)) then
                                Save(player, vehicle)
                            else
                                QBCore.Functions.Notify(Lang:t("info.only_cars_allowd"), "error", 5000)
                            end
                        else
                            QBCore.Functions.Notify(Lang:t("info.only_cars_allowd"), "error", 5000)						
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
