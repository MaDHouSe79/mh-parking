fx_version 'cerulean'
games { 'gta5' }

author 'MaDHouSe'
description 'QB Realistic Vehicle Parking'
version '1.4'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/nl.lua', -- change en to your language
    'config.lua',
    'shared/variables.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

dependencies {
    'oxmysql',
    'qb-core',
}

lua54 'yes'

