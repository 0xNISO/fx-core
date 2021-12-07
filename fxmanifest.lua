fx_version 'cerulean'
game 'gta5'

shared_script "config.lua"
shared_script "@th-lib/lib.lua" -- lib

-- Script
client_script "client/client.lua"
server_script 'server/server.lua'
