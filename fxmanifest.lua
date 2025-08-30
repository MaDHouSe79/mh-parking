--[[ ===================================================== ]] --
--[[         MH Realistic Parking Script by MaDHouSe       ]] --
--[[ ===================================================== ]] --
fx_version 'cerulean'
games {'gta5'}

author 'MaDHouSe'
description 'QB Realistic Vehicle Parking'
version '1.0.0'

ui_page 'html/index.html'

files {'html/*.html', 'html/*.js', 'html/*.css'}

shared_scripts {
  '@qb-core/shared/locale.lua',
  '@qb-core/shared/vehicles.lua',
  'locales/en.lua', -- change en to your language
  'config.lua', 
  'configs/*.lua'
}

client_scripts {
  'client/main.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua', 
  'server/install.lua', -- uncomment this after you restart your server, so it will not run the second time.
  'server/main.lua', 
  'server/update.lua'
}

dependencies {'oxmysql', 'qb-core'}

lua54 'yes'
