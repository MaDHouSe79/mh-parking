function DisplayParkedOwnerText()
	if not HideParkedVehicleNames then -- for performes
		local pl = GetEntityCoords(GetPlayerPed(-1))
		local displayWhoOwnesThisCar = nil
		for k, v in pairs(LocalVehicles) do
			displayWhoOwnesThisCar = CreateParkDisPlay(v)
			if GetDistanceBetweenCoords(pl.x, pl.y, pl.z, v.location.x, v.location.y, v.location.z, true) < Config.DisplayDistance then
				if PlayerData.job == "police" and onDuty == true then
					Draw3DText(v.location.x, v.location.y, v.location.z - 0.2, displayWhoOwnesThisCar, 0, 0.04, 0.04)
				end
				if PlayerData.citizenid == v.citizenid then
					Draw3DText(v.location.x, v.location.y, v.location.z - 0.2, displayWhoOwnesThisCar, 0, 0.04, 0.04)
				end
			end
		end
	end
end

function CreateParkDisPlay(player)
	local owner = string.format(Lang:t("info.owner", {owner = player.citizenname}))..'\n'
	local model = string.format(Lang:t("info.model", {model = player.model}))..'\n'
	local plate = string.format(Lang:t("info.plate", {plate = player.plate}))..'\n'	
	return string.format("%s", model..plate..owner)
end
-- Get the stored vehicle player is in
function GetPlayerInStoredCar(player)
	local vehicleEntity = GetVehiclePedIsIn(player)
	local findVeh = false
	for i = 1, #LocalVehicles do
		if LocalVehicles[i].entity == vehicleEntity then
			findVeh = LocalVehicles[i]
			break
		end
	end
	return findVeh
end

-- Spawn local vehicles(server data)
function SpawnVehicles(vehicles)
	Citizen.CreateThread(function()
		while IsDeleting do Citizen.Wait(100) end
		if type(vehicles) == 'table' and #vehicles > 0 and vehicles[1] ~= nil then
			for i = 1, #vehicles, 1 do
				local vehicleProps = vehicles[i].vehicle.props
				DeleteLocalVehicle(vehicles[i].vehicle)
				LoadEntity(vehicles[i], 'server')
				Wait(50)
				TableInsert(vehicleEntity, vehicles[i])
                DoAction(action)
				Wait(100)
			end
		end
	end)
end

-- Spawn single vehicle(client data)
function SpawnVehicle(vehicleData)
	Citizen.CreateThread(function()
		print("Start spawning single local vehicle")
		if LocalPlayer.state.isLoggedIn then
			while IsDeleting do Citizen.Wait(100) end
			DeleteLocalVehicle(vehicleData.vehicle)
			Wait(500)
			LoadEntity(vehicleData, 'client')
			PrepareVehicle(vehicleEntity, vehicleData)
			Wait(50)
			FreezeEntityPosition(vehicleEntity, true)
			if vehicleData.citizenid ~= QBCore.Functions.GetPlayerData().citizenid then
				SetVehicleDoorsLocked(vehicleEntity, 2)
			end
			TableInsert(vehicleEntity, vehicleData)
            DoAction(action)
		end
	end)
end

function PrepareVehicle(entity, vehicleData)
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
	exports['LegacyFuel']:SetFuel(entity, 100.0)
	SetVehRadioStation(entity, 'OFF')
	SetVehicleDirtLevel(entity, 0)
	QBCore.Functions.SetVehicleProperties(entity, vehicleData.vehicle.props)
	SetModelAsNoLongerNeeded(vehicleData.vehicle.props["model"])
end

-- Load Entiry
function LoadEntity(vehicleData, type)
	LoadModel(vehicleData.vehicle.props["model"])
	vehicleEntity = CreateVehicle(vehicleData.vehicle.props["model"], vehicleData.vehicle.location.x, vehicleData.vehicle.location.y, vehicleData.vehicle.location.z, vehicleData.vehicle.location.h, false)
	QBCore.Functions.SetVehicleProperties(vehicleEntity, vehicleData.vehicle.props)	
	if type == 'server' then
		TriggerEvent('vehiclekeys:client:SetVehicleOwnerToCitizenid', vehicleData.plate, vehicleData.citizenid)
	end
	PrepareVehicle(vehicleEntity, vehicleData)
end

-- Create Vehicle Entity
function CreateVehicleEntity(vehicle)
	LoadModel(vehicle.props["model"])
	return CreateVehicle(vehicle.props["model"], vehicle.location.x, vehicle.location.y, vehicle.location.z, vehicle.location.h, true)
end


function DoAction(action)
	if action == 'drive' then
		action = nil
		if LastUsedPlate ~= nil and vehicles[i].plate == LastUsedPlate then
			TaskWarpPedIntoVehicle(GetPlayerPed(-1), vehicleEntity, -1)
			TaskLeaveVehicle(GetPlayerPed(-1), vehicleEntity)
			LastUsedPlate = nil
		end
	end
end

-- Insert Data to table
function TableInsert(vehicleEntity, vehicleData)
	table.insert(LocalVehicles, {
		entity      = vehicleEntity,
		vehicle     = vehicleData.data,
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
			h = vehicleData.vehicle.location.h
		}
	})
end

-- remove all Vehicles
function RemoveVehicles(vehicles)
	IsDeleting = true
	if type(vehicles) == 'table' and #vehicles > 0 and vehicles[1] ~= nil then
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
	LocalVehicles    = {}
	IsDeleting = false
end

-- Delete single vehicle
function DeleteLocalVehicle(vehicle)
	if type(LocalVehicles) == 'table' and #LocalVehicles > 0 and LocalVehicles[1] ~= nil then
		for i = 1, #LocalVehicles do
			if vehicle ~= nil then
				if type(vehicle.plate) ~= 'nil' and type(LocalVehicles[i].plate) ~= 'nil' then
					if vehicle.plate == LocalVehicles[i].plate then
						local tmpModel = GetEntityModel(veh)
						SetModelAsNoLongerNeeded(tmpModel)
						DeleteEntity(LocalVehicles[i].entity)
						table.remove(LocalVehicles, i)
						tmpModel = nil
					end
				end
			end
		end
	end
end

-- Delete the vehicle near the location
function DeleteNearByVehicle(location)
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

-- Just some help text
function DisplayHelpText(text)
	SetTextComponentFormat('STRING')
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- Load car model
function LoadModel(model)
	while not HasModelLoaded(model) do
		RequestModel(model)
		Citizen.Wait(1)
	end
end

-- Draw 3d text on screen
function Draw3DText(x, y, z, textInput, fontId, scaleX, scaleY)
	local px, py, pz = table.unpack(GetGameplayCamCoords())
	local dist       = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)    
	local scale      = (1 / dist) * 20
	local fov        = (1 / GetGameplayCamFov()) * 100
	local scale      = scale * fov   
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

-- Send Email the the player phone 
function SendMail(mail_sender, mail_subject, mail_message)
	if PhoneNotification then
		local coords = GetEntityCoords(PlayerPedId());
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
function GetStreetName()
	local ped       = GetPlayerPed(-1);
	local veh       = GetVehiclePedIsIn(ped, false);
	local coords    = GetEntityCoords(PlayerPedId());
	local zone      = GetNameOfZone(coords.x, coords.y, coords.z);
	local zoneLabel = GetLabelText(zone);
	local var       = GetStreetNameAtCoord(coords.x, coords.y, coords.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
	local hash      = GetStreetNameFromHashKey(var);
	local street    = nil;
	if (hash == '') then
		street = zoneLabel;
	else
		street = hash..', '..zoneLabel;
	end
	return street;
end

function SetWaypoint(x, y)
    SetNewWaypoint(x, y)
    QBCore.Functions.Notify(Lang:t("success.route_has_been_set"), 'success');
end

