--[[ ===================================================== ]]--
--[[           MH NPC Services Script by MaDHouSe          ]]--
--[[ ===================================================== ]]--

fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'MH - ParkSystem'
author 'MaDHouSe'
version '2.0.0'

files {'core/images/*.*'}

shared_scripts {
    '@ox_lib/init.lua',
    'locales/locale.lua',
    'locales/*.lua',
    'shared/config.lua',
    'shared/configs/*.lua',
    'shared/vehicles.lua',
    'shared/functions.lua',
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'core/framework/client.lua',
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'core/framework/server.lua',
    --'core/rewrite.lua',
    'server/main.lua',
    'server/update.lua',
}

dependencies {
    'oxmysql',
    'qb-core',
}


