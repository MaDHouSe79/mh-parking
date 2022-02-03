if Config.CheckForUpdates then
    Citizen.CreateThread( function()
        updatePath = "/MaDHouSe79/qb-parking"
        resourceName = "("..GetCurrentResourceName()..")"
        PerformHttpRequest("https://raw.githubusercontent.com"..updatePath.."/master/version", checkVersion, "GET")
    end)
end

RegisterServerEvent("qb-parking:CheckVersion") 
AddEventHandler("qb-parking:CheckVersion", function()
    if updateavail then
        TriggerClientEvent("qb-parking:client:Update", source, true)
    else
        TriggerClientEvent("qb-parking:client:Update", source, false)
    end
end)

-- When the client request to refresh the vehicles tables.
RegisterServerEvent('qb-parking:server:refreshVehicles', function(parkingName)
    RefreshVehicles(source)
end)
