-- Admin Commands
AddCommand('deletepark', 'Delete Parked', { {name = "id", info = "player id"}, { name = "filename", help = "filename"} }, false, function(source, args)
    local src = source 
    TriggerClientEvent('mh-parking:client:DeletePark', src, args)
end, 'admin')

AddCommand('createpark', 'Create parked', { {name = "id", info = "player id"}, { name = "filename", help = "filename"}, { name = "job", help = "job"}, { name = "label", help = "label"} }, false, function(source, args)
    local src = source
    local id, name, job, label = nil, nil, nil, nil
    if args[1] ~= nil then id = args[1] end
    if args[2] ~= nil then name = args[2] end
	if args[3] ~= nil then job = args[3] end
	if args[4] ~= nil then label = args[4] end
	if args[5] ~= nil then label = label.." "..args[5] end
	if args[6] ~= nil then label = label.." "..args[6] end
	if args[7] ~= nil then label = label.." "..args[7] end
    if id ~= nil and name ~= nil and label ~= nil then
	    TriggerClientEvent('mh-parking:client:CreatePark', src, {id = id, name = name, job = job, label = label})
    end
end, 'admin')

AddCommand("addparkvip", 'Add player as vip', {}, true, function(source, args)
	local src, amount, targetID = source, Config.Maxparking, -1
	if args[1] and tonumber(args[1]) > 0 then targetID = tonumber(args[1]) end
	if args[2] and tonumber(args[2]) > 0 then amount = tonumber(args[2]) end
	if targetID ~= -1 then
		local Player = GetPlayer(targetID)
		if Player then
			if Config.Framework == 'esx' then
				MySQL.Async.execute("UPDATE users SET parkvip = ?, parkmax = ? WHERE owner = ?", { 1, amount, Player.identifier })
				if targetID ~= src then Notify(targetID, 'player add as vip', "success", 10000) end
				Notify(src, 'is added as vip', "success", 10000)
			elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
				MySQL.Async.execute("UPDATE players SET parkvip = ?, parkmax = ? WHERE citizenid = ?", { 1, amount, Player.PlayerData.citizenid })
				if targetID ~= src then Notify(targetID, 'player add as vip', "success", 10000) end
				Notify(src, 'is added as vip', "success", 10000)
			end
		end
	end
end, 'admin')

AddCommand("removeparkvip", 'Remove player as vip', {}, true, function(source, args)
	local src, targetID = source, -1
	if args[1] and tonumber(args[1]) > 0 then targetID = tonumber(args[1]) end
	if targetID ~= -1 then
		local Player = GetPlayer(targetID)
		if Player then
			if Config.Framework == 'esx' then
				MySQL.Async.execute("UPDATE users SET parkvip = ?, parkmax = ? WHERE owner = ?", { 0, 0, Player.identifier })
				Notify(src, 'player removed as vip', "success", 10000)
			elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
				MySQL.Async.execute("UPDATE players SET parkvip = ?, parkmax = ? WHERE citizenid = ?", { 0, 0, Player.PlayerData.citizenid })
				Notify(src, 'player removed as vip', "success", 10000)
			end
		end
	end
end, 'admin')

AddCommand("parkresetall", 'reset all players', {}, true, function(source, args)
    if Config.Framework == 'esx' then
        MySQL.Async.execute('UPDATE owned_vehicles SET stored = ?, location = ?, street = ?, parktime = ?, time = ?', { 1, nil, nil, 0, 0 })
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        MySQL.Async.execute('UPDATE player_vehicles SET state = ?, location = ?, street = ?, parktime = ?, time = ?', { 1, nil, nil, 0, 0 })
    end
end, 'admin')

AddCommand("parkresetplayer", 'reset a player', {}, true, function(source, args)
    if args ~= nil and args[1] ~= nil and type(args[1]) == 'number' then
        local id = tonumber(args[1])
        local target = GetPlayer(id)
        local citizenid = GetCitizenId(id)
        if Config.Framework == 'esx' then
             MySQL.Async.execute('UPDATE owned_vehicles SET stored = ?, location = ?, street = ?, parktime = ?, time = ? WHERE owner = ?', { 1, nil, nil, 0, 0, citizenid })
        elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
            MySQL.Async.execute('UPDATE player_vehicles SET state = ?, location = ?, street = ?, parktime = ?, time = ? WHERE citizenid = ?', { 1, nil, nil, 0, 0, citizenid })           
        end
    end
end, 'admin')

AddCommand("toggledebugpoly", 'Toggle debug polyzone on or off', {}, true, function(source, args)
    local src = source
    TriggerClientEvent('mh-parking:client:toggleDebugPoly', src)
end, 'admin')

-- User Commands
AddCommand("togglesteerangle", 'Toggle steer angle on or off', {}, true, function(source, args)
    local src = source
    TriggerClientEvent('mh-parking:client:toggleSteerAngle', src)
end)

AddCommand("toggleparktext", 'Toggle park text on or off', {}, true, function(source, args)
    local src = source
    TriggerClientEvent('mh-parking:client:toggleParkText', src)
end)

AddCommand("parkmenu", 'Open Park Systen Menu', {}, true, function(source, args)
    local src = source
    TriggerClientEvent('mh-parking:client:OpenParkMenu', src, {status = true})
end)