function Drive(player, vehicle)
	action = 'drive'
	Wait(50)
	QBCore.Functions.TriggerCallback("qb-parking:server:drive", function(callback)
		if callback.status then
			DeleteVehicle(vehicle.entity)
			DeleteVehicle(GetVehiclePedIsIn(player))
			vehicle = false	
			MakeVehicleReadyToDrive(callback.data)
		else
			QBCore.Functions.Notify(callback.message, "error", 5000)
		end
		Wait(1000)
	end, vehicle)
end

-- When player drive the car
function MakeVehicleReadyToDrive(vehicle)
	-- Delete the local entity first
	DeleteNearByVehicle(vector3(vehicle.location.x, vehicle.location.y, vehicle.location.z))
	LoadModel(vehicle.props["model"])
	local vehicleEntity = CreateVehicleEntity(vehicle)
	TaskWarpPedIntoVehicle(GetPlayerPed(-1), vehicleEntity, -1)
	QBCore.Functions.SetVehicleProperties(vehicleEntity, vehicle.props)
	-- Add Vehicle On Ground Properly
	RequestCollisionAtCoord(vehicle.location.x, vehicle.location.y, vehicle.location.z)
	SetVehicleOnGroundProperly(vehicleEntity)
	FreezeEntityPosition(vehicleEntity, false)
	SetVehicleLivery(vehicleEntity, vehicle.livery)
	SetVehicleEngineHealth(vehicleEntity, vehicle.health.engine)
	SetVehicleBodyHealth(vehicleEntity, vehicle.health.body)
	SetVehiclePetrolTankHealth(vehicleEntity, vehicle.health.tank)
	SetVehRadioStation(vehicleEntity, 'OFF')
	SetVehicleDirtLevel(vehicleEntity, 0)
	SetModelAsNoLongerNeeded(vehicle.props["model"])
end