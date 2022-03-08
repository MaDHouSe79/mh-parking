--[[ ===================================================== ]]--
--[[      QBCore Realistic Parking Script by MaDHouSe      ]]--
--[[ ===================================================== ]]--

local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData, updateavail, buildMode, ParkOwnerName = {}, false, false, nil

local function GetUsername(player)
	local tmpName = player.PlayerData.name
	if Config.UseRoleplayName then
		tmpName = player.PlayerData.charinfo.firstname ..' '.. player.PlayerData.charinfo.lastname
	end
    return tmpName
end

local function GetCitizenid(player)
	return player.PlayerData.citizenid
end

local function hasPerMission(source, type)
    if QBCore.Functions.HasPermission(source, type) then return true else return false end
end

local function addZeroForLessThan10(number)
	if(number < 10) then return 0 .. number else  return number end
end

local function FindPlayerVehicles(citizenid, cb)
    local vehicles = {}
    MySQL.Async.fetchAll("SELECT * FROM player_vehicles WHERE citizenid = @citizenid", {['@citizenid'] = citizenid}, function(rs)
        for k, v in pairs(rs) do
			vehicles[#vehicles+1] = { 
				plate = v.plate, 
				citizenid = v.citizenid, 
			}
			if PlayerData.citizenid == v.citizenid then
				TriggerClientEvent('qb-parking:client:addkey', v.plate, v.citizenid) 
			end
        end
        cb(vehicles)
    end)
end

local function FindPlayerBoats(citizenid, cb)
    local boats = {}
    MySQL.Async.fetchAll("SELECT * FROM player_boats WHERE citizenid = @citizenid", {['@citizenid'] = citizenid}, function(rs)
        for k, v in pairs(rs) do
			boats[#boats+1] = { citizenid = v.citizenid, plate = v.plate}
        end
        cb(boats)
    end)
end

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
						body        = v.body,
						engine      = v.engine,
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

function sendWebHookMessage(message)
	if Config.UseDiscoordLog then
		if Config.Webhook == "" then
			print("you have no webhook, create one on discord [https://discord.com/developers/applications] and place this in the config.lua (Config.Webhook)")
		else
			if message == nil or message == '' then return end
			local txt = "```[qb-parking] - "..message.."```"
			PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({ content = txt }), { ['Content-Type'] = 'application/json' })
		end
	end
end

local function sendLogs(title, message)
	if Config.UseDiscoordLog then
		if Config.Webhook == "" then
			print("you have no webhook, create one on discord [https://discord.com/developers/applications] and place this in the config.lua (Config.Webhook)")
		else
			if message == nil or message == '' then return end
			LogArray = {
				{
					["author"] = {
						["name"] = "Qb-Parking",
						["url"] = "https://github.com/MaDHouSe79",
						["icon_url"] = "https://icons.iconarchive.com/icons/iconarchive/red-orb-alphabet/128/Letter-M-icon.png",
					},
					["color"] = "5020550",
					["title"] = title,
					["description"] = "Time: **"..os.date('%Y-%m-%d %H:%M:%S').."**",
					["fields"] = {
						{
							["name"] = "Message",
							["value"] = message
						}
					},
					["footer"] = {
						["text"] = "QB-parking by MaDHouSe",
						["icon_url"] = "https://icons.iconarchive.com/icons/iconarchive/red-orb-alphabet/128/Letter-M-icon.png",
					}
				}
			}
			PerformHttpRequest(Config.Webhook , function(err, text, headers) end, 'POST', json.encode({username = "ParkingBot", embeds = LogArray}), { ['Content-Type'] = 'application/json' })
		end
	end
end

-- ParkingTimeCheckLoop (standalone - don't touch)
function ParkingTimeCheckLoop()
	local countImpounded = 0
	MySQL.Async.fetchAll("SELECT * FROM player_parking_vehicles", {}, function(rs)
		local impounded = {}
		local message = '\n'
		if type(rs) == 'table' and #rs > 0 then
			for _, v in pairs(rs) do
				local total = os.time() - v.time
				if v.parktime > 0 and total > v.parktime then
					print("[Parking Time Limit Detection] - Vehicle with plate: ^2"..v.plate.."^7 has been impound by the police.")
					for _, p in pairs(QBCore.Functions.GetPlayers()) do
						TriggerClientEvent("qb-parking:client:deleteVehicle", p, { plate = v.plate })
					end
					local cost = (math.floor(((os.time() - v.time) / Config.PayTimeInSecs) * v.cost))
					TriggerEvent("police:server:Impound", v.plate, true, cost, v.body, v.engine, v.fuel)					
					MySQL.Async.execute('DELETE FROM player_parking_vehicles WHERE plate = ?', {v.plate})
					MySQL.Async.execute('UPDATE player_vehicles SET state = ? WHERE plate = ?', {2,  v.plate})
					message = message .." vehicle with Plate " .. v.plate..' has just impound by the police.\nThis due to the expiration of the parking time'
					countImpounded = countImpounded + 1
				end
			end

			if countImpounded > 0 then
				sendLogs('Impound Log', message)
			end
		end
	end)
	if Config.DebugMode then
		print("Timer Loop For Checking Parking Vehicles with a max time of parking!")
	end
	SetTimeout(5000, ParkingTimeCheckLoop)
end


function generateDateTime()
	local dateTimeTable = os.date('*t')
	local dateTime = "Date "..dateTimeTable.year .."/".. addZeroForLessThan10(dateTimeTable.month) .."/"..  addZeroForLessThan10(dateTimeTable.day) .." Time "..  addZeroForLessThan10(dateTimeTable.hour) ..":".. addZeroForLessThan10(dateTimeTable.min) ..":".. addZeroForLessThan10(dateTimeTable.sec)
	return dateTime
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

local function CreateParkingLocation(source, id, parkname, display, radius, cost, parktime, job, marker, markerOffset, parktype)
	local citizenid = 0
    local cid = 0
	if tonumber(id) > 0 then cid = tonumber(id) end
	if cid ~= 0 then citizenid = QBCore.Functions.GetPlayer(cid).PlayerData.citizenid end
	local sender = QBCore.Functions.GetPlayer(source).PlayerData
	local coords = vector3(GetEntityCoords(GetPlayerPed(source)).x, GetEntityCoords(GetPlayerPed(source)).y, GetEntityCoords(GetPlayerPed(source)).z)
	local heading = GetEntityHeading(GetPlayerPed(source))
    local path = GetResourcePath(GetCurrentResourceName())
	local createDate = generateDateTime()
	if parktype ~= '' then path = path:gsub('//', '/')..'/configs/'..string.gsub(parktype, ".lua", "")..'.lua' else path = path:gsub('//', '/')..'/config.lua' end
    local file = io.open(path, 'a+')
    local label = '\n-- '..parkname.. ' created by '..sender.name..' ('..createDate..')\nConfig.ReservedParkList["'..parkname..'"] = {\n    ["name"] = "'..parkname..'",\n    ["display"] = "'..display..'",\n    ["citizenid"] = "'..citizenid..'",\n    ["coords"] = '..coords..',\n    ["cost"] = '..cost..',\n    ["parktime"] = '..parktime..',\n    ["job"] = "'..job..'",\n    ["radius"] = '..radius..'.0,\n    ["parktype"] = "'..parktype..'",\n    ["marker"] = '..marker..',\n    ["markcoords"] = '..markerOffset..',\n}'
	file:write(label)
   	file:close()
	local data = {
		["name"] = parkname, 
		["display"] = display,
		["citizenid"] = citizenid, 
		["cost"] = cost,
		["parktime"] = parktime, 
		["job"] = job, 
		["radius"] = radius, 
		["parktype"] = parktype, 
		["marker"] = marker, 
		["coords"] = vector3(coords.x, coords.y, coords.z),
		["markcoords"] = vector3(markerOffset.x, markerOffset.y, markerOffset.z) 
	}
	Config.ReservedParkList[parkname] = data
	TriggerClientEvent('qb-parking:client:newParkConfigAdded', -1, parkname, data)
end

local function Pay(source, cost)
	local hasPaid = false
	local player = QBCore.Functions.GetPlayer(source)
	if cost > 0 then 
		if player.Functions.GetMoney('cash') >= cost then
			player.Functions.RemoveMoney("cash", cost, "park-spot-paid")
			hasPaid = true
		else
			if player.Functions.GetMoney('bank') >= cost then
				player.Functions.RemoveMoney("cash", cost, "park-spot-paid")
				hasPaid = true
			end
		end
	else
		hasPaid = true
	end
	return hasPaid
end

local function SaveData(Player, vehicleData)
	MySQL.Async.execute("INSERT INTO player_parking_vehicles (citizenid, citizenname, plate, fuel, body, engine, oil, model, modelname, data, time, coords, cost, parktime, parking) VALUES (@citizenid, @citizenname, @plate, @fuel, @body, @engine, @oil, @model, @modelname, @data, @time, @coords, @cost, @parktime, @parking)", {
		["@citizenid"]   = GetCitizenid(Player),
		["@citizenname"] = GetUsername(Player),
		["@plate"]       = vehicleData.plate,
		["@fuel"]        = vehicleData.fuel,
		["@body"]        = vehicleData.body,
		["@engine"]      = vehicleData.engine,
		["@oil"]         = vehicleData.oil,
		["@model"]       = vehicleData.model,
		["@modelname"]   = vehicleData.modelname,
		["@data"]        = json.encode(vehicleData),
		["@time"]        = os.time(),
		["@coords"]      = json.encode(vehicleData.coords),
		["@cost"]        = vehicleData.cost,
		["@parktime"]    = vehicleData.parktime,
		["@parking"]     = vehicleData.parking,
	})
	MySQL.Async.execute('UPDATE player_vehicles SET state = 3 WHERE plate = @plate AND citizenid = @citizenid', {
		["@plate"]       = vehicleData.plate,
		["@citizenid"]   = GetCitizenid(Player)
	})
	TriggerClientEvent("qb-parking:client:addVehicle", -1, {
		vehicle     = vehicleData,
		plate       = vehicleData.plate, 
		fuel        = vehicleData.fuel,
		body        = vehicleData.body,
		engine      = vehicleData.engine,
		oil         = vehicleData.oil,
		citizenid   = GetCitizenid(Player), 
		citizenname = GetUsername(Player),
		model       = vehicleData.model,
		modelname   = vehicleData.modelname,
		coords      = json.decode(vehicleData.coords),
		cost        = vehicleData.cost, 
	})
end

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
						local cost = (math.floor(((os.time() - rs[1].time) / Config.PayTimeInSecs) * rs[1].cost))
						if cost < 0 then cost = 0 end
						if Pay(source, cost) then
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
								body        = rs[1].body,
								engine      = rs[1].engine,
								oil         = rs[1].oil,
								model       = rs[1].model,
								modelname   = rs[1].modelname,
								coords      = json.decode(rs[1].coords),
								cost        = rs[1].cost,
							})
							TriggerClientEvent("qb-parking:client:deleteVehicle", -1, { plate = vehicleData.plate })
						else
							cb({
								status      = false,
								message     = Lang:t('error.not_enough_money'),
								cost        = cost,
							})
						end
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
								local cost = (math.floor(((os.time() - rs[1].time) / Config.PayTimeInSecs) * rs[1].cost))
								if cost < 0 then cost = 0 end
								if Pay(source, cost) then
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
										body        = rs[1].body,
										engine      = rs[1].engine,
										oil         = rs[1].oil,
										model       = rs[1].model,
										modelname   = rs[1].modelname,
										coords      = json.decode(rs[1].coords),
										cost        = rs[1].cost,
									})
									TriggerClientEvent("qb-parking:client:deleteVehicle", -1, { plate = vehicleData.plate })
								else
									cb({
										status      = false,
										message     = Lang:t('error.not_enough_money'),
										cost        = cost,
									})
								end
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

QBCore.Functions.CreateCallback("qb-parking:server:vehicle_action", function(source, cb, plate, action)
    MySQL.Async.fetchAll("SELECT * FROM player_parking_vehicles WHERE plate = @plate", {
		['@plate'] = plate
    }, function(rs)
		if type(rs) == 'table' and #rs > 0 and rs[1] then
			if action == 'impound' then
				MySQL.Async.execute('DELETE FROM player_parking_vehicles WHERE plate = @plate', {
					["@plate"] = plate,
				})
				MySQL.Async.execute('UPDATE player_vehicles SET state = 2, garage = @garage WHERE plate = @plate AND citizenid = @citizenid', {
					["@plate"]     = plate,
					["@citizenid"] = rs[1].citizenid,
					["@garage"]    = 'impoundlot',
				})
			else
				local cost = (math.floor(((os.time() - rs[1].time) / Config.PayTimeInSecs) * rs[1].cost))
				if cost < 0 then cost = 0 end
				if Pay(source, cost) then
					MySQL.Async.execute('DELETE FROM player_parking_vehicles WHERE plate = @plate', {
						["@plate"] = plate,
					})	
					MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = @plate', {
						["@plate"] = plate,
					})
					cb({ status  = true })
					TriggerClientEvent("qb-parking:client:deleteVehicle", -1, { plate = plate })
				else
					cb({
						status      = false,
						message     = Lang:t('error.not_enough_money'),
						cost        = cost,
					})
				end
			end
		else
			cb({
				status  = false,
				message = Lang:t("info.car_not_found"),
			})
		end
    end)
end)

QBCore.Functions.CreateCallback('qb-parking:server:payparkspace', function(source, cb, cost)
    local Player = QBCore.Functions.GetPlayer(source)
    if Pay(source, cost) then
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
end)

QBCore.Functions.CreateCallback('qb-parking:server:allowtopark', function(source, cb)
	local server_allowed, player_allowed, allowed, text = false, false, false, nil
	local Player       = QBCore.Functions.GetPlayer(source)
	local citizenid    = Player.PlayerData.citizenid
	local server_total = MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM player_vehicles WHERE state = 3')
	local player_total = MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM player_vehicles WHERE citizenid=? AND state = ?', {citizenid, 3})
	if Config.UseMaxParkingOnServer then
		if server_total < Config.MaxServerParkedVehicles then
			server_allowed = true
		else
			text = Lang:t('info.maximum_cars', {amount = Config.MaxServerParkedVehicles})
		end
		if server_allowed and Config.UseMaxParkingPerPlayer then
			if player_total < Config.MaxStreetParkingPerPlayer then
				player_allowed = true
			else
				text = Lang:t('info.limit_for_player', {amount = Config.MaxStreetParkingPerPlayer})
			end
		end
		if server_allowed then
			if player_allowed then
				allowed = true
				text = nil
			end
		end
	else
		if Config.UseMaxParkingPerPlayer then
			if player_total < Config.MaxStreetParkingPerPlayer then
				player_allowed = true
			else
				text = Lang:t('info.limit_for_player')
			end
		end
		if player_allowed then
			allowed = true
			text = nil
		end
	end
	cb({
		status = allowed, 
		message = text
	})
end)

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
	Config.UseParkingSystem = not Config.UseParkingSystem
	if Config.UseParkingSystem then
		TriggerClientEvent('QBCore:Notify', source, Lang:t('system.enable', {type = "system"}), "success")
	else
		TriggerClientEvent('QBCore:Notify', source, Lang:t('system.disable', {type = "system"}), "error")
	end
end, 'admin')

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

QBCore.Commands.Add(Config.Command.buildmode, "Park Build Mode On/Off", {}, true, function(source)
	PlayerData = QBCore.Functions.GetPlayer(source).PlayerData
	if Config.JobToCreateParkSpaces[PlayerData.job.name] or hasPerMission(source, 'admin') then
		if PlayerData.job.onduty or hasPerMission(source, 'admin') then
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
	if Config.JobToCreateParkSpaces[PlayerData.job.name] or hasPerMission(source, 'admin') then
		if PlayerData.job.onduty or hasPerMission(source, 'admin') then
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
		local total = MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM player_vehicles')
		local count = 0
		
		MySQL.Async.fetchAll("SELECT * FROM player_vehicles WHERE state = 0 OR state = 1 OR state = 2", {
		}, function(vehicles)
			if type(vehicles) == 'table' and #vehicles > 0 then
				for _, vehicle in pairs(vehicles) do
					MySQL.Async.fetchAll("SELECT * FROM player_parking_vehicles WHERE plate = @plate", {
						['@plate'] = vehicle.plate
					}, function(rs)
						if type(rs) == 'table' and #rs > 0 then
							for _, v in pairs(rs) do
								MySQL.Async.execute('DELETE FROM player_parking_vehicles WHERE plate = @plate', {["@plate"] = vehicle.plate})
								MySQL.Async.execute('UPDATE player_vehicles SET state = @state WHERE plate = @plate', {["@state"] = Config.ResetState, ["@plate"] = vehicle.plate})					
								count = count + 1
							end
						end
					end)
				end
			end
		end)
		Wait(100)
		currenversion = LoadResourceFile(GetCurrentResourceName(), "version")
		local totalTimeToSpawn = count * 1000
        local spawnColour = '^2'
        if totalTimeToSpawn > 10000 then spawnColour = '^1' end

		if Config.DebugMode then
			print(Lang:t('discoord.version', {version = currenversion}))
        	print(Lang:t('discoord.found', {count = count, total =total}))
        	print(Lang:t('discoord.spawntime', {colour = spawnColour,spawntime = totalTimeToSpawn}))
			print(Lang:t('discoord.timeloop'))
		end
		if Config.UseDiscoordLog then
			local log  = Lang:t('discoord.version', {version = currenversion})
			local log1 = Lang:t('discoord.found', {count = count, total =total})
			local log2 = Lang:t('discoord.spawntime', {colour = spawnColour,spawntime = totalTimeToSpawn})
			local log3 = Lang:t('discoord.timeloop')
			message = "```"..log.."\n"..log1.."\n"..log2.."\n"..log3.."```"
			sendLogs('Server Log', message)
		end
		ParkingTimeCheckLoop()
		Wait(1000)
		--sendWebHookMessage("Parking Time Check Loop Enable!")
    end
end)

if Config.CheckForUpdates then
    Citizen.CreateThread( function()
        updatePath   = "/MaDHouSe79/qb-parking"
        resourceName = ""..GetCurrentResourceName()..""
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
		CreateParkingLocation(source, data.cid, data.parkname, data.display, data.radius, data.cost, data.parktime, data.job, data.marker, markerOffset, data.parktype)
	end
end)