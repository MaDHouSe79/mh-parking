fx_version 'cerulean'
games { 'gta5' }

author 'MaDHouSe'
description 'Realistic Vehicle Parking'
version '1.0.0'

shared_scripts {
	'@qb-core/shared/locale.lua',
        'locales/en.lua', -- change en to your language
        'shared/config.lua',
	'shared/functions.lua',
	'shared/variables.lua',
}

client_scripts {
	--"client/waypoint/3DWaypointClient.net.dll", -- only uncommend this if you want to have 3d waypoints
	'client/functions/functions.lua',
	'client/actions/drive.lua',
	'client/actions/park.lua',
	'client/actions/impound.lua',
	'client/actions/commands.lua',
	'client/events/events.lua',
	'client/threads/threads.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/events/events.lua',
	'server/functions/functions.lua',
	'server/callbacks/callback.lua',
}

-- only uncommend this if you want to have 3d waypoints.
--[[
file 'client/waypoint/3DWaypointClient.ini'
]]--

dependencies {
	'oxmysql',
	'qb-core',
	'qb-phone',
	'qb-garages',
	'qb-vehiclekeys',
}

lua54 'yes'
