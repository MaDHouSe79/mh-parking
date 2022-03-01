Config                            = {}           -- DONT EDIT CHANGE OR REMOVE THIS!!!.
Config.Trailers                   = {}           -- DONT EDIT CHANGE OR REMOVE THIS!!!.
Config.Parkzones                  = {}           -- DONT EDIT CHANGE OR REMOVE THIS!!!.
Config.ReservedParkList           = {}           -- DONT EDIT CHANGE OR REMOVE THIS!!!.
Config.Parkzones                  = {}           -- DONT EDIT CHANGE OR REMOVE THIS!!!.

Config.KeyParkBindButton          = "F5"         -- Default F5
Config.KeyParkMenuBindButton      = "F6"         -- Default F6
Config.ParkingButton              = 166          -- Default 166, [F5] 

Config.UseSpawnDelay              = true         -- Default true
Config.SpawnTimeDelay             = 100          -- Default 500

Config.DisplayDistance            = 20.0         -- Default 20.0
Config.MinSpeedToPark             = 0.9          -- Default 0.9
Config.InteractDistance           = 5.0          -- Default 5.0

Config.ForceGroundedDistane       = 100          -- Default 100
Config.ForceGroundenInMilSec      = 1500         -- Default 1500.
Config.BuildModeDisplayDistance   = 50           -- Default 50
Config.DisplayMarkerDistance      = 3            -- Default 3
Config.ResetState                 = 1            -- Default 1, 1 is stored in garage, 2 is police impound. 

Config.CheckForUpdates            = true         -- Default true
Config.UseParkingSystem           = true         -- Default true
Config.UsePhoneNotification       = false        -- Default false
Config.UseParkingBlips            = true         -- Default true
Config.UseParkedVehicleNames      = true         -- Default false 
Config.UseOnlyForVipPlayers       = false        -- Default false
Config.UseParkedLocationNames     = true         -- Default true
Config.UseRoleplayName            = true         -- Default true
Config.UseStopSpeedForPark        = true         -- Default true
Config.UseOnplayerLoad            = false        -- Default false
Config.UseTargetEye               = false        -- Default true
Config.DisplayPlayerAndPolice     = false        -- Default false


Config.BuildMode                  = false        -- DONT EDIT CHANGE OR REMOVE THIS!!!.

Config.JobToCreateParkSpaces = {                 -- The job that you need to able to create parking places.
    ['realestate'] = true,
    ['police']    = false, 
    ['mechanic']  = false,
}

Config.Trailers = {                              -- Allowed trailers you can use
    ['TRAILER'] = {                              -- Real model name
        ['model'] = 'Trailers',                  -- In case the modelname does not work propperly, use this as model name
        ['offset'] = 2.0,                        -- Offset of the trailer. this is on the Z axes and it wil force minus offset
    },
    ['boattrailer'] = {
        ['model'] = 'boattrailer',
        ['offset'] = 2.0,
    },
}

Config.Vehicles = {                              -- Allowed Vehicles that are not spawn back cause of the real model name.
    ['ADDER'] = {                                -- Real model name
        ['model'] = 'adder',                     -- In case the modelname does not work propperly, use this as model name
    },
}

Config.Command = {                               -- DONT EDIT OR REMOVE THIS!!!.
    park          = 'park',                      -- User/Admin permission
    parknames     = 'park-names',                -- User/Admin permission
    parkspotnames = 'park-lotnames',             -- User/Admin permission
    notification  = 'park-notification',         -- User/Admin permission
    system        = 'park-system',               -- Admin permission
    usevip        = 'park-usevip',               -- Admin permission
    addvip        = 'park-addvip',               -- Admin permission
    removevip     = 'park-removevip',            -- Admin permission
    createmenu    = 'park-create',               -- Admin permission
    buildmode     = 'park-build',                -- Admin permission
}


Config.IgnoreJobs = {                            -- If true this job wil be iqnore by the system then parking
    ['police']    = true,
    ['ambulance'] = true,
    ['mechanic']  = true,
}


Config.ParkColours = {                           -- Marker colours
    ['white']  = { r = 255, g = 255, b = 255 },  -- White
    ['green']  = { r = 9,   g = 255, b = 0   },  -- Green
    ['blue']   = { r = 9,   g = 9,   b = 255 },  -- Blue
    ['yellow'] = { r = 255, g = 230, b = 0   },  -- Yellow
    ['orange'] = { r = 255, g = 128, b = 0   },  -- Orange
    ['grey']   = { r = 148, g = 148, b = 148 },  -- Grey
    ['black']  = { r = 6,   g = 5,   b = 5   },  -- Black
    ['red']    = { r = 255, g = 0,   b = 0   },  -- Ted
}


Config.ParkingLocation  = {x = 232.11, y = -770.14, z = 0.0, w = 900.10, s = 99999099.0}


-- Poly Parking zones
Config.DebugPolyzone              = false        -- Default false
Config.UseParkZones               = false        -- Default false

Config.Parkzones["blokkenpark"] = { 
    ['name']     = 'Blokkenpark Parking',
    ['showBlip'] = true,
    ['enter']    = vector3(208.32, -809.08, 31.06),
    ['zones']    = {
        vector2(239.88, -820.42),
        vector2(252.73, -784.92),
        vector2(258.39, -786.84),
        vector2(271.99, -748.68),
        vector2(226.44, -733.08),
        vector2(199.94, -805.8),
        vector2(239.88, -820.42),
    },
}

Config.Parkzones["blokkenpark1"] = { 
    ['name']     = 'Back Parking',
    ['showBlip'] = true,
    ['zones']    = {
        vector2(110.04, -1046.33),
        vector2(95.75, -1077.86),
        vector2(112.06, -1084.7),
        vector2(115.73, -1085.28),
        vector2(164.05, -1085.11),
        vector2(168.08, -1084.19),
        vector2(172.57, -1084.04),
        vector2(172.98, -1071.87),
        vector2(150.98, -1063.91),
        vector2(148.16, -1059.24),
        vector2(110.04, -1046.33),
    },
}

Config.Parkzones["blueparking"] = { 
    ['name'] = 'Blue Parking',
    ['showBlip'] = true,
    ['zones'] = {
        vector2(-571.55474853516, -1167.9885253906),
        vector2(-560.74426269531, -1123.7308349609),
        vector2(-558.39019775391, -1108.1878662109),
        vector2(-558.26678466797, -1101.1785888672),
        vector2(-555.52624511719, -1101.2495117188),
        vector2(-555.25598144531, -1094.7706298828),
        vector2(-556.1689453125, -1088.4525146484),
        vector2(-590.29736328125, -1087.6552734375),
        vector2(-599.29724121094, -1079.7904052734),
        vector2(-622.7001953125, -1079.7532958984),
        vector2(-624.24230957031, -1166.8181152344)
    },

}

Config.Parkzones["redparking"] = { 
    ['name'] = 'Red Garage Parking',
    ['showBlip'] = true,
    ['zones'] = {
        vector2(-265.52224731445, -752.78411865234),
        vector2(-276.49160766602, -777.06677246094),
        vector2(-284.95486450195, -774.57147216797),
        vector2(-289.12078857422, -784.21063232422),
        vector2(-319.15814208984, -773.93432617188),
        vector2(-335.52655029297, -787.63275146484),
        vector2(-335.45526123047, -792.39379882812),
        vector2(-362.92642211914, -792.30969238281),
        vector2(-363.0451965332, -751.48718261719),
        vector2(-359.57531738281, -746.93621826172),
        vector2(-360.78924560547, -726.58422851562),
        vector2(-355.55081176758, -727.20971679688),
        vector2(-355.66015625, -709.26098632812),
        vector2(-355.54187011719, -707.77020263672),
        vector2(-350.4609375, -707.95776367188),
        vector2(-349.09564208984, -712.43273925781)
    },
}

Config.Parkzones["altaparking"] = { 
    ['name'] = 'Alta Parking',
    ['showBlip'] = true,
    ['zones'] = {
        vector2(-364.69653320312, -866.26135253906),
        vector2(-268.81900024414, -889.12109375),
        vector2(-282.29278564453, -923.46887207031),
        vector2(-298.38165283203, -920.12725830078),
        vector2(-316.87905883789, -985.56439208984),
        vector2(-365.83947753906, -970.10211181641)
    },
}
