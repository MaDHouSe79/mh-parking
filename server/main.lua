local QBCore      = exports['qb-core']:GetCoreObject()
local updateavail = false

-------------------------------------------Local Function----------------------------------------
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
			vehicles[#vehicles+1] = {
				vehicle     = json.decode(v.data),
				plate       = v.plate,
				citizenid   = v.citizenid,
				citizenname = v.citizenname,
				model       = v.model,
				fuel        = v.fuel,
			}
			TriggerEvent("vehiclekeys:server:SetVehicleOwnerToCitizenid", v.plate, v.citizenid)
        end
        cb(vehicles)
    end)
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
                }
				TriggerEvent("vehiclekeys:server:SetVehicleOwnerToCitizenid", v.plate, v.citizenid) 
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
		print("READ THE UPDATES.md to see if you have to make any changes!!")
        print("^3----------------------------------------------------------------------------------^7")
    else
        print("\n"..resourceName.." is up to date. (^2"..curVersion.."^7)")
    end
end

if Config.CheckForUpdates then
    Citizen.CreateThread( function()
        updatePath   = "/MaDHouSe79/qb-parking"
        resourceName = "qb-parking ("..GetCurrentResourceName()..")"
        PerformHttpRequest("https://raw.githubusercontent.com"..updatePath.."/master/version", checkVersion, "GET")
    end)
end

--------------------------------------------Callbacks--------------------------------------------
-- Save the car to database
QBCore.Functions.CreateCallback("qb-parking:server:save", function(source, cb, vehicleData)
    if UseParkingSystem then
		local src     = source
		local Player  = QBCore.Functions.GetPlayer(src)
		local plate   = vehicleData.plate
		local isFound = false

		if UseOnlyForVipPlayers then -- only allow for vip players
			MySQL.Async.fetchAll("SELECT * FROM player_parking_vips WHERE citizenid = @citizenid", {
				['@citizenid'] = GetCitizenid(Player),
			}, function(rs)
				if type(rs) == 'table' and #rs > 0 then
					local hasparked = rs[1].hasparked
					if hasparked < 0 then hasparked = 0 end
					if hasparked < rs[1].maxparking then
						FindPlayerVehicles(GetCitizenid(Player), function(vehicles)
							local tmpvehicle = false
							for k, v in pairs(vehicles) do
								if type(v.plate) and plate == v.plate then
									isFound = true
									tmpvehicle = v
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
										MySQL.Async.execute("INSERT INTO player_parking (citizenid, citizenname, plate, fuel, model, data, time) VALUES (@citizenid, @citizenname, @plate, @fuel, @model, @data, @time)", {
											["@citizenid"]   = GetCitizenid(Player),
											["@citizenname"] = GetUsername(Player),
											["@plate"]       = plate,
											["@fuel"]        = vehicleData.fuel,
											['@model']       = vehicleData.model,
											["@data"]        = json.encode(vehicleData),
											["@time"]        = os.time(),
										})
										MySQL.Async.execute('UPDATE player_vehicles SET state = 3 WHERE plate = @plate AND citizenid = @citizenid', {
											["@plate"]       = plate,
											["@citizenid"]   = GetCitizenid(Player)
										})
										MySQL.Async.execute('UPDATE player_parking_vips SET hasparked = hasparked + 1 WHERE citizenid = @citizenid', {
											["@citizenid"] = GetCitizenid(Player)
										})
										cb({ 
											status  = true, 
											message = Lang:t("success.parked"),
											vehicle = tmpvehicle
										})
										TriggerClientEvent("qb-parking:client:addVehicle", -1, {
											vehicle     = vehicleData,
											plate       = plate, 
											fuel        = vehicleData.fuel,
											citizenid   = GetCitizenid(Player), 
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
			FindPlayerVehicles(GetCitizenid(Player), function(vehicles) -- free for all
				local tmpvehicle = false
				for k, v in pairs(vehicles) do
					if type(v.plate) and plate == v.plate then
						isFound = true
						tmpvehicle = v
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
							MySQL.Async.execute("INSERT INTO player_parking (citizenid, citizenname, plate, fuel, model, data, time) VALUES (@citizenid, @citizenname, @plate, @fuel, @model, @data, @time)", {
								["@citizenid"]   = GetCitizenid(Player),
								["@citizenname"] = GetUsername(Player),
								["@plate"]       = plate,
								["@fuel"]        = vehicleData.fuel,
								['@model']       = vehicleData.model,
								["@data"]        = json.encode(vehicleData),
								["@time"]        = os.time(),
							})
							MySQL.Async.execute('UPDATE player_vehicles SET state = 3 WHERE plate = @plate AND citizenid = @citizenid', {
								["@plate"]       = plate,
								["@citizenid"]   = GetCitizenid(Player)
							})
							cb({ 
								status  = true, 
								message = Lang:t("success.parked"),
								vehicle = tmpvehicle
							})
							TriggerClientEvent("qb-parking:client:addVehicle", -1, {
								vehicle     = vehicleData,
								plate       = plate, 
								fuel        = vehicleData.fuel,
								citizenid   = GetCitizenid(Player), 
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
		end
	else 
		cb({
			status  = false,
			message = Lang:t("system.offline"),
		})
    end
end)

---------------------------------- When player request to drive the car ----------------------------------
QBCore.Functions.CreateCallback("qb-parking:server:drive", function(source, cb, vehicleData)
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
							["@plate"]     = plate,
							["@citizenid"] = GetCitizenid(Player)
						})
						MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = @plate AND citizenid = @citizenid', {
							["@plate"]     = plate,
							["@citizenid"] = GetCitizenid(Player)
						})
						if UseOnlyForVipPlayers then -- only allow for vip players
							MySQL.Async.fetchAll("SELECT * FROM player_parking_vips WHERE citizenid = @citizenid", {
								['@citizenid'] = GetCitizenid(Player),
							}, function(rs)
								if type(rs) == 'table' and #rs > 0 then
									local hasparked = rs[1].hasparked - 1
									if hasparked < 0 then hasparked = 0 end
									MySQL.Async.execute('UPDATE player_parking_vips SET hasparked = @hasparked WHERE citizenid = @citizenid', {
										["@citizenid"] = GetCitizenid(Player),
										["@hasparked"] = hasparked
									})
								end
							end)
						end
						cb({
							status  = true,
							message = Lang:t("info.has_take_the_car"),
							data    = json.decode(rs[1].data),
							fuel    = rs[1].fuel,
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
			message = Lang:t("system.offline"),
		})
    end
end)

QBCore.Functions.CreateCallback("qb-parking:server:vehicle_action", function(source, cb, plate, action)
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
			end
			if action ~= 'impound' then
				MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = @plate', {
					["@plate"] = plate,
				})
			end
			if UseOnlyForVipPlayers then -- only allow for vip players
				MySQL.Async.execute('UPDATE player_parking_vips SET hasparked = hasparked - 1 WHERE citizenid = @citizenid', {
					["@citizenid"] = rs[1].citizenid
				})
			end
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

------------------------------------------------------Admin Commands-------------------------------------------------
QBCore.Commands.Add(Config.Command.addvip, Lang:t("commands.addvip"), {{name='ID', help='The id of the player you want to add.'}, {name='Amount', help='The max vehicles amount a player can park'}}, true, function(source, args)
	if args[1] and tonumber(args[1]) > 0 then
		local amount = 0 
		if args[2] and tonumber(args[2]) > 0 then
			amount = args[2]
		end
		MySQL.Async.fetchAll("SELECT * FROM player_parking_vips WHERE citizenid = @citizenid", {
			['@citizenid'] = GetCitizenid(QBCore.Functions.GetPlayer(tonumber(args[1]))),
		}, function(rs)
			if type(rs) == 'table' and #rs > 0 then
				TriggerClientEvent('QBCore:Notify', source, Lang:t('system.already_vip'), "error")
			else
				MySQL.Async.execute("INSERT INTO player_parking_vips (citizenid, citizenname, maxparking) VALUES (@citizenid, @citizenname, @maxparking)", {
					["@citizenid"]   = GetCitizenid(QBCore.Functions.GetPlayer(tonumber(args[1]))),
					["@citizenname"] = GetUsername(QBCore.Functions.GetPlayer(tonumber(args[1]))),
					["@maxparking"]  = amount 
				})
				TriggerClientEvent('QBCore:Notify', source, Lang:t('system.vip_add', {username = GetUsername(QBCore.Functions.GetPlayer(tonumber(args[1])))}), "success")
			end
		end)
	end
end, 'admin')

QBCore.Commands.Add(Config.Command.removevip, Lang:t("commands.removevip"), {{name='ID', help='The id of the player you want to remove.'}}, true, function(source, args)
	if args[1] and tonumber(args[1]) > 0 then
		MySQL.Async.fetchAll("SELECT * FROM player_parking_vips WHERE citizenid = @citizenid", {
			['@citizenid'] = GetCitizenid(QBCore.Functions.GetPlayer(tonumber(args[1]))),
		}, function(rs)
			if type(rs) == 'table' and #rs > 0 then
				MySQL.Async.execute('DELETE FROM player_parking_vips WHERE citizenid = @citizenid', {
					["@citizenid"] = GetCitizenid(QBCore.Functions.GetPlayer(tonumber(args[1]))),
				})
				TriggerClientEvent('QBCore:Notify', source, Lang:t('system.vip_remove', {username = GetUsername(QBCore.Functions.GetPlayer(tonumber(args[1])))}), "success")
			else
				TriggerClientEvent('QBCore:Notify', source, Lang:t('system.vip_not_found'), "error")
			end
		end)
	end
end, 'admin')

QBCore.Commands.Add(Config.Command.system, "Park System On/Off", {}, true, function(source)
	UseParkingSystem = not UseParkingSystem
	if UseParkingSystem then
		TriggerClientEvent('QBCore:Notify', source, Lang:t('system.enable', {type = "system"}), "success")
	else
		TriggerClientEvent('QBCore:Notify', source, Lang:t('system.disable', {type = "system"}), "error")
	end
end, 'admin')

QBCore.Commands.Add(Config.Command.usevip, "Park VIP System On/Off", {}, true, function(source)
	UseOnlyForVipPlayers = not UseOnlyForVipPlayers
	if UseOnlyForVipPlayers then
		TriggerClientEvent('QBCore:Notify', source, Lang:t('system.enable', {type = "vip only"}), "success")
	else
		TriggerClientEvent('QBCore:Notify', source, Lang:t('system.disable', {type = "vip only"}), "error")
	end
end, 'admin')


----------------------------Reset state and counting to stay in sync------------------------------
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(2000)
		print("[qb-parking] - parked vehicles state check reset.")
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
								if UseOnlyForVipPlayers then -- only for vip players
									MySQL.Async.fetchAll("SELECT * FROM player_parking_vips WHERE citizenid = @citizenid", {
										['@citizenid'] = vehicle.citizenid,
									}, function(park)
										if type(park) == 'table' and #park[1] then
											local hasparked = park[1].hasparked
											hasparked = hasparked - 1
											if hasparked < 0 then hasparked = 0 end
											MySQL.Async.execute('UPDATE player_parking_vips SET hasparked = @hasparked WHERE citizenid = @citizenid', {["@hasparked"] = hasparked, ["@citizenid"] = vehicle.citizenid})	
										end
									end)	
								end
								MySQL.Async.execute('UPDATE player_vehicles SET state = @state WHERE plate = @plate', {["@state"] = Config.ResetState, ["@plate"] = vehicle.plate})					
							end
						end
					end)
				end
			end
		end)
    end
end)

RegisterServerEvent('qb-parking:server:refreshVehicles', function(parkingName)
    RefreshVehicles(source)
end)