-- On Player Load
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    Citizenid = PlayerData.citizenid
    PlayerJob  = PlayerData.job
end)

-- On job update
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

-- On jody set
RegisterNetEvent('QBCore:Client:SetDuty', function(duty)
    onDuty = duty
end)

-- QBCore Player SetPlayerData
RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
    Citizenid = PlayerData.citizenid
end)

-- Server send to client with vehicles data
RegisterNetEvent("qb-parking:client:refreshVehicles", function(vehicles)
    GlobalVehicles = vehicles
    RemoveVehicles(vehicles)
    Wait(1000)
    SpawnVehicles(vehicles)
    Wait(1000)
end)

-- Client site Add vehicle
RegisterNetEvent("qb-parking:client:addVehicle", function(vehicle)
    SpawnVehicle(vehicle)
end)

-- Client site Delete vehicle
RegisterNetEvent("qb-parking:client:deleteVehicle", function(vehicle)
    DeleteLocalVehicle(vehicle)
end)

-- impound vehicle
RegisterNetEvent("qb-parking:client:impoundVehicle",  function(vehicle)
    ImpoundVehicle(vehicle)
end)

-- Client site is Using Park Command
RegisterNetEvent("qb-parking:client:isUsingParkCommand", function()
    if IsAllowToPark() then
        if UpdateAvailable then
            QBCore.Functions.Notify(Lang:t("system.update_needed"), 'success')
        else
            isUsingParkCommand = true
        end
    end
end)

-- To add a waypoint where the vehicle had been pakred on the map
RegisterNetEvent('qb-parking:client:setParkedVecihleLocation', function(location)
    SetNewWaypoint(location.x, location.y)
    QBCore.Functions.Notify(Lang:t("success.route_has_been_set"), 'success')
end)

-- for Update checks
RegisterNetEvent("qb-parking:client:Update", function(state)
    UpdateAvailable = state
end)
