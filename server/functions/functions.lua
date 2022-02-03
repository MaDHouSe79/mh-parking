-- Save the car to database.
function SaveParkingCar(vehicleData, model, plate, PlayerData)
    local playerName = PlayerData.name
    if Config.useRoleplayName then
		playerName = PlayerData.charinfo.firstname ..' '.. PlayerData.charinfo.lastname
    end
    MySQL.Async.execute("INSERT INTO player_parking (citizenid, citizenname, plate, model, data, time) VALUES (@citizenid, @citizenname, @plate, @model, @data, @time)", {
		["@citizenid"]   = PlayerData.citizenid,
		["@citizenname"] = playerName,
		["@plate"]       = plate,
		['@model']       = model,
		["@data"]        = json.encode(vehicleData),
		["@time"]        = os.time(),
    })
    MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = @plate AND citizenid = @citizenid', {
		["@plate"]       = plate,
		["@citizenid"]   = PlayerData.citizenid
    })
end

-- When player request to drive the car.
function RestoreParkingCar(plate, PlayerData)
    MySQL.Async.execute('DELETE FROM player_parking WHERE plate = @plate AND citizenid = @citizenid', {
		["@plate"]     = plate,
		["@citizenid"] = PlayerData.citizenid
    })
    MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = @plate AND citizenid = @citizenid', {
		["@plate"]     = plate,
		["@citizenid"] = PlayerData.citizenid
    })
end

-- When the police impound the car, support for esx_policejob.
function SaveToImpound(plate, citizenid)
    MySQL.Async.execute('DELETE FROM player_parking WHERE plate = @plate AND citizenid = @citizenid', {
		["@plate"]     = plate,
		["@citizenid"] = citizenid
    })
    MySQL.Async.execute('UPDATE player_vehicles SET state = 2 WHERE plate = @plate AND citizenid = @citizenid', {
		["@plate"]     = plate,
		["@citizenid"] = citizenid
    })
end

-- Get all vehicles the player owned.
function FindPlayerVehicles(citizenid, cb)
    local vehicles = {}
    MySQL.Async.fetchAll("SELECT * FROM player_vehicles WHERE citizenid = @citizenid", {['@citizenid'] = citizenid}, function(rs)
		for k, v in pairs(rs) do
			table.insert(vehicles, {
				vehicle = json.decode(v.data),
				plate   = v.plate,
				model   = v.model,
			})
		end
		cb(vehicles)
    end)
end

-- Get the number of the vehicles.
function GetVehicleNumOfParking()
    local rs = MySQL.Async.fetchAll('SELECT id FROM player_parking', {})
    if type(rs) == 'table' then
		return #rs
    else
		return 0
    end
end

-- Refresh client local vehicles entities.
function RefreshVehicles(src)
    if src == nil then src = -1 end
    local vehicles = {}
    MySQL.Async.fetchAll("SELECT * FROM player_parking", {}, function(rs)
		if type(rs) == 'table' and #rs > 0 then
			for k, v in pairs(rs) do
				table.insert(vehicles, {
					vehicle     = json.decode(v.data),
					plate       = v.plate,
					citizenid   = v.citizenid,
					citizenname = v.citizenname,
					model       = v.model,
				})
				if QBCore.Functions.GetPlayer(src) ~= nil and QBCore.Functions.GetPlayer(src).PlayerData.citizenid == v.citizenid then
					TriggerClientEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlayer(src), v.plate)
				end
			end
			TriggerClientEvent("qb-parking:client:refreshVehicles", src, vehicles)
		end
    end)
end
