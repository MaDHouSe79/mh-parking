-- [[ ===================================================== ]] --
-- [[              MH Park System by MaDHouSe79             ]] --
-- [[ ===================================================== ]] --
Framework, CreateCallback, AddCommand = nil, nil, nil

if GetResourceState("es_extended") ~= 'missing' then
    Framework = exports['es_extended']:getSharedObject()
    CreateCallback = Framework.RegisterServerCallback
    AddCommand = Framework.RegisterCommand

    function GetPlayers()
        return Framework.Players
    end

    function GetPlayer(source)
        return Framework.GetPlayerFromId(source)
    end

    function GetJob(source)
        return Framework.GetPlayerFromId(source).job
    end

    function GetCitizenId(src)
        local xPlayer = GetPlayer(src)
        return xPlayer.identifier
    end

    function GetCitizenFullname(src)
        local xPlayer = GetPlayer(src)
        return xPlayer.name
    end

elseif GetResourceState("qb-core") ~= 'missing' then
    Framework = exports['qb-core']:GetCoreObject()
    CreateCallback = Framework.Functions.CreateCallback
    AddCommand = Framework.Commands.Add

    function GetPlayers()
        return Framework.Players
    end

    function GetPlayer(source)
        return Framework.Functions.GetPlayer(source)
    end

    function GetJob(source)
        return Framework.Functions.GetPlayer(source).PlayerData.job
    end

    function GetPlayerDataByCitizenId(citizenid)
        return Framework.Functions.GetPlayerByCitizenId(citizenid) or Framework.Functions.GetOfflinePlayerByCitizenId(citizenid)
    end

    function GetCitizenId(src)
        local xPlayer = GetPlayer(src)
        return xPlayer.PlayerData.citizenid
    end

    function GetCitizenFullname(src)
        local xPlayer = GetPlayer(src)
        return xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname
    end

elseif GetResourceState("qbx_core") ~= 'missing' then
    Framework = exports['qb-core']:GetCoreObject()
    CreateCallback = Framework.Functions.CreateCallback
    AddCommand = Framework.Commands.Add

    function GetPlayers()
        return Framework.Players
    end

    function GetPlayer(source)
        return Framework.Functions.GetPlayer(source)
    end

    function GetJob(source)
        return Framework.Functions.GetPlayer(source).PlayerData.job
    end

    function GetPlayerDataByCitizenId(citizenid)
        return Framework.Functions.GetPlayerByCitizenId(citizenid) or Framework.Functions.GetOfflinePlayerByCitizenId(citizenid)
    end

    function GetCitizenId(src)
        local xPlayer = GetPlayer(src)
        return xPlayer.PlayerData.citizenid
    end

    function GetCitizenFullname(src)
        local xPlayer = GetPlayer(src)
        return xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname
    end

end

function Notify(src, message, type, length)
    lib.notify(src, {
        title = "MH Park System",
        description = message,
        type = type
    })
end

-- Install Database
local function InstallDatabase()
    if Config.Framework == 'esx' then -- ESX Database
        MySQL.Async.execute('ALTER TABLE users ADD COLUMN IF NOT EXISTS parkvip INT NULL DEFAULT 0')
        MySQL.Async.execute('ALTER TABLE users ADD COLUMN IF NOT EXISTS parkmax INT NULL DEFAULT 0')
        MySQL.Async.execute('ALTER TABLE owned_vehicles ADD COLUMN IF NOT EXISTS steerangle INT NULL DEFAULT 0')
        MySQL.Async.execute('ALTER TABLE owned_vehicles ADD COLUMN IF NOT EXISTS location TEXT NULL DEFAULT NULL')
        MySQL.Async.execute('ALTER TABLE owned_vehicles ADD COLUMN IF NOT EXISTS lastlocation TEXT NULL DEFAULT NULL')
        MySQL.Async.execute('ALTER TABLE owned_vehicles ADD COLUMN IF NOT EXISTS street TEXT NULL DEFAULT NULL')
        MySQL.Async.execute('ALTER TABLE owned_vehicles ADD COLUMN IF NOT EXISTS parktime INT NULL DEFAULT 0')
        MySQL.Async.execute('ALTER TABLE owned_vehicles ADD COLUMN IF NOT EXISTS time BIGINT NOT NULL DEFAULT 0')
        MySQL.Async.execute('ALTER TABLE owned_vehicles ADD COLUMN IF NOT EXISTS trailerdata LONGTEXT NULL DEFAULT NULL')
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then --- QB or QBX Database
        MySQL.Async.execute('ALTER TABLE players ADD COLUMN IF NOT EXISTS parkvip INT NULL DEFAULT 0')
        MySQL.Async.execute('ALTER TABLE players ADD COLUMN IF NOT EXISTS parkmax INT NULL DEFAULT 0')
        MySQL.Async.execute('ALTER TABLE player_vehicles ADD COLUMN IF NOT EXISTS steerangle INT NULL DEFAULT 0')
        MySQL.Async.execute('ALTER TABLE player_vehicles ADD COLUMN IF NOT EXISTS location TEXT NULL DEFAULT NULL')
        MySQL.Async.execute('ALTER TABLE player_vehicles ADD COLUMN IF NOT EXISTS lastlocation TEXT NULL DEFAULT NULL')
        MySQL.Async.execute('ALTER TABLE player_vehicles ADD COLUMN IF NOT EXISTS street TEXT NULL DEFAULT NULL')
        MySQL.Async.execute('ALTER TABLE player_vehicles ADD COLUMN IF NOT EXISTS parktime INT NULL DEFAULT 0')
        MySQL.Async.execute('ALTER TABLE player_vehicles ADD COLUMN IF NOT EXISTS time BIGINT NOT NULL DEFAULT 0')
        MySQL.Async.execute('ALTER TABLE player_vehicles ADD COLUMN IF NOT EXISTS trailerdata LONGTEXT NULL DEFAULT NULL')
    end
end
InstallDatabase()
