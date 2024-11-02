--[[ ===================================================== ]] --
--[[         MH Realistic Parking Script by MaDHouSe       ]] --
--[[ ===================================================== ]] --
local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData, updateavail = {}, false

-- Discoord webhook
local UseDiscoordLog = false
local Webhook = ""

local function GetUsername(player)
    local tmpName = player.PlayerData.name
    if Config.UseRoleplayName then
        tmpName = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
    end
    return tmpName
end

local function GetCitizenid(player)
    return player.PlayerData.citizenid
end

local function countPlayers()
    local count = 0
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        count = count + 1
    end
    return count
end

local function hasPerMission(source, type)
    local result = false
    if IsPlayerAceAllowed(source, 'command') then
        result = true
    end
    return result
end

local function addZeroForLessThan10(number)
    if (number < 10) then
        return 0 .. number
    else
        return number
    end
end

local function FindPlayerVehicles(citizenid, cb)
    local vehicles = {}
    MySQL.Async.fetchAll("SELECT * FROM player_vehicles WHERE citizenid = ?", {citizenid}, function(rs)
        for k, v in pairs(rs) do
            vehicles[#vehicles + 1] = {
                plate = v.plate,
                citizenid = v.citizenid,
                model = v.vehicle
            }
        end
        cb(vehicles)
    end)
end

local function FindVIPPlayerVehicles(citizenid, cb)
    local vehicles = {}
    MySQL.Async.fetchAll("SELECT * FROM player_vehicles WHERE citizenid = ?", {citizenid}, function(rs)
        if #rs > 0 then
            MySQL.Async.fetchAll("SELECT * FROM player_parking_vips WHERE citizenid = ?", {citizenid}, function(rs)
            end)
        end
        cb(vehicles)
    end)
end

local function RefreshVehicles(source)
    if source ~= nil then
        local vehicles = {}
	local Player = QBCore.Functions.GetPlayer(src)
        MySQL.Async.fetchAll("SELECT * FROM player_parking", {}, function(rs)
            if type(rs) == 'table' and #rs > 0 then
                for k, v in pairs(rs) do
                    vehicles[#vehicles + 1] = {
                        vehicle = json.decode(v.data),
                        steerangle = v.steerangle,
                        plate = v.plate,
                        citizenid = v.citizenid,
                        citizenname = v.citizenname,
                        model = v.model,
                        modelname = v.modelname,
                        fuel = v.fuel,
                        body = v.body,
                        engine = v.engine,
                        coords = json.decode(v.coords)
                    }
                    if Player.PlayerData.citizenid == v.citizenid then TriggerClientEvent('qb-vehiclekeys:client:AddKeys', Player.PlayerData.source, v.plate) end
                end
                TriggerClientEvent("mh-parking:client:refreshVehicles", source, vehicles)
            end
        end)
    end
end

local function sendLogs(title, message)
    if UseDiscoordLog then
        if Webhook == "" then
            print(
                "you have no webhook, create one on discord [https://discord.com/developers/applications] and place this in the config.lua (Config.Webhook)")
        else
            if message == nil or message == '' then
                return
            end
            LogArray = {{
                ["author"] = {
                    ["name"] = "mh-parking",
                    ["url"] = "https://github.com/MaDHouSe79",
                    ["icon_url"] = "https://icons.iconarchive.com/icons/iconarchive/red-orb-alphabet/128/Letter-M-icon.png"
                },
                ["color"] = "5020550",
                ["title"] = title,
                ["description"] = "Time: **" .. os.date('%Y-%m-%d %H:%M:%S') .. "**",
                ["fields"] = {{
                    ["name"] = "Message",
                    ["value"] = message
                }},
                ["footer"] = {
                    ["text"] = "mh-parking by MaDHouSe",
                    ["icon_url"] = "https://icons.iconarchive.com/icons/iconarchive/red-orb-alphabet/128/Letter-M-icon.png"
                }
            }}
            PerformHttpRequest(Webhook, function(err, text, headers)
            end, 'POST', json.encode({
                username = "ParkingBot",
                embeds = LogArray
            }), {
                ['Content-Type'] = 'application/json'
            })
        end
    end
end

-- ParkingTimeCheckLoop (standalone - don't touch)
local function ParkingTimeCheckLoop()
    local countImpounded = 0
    MySQL.Async.fetchAll("SELECT * FROM player_parking", {}, function(rs)
        local impounded = {}
        local message = '\n'
        if type(rs) == 'table' and #rs > 0 then
            for _, v in pairs(rs) do
                local total = os.time() - v.time
                if v.parktime > 0 and total > v.parktime then
                    print("[Parking Time Limit Detection] - Vehicle with plate: ^2" .. v.plate ..
                              "^7 has been impound by the police.")
                    for _, p in pairs(QBCore.Functions.GetPlayers()) do
                        TriggerClientEvent("mh-parking:client:deleteVehicle", p, {
                            plate = v.plate
                        })
                    end
                    local cost = (math.floor(((os.time() - v.time) / Config.PayTimeInSecs) * v.cost))
                    TriggerEvent("police:server:Impound", v.plate, true, cost, v.body, v.engine, v.fuel)
                    MySQL.Async.execute('DELETE FROM player_parking WHERE plate = ?', {v.plate})
                    MySQL.Async.execute('UPDATE player_vehicles SET state = ? WHERE plate = ?', {2, v.plate})
                    message = message .. " vehicle with Plate " .. v.plate ..
                                  ' has just impound by the police.\nThis due to the expiration of the parking time'
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

local function generateDateTime()
    local dateTimeTable = os.date('*t')
    local dateTime = "Date " .. dateTimeTable.year .. "/" .. addZeroForLessThan10(dateTimeTable.month) .. "/" ..
                         addZeroForLessThan10(dateTimeTable.day) .. " Time " .. addZeroForLessThan10(dateTimeTable.hour) ..
                         ":" .. addZeroForLessThan10(dateTimeTable.min) .. ":" ..
                         addZeroForLessThan10(dateTimeTable.sec)
    return dateTime
end

local function CreateParkingLocation(source, id, parkname, display, radius, cost, parktime, job, marker, markerOffset,
    parktype)
    local citizenid = 0
    local cid = 0
    if tonumber(id) > 0 then
        cid = tonumber(id)
    end
    if cid ~= 0 then
        citizenid = QBCore.Functions.GetPlayer(cid).PlayerData.citizenid
    end
    local sender = QBCore.Functions.GetPlayer(source).PlayerData
    local coords = vector3(GetEntityCoords(GetPlayerPed(source)).x, GetEntityCoords(GetPlayerPed(source)).y,
        GetEntityCoords(GetPlayerPed(source)).z)
    local heading = GetEntityHeading(GetPlayerPed(source))
    local path = GetResourcePath(GetCurrentResourceName())
    local createDate = generateDateTime()
    if parktype ~= '' then
        path = path:gsub('//', '/') .. '/configs/' .. string.gsub(parktype, ".lua", "") .. '.lua'
    else
        path = path:gsub('//', '/') .. '/config.lua'
    end
    local file = io.open(path, 'a+')
    local label = '\n-- ' .. parkname .. ' created by ' .. sender.name .. ' (' .. createDate ..
                      ')\nConfig.ReservedParkList["' .. parkname .. '"] = {\n    ["name"] = "' .. parkname ..
                      '",\n    ["display"] = "' .. display .. '",\n    ["citizenid"] = "' .. citizenid ..
                      '",\n    ["coords"] = ' .. coords .. ',\n    ["cost"] = ' .. cost .. ',\n    ["parktime"] = ' ..
                      parktime .. ',\n    ["job"] = "' .. job .. '",\n    ["radius"] = ' .. radius ..
                      '.0,\n    ["parktype"] = "' .. parktype .. '",\n    ["marker"] = ' .. marker ..
                      ',\n    ["markcoords"] = ' .. markerOffset .. ',\n}'
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
    TriggerClientEvent('mh-parking:client:newParkConfigAdded', -1, parkname, data)
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

local function SaveData(Player, data)
    MySQL.Async.execute(
        "INSERT INTO player_parking (citizenid, citizenname, plate, steerangle, fuel, body, engine, oil, model, modelname, data, time, coords, cost, parktime, parking) VALUES (@citizenid, @citizenname, @plate, @steerangle, @fuel, @body, @engine, @oil, @model, @modelname, @data, @time, @coords, @cost, @parktime, @parking)",
        {
            ["@citizenid"] = GetCitizenid(Player),
            ["@citizenname"] = GetUsername(Player),
            ["@plate"] = data.plate,
            ["@steerangle"] = data.steerangle,
            ["@fuel"] = data.fuel,
            ["@body"] = data.body,
            ["@engine"] = data.engine,
            ["@oil"] = data.oil,
            ["@model"] = data.model,
            ["@modelname"] = data.modelname,
            ["@data"] = json.encode(data),
            ["@time"] = os.time(),
            ["@coords"] = json.encode(data.coords),
            ["@cost"] = data.cost,
            ["@parktime"] = data.parktime,
            ["@parking"] = data.parking
        })
    MySQL.Async.execute('UPDATE player_vehicles SET state = 3 WHERE plate = @plate AND citizenid = @citizenid', {
        ["@plate"] = data.plate,
        ["@citizenid"] = GetCitizenid(Player)
    })
    if Config.UseOnlyForVipPlayers then -- only allow for vip players
        MySQL.Async.execute('UPDATE player_parking_vips SET hasparked = hasparked + 1 WHERE citizenid = @citizenid', {
            ["@citizenid"] = GetCitizenid(Player)
        })
    end
    TriggerClientEvent("mh-parking:client:addVehicle", -1, {
        vehicle = data,
        steerangle = data.steerangle,
        plate = data.plate,
        fuel = data.fuel,
        body = data.body,
        engine = data.engine,
        oil = data.oil,
        citizenid = GetCitizenid(Player),
        citizenname = GetUsername(Player),
        model = data.model,
        modelname = data.modelname,
        coords = json.decode(data.coords),
        cost = data.cost
    })
end

local function DeleteParkedCount(plate)
    MySQL.Async.fetchAll("SELECT * FROM player_vehicles", {}, function(rs)
        for k, v in pairs(rs) do
            if v.plate == plate then
                 MySQL.Async.execute('UPDATE player_parking_vips SET hasparked = hasparked - 1 WHERE citizenid = ?', {v.citizenid})
            end
        end
    end)
end
    
QBCore.Functions.CreateCallback("mh-parking:server:save", function(source, cb, data)
    if Config.UseParkingSystem then
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        local isFound = false
        local model = nil
        if Config.UseOnlyForVipPlayers then -- only allow for vip players
            MySQL.Async.fetchAll("SELECT * FROM player_parking_vips WHERE citizenid = @citizenid", {
                ['@citizenid'] = Player.PlayerData.citizenid
            }, function(rs)
                if type(rs) == 'table' and #rs > 0 then
                    local hasparked = rs[1].hasparked
                    if hasparked < 0 then
                        hasparked = 0
                    end
                    if hasparked < rs[1].maxparking then
                        FindPlayerVehicles(Player.PlayerData.citizenid, function(vehicles)
                            for k, v in pairs(vehicles) do
                                if type(v.plate) and data.plate == v.plate then
                                    model = v.model
                                    isFound = true
                                end
                            end
                            if isFound then
                                MySQL.Async.fetchAll(
                                    "SELECT * FROM player_vehicles WHERE citizenid = @citizenid AND plate = @plate AND state = 3",
                                    {
                                        ['@citizenid'] = Player.PlayerData.citizenid,
                                        ['@plate'] = data.plate
                                    }, function(rs)
                                        if type(rs) == 'table' and #rs > 0 then
                                            cb({
                                                status = false,
                                                message = Lang:t("info.car_already_parked")
                                            })
                                        else
                                            data.model = model
                                            SaveData(Player, data)
                                            cb({
                                                status = true,
                                                message = Lang:t("success.parked")
                                            })
                                        end
                                    end)
                            end
                        end)
                    end
                end
            end)
        else
            FindPlayerVehicles(Player.PlayerData.citizenid, function(vehicles) -- free for all
                for k, v in pairs(vehicles) do
                    if v then
                        if v.plate and data.plate == v.plate then
                            model = v.model
                            isFound = true
                        end
                    end
                end
                if isFound then
                    MySQL.Async.fetchAll(
                        "SELECT * FROM player_vehicles WHERE citizenid = @citizenid AND plate = @plate AND state = 3",
                        {
                            ['@citizenid'] = Player.PlayerData.citizenid,
                            ['@plate'] = data.plate
                        }, function(rs)
                            if type(rs) == 'table' and #rs > 0 then
                                cb({
                                    status = false,
                                    message = Lang:t("info.car_already_parked")
                                })
                            else
                                data.model = model
                                SaveData(Player, data)
                                cb({
                                    status = true,
                                    message = Lang:t("success.parked")
                                })
                            end
                        end)
                else
                    cb({
                        status = false,
                        message = "Vehicle not found, or you are not the owner of this vehicle"
                    })
                end
            end)
        end
    else
        cb({
            status = false,
            message = Lang:t("system.offline")
        })
    end
end)

QBCore.Functions.CreateCallback("mh-parking:server:drive", function(source, cb, data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local isFound = false
    FindPlayerVehicles(Player.PlayerData.citizenid, function(vehicles)
        for k, v in pairs(vehicles) do
            if v then
                if v.plate and data.plate == v.plate then
                    isFound = true
                end
            end
        end
        if isFound then
            MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE citizenid = @citizenid AND plate = @plate", {
                ['@citizenid'] = Player.PlayerData.citizenid,
                ['@plate'] = data.plate
            }, function(rs)
                if type(rs) == 'table' and #rs > 0 and rs[1] then
                    local cost = (math.floor(((os.time() - rs[1].time) / Config.PayTimeInSecs) * rs[1].cost))
                    if cost < 0 then
                        cost = 0
                    end
                    if Pay(src, cost) then
                        MySQL.Async.execute(
                            'DELETE FROM player_parking WHERE plate = @plate AND citizenid = @citizenid', {
                                ["@plate"] = data.plate,
                                ["@citizenid"] = Player.PlayerData.citizenid
                            })
                        MySQL.Async.execute(
                            'UPDATE player_vehicles SET state = 0 WHERE plate = @plate AND citizenid = @citizenid', {
                                ["@plate"] = data.plate,
                                ["@citizenid"] = Player.PlayerData.citizenid
                            })
                        if Config.UseOnlyForVipPlayers then -- only allow for vip players
                            MySQL.Async.fetchAll("SELECT * FROM player_parking_vips WHERE citizenid = @citizenid", {
                                ['@citizenid'] = GetCitizenid(Player)
                            }, function(rs)
                                if type(rs) == 'table' and #rs > 0 then
                                    local hasparked = rs[1].hasparked - 1
                                    if hasparked < 0 then
                                        hasparked = 0
                                    end
                                    MySQL.Async.execute(
                                        'UPDATE player_parking_vips SET hasparked = @hasparked WHERE citizenid = @citizenid',
                                        {
                                            ["@citizenid"] = GetCitizenid(Player),
                                            ["@hasparked"] = hasparked
                                        })
                                end
                            end)
                        end
                        cb({
                            status = true,
                            message = Lang:t("info.has_take_the_car"),
                            citizenid = Player.PlayerData.citizenid,
                            citizenname = GetUsername(Player),
                            vehicle = json.decode(rs[1].data),
                            steerangle = rs[1].steerangle,
                            plate = rs[1].plate,
                            fuel = rs[1].fuel,
                            body = rs[1].body,
                            engine = rs[1].engine,
                            oil = rs[1].oil,
                            model = rs[1].model,
                            modelname = rs[1].modelname,
                            coords = json.decode(rs[1].coords),
                            cost = rs[1].cost
                        })
                        TriggerClientEvent("mh-parking:client:deleteVehicle", -1, {
                            plate = data.plate
                        })
                    else
                        cb({
                            status = false,
                            message = Lang:t('error.not_enough_money'),
                            cost = cost
                        })
                    end
                end
            end)
        else
            cb({
                status = false,
                message = "Vehicle not found, or you are not the owner of this vehicle"
            })
        end
    end)
end)

QBCore.Functions.CreateCallback('mh-parking:server:isOwner', function(source, cb, plate)
    local src = source
    local citizenid = QBCore.Functions.GetPlayer(src).PlayerData.citizenid
    local isOwner = false
    MySQL.Async.fetchAll("SELECT * FROM player_vehicles WHERE citizenid = ?", {citizenid}, function(rs)
        for k, v in pairs(rs) do
            if v.plate == plate then
                isOwner = true
            end
        end
        cb(isOwner)
    end)
end)

QBCore.Functions.CreateCallback('mh-parking:server:payparkspace', function(source, cb, cost)
    local Player = QBCore.Functions.GetPlayer(source)
    if Pay(source, cost) then
        cb({
            status = true,
            message = Lang:t('info.paid_park_space', {
                paid = cost
            })
        })
    else
        cb({
            status = false,
            message = Lang:t('error.not_enough_money')
        })
    end
end)

QBCore.Commands.Add(Config.Command.addvip, Lang:t("commands.addvip"), {{
    name = 'ID',
    help = 'De id van de speler die je wilt toevoegen.'
}, {
    name = 'Amount',
    help = 'Het maximale aantal voertuigen dat een speler kan parkeren'
}}, true, function(source, args)
    if args[1] and tonumber(args[1]) > 0 then
        local amount = Config.MaxStreetParkingPerPlayer
        if args[2] and tonumber(args[2]) > 0 then
            amount = tonumber(args[2])
        end
        MySQL.Async.fetchAll("SELECT * FROM player_parking_vips WHERE citizenid = @citizenid", {
            ['@citizenid'] = GetCitizenid(QBCore.Functions.GetPlayer(tonumber(args[1])))
        }, function(rs)
            if type(rs) == 'table' and #rs > 0 then
                TriggerClientEvent('QBCore:Notify', source, Lang:t('system.already_vip'), "error")
            else
                MySQL.Async.execute(
                    "INSERT INTO player_parking_vips (citizenid, citizenname, maxparking, hasparked) VALUES (@citizenid, @citizenname, @maxparking, @hasparked)",
                    {
                        ["@citizenid"] = GetCitizenid(QBCore.Functions.GetPlayer(tonumber(args[1]))),
                        ["@citizenname"] = GetUsername(QBCore.Functions.GetPlayer(tonumber(args[1]))),
                        ['@maxparking'] = amount,
                        ['@hasparked'] = 0
                    })
                TriggerClientEvent('QBCore:Notify', source, Lang:t('system.vip_add', {
                    username = GetUsername(QBCore.Functions.GetPlayer(tonumber(args[1])))
                }), "success")
            end
        end)
    end
end, 'admin')

QBCore.Commands.Add(Config.Command.removevip, Lang:t("commands.removevip"), {{
    name = 'ID',
    help = 'The id of the player you want to remove.'
}}, true, function(source, args)
    if args[1] and tonumber(args[1]) > 0 then
        MySQL.Async.fetchAll("SELECT * FROM player_parking_vips WHERE citizenid = @citizenid", {
            ['@citizenid'] = GetCitizenid(QBCore.Functions.GetPlayer(tonumber(args[1])))
        }, function(rs)
            if type(rs) == 'table' and #rs > 0 then
                MySQL.Async.execute('DELETE FROM player_parking_vips WHERE citizenid = @citizenid', {
                    ["@citizenid"] = GetCitizenid(QBCore.Functions.GetPlayer(tonumber(args[1])))
                })
                TriggerClientEvent('QBCore:Notify', source, Lang:t('system.vip_remove', {
                    username = GetUsername(QBCore.Functions.GetPlayer(tonumber(args[1])))
                }), "success")
            else
                TriggerClientEvent('QBCore:Notify', source, Lang:t('system.vip_not_found'), "error")
            end
        end)
    end
end, 'admin')

QBCore.Commands.Add(Config.Command.system, "Park System On/Off", {}, true, function(source)
    Config.UseParkingSystem = not Config.UseParkingSystem
    if Config.UseParkingSystem then
        TriggerClientEvent('QBCore:Notify', source, Lang:t('system.enable', {
            type = "system"
        }), "success")
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t('system.disable', {
            type = "system"
        }), "error")
    end
end, 'admin')

QBCore.Commands.Add(Config.Command.usevip, "Park VIP System On/Off", {}, true, function(source)
    Config.UseOnlyForVipPlayers = not Config.UseOnlyForVipPlayers
    if Config.UseOnlyForVipPlayers then
        TriggerClientEvent('QBCore:Notify', source, Lang:t('system.enable', {
            type = "vip only"
        }), "success")
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t('system.disable', {
            type = "vip only"
        }), "error")
    end
end, 'admin')

QBCore.Commands.Add(Config.Command.park, "Park Or Drive", {}, true, function(source)
    TriggerClientEvent("mh-parking:client:park", source)
end)

QBCore.Commands.Add(Config.Command.parknames, "Park Names On/Off", {}, true, function(source)
    Config.UseParkedVehicleNames = not Config.UseParkedVehicleNames
    if Config.UseParkedVehicleNames then
        TriggerClientEvent("mh-parking:client:useparknames", source)
        TriggerClientEvent('QBCore:Notify', source, Lang:t('system.enable', {
            type = "names"
        }), "success")
    else
        TriggerClientEvent("mh-parking:client:useparknames", source)
        TriggerClientEvent('QBCore:Notify', source, Lang:t('system.disable', {
            type = "names"
        }), "error")
    end
end)

QBCore.Commands.Add(Config.Command.parkspotnames, "Park Markers On/Off", {}, true, function(source)
    Config.UseParkedLocationNames = not Config.UseParkedLocationNames
    if Config.UseParkedLocationNames then
        TriggerClientEvent("mh-parking:client:useparkspotnames", source)
        TriggerClientEvent('QBCore:Notify', source, Lang:t('system.enable', {
            type = "parkspot names"
        }), "success")
    else
        TriggerClientEvent("mh-parking:client:useparkspotnames", source)
        TriggerClientEvent('QBCore:Notify', source, Lang:t('system.disable', {
            type = "parkspot names"
        }), "error")
    end
end)

QBCore.Commands.Add(Config.Command.buildmode, "Park Build Mode On/Off", {}, true, function(source)
    PlayerData = QBCore.Functions.GetPlayer(source).PlayerData
    if Config.JobToCreateParkSpaces[PlayerData.job.name] or hasPerMission(source, 'command') then
        if PlayerData.job.onduty or hasPerMission(source, 'command') then
            Config.BuildMode = not Config.BuildMode
            if Config.BuildMode then
                TriggerClientEvent("mh-parking:client:buildmode", source)
                TriggerClientEvent('QBCore:Notify', source, Lang:t('system.enable', {
                    type = "Build Mode"
                }), "success")
            else
                TriggerClientEvent("mh-parking:client:buildmode", source)
                TriggerClientEvent('QBCore:Notify', source, Lang:t('system.disable', {
                    type = "Build Mode"
                }), "error")
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
    if Config.JobToCreateParkSpaces[PlayerData.job.name] or hasPerMission(source, 'command') then
        if PlayerData.job.onduty or hasPerMission(source, 'command') then
            TriggerClientEvent("mh-parking:client:openmenu", source)
        else
            TriggerClientEvent('QBCore:Notify', source, Lang:t('system.must_be_onduty'), "error")
        end
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t('system.not_the_right_job'), "error")
    end
end)
    
RegisterServerEvent('mh-parking:server:unpark', function(plate)
    MySQL.Async.execute('DELETE FROM player_parking WHERE plate = ?', {plate})
    MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = ?', {plate})
    DeleteParkedCount(plate)    
    TriggerClientEvent("mh-parking:client:unparkVehicle", -1, plate, false)
end)

RegisterServerEvent('mh-parking:server:impound', function(plate)
    MySQL.Async.execute('DELETE FROM player_parking WHERE plate = ?', {plate})
    MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = ?', {plate})
    DeleteParkedCount(plate)
    TriggerClientEvent("mh-parking:client:unparkVehicle", -1, plate, true)
end)

RegisterServerEvent('mh-parking:server:refreshVehicles', function(parkingName)
    local src = source
    RefreshVehicles(src)
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

-- Create new parking space.
RegisterServerEvent('mh-parking:server:AddNewParkingSpot', function(source, data, markerOffset)
    if data.cid == "" or data.parkname == "" then
        TriggerClientEvent('QBCore:Notify', source, "Parking space not saved", "error")
    else
        CreateParkingLocation(source, data.cid, data.parkname, data.display, data.radius, data.cost, data.parktime,
            data.job, data.marker, markerOffset, data.parktype)
    end
end)

RegisterNetEvent('police:server:Impound', function(plate, fullImpound, price, body, engine, fuel)
    local src = source
	MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE plate = ?", {plate}, function(rs)
		if type(rs) == 'table' and #rs > 0 and rs[1] ~= nil and rs[1].plate == plate then
			MySQL.Async.execute('DELETE FROM player_parking WHERE plate = ?', {plate})
			MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = ?', {plate})
            DeleteParkedCount(plate)
            TriggerClientEvent("mh-parking:client:unparkVehicle", -1, plate, true)
		end
	end)
end)
