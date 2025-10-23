fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'MH Parking - A Real Life Advanced Parking System.'
author 'MaDHouSe'
version '2.0.0'

files {
	'images/*.*'
}

shared_scripts {
    '@ox_lib/init.lua',
    'locales/locale.lua',
    'locales/*.lua',
    'shared/config.lua',
    'shared/vehicles.lua',
    'shared/functions.lua',
}

client_scripts {
    'core/framework/client.lua',
    'client/main.lua',
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'core/framework/server.lua',
    'server/main.lua',
    'server/update.lua',
}

dependencies {
    'oxmysql',
    'ox_lib',
}