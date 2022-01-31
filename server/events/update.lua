-- This wil let you know is there is an update.
if Config.CheckForUpdates then
    Citizen.CreateThread( function()
        updatePath = "/MaDHouSe79/qb-parking"
        resourceName = "qb-parking ("..GetCurrentResourceName()..")"
        PerformHttpRequest("https://raw.githubusercontent.com"..updatePath.."/master/version", checkVersion, "GET")
    end)
end
RegisterServerEvent("dp:CheckVersion") 
AddEventHandler("dp:CheckVersion", function()
    if updateavail then
        TriggerClientEvent("dp:Update", source, true)
    else
        TriggerClientEvent("dp:Update", source, false)
    end
end)

function checkVersion(err, responseText, headers)
    curVersion = LoadResourceFile(GetCurrentResourceName(), "version")
    if responseText == nil then
        print("^1"..resourceName.." check for updates failed ^7")
        return
    end
    if curVersion ~= responseText and tonumber(curVersion) < tonumber(responseText) then
        updateavail = true
        print("\n^1----------------------------------------------------------------------------------^7")
        print(resourceName.." is outdated, latest version is: ^2"..responseText.."^7, installed version: ^1"..curVersion.."^7!\nupdate from https://github.com"..updatePath.."")
        print("^1----------------------------------------------------------------------------------^7")
    elseif tonumber(curVersion) > tonumber(responseText) then
        print("\n^3----------------------------------------------------------------------------------^7")
        print(resourceName.." git version is: ^2"..responseText.."^7, installed version: ^1"..curVersion.."^7!")
        print("^3----------------------------------------------------------------------------------^7")
    else
        print(resourceName.." is up to date. (^2"..curVersion.."^7)")
    end
end