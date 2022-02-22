Config                         = {}           -- Holder..

Config.UseSpawnDelay           = true
Config.DeleteDelay             = 500
Config.FreezeDelay             = 100


Config.DisplayDistance         = 20.0         -- 👉 Distence to see text above parked vehicles (player dependent)
Config.parkingButton           = 166          -- 👉 F5 (vehicle exit and or park)
Config.ResetState              = 1            -- 👉 1 is stored in garage, 2 is police impound. 

Config.PlaceOnGroundRadius     = 50.0         -- 👉 Default 50.0, if vehicles are floating, the vehicles get on the ground if you are in this amount of radius of this vehicle.

Config.UseOnlyForVipPlayers    = true         -- 👉 Default true, set it to false, It's not recommended to do that, but if you want you can.
Config.CheckForUpdates         = true         -- 👉 If you want to stay updated keep it on true.


-- 👇 Base config when the server start, this is the default settings
Config.UseParkingSystem        = true         -- 👉 Auto turn on when server is starting. (default true)
Config.UseRoleplayName         = true         -- 👉 If you want to use Roleplay name above the cars (firstname lastname) set this on true
Config.UsePhoneNotification    = false        -- 👉 Auto turn on when server is starting. (default true)
Config.UseParkedVehicleNames   = true         -- 👉 Default is false, if you want to see names just type /park-names on/off if you set this to true it is auto on 


-- 👇 change this to your own commands
Config.Command = {
    park         = 'park',                   -- 👉 User/Admin permission
    parknames    = 'park-names',             -- 👉 User/Admin permission
    notification = 'park-notification',      -- 👉 User/Admin permission
    system       = 'park-system',            -- 👉 Admin permission
    usevip       = 'park-usevip',
    addvip       = 'park-addvip',            -- 👉 Admin permission (/park-addvip [id] [amount])
    removevip    = 'park-removevip'          -- 👉 Admin permission
}

-- 👇 Dont change this, you will not be able to park if you change this...
Config.ParkingLocation = {x = 232.11, y = -770.14, z = 0.0, w = 900.10, s = 99999099.0}
