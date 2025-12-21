-- ═══════════════════════════════════════════════════════════ --
--          MH-PARKING – 100% Statebag by MaDHouSe79           --
-- ═══════════════════════════════════════════════════════════ --
Framework, OnPlayerLoaded, OnPlayerUnload, CreateCallback, AddCommand  = {},  nil, nil, nil, nil

if GetResourceState('es_extended') == 'started' then
    Framework = { name = 'esx', obj = exports['es_extended']:getSharedObject() }
    CreateCallback = Framework.TriggerServerCallback
    AddCommand = Framework.obj.RegisterCommand
    function GetPlayer(src) return Framework.obj.GetPlayerFromId(src) end
    function GetPlayers() return Framework.obj.GetPlayers() end
elseif GetResourceState('qb-core') == 'started' then
    Framework = { name = 'qb', obj = exports['qb-core']:GetCoreObject() }
    CreateCallback = Framework.obj.Functions.CreateCallback
    AddCommand = Framework.obj.Commands.Add
    function GetPlayer(src) return Framework.obj.Functions.GetPlayer(src) end
    function GetPlayers() return Framework.obj.Functions.GetPlayers() end
    function AddMoney(src, amount) local Player = GetPlayer(src) return Player.Functions.AddMoney('cash', amount) end
    function RemoveMoney(src, amount) local Player = GetPlayer(src) return Player.Functions.RemoveMoney('cash', amount) end
elseif GetResourceState('qbx_core') == 'started' then
    Framework = { name = 'qbx', obj = exports['qb-core']:GetCoreObject() }
    CreateCallback = Framework.obj.Functions.CreateCallback
    AddCommand = Framework.obj.Commands.Add
    function GetPlayer(src) return Framework.obj.Functions.GetPlayer(src) end
    function GetPlayers() return Framework.obj.Functions.GetPlayers() end
    function AddMoney(src, amount) local Player = GetPlayer(src) return Player.Functions.AddMoney('cash', amount) end
    function RemoveMoney(src, amount) local Player = GetPlayer(src) return Player.Functions.RemoveMoney('cash', amount) end
end

function IsAdmin(src)
    if IsPlayerAceAllowed(src, 'admin') or IsPlayerAceAllowed(src, 'command') then return true end
    return false
end

function IsPolice(src)
    local Player = GetPlayer(src)
    if Player ~= nil and Player.PlayerData ~= nil and Player.PlayerData.job ~= nil and Player.PlayerData.job.name ~= nil and Player.PlayerData.job.name == 'police' then return true end
    return false  
end

function GetIdentifier(src)
    local Player = GetPlayer(src)
    if Player then
        if Framework.name == "esx" then
            return Player.identifier
        elseif Framework.name == "qb" or Framework.name == "qbx" then
            return Player.PlayerData.citizenid or Player.PlayerData.identifier
        end
    end
    return false
end

function GetFullname(citizenid)
    local info = {fistname = "Unknow", lastname = "Unknow"}
    local target = Database.GetPlayerData(citizenid)
    if Framework.name == "esx" then 
        info = {fistname = target.firstname, lastname = target.lastname}
    elseif Framework.name == "qb" or Framework.name == "qbx" then
        local charinfo = json.decode(target.charinfo)
        info = {fistname = charinfo.firstname, lastname = charinfo.lastname}
    end
    return info
end