-- ═══════════════════════════════════════════════════════════ --
--          MH-PARKING – 100% Statebag by MaDHouSe79           --
-- ═══════════════════════════════════════════════════════════ --
fx_version 'cerulean'
game 'gta5'

author 'MaDHouSe79'
description 'MH Parking - 100% Statebag - Server side spawns.'
version '1.0.0'
lua54 'yes'

use_experimental_fxv2_oal "yes"

ui_page 'html/index.html'

files {
    'html/theme.ini',
    'html/index.html',
    'html/assets/css/style.css',
    'html/assets/js/script.js',
    'html/assets/images/*.png',
    'core/images/*.*',
}

shared_scripts {
    '@ox_lib/init.lua',
    'locales/locale.lua',
    'locales/*.lua',
}


client_script {
    'core/framework/client.lua',
    'core/functions/client.lua',
    'core/target/client.lua',
    'client/main.lua',
}

server_script {
    '@oxmysql/lib/MySQL.lua',
    'core/sv_config.lua',
    'core/vehicles.lua',
    'core/framework/server.lua',    
    'core/database.lua',
    'core/functions/server.lua',
    'server/main.lua',
    'server/update.lua',
}