-- [[ ===================================================== ]] --
-- [[              MH Park System by MaDHouSe79             ]] --
-- [[ ===================================================== ]] --
Framework, CreateCallback, AddCommand = nil, nil, nil
if Config.Framework == 'esx' then
    Framework = exports['es_extended']:getSharedObject()
    CreateCallback = Framework.RegisterServerCallback
    AddCommand = Framework.RegisterCommand
    function GetPlayers() return Framework.Players end
    function GetPlayer(src) return Framework.GetPlayerFromId(src) end
    function GetJob(src) return Framework.GetPlayerFromId(src).job end
    function GetCitizenId(src) local Player = GetPlayer(src) return Player.identifier end
    function GetCitizenFullname(src) local Player = GetPlayer(src) return Player.name end
elseif Config.Framework == 'qb' then
    Framework = exports['qb-core']:GetCoreObject()
    CreateCallback = Framework.Functions.CreateCallback
    AddCommand = Framework.Commands.Add
    function GetPlayers() return Framework.Players end
    function GetPlayer(src) return Framework.Functions.GetPlayer(src) end
    function GetJob(src) return Framework.Functions.GetPlayer(src).PlayerData.job end
    function GetPlayerDataByCitizenId(citizenid) return Framework.Functions.GetPlayerByCitizenId(citizenid) or Framework.Functions.GetOfflinePlayerByCitizenId(citizenid) end
    function GetCitizenId(src) local Player = Framework.Functions.GetPlayer(src) return Player.PlayerData.citizenid end
    function GetCitizenFullname(src) local Player = Framework.Functions.GetPlayer(src) return Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname end
elseif Config.Framework == 'qbx' then
    Framework = exports['qb-core']:GetCoreObject()
    CreateCallback = Framework.Functions.CreateCallback
    AddCommand = Framework.Commands.Add
    function GetPlayers() return Framework.Players end
    function GetPlayer(src) return Framework.Functions.GetPlayer(src) end
    function GetJob(src) return Framework.Functions.GetPlayer(src).PlayerData.job end
    function GetPlayerDataByCitizenId(citizenid) return Framework.Functions.GetPlayerByCitizenId(citizenid) or Framework.Functions.GetOfflinePlayerByCitizenId(citizenid) end
    function GetCitizenId(src) local Player = Framework.Functions.GetPlayer(src) return Player.PlayerData.citizenid end
    function GetCitizenFullname(src) local Player = Framework.Functions.GetPlayer(src) return Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname end
end

function Notify(src, message, type, length)
    lib.notify(src, {title = "MH Parking V2", description = message, type = type})
end

function InstallDatabase()
	if Config.Framework == 'esx' then -- ESX Database
		MySQL.Async.execute('ALTER TABLE users ADD COLUMN IF NOT EXISTS parkvip INT NULL DEFAULT 0')
		MySQL.Async.execute('ALTER TABLE users ADD COLUMN IF NOT EXISTS parkmax INT NULL DEFAULT 0')
		MySQL.Async.execute('ALTER TABLE owned_vehicles ADD COLUMN IF NOT EXISTS steerangle INT NULL DEFAULT 0')
		MySQL.Async.execute('ALTER TABLE owned_vehicles ADD COLUMN IF NOT EXISTS location TEXT NULL DEFAULT NULL')
		MySQL.Async.execute('ALTER TABLE owned_vehicles ADD COLUMN IF NOT EXISTS street TEXT NULL DEFAULT NULL')
        MySQL.Async.execute('ALTER TABLE owned_vehicles ADD COLUMN IF NOT EXISTS parktime INT NULL DEFAULT 0')
        MySQL.Async.execute('ALTER TABLE owned_vehicles ADD COLUMN IF NOT EXISTS time BIGINT NULL DEFAULT 0')
	elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then --- QB or QBX Database
		MySQL.Async.execute('ALTER TABLE players ADD COLUMN IF NOT EXISTS parkvip INT NULL DEFAULT 0')
		MySQL.Async.execute('ALTER TABLE players ADD COLUMN IF NOT EXISTS parkmax INT NULL DEFAULT 0')
		MySQL.Async.execute('ALTER TABLE player_vehicles ADD COLUMN IF NOT EXISTS steerangle INT NULL DEFAULT 0')
		MySQL.Async.execute('ALTER TABLE player_vehicles ADD COLUMN IF NOT EXISTS location TEXT NULL DEFAULT NULL')
		MySQL.Async.execute('ALTER TABLE player_vehicles ADD COLUMN IF NOT EXISTS street TEXT NULL DEFAULT NULL')
        MySQL.Async.execute('ALTER TABLE player_vehicles ADD COLUMN IF NOT EXISTS parktime INT NULL DEFAULT 0')
        MySQL.Async.execute('ALTER TABLE player_vehicles ADD COLUMN IF NOT EXISTS time BIGINT NULL DEFAULT 0')
	end
end
InstallDatabase()
