RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()	
    PlayerData = QBCore.Functions.GetPlayerData() 
    Citizenid  = PlayerData.citizenid 
    PlayerJob  = PlayerData.job
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo) 
     PlayerJob = JobInfo 
end)

RegisterNetEvent('QBCore:Client:SetDuty', function(duty) 
    onDuty = duty 
end)

RegisterNetEvent("qb-parking:client:refreshVehicles", function(vehicles) 
    GlobalVehicles = vehicles
    RemoveVehicles(vehicles)
    Citizen.Wait(1000)
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

RegisterNetEvent("qb-parking:client:isUsingParkCommand", function(vehicle) 
    if IsAllowToPark() then
        isUsingParkCommand = true
    end
end)

RegisterNetEvent('qb-parking:client:setParkedVecihleLocation', function(location)
	SetWaypoint(location.x, location.y)
end)