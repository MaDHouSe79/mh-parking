fx_version 'cerulean'
games { 'gta5' }

author 'MaDHouSe'
description 'QB Realistic Vehicle Parking'
version '1.4'

ui_page 'html/index.html'

files {
	'html/*.html',
	'html/*.js',
	'html/*.css',
}

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua', -- change en to your language
    'config.lua',
    'configs/*.lua',
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
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