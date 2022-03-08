fx_version 'cerulean'
games { 'gta5' }

author 'MaDHouSe'
description 'QB Realistic Vehicle Parking'
version '2.0'

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