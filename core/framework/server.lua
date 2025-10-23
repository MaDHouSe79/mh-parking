-- [[ ===================================================== ]] --
-- [[               MH Parking V2 by MaDHouSe79             ]] --
-- [[ ===================================================== ]] --
Framework, CreateCallback, AddCommand = nil, nil, nil
if Config.Framework == 'esx' then
    Framework = exports['es_extended']:getSharedObject()
    CreateCallback = Framework.RegisterServerCallback
    AddCommand = Framework.RegisterCommand
    function GetPlayers() return Framework.Players end
    function GetPlayer(source) return Framework.GetPlayerFromId(source) end
    function GetJob(source) return Framework.GetPlayerFromId(source).job end
    function GetCitizenId(src) local xPlayer = GetPlayer(src) return xPlayer.identifier end
    function GetCitizenFullname(src) local xPlayer = GetPlayer(src) return xPlayer.name end
elseif Config.Framework == 'qb' then
    Framework = exports['qb-core']:GetCoreObject()
    CreateCallback = Framework.Functions.CreateCallback
    AddCommand = Framework.Commands.Add
    function GetPlayers() return Framework.Players end
    function GetPlayer(source) return Framework.Functions.GetPlayer(source) end
    function GetJob(source) return Framework.Functions.GetPlayer(source).PlayerData.job end
    function GetPlayerDataByCitizenId(citizenid) return Framework.Functions.GetPlayerByCitizenId(citizenid) or Framework.Functions.GetOfflinePlayerByCitizenId(citizenid) end
    function GetCitizenId(src) local xPlayer = GetPlayer(src) return xPlayer.PlayerData.citizenid end
    function GetCitizenFullname(src) local xPlayer = GetPlayer(src) return xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname end
elseif Config.Framework == 'qbx' then
    Framework = exports['qb-core']:GetCoreObject()
    CreateCallback = Framework.Functions.CreateCallback
    AddCommand = Framework.Commands.Add
    function GetPlayers() return Framework.Players end
    function GetPlayer(source) return Framework.Functions.GetPlayer(source) end
    function GetJob(source) return Framework.Functions.GetPlayer(source).PlayerData.job end
    function GetPlayerDataByCitizenId(citizenid) return Framework.Functions.GetPlayerByCitizenId(citizenid) or Framework.Functions.GetOfflinePlayerByCitizenId(citizenid) end
    function GetCitizenId(src) local xPlayer = GetPlayer(src) return xPlayer.PlayerData.citizenid end
    function GetCitizenFullname(src) local xPlayer = GetPlayer(src) return xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname end
end

function Notify(src, message, type, length)
    if GetResourceState("ox_lib") ~= 'missing' then
        lib.notify(src, {title = "MH Parking V2", description = message, type = type})
    else
        Framework.Functions.Notify(src, {text = "MH Parking V2", caption = message}, type, length)
    end
end

function InstallDatabase()
	if Config.Framework == 'esx' then -- ESX Database
		MySQL.Async.execute('ALTER TABLE users ADD COLUMN IF NOT EXISTS parkvip INT NULL DEFAULT 0')
		MySQL.Async.execute('ALTER TABLE users ADD COLUMN IF NOT EXISTS parkmax INT NULL DEFAULT 0')
		MySQL.Async.execute('ALTER TABLE owned_vehicles ADD COLUMN IF NOT EXISTS steerangle INT NULL DEFAULT 0')
		MySQL.Async.execute('ALTER TABLE owned_vehicles ADD COLUMN IF NOT EXISTS location TEXT NULL DEFAULT NULL')
		MySQL.Async.execute('ALTER TABLE owned_vehicles ADD COLUMN IF NOT EXISTS street TEXT NULL DEFAULT NULL')
        MySQL.Async.execute('ALTER TABLE owned_vehicles ADD COLUMN IF NOT EXISTS parktime INT NULL DEFAULT 0')
        MySQL.Async.execute('ALTER TABLE owned_vehicles ADD COLUMN IF NOT EXISTS time BIGINT NOT NULL')
	elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then --- QB or QBX Database
		MySQL.Async.execute('ALTER TABLE players ADD COLUMN IF NOT EXISTS parkvip INT NULL DEFAULT 0')
		MySQL.Async.execute('ALTER TABLE players ADD COLUMN IF NOT EXISTS parkmax INT NULL DEFAULT 0')
		MySQL.Async.execute('ALTER TABLE player_vehicles ADD COLUMN IF NOT EXISTS steerangle INT NULL DEFAULT 0')
		MySQL.Async.execute('ALTER TABLE player_vehicles ADD COLUMN IF NOT EXISTS location TEXT NULL DEFAULT NULL')
		MySQL.Async.execute('ALTER TABLE player_vehicles ADD COLUMN IF NOT EXISTS street TEXT NULL DEFAULT NULL')
        MySQL.Async.execute('ALTER TABLE player_vehicles ADD COLUMN IF NOT EXISTS parktime INT NULL DEFAULT 0')
        MySQL.Async.execute('ALTER TABLE player_vehicles ADD COLUMN IF NOT EXISTS time BIGINT NOT NULL')
	end
end
InstallDatabase()