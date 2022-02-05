Config                        = {}

Config.CheckForUpdates        = true         -- 👉 If you want to stay updated keep it on true.
Config.Maxcarparking          = 50           -- 👉 Max allowed cars in world space (Default, dont go to hight)
Config.DisplayDistance        = 50           -- 👉 Distence to see text above parked vehicles (player dependent)

Config.KeyBindButton          = "F5"         -- 👉 If you want to change the drive and park button. (you must use /binds for this)
Config.parkingButton          = 166          -- 👉 F5 (vehicle exit and or park)
Config.useRoleplayName        = true         -- 👉 If you want to use Roleplay name above the cars (firstname lastname) set this on true
Config.YourFuelExportName     = 'LegacyFuel' -- 👉 Default is LegacyFuel, if you use a other fuel script, for example cc-fuel
Config.UseStopSpeedForPark    = true         -- 👉 Default true
Config.MinSpeedToPark         = 1            -- 👉 Default 0 

Config.ImUsingOtherKeyScript  = false        -- 👉 Default false, if you have an other vehiclekeys script, set this to true. 

-- 👇 Base config when the server start, this is the default settings
Config.PhoneNotification      = true         -- 👉 Auto turn on when server is starting. (default true)
Config.UseParkingSystem       = true         -- 👉 Auto turn on when server is starting. (default true)
Config.HideParkedVehicleNames = false        -- 👉 Default is false, if you want to see names just type /park-names on/off if you set this to true it is auto on 

-- 👇 change this to your own commands
Config.Command = {
    park         = 'park',                   -- User/Admin permission
    parknames    = 'park-names',             -- User/Admin permission
    notification = 'park-notification',      -- User/Admin permission
    vip          = 'park-vip',               -- Admin permission
    system       = 'park-system',            -- Admin permission
    addvip       = 'park-addvip',            -- Admin permission (/park-addvip [id] [amount])
    removevip    = 'park-removevip'          -- Admin permission
}

-- 👇 Dont change this, you will not be able to park if you change this...
Config.ParkingLocation = {x = 232.11, y = -770.14, z = 0.0, w = 900.10, s = 99999099.0}
