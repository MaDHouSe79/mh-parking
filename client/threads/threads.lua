-- Main thread
Citizen.CreateThread(function()	
	PlayerData = QBCore.Functions.GetPlayerData()
	Citizenid  = PlayerData.citizenid
end)

Citizen.CreateThread(function()
	while true do
		Wait(0)
		local pl = GetEntityCoords(GetPlayerPed(-1))
		
		if GetDistanceBetweenCoords(pl.x, pl.y, pl.z, Config.ParkingLocation.x, Config.ParkingLocation.y, Config.ParkingLocation.z, true) < Config.ParkingLocation.s then
			inParking = true
			crParking = 'allparking'
		end
		
		if inParking then
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
	end
end)


Citizen.CreateThread(function()
	if UseParkingSystem then
		while true do
			Citizen.Wait(0)
			if inParking and IsPedInAnyVehicle(GetPlayerPed(-1)) then
				local player = GetPlayerPed(-1)
				local storedVehicle = GetPlayerInStoredCar(player)
				local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1))
				if storedVehicle ~= false and IsAllowToPark(Citizenid) then
					DisplayHelpText(Lang:t("info.press_drive_car"))
					if IsControlJustReleased(0, Config.parkingButton) then --[[F5]] 
						isUsingParkCommand = true 
					end
				end
				if isUsingParkCommand then
					isUsingParkCommand = false
					if storedVehicle ~= false then
						Drive(player, storedVehicle)
					else
						if vehicle ~= 0 then
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
		end
	end
end)

Citizen.CreateThread(function()	
    while true do
        Citizen.Wait(0);
        DisplayParkedOwnerText()
    end 
end)