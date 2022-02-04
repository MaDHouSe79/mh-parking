local QBCore = exports['qb-core']:GetCoreObject()
local updateavail = false

-------------------------------------------Local Function----------------------------------------

-- Get all vehicles the player owned.
local function FindPlayerVehicles(citizenid, cb)
    local vehicles = {}
    MySQL.Async.fetchAll("SELECT * FROM player_vehicles WHERE citizenid = @citizenid", {['@citizenid'] = citizenid}, function(rs)
        for k, v in pairs(rs) do
            vehicles[#vehicles+1] = {
                vehicle = json.decode(v.data),
                plate   = v.plate,
                model   = v.model,
            }
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
                }
                if QBCore.Functions.GetPlayer(src) ~= nil and QBCore.Functions.GetPlayer(src).PlayerData.citizenid == v.citizenid then
                    if not Config.ImUsingOtherKeyScript then
                        TriggerClientEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlayer(src), v.plate)
                    end
                end
            end
            TriggerClientEvent("qb-parking:client:refreshVehicles", src, vehicles)
        end
    end)
end

local function checkVersion(err, responseText, headers)
    curVersion = LoadResourceFile(GetCurrentResourceName(), "version")
    if responseText == nil then
        print("^1"..resourceName.." check for updates failed ^7")
        return
    end
    if curVersion ~= responseText and tonumber(curVersion) < tonumber(responseText) then
        updateavail = true
        print("\n^1----------------------------------------------------------------------------------^7")
        print(resourceName.." is outdated, latest version is: ^2"..responseText.."^7, installed version: ^1"..curVersion.."^7!\nupdate from https://github.com"..updatePath.."")
        print("^1----------------------------------------------------------------------------------^7")
    elseif tonumber(curVersion) > tonumber(responseText) then
        print("\n^3----------------------------------------------------------------------------------^7")
        print(resourceName.." git version is: ^2"..responseText.."^7, installed version: ^1"..curVersion.."^7!")
        print("^3----------------------------------------------------------------------------------^7")
    else
        print("\n"..resourceName.." is up to date. (^2"..curVersion.."^7)")
    end
end
-------------------------------------------------------------------------------------------------



--------------------------------------------Callbacks--------------------------------------------

-- Save the car to database
QBCore.Functions.CreateCallback("qb-parking:server:save", function(source, cb, vehicleData)
    if UseParkingSystem then
		local src     = source
		local Player  = QBCore.Functions.GetPlayer(src)
		local plate   = vehicleData.plate
		local isFound = false
		MySQL.Async.fetchAll("SELECT * FROM player_parking_vips WHERE citizenid = @citizenid", {
			['@citizenid'] = Player.PlayerData.citizenid,
		}, function(rs)
			if type(rs) == 'table' and #rs > 0 then
				FindPlayerVehicles(Player.PlayerData.citizenid, function(vehicles)
					for k, v in pairs(vehicles) do
						if type(v.plate) and plate == v.plate then
						isFound = true
						end		
					end
					if isFound then
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
								MySQL.Async.execute("INSERT INTO player_parking (citizenid, citizenname, plate, model, data, time) VALUES (@citizenid, @citizenname, @plate, @model, @data, @time)", {
									["@citizenid"]   = Player.PlayerData.citizenid,
									["@citizenname"] = GetUsername(Player),
									["@plate"]       = plate,
									['@model']       = vehicleData.model,
									["@data"]        = json.encode(vehicleData),
									["@time"]        = os.time(),
								})
								MySQL.Async.execute('UPDATE player_vehicles SET state = 3 WHERE plate = @plate AND citizenid = @citizenid', {
									["@plate"]       = plate,
									["@citizenid"]   = Player.PlayerData.citizenid
								})
								cb({ 
									status  = true, 
									message = Lang:t("success.parked"),
								})
								--Wait(10)
								TriggerClientEvent("qb-parking:client:addVehicle", -1, {
									vehicle     = vehicleData,
									plate       = plate, 
									citizenid   = Player.PlayerData.citizenid, 
									citizenname = GetUsername(Player),
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
    if UseParkingSystem then
		local src = source
		local Player = QBCore.Functions.GetPlayer(src)
		local plate = vehicleData.plate
		local isFound = false
		FindPlayerVehicles(Player.PlayerData.citizenid, function(vehicles)
			for k, v in pairs(vehicles) do
				if type(v.plate) and plate == v.plate then
					isFound = true
				end
			end
			if isFound then
				MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE citizenid = @citizenid AND plate = @plate", {
					['@citizenid'] = Player.PlayerData.citizenid,
					['@plate'] = plate
				}, function(rs)
					if type(rs) == 'table' and #rs > 0 and rs[1] then
						MySQL.Async.execute('DELETE FROM player_parking WHERE plate = @plate AND citizenid = @citizenid', {
							["@plate"] = plate,
							["@citizenid"] = Player.PlayerData.citizenid
						})
						MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = @plate AND citizenid = @citizenid', {
						    ["@plate"] = plate,
						    ["@citizenid"] = Player.PlayerData.citizenid
						})
						cb({
							status = true,
							message = Lang:t("info.has_take_the_car"),
							data = json.decode(rs[1].data),
						})
						TriggerClientEvent("qb-parking:client:deleteVehicle", -1, { plate = plate })
					end
				end)
			else
				cb({
					status = false,
					message = Lang:t("info.must_own_car"),
				})
			end
		end)
    else 
		cb({
			status = false,
			message = Lang:t("system.offline"),
		})
    end
end)

-- When the police impound the car
QBCore.Functions.CreateCallback("qb-parking:server:impound", function(source, cb, vehicleData)
    local src = source
    local plate = vehicleData.plate
    MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE plate = @plate", {
		['@plate'] = plate
    }, function(rs)
		if type(rs) == 'table' and #rs > 0 and rs[1] then
			print("Police impound the vehicle: ", vehicleData.plate, rs[1].citizenid)
			MySQL.Async.execute('DELETE FROM player_parking WHERE plate = @plate AND citizenid = @citizenid', {
				["@plate"] = plate,
				["@citizenid"] = rs[1].citizenid
			})
			MySQL.Async.execute('UPDATE player_vehicles SET state = 2 WHERE plate = @plate AND citizenid = @citizenid', {
			    ["@plate"] = plate,
				["@citizenid"] = rs[1].citizenid
			})
			cb({ status = true })
			TriggerClientEvent("qb-parking:client:deleteVehicle", -1, { plate = plate })
		else
			cb({
				status = false,
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
			print("SOmeone stole this vehicle: ", vehicleData.plate, rs[1].citizenid)
			MySQL.Async.execute('DELETE FROM player_parking WHERE plate = @plate', {
				["@plate"] = plate,
			})
			MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = @plate', {
				["@plate"] = plate,
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


-- Save vip player to database
QBCore.Functions.CreateCallback("qb-parking:server:AddVip", function(source, cb, id)
	for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local player = QBCore.Functions.GetPlayer(v)
		if tonumber(player.PlayerData.cid) == tonumber(id) then
			MySQL.Async.fetchAll("SELECT * FROM player_parking_vips WHERE citizenid = @citizenid", {
				['@citizenid'] = player.PlayerData.citizenid,
			}, function(rs)
				if type(rs) == 'table' and #rs > 0 then
					cb({
						status  = false,
						message = Lang:t('system.already_vip')
					})
				else
					MySQL.Async.execute("INSERT INTO player_parking_vips (citizenid, citizenname) VALUES (@citizenid, @citizenname)", {
						["@citizenid"]   = player.PlayerData.citizenid,
						["@citizenname"] = GetUsername(player),
					})
					cb({ 
						status  = true, 
						message = Lang:t('system.vip_add', {username = GetUsername(player)}),
					})
				end
			end)
		else
			cb({
				status = false,
				message = Lang:t('system.vip_not_found')
			})
		end
	end
end)

QBCore.Functions.CreateCallback("qb-parking:server:RemoveVip", function(source, cb, id)
	for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local player = QBCore.Functions.GetPlayer(v)
		if tonumber(player.PlayerData.cid) == tonumber(id) then
			MySQL.Async.fetchAll("SELECT * FROM player_parking_vips WHERE citizenid = @citizenid", {
				['@citizenid'] = player.PlayerData.citizenid,
			}, function(rs)
				if type(rs) == 'table' and #rs > 0 then
					MySQL.Async.execute('DELETE FROM player_parking_vips WHERE citizenid = @citizenid', {
						["@citizenid"] = player.PlayerData.citizenid,
					})
					cb({ 
						status  = true, 
						message = Lang:t('system.vip_remove', {username = GetUsername(player)}),
					})
				else
					cb({
						status  = false,
						message = Lang:t('system.vip_not_found')
					})
				end
			end)
		end
	end
end)

-------------------------------------------------------------------------------------------------



if Config.CheckForUpdates then
    Citizen.CreateThread( function()
        updatePath = "/MaDHouSe79/qb-parking"
        resourceName = "qb-parking ("..GetCurrentResourceName()..")"
        PerformHttpRequest("https://raw.githubusercontent.com"..updatePath.."/master/version", checkVersion, "GET")
    end)
end

-- version check
RegisterServerEvent("dp:CheckVersion") 
AddEventHandler("dp:CheckVersion", function()
    if updateavail then
        TriggerClientEvent("dp:Update", source, true)
    else
        TriggerClientEvent("dp:Update", source, false)
    end
end)

-- When the client request to refresh the vehicles.
RegisterServerEvent('qb-parking:server:refreshVehicles', function(parkingName)
    RefreshVehicles(source)
end)