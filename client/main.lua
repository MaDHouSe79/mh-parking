QBCore  = exports['qb-core']:GetCoreObject()
clientSystem = ParkClient()

RegisterKeyMapping('park', 'Park or Drive', 'keyboard', Config.KeyBindButton) 

RegisterCommand(Config.Command.park, function()
    clientSystem.IsUsingCommand = true
end, false)

RegisterCommand(Config.Command.parknames, function()
    clientSystem.CommandParknames()
end, false)

RegisterCommand(Config.Command.notification, function()
    clientSystem.CommandNotification()
end, false)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    clientSystem.SetPlayerData(QBCore.Functions.GetPlayerData())
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    clientSystem.SetPlayerJob(JobInfo)
end)

RegisterNetEvent('QBCore:Client:SetDuty', function(duty)
    clientSystem.SetOnDuty(duty)
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
    clientSystem.SetPlayerData(data)
end)

RegisterNetEvent("qb-parking:client:refreshVehicles", function(vehicles)
    clientSystem.RefreshVehicles(vehicles)
end)

RegisterNetEvent("qb-parking:client:addVehicle", function(vehicle)
    clientSystem.SpawnVehicle(vehicle)
end)

RegisterNetEvent("qb-parking:client:deleteVehicle", function(vehicle)
    clientSystem.DeleteLocalVehicle(vehicle)
end)

RegisterNetEvent("qb-parking:client:impoundVehicle",  function(vehicle)
    clientSystem.Impound(vehicle)
end)

RegisterNetEvent("qb-parking:client:stolenVehicle",  function(vehicle)
    clientSystem.Stolen(vehicle)
end)

RegisterNetEvent('qb-parking:client:setParkedVecihleLocation', function(location)
    clientSystem.SetNewWaypoint(location.x, location.y)
end)

RegisterNetEvent("qb-parking:client:GetUpdate", function(state)
    clientSystem.UpdateSystem(state)
end)

CreateThread(function()
    clientSystem.SetPlayerData(QBCore.Functions.GetPlayerData())
    clientSystem.RunLocatiobControll()
end)

CreateThread(function()
    clientSystem.RunParkControll()
end)

CreateThread(function()
    clientSystem.RunDisplayOwnerText()
end)
