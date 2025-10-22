-- [[ ===================================================== ]] --
-- [[               MH Parking V2 by MaDHouSe79             ]] --
-- [[ ===================================================== ]] --
Config = {}
---------------------------------------------------------------------------------------
Config.Framework = "qb"             -- For qb/qbx/esx
Config.FuelScript = "mh-fuel"       -- For qb-fuel/mh-fuel/ox_fuel
Config.KeyScript = "qb-vehiclekeys" -- For qb-vehiclekeys/qbx_vehiclekeys
---------------------------------------------------------------------------------------
-- 3d text above parked vehicles
Config.Display3DText = true
Config.DisplayDistance = 15
Config.DisplayToAllPlayers = true
---------------------------------------------------------------------------------------
Config.OnlyAutoParkWhenEngineIsOff = true
Config.keepEngineOnWhenAbandoned = false
---------------------------------------------------------------------------------------
Config.DisableParkedVehiclesCollision = false
---------------------------------------------------------------------------------------
Config.Display3DText = true
Config.SaveSteeringAngle = true
---------------------------------------------------------------------------------------
-- This are gas pumps where you can't use the park system.
Config.DisableNeedByPumpModels = {
    ['prop_vintage_pump'] = true,
    ['prop_gas_pump_1a'] = true,
    ['prop_gas_pump_1b'] = true,
    ['prop_gas_pump_1c'] = true,
    ['prop_gas_pump_1d'] = true,
    ['prop_gas_pump_old2'] = true,
    ['prop_gas_pump_old3'] = true
}
---------------------------------------------------------------------------------------
Config.UseRadiusForBlips = true -- When true, you see a circle raduis on the map where you can.t park.
-- This are locations where you can't use the park system.
-- the reason for this is it can be that you need to use the vehicle on that point.
-- So if you want that, you can't use the park system cause you can't use the vehicle when parked.
-- If you want to see the radius on the map you need to set Config.DebugBlipForRadius to true
Config.UseUnableParkingBlips = true -- If this is true, you see blip for radius in the map.
Config.NoParkingLocations = {
    -- Default locations
    {coords = vector3(-333.0179, -135.5331, 38.3735), radius = 15.0, color = 1, sprite = 163, job = 'mechanic'},   -- ls costum 1
    {coords = vector3(731.7255, -1088.9088, 21.30), radius = 10.0, color = 1, sprite = 163, job = 'mechanic'},     -- ls costum 2
    {coords = vector3(-1155.3927, -2008.8042, 12.8369), radius = 15.0, color = 1, sprite = 163, job = 'mechanic'}, -- ls costum 3
    {coords = vector3(1178.6400, 2639.0259, 37.7538), radius = 15.0, color = 1, sprite = 163, job = 'mechanic'},   -- ls costum 4
    {coords = vector3(107.4339, 6624.6465, 31.7872), radius = 15.0, color = 1, sprite = 163, job = 'mechanic'},    -- ls costum 5
    {coords = vector3(-212.2455, -1325.4657, 30.2536), radius = 18.0, color = 1, sprite = 163, job = 'mechanic'},  -- bennys
    {coords = vector3(477.6514, -1021.8871, 27.3948), radius = 20.0, color = 1, sprite = 163, job = 'police'},     -- police back gate
    {coords = vector3(291.2697, -587.2904, 42.5459), radius = 15.0, color = 1, sprite = 163, job = 'ambulance'},   -- hospital front door
    {coords = vector3(408.9072, -1639.3105, 28.6553), radius = 25.0, color = 1, sprite = 163, job = nil},          -- Impound
    {coords = vector3(-644.0579, -232.3487, 37.1400), radius = 30.0, color = 1, sprite = 163, job = nil},          -- Jewelery
    {coords = vector3(-614.0209, -279.3901, 38.1910), radius = 30.0, color = 1, sprite = 163, job = nil},          -- Jewelery
    {coords = vector3(539.6107, -181.2838, 53.8477), radius = 30.0, color = 1, sprite = 163, job = 'mechanic'},    -- a mechanic shop close by the highway
    -- Car lift locations (mh-carlift)
    {coords = vector3(2345.31, 3141.512, 47.37874), radius = 10.0, color = 1, sprite = 163, job = 'scraptard'},    -- scraptard pos 1 (in de hal) (left)
    {coords = vector3(2358.866, 3139.057, 47.37369), radius = 10.0, color = 1, sprite = 163, job = 'scraptard'},   -- scraptard pos 2 (in de hal) (right)
    {coords = vector3(2333.153, 3042.031, 47.31144), radius = 10.0, color = 1, sprite = 163, job = 'scraptard'},   -- scraptard pos 3 (outside) (left)
    {coords = vector3(2339.808, 3042.183, 47.3141), radius = 10.0, color = 1, sprite = 163, job = 'scraptard'},    -- scraptard pos 4 (outside) (right)
    --
    {coords = vector3(137.2251, -3029.2095, 20.4204), radius = 50.0, color = 1, sprite = 163, job = nil},          --
    -- you can add more here.
}
---------------------------------------------------------------------------------------
-- Parking lots
-- If false players can park anyware, if true they can park only on parkinglots.
-- Players are not allwed to park close by -> (Config.DisableNeedByLocations or Config.DisableNeedByPumpModels)
-- If you want to see the radius in the map you need to set Config.DebugBlipForRadius to true
Config.UseParkingLotsOnly = false
Config.UseParkingLotsBlips = true  --If true players see parking lot blips on the map
Config.AllowedParkingLots = {
    {coords = vector3(96.9411, -1402.1882, 28.5636), radius = 10.0, color = 2, sprite = 237},   -- parkinglot 1
    {coords = vector3(228.7590, -786.5502, 30.0108), radius = 40.0, color = 2, sprite = 237},   -- parkinglot 2
    {coords = vector3(40.5961, -869.4373, 29.8342), radius = 30.0, color = 2, sprite = 237},    -- parkinglot 3
    {coords = vector3(-318.9083, -763.3641, 33.3298), radius = 50.0, color = 2, sprite = 237},  -- parkinglot 4
    {coords = vector3(-323.1429, -909.4062, 30.4433), radius = 50.0, color = 2, sprite = 237},  -- parkinglot 5
    {coords = vector3(140.4888, -1072.2378, 28.5544), radius = 50.0, color = 2, sprite = 237},  -- parkinglot 6
    {coords = vector3(16.6738, -1735.4730, 28.6658), radius = 40.0, color = 2, sprite = 237},   -- parkinglot 7
    {coords = vector3(280.1839, -332.9366, 44.2822), radius = 20.0, color = 2, sprite = 237},   -- parkinglot 8
    {coords = vector3(65.4638, 24.4819, 68.9776), radius = 15.0, color = 2, sprite = 237},      -- parkinglot 9
    {coords = vector3(-1136.9712, -753.5242, 18.7554), radius = 17.0, color = 2, sprite = 237}, -- parkinglot 10
    {coords = vector3(1702.2766, 3769.2583, 33.8426), radius = 10.0, color = 2, sprite = 237},  -- parkinglot 11
    {coords = vector3(45.9778, 6376.5962, 30.5970), radius = 20.0, color = 2, sprite = 237},    -- parkinglot 12
    {coords = vector3(-759.9047, 5537.7280, 32.8484), radius = 20.0, color = 2, sprite = 237},  -- parkinglot 13
    {coords = vector3(-464.8556, -769.8253, 29.9245), radius = 20.0, color = 2, sprite = 237},  -- parkinglot 14
    {coords = vector3(253.9985, -1156.1332, 28.6003), radius = 15.0, color = 2, sprite = 237},  -- parkinglot 15
    {coords = vector3(1183.6377, -1550.7142, 34.1825), radius = 20.0, color = 2, sprite = 237}, -- parkinglot 16
    {coords = vector3(131.8025, -712.3470, 32.4903), radius = 50.0, color = 2, sprite = 237},   -- parkinglot 17
    -- you can add here.
}