--[[ ===================================================== ]]--
--[[      QBCore Realistic Parking Script by MaDHouSe      ]]--
--[[ ===================================================== ]]--

local QBCore        = exports['qb-core']:GetCoreObject()
local updateavail   = false
local buildMode     = false
local ParkOwnerName = nil
local PlayerData    = {}

-- Get Player username
local function GetUsername(player)
	local tmpName = player.PlayerData.name
	if Config.UseRoleplayName then
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
				vehicle = json.decode(v.data), 
				plate = v.plate, 
				citizenid = v.citizenid, 
				citizenname = v.citizenname, 
				model = v.model, 
				fuel = v.fuel,
				coords = json.decode(v.coords), 
			}
			if PlayerData.citizenid == v.citizenid then
				TriggerClientEvent('qb-parking:client:addkey', v.plate, v.citizenid) 
			end
        end
        cb(vehicles)
    end)
end

-- Get all vehicles the player owned.
local function FindPlayerBoats(citizenid, cb)
    local boats = {}
    MySQL.Async.fetchAll("SELECT * FROM player_boats WHERE citizenid = @citizenid", {['@citizenid'] = citizenid}, function(rs)
        for k, v in pairs(rs) do
			boats[#boats+1] = { model = v.model, citizenid = v.citizenid, plate = v.plate, fuel = v.fuel }
        end
        cb(boats)
    end)
end

-- Refresh client local vehicles entities.
local function RefreshVehicles(source)
    if source ~= nil then 
		local Player = QBCore.Functions.GetPlayer(source)
        local vehicles = {}
        MySQL.Async.fetchAll("SELECT * FROM player_parking_vehicles", {}, function(rs)
			if type(rs) == 'table' and #rs > 0 then
				for k, v in pairs(rs) do
					vehicles[#vehicles+1] = { 
						vehicle     = json.decode(v.data), 
						plate       = v.plate, 
						citizenid   = v.citizenid, 
						citizenname = v.citizenname, 
						model       = v.model, 
						modelname   = v.modelname,
						fuel        = v.fuel,
						coords      = json.decode(v.coords), 
					}
					if PlayerData.citizenid == v.citizenid then
						TriggerClientEvent('qb-parking:client:addkey', v.plate, v.citizenid) 
					end
				end
				TriggerClientEvent("qb-parking:client:refreshVehicles", source, vehicles)
			end
		end)
	end
end

function addZeroForLessThan10(number)
	if(number < 10) then
		return 0 .. number
	else
		return number
	end
end

function generateDateTime()
	local dateTimeTable = os.date('*t')
	local dateTime = "Date "..dateTimeTable.year .."/".. addZeroForLessThan10(dateTimeTable.month) .."/"..  addZeroForLessThan10(dateTimeTable.day) .." Time "..  addZeroForLessThan10(dateTimeTable.hour) ..":".. addZeroForLessThan10(dateTimeTable.min) ..":".. addZeroForLessThan10(dateTimeTable.sec)
	return dateTime
end
   
-- Version Check
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

--source, data.cid, data.parkname, data.display, data.radius, data.cost, data.job, data.marker, markerOffset, data.parktype
local function SaveParkPlace(source, data, markerOffset)
	local coords = vector3(GetEntityCoords(GetPlayerPed(source)).x, GetEntityCoords(GetPlayerPed(source)).y, GetEntityCoords(GetPlayerPed(source)).z)
	--MySQL.Async.execute("INSERT INTO player_parking_reserved (citizenid, display, cost, radius, parktype, marker, coords, markcoords, time, job) VALUES (?,?,?,?,?,?,?,?,?,?)", {
	--	data.cid, data.display, data.cost, data.radius, data.parktype, data.marker, json.encode(coords), json.encode(markerOffset), os.time(), data.job
	--})
end

-- Create a park location
local function CreateParkingLocation(source, id, parkname, display, radius, cost, job, marker, markerOffset, parktype)
	local citizenid = 0
    local cid = 0
	if tonumber(id) > 0 then cid = tonumber(id) end
	if cid ~= 0 then
		citizenid = QBCore.Functions.GetPlayer(cid).PlayerData.citizenid
	end
	local sender = QBCore.Functions.GetPlayer(source).PlayerData
	local coords = vector3(GetEntityCoords(GetPlayerPed(source)).x, GetEntityCoords(GetPlayerPed(source)).y, GetEntityCoords(GetPlayerPed(source)).z)
	local heading = GetEntityHeading(GetPlayerPed(source))
    local path = GetResourcePath(GetCurrentResourceName())
	local createDate = generateDateTime()
	if parktype ~= '' then
		path = path:gsub('//', '/')..'/configs/'..string.gsub(parktype, ".lua", "")..'.lua'
	else
		path = path:gsub('//', '/')..'/config.lua'
	end
    local file = io.open(path, 'a+')
    local label = '\n-- '..parkname.. ' created by '..sender.name..' ('..createDate..')\nConfig.ReservedParkList["'..parkname..'"] = {\n    ["name"] = "'..parkname..'",\n    ["display"] = "'..display..'",\n    ["citizenid"] = "'..citizenid..'",\n    ["coords"] = '..coords..',\n    ["cost"] = '..cost..',\n    ["job"] = "'..job..'",\n    ["radius"] = '..radius..'.0,\n    ["parktype"] = "'..parktype..'",\n    ["marker"] = '..marker..',\n    ["markcoords"] = '..markerOffset..',\n}'
	file:write(label)
   	file:close()
	local data = {}
	data = {
		["name"]       = parkname, 
		["display"]    = display, 
		["citizenid"]  = citizenid, 
		["cost"]       = cost, 
		["job"]        = job, 
		["radius"]     = radius, 
		["parktype"]   = parktype, 
		["marker"]     = marker, 
		["coords"]     = vector3(coords.x, coords.y, coords.z), 
		["markcoords"] = vector3(markerOffset.x, markerOffset.y, markerOffset.z), 
	}
	Config.ReservedParkList[parkname] = data
	TriggerClientEvent('qb-parking:client:newParkConfigAdded', -1, parkname, data)
	
end



local function SaveData(Player, vehicleData)
	MySQL.Async.execute("INSERT INTO player_parking_vehicles (citizenid, citizenname, plate, fuel, oil, model, modelname, data, time, coords) VALUES (@citizenid, @citizenname, @plate, @fuel, @oil, @model, @modelname, @data, @time, @coords)", {
		["@citizenid"]   = GetCitizenid(Player),
		["@citizenname"] = GetUsername(Player),
		["@plate"]       = vehicleData.plate,
		["@fuel"]        = vehicleData.fuel,
		["@oil"]         = vehicleData.oil,
		['@model']       = vehicleData.model,
		["@modelname"]   = vehicleData.modelname,
		["@data"]        = json.encode(vehicleData),
		["@time"]        = os.time(),
		["coords"]       = json.encode(vehicleData.coords),
	})
	MySQL.Async.execute('UPDATE player_vehicles SET state = 3 WHERE plate = @plate AND citizenid = @citizenid', {
		["@plate"]       = plate,
		["@citizenid"]   = GetCitizenid(Player)
	})
	TriggerClientEvent("qb-parking:client:addVehicle", -1, {
		vehicle     = vehicleData,
		plate       = vehicleData.plate, 
		fuel        = vehicleData.fuel,
		oil         = vehicleData.oil,
		citizenid   = GetCitizenid(Player), 
		citizenname = GetUsername(Player),
		model       = vehicleData.model,
		modelname   = vehicleData.modelname,
		coords      = json.decode(vehicleData.coords),
	})
end

local function hasPermission(source, type)
	if QBCore.Functions.HasPermission(source, type) then
		return true
	else
		return false
	end
end
-- Save the car to database
QBCore.Functions.CreateCallback("qb-parking:server:save", function(source, cb, vehicleData)
    if Config.UseParkingSystem then
		local src     = source
		local Player  = QBCore.Functions.GetPlayer(src)
		local isFound = false
		if Config.UseOnlyForVipPlayers then -- only allow for vip players
			MySQL.Async.fetchAll("SELECT * FROM player_parking_vips WHERE citizenid = @citizenid", {
				['@citizenid'] = GetCitizenid(Player),
			}, function(rs)
				if type(rs) == 'table' and #rs > 0 then
					FindPlayerVehicles(GetCitizenid(Player), function(vehicles)
						for k, v in pairs(vehicles) do
							if type(v.plate) and vehicleData.plate == v.plate then
								isFound = true
							end		
						end
						if isFound then
							MySQL.Async.fetchAll("SELECT * FROM player_parking_vehicles WHERE citizenid = @citizenid AND plate = @plate", {
								['@citizenid'] = GetCitizenid(Player),
								['@plate']     = vehicleData.plate
							}, function(rs)
								if type(rs) == 'table' and #rs > 0 then
									cb({status  = false, message = Lang:t("info.car_already_parked")})
								else
									SaveData(Player, vehicleData)
									cb({status  = true, message = Lang:t("success.parked")})
								end
							end)
						else
							FindPlayerBoats(GetCitizenid(Player), function(boats) 
								for k, v in pairs(boats) do
									if type(v.plate) and vehicleData.plate == v.plate then
										isFound = true
									end		
								end
								if isFound then
									SaveData(Player, vehicleData)
									cb({status  = true, message = Lang:t("success.parked")})
								else
									cb({status  = false, message = Lang:t("info.must_own_car")})
								end
							end)
						end
					end)
				end
			end)
		else 
			FindPlayerVehicles(GetCitizenid(Player), function(vehicles) -- free for all
				for k, v in pairs(vehicles) do
					if type(v.plate) and vehicleData.plate == v.plate then
						isFound = true
					end		
				end
				if isFound then
					MySQL.Async.fetchAll("SELECT * FROM player_parking_vehicles WHERE citizenid = @citizenid AND plate = @plate", {
						['@citizenid'] = GetCitizenid(Player),
						['@plate'] = vehicleData.plate
					}, function(rs)
						if type(rs) == 'table' and #rs > 0 then
							cb({status = false, message = Lang:t("info.car_already_parked")})
						else
							SaveData(Player, vehicleData)
							cb({status  = true, message = Lang:t("success.parked")})
						end
					end)	
				else 
					FindPlayerBoats(GetCitizenid(Player), function(boats) 
						for k, v in pairs(boats) do
							if type(v.plate) and vehicleData.plate == v.plate then
								isFound = true
							end		
						end
						if isFound then
							SaveData(Player, vehicleData)
							cb({status  = true, message = Lang:t("success.parked")})
						else
							cb({status = false, message = Lang:t("info.must_own_car")})
						end
					end)	
				end
			end)
		end
	else 
		cb({status = false, message = Lang:t("system.offline")})
    end
end)

-- When player request to drive the car
QBCore.Functions.CreateCallback("qb-parking:server:drive", function(source, cb, vehicleData)
    if Config.UseParkingSystem then
		local src = source
		local Player = QBCore.Functions.GetPlayer(src)
		local isFound = false
		FindPlayerVehicles(GetCitizenid(Player), function(vehicles)
			for k, v in pairs(vehicles) do
				if type(v.plate) and vehicleData.plate == v.plate then
					isFound = true
				end
			end
			if isFound then
				MySQL.Async.fetchAll("SELECT * FROM player_parking_vehicles WHERE citizenid = @citizenid AND plate = @plate", {
					['@citizenid'] = GetCitizenid(Player),
					['@plate'] = vehicleData.plate
				}, function(rs)
					if type(rs) == 'table' and #rs > 0 and rs[1] then
						MySQL.Async.execute('DELETE FROM player_parking_vehicles WHERE plate = @plate AND citizenid = @citizenid', {
							["@plate"]     = vehicleData.plate,
							["@citizenid"] = GetCitizenid(Player)
						})
						MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = @plate AND citizenid = @citizenid', {
							["@plate"]     = vehicleData.plate,
							["@citizenid"] = GetCitizenid(Player)
						})
						cb({
							status      = true,
							message     = Lang:t("info.has_take_the_car"),
							citizenid   = GetCitizenid(Player), 
							citizenname = GetUsername(Player),
							vehicle     = json.decode(rs[1].data),
							plate       = rs[1].plate, 
							fuel        = rs[1].fuel,
							oil         = rs[1].oil,
							model       = rs[1].model,
							modelname   = rs[1].modelname,
							coords      = json.decode(rs[1].coords),
						})
						TriggerClientEvent("qb-parking:client:deleteVehicle", -1, { plate = vehicleData.plate })
					end
				end)
			else
				FindPlayerBoats(GetCitizenid(Player), function(boats) 
					for k, v in pairs(boats) do
						if type(v.plate) and vehicleData.plate == v.plate then
							isFound = true
						end
					end
					if isFound then
						MySQL.Async.fetchAll("SELECT * FROM player_parking_vehicles WHERE citizenid = @citizenid AND plate = @plate", {

							['@citizenid'] = GetCitizenid(Player),
							['@plate'] = vehicleData.plate
						}, function(rs)
							if type(rs) == 'table' and #rs > 0 and rs[1] then
								MySQL.Async.execute('DELETE FROM player_parking_vehicles WHERE plate = @plate AND citizenid = @citizenid', {

									["@plate"]     = vehicleData.plate,
									["@citizenid"] = GetCitizenid(Player)
								})
								MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = @plate AND citizenid = @citizenid', {
									["@plate"]     = vehicleData.plate,
									["@citizenid"] = GetCitizenid(Player)
								})
								cb({
									status      = true,
									message     = Lang:t("info.has_take_the_car"),
									vehicle     = json.decode(rs[1].data),
									plate       = rs[1].plate, 
									fuel        = rs[1].fuel,
									oil         = rs[1].oil,
									citizenid   = GetCitizenid(Player), 
									citizenname = GetUsername(Player),
									model       = rs[1].model,
									modelname   = rs[1].modelname,
									coords      = json.decode(rs[1].coords),
								})
								TriggerClientEvent("qb-parking:client:deleteVehicle", -1, { plate = vehicleData.plate })
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
		end)
    else 
		cb({
			status  = false,
			message = Lang:t("system.offline"),
		})
    end
end)

-- vehicle action, this can be impound sloten or unpark the vehicle
QBCore.Functions.CreateCallback("qb-parking:server:vehicle_action", function(source, cb, plate, action)
    MySQL.Async.fetchAll("SELECT * FROM player_parking_vehicles WHERE plate = @plate", {
		['@plate'] = plate
    }, function(rs)
		if type(rs) == 'table' and #rs > 0 and rs[1] then
			MySQL.Async.execute('DELETE FROM player_parking_vehicles WHERE plate = @plate', {
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

-- Pay for the parking space
QBCore.Functions.CreateCallback('qb-parking:server:payparkspace', function(source, cb, cost)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.Functions.RemoveMoney("cash", cost, "park-spot-paid") then
		cb({
			status = true,
			message = Lang:t('info.paid_park_space', { paid = cost }) 
	    })
    else
		if Player.Functions.RemoveMoney("bank", cost, "park-spot-paid") then
			cb({
				status = true,
				message = Lang:t('info.paid_park_space', { paid = cost }) 
			})
		else
			cb({
				status = false, 
				message = Lang:t('error.not_enough_money')
			})
		end
    end
end)

-- Save vip player to database
QBCore.Commands.Add(Config.Command.addvip, Lang:t("commands.addvip"), {{name='ID', help='The id of the player you want to add.'}}, true, function(source, args)
	if args[1] and tonumber(args[1]) > 0 then
		MySQL.Async.fetchAll("SELECT * FROM player_parking_vips WHERE citizenid = @citizenid", {
			['@citizenid'] = GetCitizenid(QBCore.Functions.GetPlayer(tonumber(args[1]))),
		}, function(rs)
			if type(rs) == 'table' and #rs > 0 then
				TriggerClientEvent('QBCore:Notify', source, Lang:t('system.already_vip'), "error")
			else
				MySQL.Async.execute("INSERT INTO player_parking_vips (citizenid, citizenname) VALUES (@citizenid, @citizenname)", {
					["@citizenid"]   = GetCitizenid(QBCore.Functions.GetPlayer(tonumber(args[1]))),
					["@citizenname"] = GetUsername(QBCore.Functions.GetPlayer(tonumber(args[1])))
				})
				TriggerClientEvent('QBCore:Notify', source, Lang:t('system.vip_add', {username = GetUsername(QBCore.Functions.GetPlayer(tonumber(args[1])))}), "success")
			end
		end)
	end
end, 'admin')

-- Remove VIP
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

-- Turn System On/Off
QBCore.Commands.Add(Config.Command.system, "Park System On/Off", {}, true, function(source)
	Config.UseParkingSystem = not Config.UseParkingSystem
	if Config.UseParkingSystem then
		TriggerClientEvent('QBCore:Notify', source, Lang:t('system.enable', {type = "system"}), "success")
	else
		TriggerClientEvent('QBCore:Notify', source, Lang:t('system.disable', {type = "system"}), "error")
	end
end, 'admin')

-- Turn VIP System On/Off
QBCore.Commands.Add(Config.Command.usevip, "Park VIP System On/Off", {}, true, function(source)
	Config.UseOnlyForVipPlayers = not Config.UseOnlyForVipPlayers
	if Config.UseOnlyForVipPlayers then
		TriggerClientEvent('QBCore:Notify', source, Lang:t('system.enable', {type = "vip only"}), "success")
	else
		TriggerClientEvent('QBCore:Notify', source, Lang:t('system.disable', {type = "vip only"}), "error")
	end
end, 'admin')


QBCore.Commands.Add(Config.Command.park, "Park Or Drive", {}, true, function(source)
	TriggerClientEvent("qb-parking:client:park", source)
end)

QBCore.Commands.Add(Config.Command.parknames, "Park Names On/Off", {}, true, function(source)
	Config.UseParkedVehicleNames = not Config.UseParkedVehicleNames
	if Config.UseParkedVehicleNames then
		TriggerClientEvent("qb-parking:client:useparknames", source)
		TriggerClientEvent('QBCore:Notify', source, Lang:t('system.enable', {type = "names"}), "success")
	else
		TriggerClientEvent("qb-parking:client:useparknames", source)
		TriggerClientEvent('QBCore:Notify', source, Lang:t('system.disable', {type = "names"}), "error")
	end
end)

QBCore.Commands.Add(Config.Command.parkspotnames, "Park Markers On/Off", {}, true, function(source)
	Config.UseParkedLocationNames = not Config.UseParkedLocationNames
    if Config.UseParkedLocationNames then
		TriggerClientEvent("qb-parking:client:useparkspotnames", source)
		TriggerClientEvent('QBCore:Notify', source, Lang:t('system.enable', {type = "parkspot names"}), "success")
	else
		TriggerClientEvent("qb-parking:client:useparkspotnames", source)
		TriggerClientEvent('QBCore:Notify', source, Lang:t('system.disable', {type = "parkspot names"}), "error")
	end
end)

QBCore.Commands.Add(Config.Command.notification, "Park notification On/Off", {}, true, function(source)
	Config.PhoneNotification = not Config.PhoneNotification
    if Config.PhoneNotification then
		TriggerClientEvent("qb-parking:client:usenotification", source)
		TriggerClientEvent('QBCore:Notify', source, Lang:t('system.enable', {type = "notifications"}), "success")
	else
		TriggerClientEvent("qb-parking:client:usenotification", source)
		TriggerClientEvent('QBCore:Notify', source, Lang:t('system.disable', {type = "notifications"}), "error")
	end
end)

QBCore.Commands.Add(Config.Command.buildmode, "Park Build Mode On/Off", {}, true, function(source)
	PlayerData = QBCore.Functions.GetPlayer(source).PlayerData
	if Config.JobToCreateParkSpaces[PlayerData.job.name] or hasPermission(source, 'admin') then
		if PlayerData.job.onduty or hasPermission(source, 'admin') then
			Config.BuildMode = not Config.BuildMode
			if Config.BuildMode then
				TriggerClientEvent("qb-parking:client:buildmode", source)
				TriggerClientEvent('QBCore:Notify', source, Lang:t('system.enable', {type = "Build Mode"}), "success")
			else
				TriggerClientEvent("qb-parking:client:buildmode", source)
				TriggerClientEvent('QBCore:Notify', source, Lang:t('system.disable', {type = "Build Mode"}), "error")
			end
		else
			TriggerClientEvent('QBCore:Notify', source, Lang:t('system.must_be_onduty'), "error")
		end
	else
		TriggerClientEvent('QBCore:Notify', source, Lang:t('system.not_the_right_job'), "error")
	end
end)


QBCore.Commands.Add(Config.Command.createmenu, "Park Create Menu", {}, true, function(source)
    PlayerData = QBCore.Functions.GetPlayer(source).PlayerData
	if Config.JobToCreateParkSpaces[PlayerData.job.name] or hasPermission(source, 'admin') then
		if PlayerData.job.onduty or hasPermission(source, 'admin') then
			TriggerClientEvent("qb-parking:client:openmenu", source)
		else
			TriggerClientEvent('QBCore:Notify', source, Lang:t('system.must_be_onduty'), "error")
		end
	else
		TriggerClientEvent('QBCore:Notify', source, Lang:t('system.not_the_right_job'), "error")
	end
end)

-- Reset state and counting to stay in sync.
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(2000)
		print("[qb-parking] - parked vehicles state check reset.")
		MySQL.Async.fetchAll("SELECT * FROM player_vehicles WHERE state = @state", {["@state"] = 3}, function(rs)
			if type(rs) == 'table' and #rs > 0 then
				for _, v in pairs(rs) do
					MySQL.Async.fetchAll("SELECT * FROM player_parking_vehicles WHERE plate = @plate", {
						['@plate'] = v.plate
					}, function(rs1)
						if type(rs1) == 'table' and #rs1 <= 0 then
							MySQL.Async.execute('UPDATE player_vehicles SET state = 1 WHERE plate = @plate', {["@plate"] = v.plate})	
						end
					end)
				end
			end
		end)
    end
end)

if Config.CheckForUpdates then
    Citizen.CreateThread( function()
        updatePath   = "/MaDHouSe79/qb-parking"
        resourceName = "qb-parking ("..GetCurrentResourceName()..")"
        PerformHttpRequest("https://raw.githubusercontent.com"..updatePath.."/master/version", checkVersion, "GET")
    end)
end

-- version check
RegisterServerEvent("qb-parking:server:CheckVersion", function()
    if updateavail then
        TriggerClientEvent("qb-parking:client:GetUpdate", source, true)
    else
        TriggerClientEvent("qb-parking:client:GetUpdate", source, false)
    end
end)

-- When the client request to refresh the vehicles.
RegisterServerEvent('qb-parking:server:onjoin', function(source)
	PlayerData = QBCore.Functions.GetPlayer(source)
    RefreshVehicles(source)
end)
RegisterServerEvent('qb-parking:server:refreshVehicles', function(parkingName)
    RefreshVehicles(source)
end)

-- Create new parking space.
RegisterServerEvent('qb-parking:server:AddNewParkingSpot', function(source, data, markerOffset)
	if data.cid == "" or data.parkname == "" then
		TriggerClientEvent('QBCore:Notify', source, "Parking space not saved", "error")
	else
		CreateParkingLocation(source, data.cid, data.parkname, data.display, data.radius, data.cost, data.job, data.marker, markerOffset, data.parktype)
		SaveParkPlace(source, data, markerOffset)
	end
end)