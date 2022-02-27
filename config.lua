Config                            = {}
Config.CheckForUpdates            = true      -- 👉 If you want to stay updated keep it on true.
Config.UsingTargetEye             = true      -- 👉 if you have target eye 

Config.DisplayDistance            = 20.0      -- 👉 Distence to see text above parked vehicles (player dependent)

Config.KeyBindButton              = "F5"      -- 👉 If you want to change the drive and park button. (you must use /binds for this)
Config.parkingButton              = 166       -- 👉 F5 (vehicle exit and or park)
Config.ResetState                 = 1         -- 👉 1 is stored in garage, 2 is police impound. 

Config.UseParkingSystem           = true      -- 👉 Auto turn on when server is starting. (default true)
Config.UsePhoneNotification       = false     -- 👉 Auto turn on when server is starting. (default true)
Config.UseParkingBlips            = true      -- 👉 Default true
Config.UseParkedVehicleNames      = true      -- 👉 Default is false, if you want to see names just type /park-names on/off if you set this to true it is auto on 
Config.UseOnlyPreCreatedParkSpots = true      -- 👉 true If players can only park on pre-created locations, if false ot true player are not able to park on pre-created park lots
Config.UseOnlyForVipPlayers       = false     -- 👉 if you want to use it for vip players only
Config.UseParkedLocationNames     = true      -- 👉 if you want to see markers
Config.UseRoleplayName            = true      -- 👉 If you want to use Roleplay name above the cars (firstname lastname) set this on true

Config.UseStopSpeedForPark        = true      -- 👉 Default true
Config.MinSpeedToPark             = 0.9       -- 👉 Default 0.9 the min speed to be able to park


Config.UseSpawnDelay              = true      -- 👉 Default true, if your vehicles spawn on top of each other, set this to true
Config.TimeDelay                  = 500       -- 👉 Default 500, a delay for spawning in a other vehicle. (works only if Config.UseSpawnDelay = true)

Config.DisplayPlayerAndPolice     = false     -- 👉 if you want to see the police vehicle info or citizen vehicle info.
Config.ForceGroundedDistane       = 100       -- 👉 Force vehicle to the ground in a amount of distace, default is 100 this is 50mtr, make this higher will cost proccess
Config.ForceGroundenInMilSec      = 1500      -- 👉 Force vehicle to the ground in a amount of miliseconds, default is 1500.

-- 👇 change this to your own commands
Config.Command = {
    park          = 'park',                   -- 👉 User/Admin permission
    parknames     = 'park-names',             -- 👉 User/Admin permission
    parkspotnames = 'park-lotnames',          -- 👉 User/Admin permission
    notification  = 'park-notification',      -- 👉 User/Admin permission
    system        = 'park-system',            -- 👉 Admin permission
    usevip        = 'park-usevip',            -- 👉 Admin permission
    addvip        = 'park-addvip',            -- 👉 Admin permission
    removevip     = 'park-removevip',         -- 👉 Admin permission
    createmenu    = 'park-create',            -- 👉 Admin permission
    buildmode     = 'park-build',             -- 👉 Admin permission
}

-- 👇 Dont change this, you will not be able to park if you change this...
Config.ParkingLocation = {x = 232.11, y = -770.14, z = 0.0, w = 900.10, s = 99999099.0}
Config.UseParkedLocationNames     = true      -- 👉 if you want to see markers
Config.ReservedParkList = {}                  -- 👉 DONT EDIT OR REMOVE THIS!!!.

Config.BuildModeDisplayDistance   = 25        -- 👉 View Distance In Build Mode, You are able to see more markers to line up new park zones.
Config.DisplayMarkerRadius        = 3         -- 👉 When you see the markers, lower is less distane, a higher value, you are able to the markers from more distance.

Config.IgnoreJobs = {                         -- 👉 if true this job wil be iqnore by the system then parking
    ['police']    = true,
    ['ambulance'] = true,
    ['mechanic']  = true,
}

Config.ParkColours = {
    ['white']  = { r = 255, g = 255, b = 255 }, -- white
    ['green']  = { r = 9,   g = 255, b = 0   }, -- green
    ['blue']   = { r = 9,   g = 9,   b = 255 }, -- blue
    ['yellow'] = { r = 255, g = 230, b = 0   }, -- yellow
    ['orange'] = { r = 255, g = 128, b = 0   }, -- orange
    ['grey']   = { r = 148, g = 148, b = 148 }, -- grey
    ['black']  = { r = 6,   g = 5,   b = 5   }, -- black
    ['red']    = { r = 255, g = 0,   b = 0   }, -- red
}
