fx_version 'cerulean'
games { 'gta5' }

author 'MaDHouSe'
description 'QB Realistic Vehicle Parking'
version '1.4'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua', -- change en to your language
    'config.lua',
    'shared/functions.lua',
    'shared/variables.lua',
}

client_scripts {
    'client/main.lua',
    'client/functions.lua',
    'client/actions/drive.lua',
    'client/actions/park.lua',
    'client/actions/impound.lua',
    'client/actions/commands.lua',
    'client/events.lua',
    'client/threads.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/events.lua',
    'server/functions.lua',
    'server/callback.lua',
}

dependencies {
    'oxmysql',
    'qb-core',
    'qb-phone',
    'qb-garages',
    'qb-vehiclekeys',
}

lua54 'yes'

