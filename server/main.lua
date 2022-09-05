local QBCore      = exports['qb-core']:GetCoreObject()
local updateavail = false

-- Get Player username
local function GetUsername(player)
	local tmpName = player.PlayerData.name
	if Config.useRoleplayName then
		tmpName = player.PlayerData.charinfo.firstname ..' '.. player.PlayerData.charinfo.lastname
	end
    return tmpName
end

-- Get Citizenid
local function GetCitizenid(player)
	return player.PlayerData.citizenid
end

-- Get all vehicles the player owned.
local function FindPlayerVehicles(citizenid, cb)
    local vehicles = {}
    MySQL.Async.fetchAll("SELECT * FROM player_vehicles WHERE citizenid = @citizenid", {['@citizenid'] = citizenid}, function(rs)
        for k, v in pairs(rs) do
			vehicles[#vehicles+1] = {plate = v.plate}
        end
        cb(vehicles)
    end)
end

-- Get the number of the vehicles.
local function GetVehicleNumOfParking()
    local rs = MySQL.Async.fetchAll('SELECT id FROM player_parking', {})
    if type(rs) == 'table' then
        return #rs
    else
        return 0
    end
end

-- Refresh client local vehicles entities.
local function RefreshVehicles(src)
    if src == nil then src = -1 end
        local vehicles = {}
        MySQL.Async.fetchAll("SELECT * FROM player_parking", {}, function(rs)
        if type(rs) == 'table' and #rs > 0 then
            for k, v in pairs(rs) do
                vehicles[#vehicles+1] = {
                    vehicle     = json.decode(v.data),
                    plate       = v.plate,
                    citizenid   = v.citizenid,
                    citizenname = v.citizenname,
                    model       = v.model,
					fuel        = v.fuel,
					oil         = v.oil,
                }
				TriggerClientEvent('mh-parking:client:addkey', src, v.plate, v.citizenid)
            end
            TriggerClientEvent("mh-parking:client:refreshVehicles", src, vehicles)
        end
    end)
end

local function SaveData(Player, vehicleData)
	MySQL.Async.execute("INSERT INTO player_parking (citizenid, citizenname, plate, fuel, oil, model, data, time) VALUES (@citizenid, @citizenname, @plate, @fuel, @oil, @model, @data, @time)", {
		["@citizenid"]   = GetCitizenid(Player),
		["@citizenname"] = GetUsername(Player),
		["@plate"]       = vehicleData.plate,
		["@fuel"]        = vehicleData.fuel,
		["@oil"]         = vehicleData.oil,
		['@model']       = vehicleData.model,
		["@data"]        = json.encode(vehicleData),
		["@time"]        = os.time(),
	})
	MySQL.Async.execute('UPDATE player_vehicles SET state = 3 WHERE plate = @plate AND citizenid = @citizenid', {
		["@plate"]       = vehicleData.plate,
		["@citizenid"]   = GetCitizenid(Player)
	})
	TriggerClientEvent("mh-parking:client:addVehicle", -1, {
		vehicle     = vehicleData,
		plate       = vehicleData.plate, 
		fuel        = vehicleData.fuel,
		oil         = vehicleData.oil,
		citizenid   = GetCitizenid(Player), 
		citizenname = GetUsername(Player),
		model       = vehicleData.model,
	})
end

-- Save the car to database
QBCore.Functions.CreateCallback("mh-parking:server:save", function(source, cb, vehicleData)
    if UseParkingSystem then
		local src     = source
		local Player  = QBCore.Functions.GetPlayer(src)
		local plate   = vehicleData.plate
		local isFound = false
		FindPlayerVehicles(GetCitizenid(Player), function(vehicles) -- free for all
			for k, v in pairs(vehicles) do
				if type(v.plate) and plate == v.plate then
					isFound = true
				end		
			end
			if isFound then
				MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE citizenid = @citizenid AND plate = @plate", {
					['@citizenid'] = GetCitizenid(Player),
					['@plate']     = plate
				}, function(rs)
					if type(rs) == 'table' and #rs > 0 then
						cb({
							status  = false,
							message = Lang:t("info.car_already_parked"),
						})
					else
						if #rs < Config.Maxcarparking then
							SaveData(Player, vehicleData)
							cb({ 
								status  = true, 
								message = Lang:t("success.parked"),
							})
						else 
							cb({ 
								status  = true, 
								message = Lang:t("info.maximum_cars", {value = Config.Maxcarparking}),
							})
						end
					end
				end)	
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
QBCore.Functions.CreateCallback("mh-parking:server:drive", function(source, cb, vehicleData)
    if UseParkingSystem then
		local src = source
		local Player = QBCore.Functions.GetPlayer(src)
		local plate = vehicleData.plate
		local isFound = false
		FindPlayerVehicles(GetCitizenid(Player), function(vehicles)
			for k, v in pairs(vehicles) do
				if type(v.plate) and plate == v.plate then
					isFound = true
				end
			end
			if isFound then
				MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE citizenid = @citizenid AND plate = @plate", {
					['@citizenid'] = GetCitizenid(Player),
					['@plate'] = plate
				}, function(rs)
					if type(rs) == 'table' and #rs > 0 and rs[1] then
						MySQL.Async.execute('DELETE FROM player_parking WHERE plate = @plate AND citizenid = @citizenid', {
							["@plate"] = plate,
							["@citizenid"] = GetCitizenid(Player)
						})
						MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = @plate AND citizenid = @citizenid', {
							["@plate"] = plate,
							["@citizenid"] = GetCitizenid(Player)
						})
						cb({
							status  = true,
							message = Lang:t("info.has_take_the_car"),
							data    = json.decode(rs[1].data),
							fuel    = rs[1].fuel,
						})
						TriggerClientEvent("mh-parking:client:deleteVehicle", -1, { plate = plate })
					end
				end)			
			end
		end)
    else 
		cb({
			status  = false,
			message = Lang:t("system.offline"),
		})
    end
end)

QBCore.Functions.CreateCallback("mh-parking:server:vehicle_action", function(source, cb, plate, action)
    MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE plate = @plate", {
		['@plate'] = plate
    }, function(rs)
		if type(rs) == 'table' and #rs > 0 and rs[1] then
			
			MySQL.Async.execute('DELETE FROM player_parking WHERE plate = @plate', {
				["@plate"] = plate,
			})

			if action == 'impound' then
				MySQL.Async.execute('UPDATE player_vehicles SET state = 2, garage = @garage WHERE plate = @plate AND citizenid = @citizenid', {
					["@plate"]     = plate,
					["@citizenid"] = rs[1].citizenid,
					["@garage"]    = 'impoundlot',
				})
			else
				MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = @plate', {
					["@plate"] = plate,
				})
			end
			cb({ status  = true })
			TriggerClientEvent("mh-parking:client:deleteVehicle", -1, { plate = plate })
		else
			cb({
				status  = false,
				message = Lang:t("info.car_not_found"),
			})
		end
    end)
end)

-- Reset state and counting to stay in sync.
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(2000)
		print("[mh-parking] - parked vehicles state check reset.")
		MySQL.Async.fetchAll("SELECT * FROM player_vehicles WHERE state = 0 OR state = 1 OR state = 2", {
		}, function(vehicles)
			if type(vehicles) == 'table' and #vehicles > 0 then
				for _, vehicle in pairs(vehicles) do
					MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE plate = @plate", {
						['@plate'] = vehicle.plate
					}, function(rs)
						if type(rs) == 'table' and #rs > 0 then
							for _, v in pairs(rs) do
								MySQL.Async.execute('DELETE FROM player_parking WHERE plate = @plate', {["@plate"] = vehicle.plate})
								MySQL.Async.execute('UPDATE player_vehicles SET state = @state WHERE plate = @plate', {["@state"] = Config.ResetState, ["@plate"] = vehicle.plate})					
							end
						end
					end)
				end
			end
		end)
    end
end)

-- When the client request to refresh the vehicles.
RegisterServerEvent('mh-parking:server:unpark', function(plate)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	MySQL.Async.execute('DELETE FROM player_parking WHERE plate = ?', {plate})
	MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = ?', {plate})
	TriggerClientEvent("mh-parking:client:deleteVehicle", -1, { plate = plate, deleteEntity = true })
end)

RegisterServerEvent('mh-parking:server:onjoin', function(id, citizenid)
    MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE citizenid = ?", {citizenid}, function(vehicles)
        for k, v in pairs(vehicles) do
            if v.citizenid == citizenid then
                TriggerClientEvent('mh-parking:client:addkey', id, v.plate, v.citizenid)
            end
        end
    end)
end)

-- When the client request to refresh the vehicles.
RegisterServerEvent('mh-parking:server:refreshVehicles', function(parkingName)
    RefreshVehicles(source)
end)
