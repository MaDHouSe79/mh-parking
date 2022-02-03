RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    Citizenid = PlayerData.citizenid
    PlayerJob  = PlayerData.job
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

RegisterNetEvent('QBCore:Client:SetDuty', function(duty)
    onDuty = duty
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
    Citizenid = PlayerData.citizenid
end)

RegisterNetEvent("qb-parking:client:refreshVehicles", function(vehicles)
    GlobalVehicles = vehicles
    RemoveVehicles(vehicles)
    Wait(1000)
    SpawnVehicles(vehicles)
    Wait(1000)
end)

RegisterNetEvent("qb-parking:client:addVehicle", function(vehicle)
    SpawnVehicle(vehicle)
end)

RegisterNetEvent("qb-parking:client:deleteVehicle", function(vehicle)
    DeleteLocalVehicle(vehicle)
end)

RegisterNetEvent("qb-parking:client:impoundVehicle",  function(vehicle)
    ImpoundVehicle(vehicle)
end)

RegisterNetEvent("qb-parking:client:stolenVehicle",  function(vehicle)
    StolenVehicle(vehicle)
end)


RegisterNetEvent("qb-parking:client:isUsingParkCommand", function()
    if IsAllowToPark() then
        isUsingParkCommand = true
    end
end)

RegisterNetEvent('qb-parking:client:setParkedVecihleLocation', function(location)
    SetNewWaypoint(location.x, location.y)
    QBCore.Functions.Notify(Lang:t("success.route_has_been_set"), 'success')
end)

