Config                        = {}
Config.debug                  = true
Config.Maxcarparking          = 50           -- max allowed cars in world space (Default, dont go to hight)
Config.DisplayDistance        = 50           -- distence to see test above vehicles
Config.SoundWhenCloseDoors    = false        -- sound when closing doors
Config.parkingButton          = 166          -- F5 (vehicle exit and or park)


-- 👇 Base config when the server start
Config.PhoneNotification      = true         -- 👉 Auto turn on when server is starting.
Config.UseParkingSystem       = true         -- 👉 Auto turn on when server is starting.
Config.OnlyAllowVipPlayers    = true         -- 👉 I recommend, to use this mod only for vip players....
Config.HideParkedVehicleNames = false        -- 👉 default is true, if you want to see names just type /park-names on/off if you set this to true it is auto on 


Config.Command = {
	park         = 'park',                   -- User/Admin permission
	parknames    = 'park-names',             -- User/Admin permission
	notification = 'park-notification',      -- User/Admin permission
	vip          = 'park-vip',               -- Admin permission
	system       = 'park-system',            -- Admin permission
}

Config.VipPlayers = {                        -- Add more vip plaers if you want.
	[1] = {
		username  = "MaDHouSe",              -- Just to know who it is
		citizenid = "AWC63661",              -- you gen cet this from the databse players table copy citizenid and add this here
		isAdmin   = true,
	},

	[2] = {                                  -- example player 2 to add more players as VIP
		username  = "changeme",
		citizenid = "changeme",
		isAdmin   = false,
	},
	[3] = {                                  -- example player 3 to add more players as VIP
		username  = "changeme",
		citizenid = "changeme",
		isAdmin   = false,
	}, -- just add more here
}

Config.ParkingLocation = {x = 232.11, y = -770.14, z = 0.0, w = 900.10, s = 99999099.0}