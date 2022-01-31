-- Main threads.
CreateThread(function()
    PlayerData = QBCore.Functions.GetPlayerData()
    PlayerJob = PlayerData.job
    Citizenid = PlayerData.citizenid
end)

CreateThread(function()
    while true do
		local pl = GetEntityCoords(PlayerPedId())
		if #(pl - vector3(Config.ParkingLocation.x, Config.ParkingLocation.y, Config.ParkingLocation.z)) < Config.ParkingLocation.s then
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
		Wait(0)
    end
end)

CreateThread(function()
    if UseParkingSystem then
		while true do
			local player = PlayerPedId()
			if inParking and IsPedInAnyVehicle(player) then
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
						storedVehicle = nil
					else
						if vehicle ~= 0 then
							if GetEntitySpeed(vehicle) > 0 then
								QBCore.Functions.Notify(Lang:t("info.stop_car"), "primary", 5000)
							elseif IsAllowToPark(Citizenid) then
								if IsThisModelACar(GetEntityModel(vehicle)) or IsThisModelABike(GetEntityModel(vehicle)) or IsThisModelABicycle(GetEntityModel(vehicle)) then
									Save(player, vehicle)
								else
									QBCore.Functions.Notify(Lang:t("info.only_cars_allowd"), "primary", 5000)
								end	
								player = nil								
							else
								QBCore.Functions.Notify(Lang:t("system.no_permission"), "error", 5000)
							end
						end
						vehicle = nil
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
    while true do
        DisplayParkedOwnerText()
        Wait(0)
    end
end)
