
-- Admin Commands
AddCommand("addparkvip", "Add player as vip", {}, true, function(source, args)
    local src, amount, targetID = source, SV_Config.DefaultMaxParking, -1
    if args[1] and tonumber(args[1]) > 0 then targetID = tonumber(args[1]) end
    if args[2] and tonumber(args[2]) > 0 then amount = tonumber(args[2]) end
    if targetID ~= -1 then
        Database.AddVip(targetID, amount)
        if targetID ~= src then Notify(targetID, 'player add as vip', "success", 10000) end
        Notify(src, 'is added as vip', "success", 10000)
    end
end, 'admin')

AddCommand("removeparkvip", "Remove player as vip", {}, true, function(source, args)
    local src, targetID = source, -1
    if args[1] and tonumber(args[1]) > 0 then targetID = tonumber(args[1]) end
    if targetID ~= -1 then
        Database.RemovedVip(targetID)
        Notify(src, 'player removed as vip', "success", 10000)
    end
end, 'admin')

AddCommand("parkmenu", "Player park menu", {}, true, function(source, args)
    local src = source
    TriggerClientEvent('mh-parking:openparkmenu', src)
end)