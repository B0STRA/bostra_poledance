fx_version 'cerulean'
version '2.0.0'
game 'gta5'
lua54 'yes'
author 'Bostra'
description 'FiveM Poledancing'

dependency 'ox_lib'
dependency 'ox_target'
dependency 'ox_inventory'

files { 'config/config.lua' }
shared_scripts { '@ox_lib/init.lua', 'config/config.lua' }
client_scripts { 'client/client.lua' }
server_scripts { 'server/server.lua' }
