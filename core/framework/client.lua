-- ═══════════════════════════════════════════════════════════ --
--          MH-PARKING – 100% Statebag by MaDHouSe79           --
-- ═══════════════════════════════════════════════════════════ --
Framework, TriggerCallback, OnPlayerLoaded, OnPlayerUnload = nil, nil, nil, nil
isLoggedIn, PlayerData = false, {}

if GetResourceState("es_extended") == 'started' then
    Framework = { name = 'esx', obj = exports['es_extended']:getSharedObject() }
    TriggerCallback = Framework.obj.TriggerServerCallback
    OnPlayerLoaded = 'esx:playerLoaded'
    OnPlayerUnload = 'esx:playerUnLoaded'
    function GetPlayerData() TriggerCallback('esx:getPlayerData', function(data) PlayerData = data end) return PlayerData end
    function IsDead() return (GetEntityHealth(PlayerPedId()) <= 0) end
elseif GetResourceState("qb-core") == 'started' then
    Framework = { name = 'qb', obj = exports['qb-core']:GetCoreObject() }
    TriggerCallback = Framework.obj.Functions.TriggerCallback
    OnPlayerLoaded = 'QBCore:Client:OnPlayerLoaded'
    OnPlayerUnload = 'QBCore:Client:OnPlayerUnload'
    function GetPlayerData() return Framework.obj.Functions.GetPlayerData() end
    function IsDead() return Framework.obj.Functions.GetPlayerData().metadata['isdead'] end
    RegisterNetEvent('QBCore:Player:SetPlayerData', function(data) PlayerData = data end)
    RegisterNetEvent('QBCore:Client:UpdateObject', function() Framework.obj = exports['qb-core']:GetCoreObject() end)
elseif GetResourceState("qbx_core") == 'started' then
    Framework = { name = 'qb', obj = exports['qb-core']:GetCoreObject() }
    TriggerCallback = Framework.obj.Functions.TriggerCallback
    OnPlayerLoaded = 'QBCore:Client:OnPlayerLoaded'
    OnPlayerUnload = 'QBCore:Client:OnPlayerUnload'
    function GetPlayerData() return Framework.obj.Functions.GetPlayerData() end
    function IsDead() return Framework.obj.Functions.GetPlayerData().metadata['isdead'] end
    RegisterNetEvent('QBCore:Player:SetPlayerData', function(data) PlayerData = data end)
    RegisterNetEvent('QBCore:Client:UpdateObject', function() Framework.obj = exports['qb-core']:GetCoreObject() end)
end

function GetIdentifier()
    PlayerData = GetPlayerData()
    return PlayerData.citizenid or PlayerData.identifier
end

function IsPolice()
    PlayerData = GetPlayerData()
    if PlayerData ~= nil and PlayerData.job ~= nil and PlayerData.job.name ~= nil and PlayerData.job.name == 'police' then return true end
    return false  
end