Config                           = {}           -- DONT EDIT CHANGE OR REMOVE THIS!!!.
Config.Trailers                  = {}           -- DONT EDIT CHANGE OR REMOVE THIS!!!.
Config.Parkzones                 = {}           -- DONT EDIT CHANGE OR REMOVE THIS!!!.
Config.ReservedParkList          = {}           -- DONT EDIT CHANGE OR REMOVE THIS!!!.
Config.Parkzones                 = {}           -- DONT EDIT CHANGE OR REMOVE THIS!!!.
Config.BuildMode                 = false        -- DONT EDIT CHANGE OR REMOVE THIS!!!.

Config.CheckForUpdates           = true         -- Default true
Config.ResetState                = 1            -- Default 1, 1 is stored in garage, 2 is police impound. 

Config.ImpoundPrice              = 1000

Config.KeyParkBindButton         = "F5"         -- Default F5
Config.KeyParkMenuBindButton     = "F6"         -- Default F6
Config.ParkingButton             = 166          -- Default 166, [F5] 


-- just if you use other sripts than default qb
Config.FuelScript                = "LegacyFuel" -- Default LegacyFuel, but you can use cc-fuel aswell ot a other fuel scirpt
Config.KeyScriptTrigger          = "qb-vehiclekeys:server:AcquireVehicleKeys" -- in case you have a other key script

Config.DisplayMarkerDistance     = 15           -- Default 10
Config.PayTimeInSecs             = 3600         -- 1 hour

Config.UseParkingSystem          = true         -- Default true,  this turn the parking system On or Off.
Config.UseOnlyPreCreatedSpots    = false        -- Default false,  if you only want to use pre-created locations.
Config.UseParkingBlips           = true         -- Default true,  if you want to see parking blips 
Config.UseParkedVehicleNames     = true         -- Default true  if you want parking vehicles names.
Config.ParkedNamesViewDistance   = 5            -- Default 5,     you canset this higher
Config.UseOnlyForVipPlayers      = false        -- Default false  if you only want that vip players can park.
Config.UseParkedLocationNames    = true         -- Default true   if you want parking owner names above vehicles.


Config.UseOwnerNames             = true         -- Default true   if you want to use owner names
Config.UseRoleplayName           = true         -- Default true   if you want to use roleplay names
Config.UseTargetEye              = true         -- Default false  if you want to use target eye, to park a trailer you need target eye.


-- only for server performance
Config.UseMaxParkingPerPlayer    = true         -- Default true if you want to use a max amount of parked vehicles per player
Config.MaxStreetParkingPerPlayer = 2            -- Default 2, total allowed parked vehicles per player in world
Config.UseMaxParkingOnServer     = true         -- Default true if you want to use a max amount of vehicles that can park on the server.
Config.MaxServerParkedVehicles   = 50           -- Default 50, total allowed parked vehicles on the server.


-- 👇 Sometime the vehicle spawn on top of each other and to avoid this you can use this delay below.
Config.UseSpawnDelay          = true            -- Default true, if your vehicles spawn on top of each other, set this to true
Config.DeleteDelay            = 1500            -- Default 1500, a delay for spawning in a other vehicle. (works only if Config.UseSpawnDelay = true)
Config.FreezeDelay            = 500             -- Default 50, a sort delay for freezeing a vehicle. (works only if Config.UseSpawnDelay = true)


Config.JobToCreateParkSpaces = {                -- The job that you need to able to create parking places.
    ['realestate'] = true,
    ['police']    = false, 
    ['mechanic']  = false,
}

Config.Trailers = {                             -- Allowed trailers you can use
    ['TRAILER'] = {                             -- Real model name
        ['model'] = 'Trailers',                 -- In case the modelname does not work propperly, use this as model name
        ['offset'] = 2.0,                       -- Offset of the trailer. this is on the Z axes and it wil force minus offset
    },
    ['boattrailer'] = {
        ['model'] = 'boattrailer',
        ['offset'] = 2.0,
    },
}

Config.Vehicles = {                             -- Allowed Vehicles that are not spawn back cause of the real model name.
    ['ADDER'] = {                               -- Real model name
        ['model'] = 'adder',                    -- In case the modelname does not work propperly, use this as model name
    },
}

Config.Command = {                              -- DONT EDIT OR REMOVE THIS!!!.
    park          = 'park',                     -- User/Admin permission
    parknames     = 'park-names',               -- User/Admin permission
    parkspotnames = 'park-lotnames',            -- User/Admin permission
    system        = 'park-system',              -- Admin permission
    usevip        = 'park-usevip',              -- Admin permission
    addvip        = 'park-addvip',              -- Admin permission
    removevip     = 'park-removevip',           -- Admin permission
    createmenu    = 'park-cmenu',               -- Admin permission (Create NUI Menu)
    buildmode     = 'park-bmode',               -- Admin permission (Build Mode Markers)
}

Config.IgnoreJobs = {                           -- If true this job wil be iqnore by the system when parking
    ['police']    = true,
    ['ambulance'] = true,
    ['mechanic']  = true,
}

Config.ParkColours = {                          -- Marker colours
    ['white']  = { r = 255, g = 255, b = 255 }, -- White
    ['green']  = { r = 9,   g = 255, b = 0   }, -- Green
    ['blue']   = { r = 9,   g = 9,   b = 255 }, -- Blue
    ['yellow'] = { r = 255, g = 230, b = 0   }, -- Yellow
    ['orange'] = { r = 255, g = 128, b = 0   }, -- Orange
    ['grey']   = { r = 148, g = 148, b = 148 }, -- Grey
    ['black']  = { r = 6,   g = 5,   b = 5   }, -- Black
    ['red']    = { r = 255, g = 0,   b = 0   }, -- Ted
}

Config.ParkingLocation  = {x = 232.11, y = -770.14, z = 0.0, w = 900.10, s = 99999099.0}

Config.DebugMode = false -- if you want to see debug in your console.
