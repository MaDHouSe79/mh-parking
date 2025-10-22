fx_version 'cerulean'
game 'gta5'

description 'MH - Parking V2'
author 'MaDHouSe'
version '2.0.0'

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

lua54 'yes'
