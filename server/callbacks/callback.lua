-- Save the car to database
QBCore.Functions.CreateCallback("qb-parking:server:save", function(source, cb, vehicleData)

	if UseParkingSystem then
		local src     = source
		local Player  = QBCore.Functions.GetPlayer(src)

		if IsAllowToPark(Player.PlayerData.citizenid) then
			local plate   = vehicleData.plate
			local isFound = false
			FindPlayerVehicles(Player.PlayerData.citizenid, function(vehicles)
				for k, v in pairs(vehicles) do
					if type(v.plate) ~= 'nil' and plate == v.plate then
						isFound = true
					end		
				end
				if GetVehicleNumOfParking(vehicleData.parking) > Config.Maxcarparking then
					cb({
						status  = false,
						message = Lang:t("maximum_cars", {value = Config.Maxcarparking}),
					})
				elseif isFound then
					MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE citizenid = @citizenid AND plate = @plate", {
						['@citizenid'] = Player.PlayerData.citizenid,
						['@plate']     = plate
					}, function(rs)
						if type(rs) == 'table' and #rs > 0 then
							cb({
								status  = false,
								message = Lang:t("info.car_already_parked", {}),
							})
						else
							SaveParkingCar(vehicleData, vehicleData.model, plate, Player.PlayerData)
							cb({ 
								status  = true, 
								message = Lang:t("success.parked",{}) ,
							})
							Wait(100)
							TriggerClientEvent("qb-parking:client:addVehicle", -1, {
								vehicle     = vehicleData,
								plate       = plate, 
								citizenid   = Player.PlayerData.citizenid, 
								citizenname = Player.PlayerData.name,
								model       = vehicleData.model,
							})
						end
					end)
				else
					cb({
						status  = false,
						message = Lang:t("info.must_own_car"),
					})
				end
			end)
		else
			cb({
				status  = false,
				message = "You are not allows to use the park system",
			})
		end
	else 
		cb({
			status  = false,
			message = "Park Systen is disable",
		})
	end
end)

-- When player request to drive the car
QBCore.Functions.CreateCallback("qb-parking:server:drive", function(source, cb, vehicleData)

	if UseParkingSystem then
		local src     = source
		local Player  = QBCore.Functions.GetPlayer(src)

		if IsAllowToPark(Player.PlayerData.citizenid) then
			local plate   = vehicleData.plate
			local isFound = false
			FindPlayerVehicles(Player.PlayerData.citizenid, function(vehicles)
				for k, v in pairs(vehicles) do
					if type(v.plate) ~= 'nil' and plate == v.plate then
						isFound = true
					end		
				end
				if isFound then
					MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE citizenid = @citizenid AND plate = @plate", {
						['@citizenid'] = Player.PlayerData.citizenid,
						['@plate']     = plate
					}, function(rs)
						if type(rs) == 'table' and #rs > 0 and rs[1] ~= nil then
							RestoreParkingCar(plate, Player.PlayerData)
							cb({
								status  = true,
								message = Lang:t("info.has_take_the_car"),
								data    = json.decode(rs[1].data),
							})
							TriggerClientEvent("qb-parking:client:deleteVehicle", -1, { plate = plate })
						end
					end)
				else
					cb({
						status  = false,
						message = Lang:t("info.must_own_car"),
					})
				end
			end)
		else
			cb({
				status  = false,
				message = "You are not allows to use the park system",
			})
		end
	else 
		cb({
			status  = false,
			message = "Park Systen is disable",
		})
	end
end)

-- When the police impound the car, support for esx_policejob
QBCore.Functions.CreateCallback("qb-parking:server:impound", function(source, cb, vehicleData)
	local src     = source
    local Player  = QBCore.Functions.GetPlayer(src)
    local plate   = vehicleData.plate
	MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE plate = @plate", {
		['@plate'] = plate
	}, 	function(rs)
		if type(rs) == 'table' and #rs > 0 and rs[1] ~= nil then
			print("Police impound the vehicle: ", vehicleData.plate, rs[1].citizenid)
			SaveToImpound(plate, rs[1].citizenid)
			cb({ status  = true })
			TriggerClientEvent("qb-parking:client:deleteVehicle", -1, { plate = plate })
		else
			cb({
				status  = false,
				message = Lang:t("info.car_not_found", {}),
			})
			print(Lang:t("error"))
		end
	end)
end)