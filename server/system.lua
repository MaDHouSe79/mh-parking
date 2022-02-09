local QBCore = exports['qb-core']:GetCoreObject()

-- Player Class
local Player = function()
    self = {} 
    self.player = nil
    self.username = nil
    self.citizenid = nil

    -- Set Player
    self.SetPlayer = function(player)
        self.player = player
        return self
    end

    -- Get Username
    self.GetUsername = function()
        self.username = self.player.PlayerData.name
        if Config.useRoleplayName then
            self.username = self.player.PlayerData.charinfo.firstname ..' '.. self.player.PlayerData.charinfo.lastname
        end
        return self.username
    end

    -- Get Citizenid
    self.GetCitizenid = function(player)
        self.citizenid = self.player.PlayerData.citizenid
        return self.citizenid
    end

     -- return object
    return self
end

-- Vehicles class
local Vehicles = function()
	self = {} 
    self.vehicles = {}

    -- Add vehicle
    self.Add = function(vehicle)  
        self.vehicles[#self.vehicles+1]={vehicle=json.decode(vehicle.data),plate=vehicle.plate,citizenid=vehicle.citizenid,citizenname=vehicle.citizenname,model=vehicle.model}
    end

    -- Remove vehicle
    self.Remove = function(num)        
        self.vehicles[num] = nil 
    end

    -- Get vehicle
    self.Get = function(num)
         return self.vehicles[num]       
    end

    -- Returns list
    self.List = function() 
        return self.vehicles            
    end

    -- Clear list
    self.Clear = function()            
        self.vehicles = {}       
    end

     -- Return object
    return self
end

-- Server Class
ParkServer = function()
	self = {}
   
    -- Get Player username
    self.GetUsername = function(player)
        tmpPlayer = Player()
        tmpPlayer.SetPlayer(player)
        return tmpPlayer.GetUsername()
    end

    -- Get Citizenid
    self.GetCitizenid = function(player)
        tmpPlayer = Player()
        tmpPlayer.SetPlayer(player)
        return tmpPlayer.GetCitizenid()
    end

    -- Check Version
    self.CheckVersion = function(err, responseText, headers)
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
            print("\n"..resourceName.." is up to date. (^2"..curVersion.."^7)")
        end
    end

    -- Get all vehicles the player owned.
    self.FindPlayerVehicles = function(citizenid, cb)
        local vehicles = Vehicles()
        MySQL.Async.fetchAll("SELECT * FROM player_vehicles WHERE citizenid = @citizenid", {['@citizenid'] = citizenid}, function(rs)
            for k, v in pairs(rs) do
                vehicles.Add(v)
            end
            cb(vehicles.List())
        end)
    end

    -- Get the number of the vehicles.
    self.GetVehicleNumOfParking = function()
        local rs = MySQL.Async.fetchAll('SELECT id FROM player_parking', {})
        if type(rs) == 'table' then
            return #rs
        else
            return 0
        end
    end

    -- Refresh client local vehicles entities.
    self.RefreshVehicles = function(src)
        if src == nil then src = -1 end
            local vehicles = Vehicles()
            MySQL.Async.fetchAll("SELECT * FROM player_parking", {}, function(rs)
            if type(rs) == 'table' and #rs > 0 then
                for k, v in pairs(rs) do
                    vehicles.Add(v)
                    if QBCore.Functions.GetPlayer(src) ~= nil and QBCore.Functions.GetPlayer(src).PlayerData.citizenid == v.citizenid then
                        if not Config.ImUsingOtherKeyScript then
                            TriggerClientEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlayer(src), v.plate)
                        end
                    end
                end
                TriggerClientEvent("qb-parking:client:refreshVehicles", src, vehicles.List())
            end
        end)
    end

    self.FindVehicle = function(plate, vehicles)
        for k, v in pairs(vehicles) do
	    if type(v.plate) and plate == v.plate then
	        return  true
	    end
        end
        return false
    end

    -- Return object
    return self
end
