local QBCore = exports['qb-core']:GetCoreObject()
local serverSystem = ParkServer()

------------------------------------------Server Event------------------------------------------
-- When the client request to refresh the vehicles.
RegisterServerEvent('qb-parking:server:refreshVehicles', function(parkingName)
    serverSystem.RefreshVehicles(source)
end)

-------------------------------------------Call Backs--------------------------------------------
-- Save the car to database
QBCore.Functions.CreateCallback("qb-parking:server:save", function(source, cb, vehicleData)
    if UseParkingSystem then
		local src     = source
		local Player  = QBCore.Functions.GetPlayer(src)
		local plate   = vehicleData.plate
		MySQL.Async.fetchAll("SELECT * FROM player_parking_vips WHERE citizenid = @citizenid", {
			['@citizenid'] = serverSystem.GetCitizenid(Player),
		}, function(rs)
			if type(rs) == 'table' and #rs > 0 then
				local hasparked = rs[1].hasparked
				if hasparked < 0 then hasparked = 1 end
				if hasparked < rs[1].maxparking then
					serverSystem.FindPlayerVehicles(serverSystem.GetCitizenid(Player), function(vehicles)
						if serverSystem.FindVehicle(plate, vehicles) then
							MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE citizenid = @citizenid AND plate = @plate", {
								['@citizenid'] = serverSystem.GetCitizenid(Player),
								['@plate']     = plate
							}, function(rs)
								if type(rs) == 'table' and #rs > 0 then
									cb({
										status  = false,
										message = Lang:t("info.car_already_parked"),
									})
								else
									MySQL.Async.execute("INSERT INTO player_parking (citizenid, citizenname, plate, model, data, time) VALUES (@citizenid, @citizenname, @plate, @model, @data, @time)", {
										["@citizenid"]   = serverSystem.GetCitizenid(Player),
										["@citizenname"] = serverSystem.GetUsername(Player),
										["@plate"]       = plate,
										['@model']       = vehicleData.model,
										["@data"]        = json.encode(vehicleData),
										["@time"]        = os.time(),
									})
									MySQL.Async.execute('UPDATE player_vehicles SET state = 3 WHERE plate = @plate AND citizenid = @citizenid', {
										["@plate"]       = plate,
										["@citizenid"]   = serverSystem.GetCitizenid(Player)
									})
									MySQL.Async.execute('UPDATE player_parking_vips SET hasparked = hasparked + 1 WHERE citizenid = @citizenid', {
										["@citizenid"] = serverSystem.GetCitizenid(Player)
									})
									cb({ 
										status  = true, 
										message = Lang:t("success.parked"),
									})
									TriggerClientEvent("qb-parking:client:addVehicle", -1, {
										vehicle     = vehicleData,
										plate       = plate, 
										citizenid   = serverSystem.GetCitizenid(Player), 
										citizenname = serverSystem.GetUsername(Player),
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
						message = Lang:t("system.max_allow_reached", { max = rs[1].maxparking}),
					})
				end
			else
				cb({
					status  = false,
					message = Lang:t("system.no_permission"),
				})
			end
		end)
	else 
		cb({
			status  = false,
			message = Lang:t("system.offline"),
		})
    end
end)

-- When player request to drive the car
QBCore.Functions.CreateCallback("qb-parking:server:drive", function(source, cb, vehicleData)
	local src     = source
	local Player  = QBCore.Functions.GetPlayer(src)
	local plate   = vehicleData.plate
	local isFound = false
	serverSystem.FindPlayerVehicles(serverSystem.GetCitizenid(Player), function(vehicles)
		if serverSystem.FindVehicle(plate, vehicles) then
			MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE citizenid = @citizenid AND plate = @plate", {
				['@citizenid'] = serverSystem.GetCitizenid(Player),
				['@plate']     = plate
			}, function(rs)
				if type(rs) == 'table' and #rs > 0 and rs[1] then
					MySQL.Async.execute('DELETE FROM player_parking WHERE plate = @plate AND citizenid = @citizenid', {
						["@plate"]     = plate,
						["@citizenid"] = serverSystem.GetCitizenid(Player)
					})
					MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = @plate AND citizenid = @citizenid', {
						["@plate"]     = plate,
						["@citizenid"] = serverSystem.GetCitizenid(Player)
					})
					MySQL.Async.fetchAll("SELECT * FROM player_parking_vips WHERE citizenid = @citizenid", {
						['@citizenid'] = serverSystem.GetCitizenid(Player),
					}, function(rs)
						if type(rs) == 'table' and #rs > 0 then
							local hasparked = rs[1].hasparked - 1
							if hasparked < 0 then hasparked = 0 end
							MySQL.Async.execute('UPDATE player_parking_vips SET hasparked = @hasparked WHERE citizenid = @citizenid', {
								["@citizenid"] = serverSystem.GetCitizenid(Player),
								["@hasparked"] = hasparked
							})
						end
					end)
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
end)

-- When the police impound the car
QBCore.Functions.CreateCallback("qb-parking:server:impound", function(source, cb, vehicleData)
    local src   = source
    local plate = vehicleData.plate
    MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE plate = @plate", {
		['@plate'] = plate
    }, function(rs)
		if type(rs) == 'table' and #rs > 0 and rs[1] then
			print("Police impound the vehicle: ", vehicleData.plate, rs[1].citizenid)
			MySQL.Async.execute('DELETE FROM player_parking WHERE plate = @plate AND citizenid = @citizenid', {
				["@plate"]     = plate,
				["@citizenid"] = rs[1].citizenid
			})
			MySQL.Async.execute('UPDATE player_vehicles SET state = 2 WHERE plate = @plate AND citizenid = @citizenid', {
			    ["@plate"]     = plate,
				["@citizenid"] = rs[1].citizenid
			})
			MySQL.Async.execute('UPDATE player_parking_vips SET hasparked = hasparked - 1 WHERE citizenid = @citizenid', {
				["@citizenid"] = rs[1].citizenid
			})
			cb({ status = true })
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

-- When vehicle gets stolen by other player
QBCore.Functions.CreateCallback("qb-parking:server:stolen", function(source, cb, vehicleData)
    local src    = source
    local plate  = vehicleData.plate
    MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE plate = @plate", {
		['@plate'] = plate
    }, function(rs)
		if type(rs) == 'table' and #rs > 0 and rs[1] then
			print("Someone stole this vehicle: ", vehicleData.plate, rs[1].citizenid)
			MySQL.Async.execute('DELETE FROM player_parking WHERE plate = @plate', {
				["@plate"] = plate,
			})
			MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = @plate', {
				["@plate"] = plate,
			})
			MySQL.Async.execute('UPDATE player_parking_vips SET hasparked = hasparked - 1 WHERE citizenid = @citizenid', {
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

----------------------------------------------Server Admin Commands---------------------------------------------
QBCore.Commands.Add(Config.Command.addvip, Lang:t("commands.addvip"), {{name='ID', help='The id of the player you want to add.'}, {name='Amount', help='The max vehicles amount a player can park'}}, true, function(source, args)
	if args[1] and tonumber(args[1]) > 0 then
		local amount = 0 
		if args[2] and tonumber(args[2]) > 0 then
			amount = args[2]
		end
		MySQL.Async.fetchAll("SELECT * FROM player_parking_vips WHERE citizenid = @citizenid", {
			['@citizenid'] = serverSystem.GetCitizenid(QBCore.Functions.GetPlayer(tonumber(args[1]))),
		}, function(rs)
			if type(rs) == 'table' and #rs > 0 then
				TriggerClientEvent('QBCore:Notify', source, Lang:t('system.already_vip'), "error")
			else
				MySQL.Async.execute("INSERT INTO player_parking_vips (citizenid, citizenname, maxparking) VALUES (@citizenid, @citizenname, @maxparking)", {
					["@citizenid"]   = serverSystem.GetCitizenid(QBCore.Functions.GetPlayer(tonumber(args[1]))),
					["@citizenname"] = serverSystem.GetUsername(QBCore.Functions.GetPlayer(tonumber(args[1]))),
					["@maxparking"]  = amount 
				})
				TriggerClientEvent('QBCore:Notify', source, Lang:t('system.vip_add', {username = serverSystem.GetUsername(QBCore.Functions.GetPlayer(tonumber(args[1])))}), "success")
			end
		end)
	end
end, 'admin')

QBCore.Commands.Add(Config.Command.removevip, Lang:t("commands.removevip"), {{name='ID', help='The id of the player you want to remove.'}}, true, function(source, args)
	if args[1] and tonumber(args[1]) > 0 then
		MySQL.Async.fetchAll("SELECT * FROM player_parking_vips WHERE citizenid = @citizenid", {
			['@citizenid'] = serverSystem.GetCitizenid(QBCore.Functions.GetPlayer(tonumber(args[1]))),
		}, function(rs)
			if type(rs) == 'table' and #rs > 0 then
				MySQL.Async.execute('DELETE FROM player_parking_vips WHERE citizenid = @citizenid', {
					["@citizenid"] = serverSystem.GetCitizenid(QBCore.Functions.GetPlayer(tonumber(args[1]))),
				})
				TriggerClientEvent('QBCore:Notify', source, Lang:t('system.vip_remove', {username = serverSystem.GetUsername(QBCore.Functions.GetPlayer(tonumber(args[1])))}), "success")
			else
				TriggerClientEvent('QBCore:Notify', source, Lang:t('system.vip_not_found'), "error")
			end
		end)
	end
end, 'admin')

QBCore.Commands.Add(Config.Command.system, "Park System On/Off", {}, false, function(source, args)
	if args[1] == "On" then
		UseParkingSystem = true
	else
		UseParkingSystem = false
	end
	if UseParkingSystem then
		TriggerClientEvent('QBCore:Notify', source, Lang:t('system.enable', {type = "system"}), "success")
	else
		TriggerClientEvent('QBCore:Notify', source, Lang:t('system.disable', {type = "system"}), "error")
	end
end, 'admin')

----------------------------------------------Update Check---------------------------------------------
local function checkVersion(err, responseText, headers)
    serverSystem.CheckVersion(err, responseText, headers)
end

if Config.CheckForUpdates then
    Citizen.CreateThread( function()
        updatePath   = "/MaDHouSe79/qb-parking"
        resourceName = "qb-parking ("..GetCurrentResourceName()..")"
        PerformHttpRequest("https://raw.githubusercontent.com"..updatePath.."/master/version", checkVersion, "GET")
    end)
end
