-- Save 
function Save(player, vehicle)
	ParkCar(player, vehicle)
    local vehicleProps = QBCore.Functions.GetVehicleProperties(vehicle)
	local displaytext  = GetDisplayNameFromVehicleModel(vehicleProps["model"])
	local carModelName = GetLabelText(displaytext)
	action             = 'park'
	LastUsedPlate      = vehicleProps.plate
	QBCore.Functions.TriggerCallback("qb-parking:server:save", function(callback)
		if callback.status then
			DeleteVehicle(vehicle)
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
		location    = {x = GetEntityCoords(vehicle).x, y = GetEntityCoords(vehicle).y, z = GetEntityCoords(vehicle).z - 0.5, h = GetEntityHeading(vehicle)},   
	})
end

function ParkCar(player, vehicle)
	TaskLeaveVehicle(player, vehicle)						
	for i = 0, 5 do
		SetVehicleDoorShut(vehicle, i, false) -- will close all doors from 0-5
		if Config.SoundWhenCloseDoors then
			PlayVehicleDoorCloseSound(vehicle, i)
		end
	end			
	Citizen.Wait(2000)
	SetVehicleDoorsLocked(vehicle, 2)
	SetVehicleLights(vehicle, 2)
	Citizen.Wait(150)
	SetVehicleLights(vehicle, 0)
	Citizen.Wait(150)
	SetVehicleLights(vehicle, 2)
	Citizen.Wait(150)
	SetVehicleLights(vehicle, 0)
end