RegisterKeyMapping('park', 'Park or Drive', 'keyboard', 'F5') 

RegisterCommand(Config.Command.park, function()
    isUsingParkCommand = true
end, false)

RegisterCommand(Config.Command.parknames, function()
    HideParkedVehicleNames = not HideParkedVehicleNames
    if HideParkedVehicleNames then
        QBCore.Functions.Notify(Lang:t('system.enable', {type = "names"}), "primary", 1500)
    else
        QBCore.Functions.Notify(Lang:t('system.disable', {type = "names"}), "primary", 1500)
    end
end, false)

RegisterCommand(Config.Command.notification, function()
    PhoneNotification = not PhoneNotification
    if PhoneNotification then
        QBCore.Functions.Notify(Lang:t('system.enable', {type = "notifications"}), "primary", 1500)
    else
        QBCore.Functions.Notify(Lang:t('system.disable', {type = "notifications"}), "primary", 1500)
    end
end, false)

-- Admin Only
RegisterCommand(Config.Command.vip, function()
    if IsAdmin(Citizenid) then
        OnlyAllowVipPlayers = not OnlyAllowVipPlayers
        if OnlyAllowVipPlayers then
            QBCore.Functions.Notify(Lang:t('system.parkvip', {type = "vip"}), "primary", 1500)
        else
            QBCore.Functions.Notify(Lang:t('system.freeforall', {type = "freeforall"}), "primary", 1500)
        end
    else
        QBCore.Functions.Notify(Lang:t('system.no_permission'), "primary", 1500)
    end
end, false)

RegisterCommand(Config.Command.system, function()
    if IsAdmin(Citizenid) then
        UseParkingSystem = not UseParkingSystem
        if UseParkingSystem then
            QBCore.Functions.Notify(Lang:t('system.enable', {type = "system"}), "primary", 1500)
        else
            QBCore.Functions.Notify(Lang:t('system.disable', {type = "system"}), "primary", 1500)
        end
    else
        QBCore.Functions.Notify(Lang:t('system.no_permission'), "error", 1500)
    end
end, false)
