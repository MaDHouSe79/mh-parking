fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'MH Parking - A Real Life Advanced Parking System.'
author 'MaDHouSe'
version '2.0.0'

ui_page 'html/index.html'

files {'core/html/*.html', 'core/html/*.js', 'core/html/*.css', 'core/html/assets/images/*.*'}

shared_scripts {
    '@ox_lib/init.lua', -- (remove -- if you want to uae this)
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
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'core/framework/server.lua',
    'core/rewrite.lua',
    'server/commands.lua',
    'server/main.lua',
    'server/update.lua',
}

dependencies {
    'oxmysql',
    'ox_lib',
}