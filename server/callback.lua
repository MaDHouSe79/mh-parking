-- Save the car to database.
QBCore.Functions.CreateCallback("qb-parking:server:save", function(source, cb, vehicleData)
    if UseParkingSystem then
		local src     = source
		local Player  = QBCore.Functions.GetPlayer(src)
		if IsAllowToPark(Player.PlayerData.citizenid) then
			local plate   = vehicleData.plate
			local fuellvl = 0
			local isFound = false
			FindPlayerVehicles(Player.PlayerData.citizenid, function(vehicles)
				for k, v in pairs(vehicles) do
					if type(v.plate) ~= 'nil' and plate == v.plate then
						fuellvl = v.fuel
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
								message = Lang:t("info.car_already_parked"),
							})
						else
							MySQL.Async.execute('DELETE FROM player_parking WHERE plate = @plate AND citizenid = @citizenid', {
								["@plate"]     = plate,
								["@citizenid"] = Player.PlayerData.citizenid
    							})
    							MySQL.Async.execute('UPDATE player_vehicles SET state = 2 WHERE plate = @plate AND citizenid = @citizenid', {
								["@plate"]     = plate,
								["@citizenid"] = Player.PlayerData.citizenid
   							})
							cb({ 
								status  = true, 
								message = Lang:t("success.parked"),
							})
							Wait(100)
							TriggerClientEvent("qb-parking:client:addVehicle", -1, {
								vehicle     = vehicleData,
								plate       = plate, 
								fuel        = fuellvl,
								citizenid   = Player.PlayerData.citizenid, 
								citizenname = GetPlayerName(Player),
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
				message = Lang:t("system.no_permission"),
			})
		end
    else 
		cb({
			status  = false,
			message = Lang:t("system.offline"),
		})
    end
end)

-- When player request to drive the car.
QBCore.Functions.CreateCallback("qb-parking:server:drive", function(source, cb, vehicleData)
    if UseParkingSystem then
		local src     = source
		local Player  = QBCore.Functions.GetPlayer(src)
		if IsAllowToPark(Player.PlayerData.citizenid) then
			local plate   = vehicleData.plate
			local fuellvl = 0
			local isFound = false
			FindPlayerVehicles(Player.PlayerData.citizenid, function(vehicles)
				for k, v in pairs(vehicles) do
					if type(v.plate) ~= 'nil' and plate == v.plate then
						fuellvl = v.fuel
						isFound = true
					end
				end
				if isFound then
					MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE citizenid = @citizenid AND plate = @plate", {
						['@citizenid'] = Player.PlayerData.citizenid,
						['@plate']     = plate
					}, function(rs)
						if type(rs) == 'table' and #rs > 0 and rs[1] ~= nil then
							MySQL.Async.execute('DELETE FROM player_parking WHERE plate = @plate AND citizenid = @citizenid', {
								["@plate"]     = plate,
								["@citizenid"] = Player.PlayerData.citizenid
						        })
						        MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = @plate AND citizenid = @citizenid', {
								["@plate"]     = plate,
								["@citizenid"] = Player.PlayerData.citizenid
						        })
							cb({
								status  = true,
								message = Lang:t("info.has_take_the_car"),
								fuel    = fuellvl,
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
				message = Lang:t("system.no_permission"),
			})
		end
        else 
		cb({
			status  = false,
			message = Lang:t("system.offline"),
		})
        end
end)

-- When the police impound the car
QBCore.Functions.CreateCallback("qb-parking:server:impound", function(source, cb, vehicleData)
    local src     = source
    local plate   = vehicleData.plate
    MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE plate = @plate", {
		['@plate'] = plate
    }, function(rs)
		if type(rs) == 'table' and #rs > 0 and rs[1] ~= nil then
			print("Police impound the vehicle: ", vehicleData.plate, rs[1].citizenid)
			MySQL.Async.execute('DELETE FROM player_parking WHERE plate = @plate AND citizenid = @citizenid', {
				["@plate"]     = plate,
				["@citizenid"] = rs[1].citizenid
			})
			MySQL.Async.execute('UPDATE player_vehicles SET state = 2 WHERE plate = @plate AND citizenid = @citizenid', {
				["@plate"]     = plate,
				["@citizenid"] = rs[1].citizenid
			})
			cb({ status  = true })
			TriggerClientEvent("qb-parking:client:deleteVehicle", -1, { plate = plate })
		else
			cb({
				status  = false,
				message = Lang:t("info.car_not_found"),
			})
			print(Lang:t("error"))
		end
        end)
end)


-- When a vehicle gets stolen by other player. We need this to unpark the vehicle.
QBCore.Functions.CreateCallback("qb-parking:server:stolen", function(source, cb, vehicleData)
    local src     = source
    local plate   = vehicleData.plate
    MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE plate = @plate", {
		['@plate'] = plate
    }, function(rs)
		if type(rs) == 'table' and #rs > 0 and rs[1] ~= nil then
			print("A Player has stolen a vehicle: ", vehicleData.plate, rs[1].citizenid)
			MySQL.Async.execute('DELETE FROM player_parking WHERE plate = @plate', {
				["@plate"]     = plate,
				["@citizenid"] = rs[1].citizenid
			})
			MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = @plate', {
				["@plate"]     = plate,
				["@citizenid"] = rs[1].citizenid
			})
			cb({ status  = true })
			TriggerClientEvent("qb-parking:client:deleteVehicle", -1, { plate = plate })
		else
			cb({
				status  = false,
				message = Lang:t("info.car_not_found"),
			})
			print(Lang:t("error"))
		end
        end)
end)
