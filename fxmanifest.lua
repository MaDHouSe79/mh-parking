fx_version 'cerulean'
games { 'gta5' }

author 'MaDHouSe'
description 'Realistic Vehicle Parking'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    --'shared/locale.lua', -- if you use a older version of QBCore, uncommand this and command above.
    'shared/locale.lua',
    'locales/en.lua',  -- change en to your language.
    'shared/config.lua',
    'shared/functions.lua',
    'shared/variables.lua',
}

client_scripts {
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
    'server/events.lua',
    'server/functions.lua',
    'server/callback.lua'
}

dependencies {
    'oxmysql',
    'qb-core',
    'qb-vehiclekeys',
}

lua54 'yes'
