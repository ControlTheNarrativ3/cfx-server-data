fx_version 'cerulean'
game 'gta5'

name "NyxRP_hud"
author "ControlTheNarrativ3"
version "1.0.0"
description "A simple and clean hud"

client_scripts {
    "main/client.lua"
}

server_scripts {
    'main/server.lua',
    --"main/updater.lua"
}

shared_scripts {
    "config.lua"
}
ui_page ("ui/ui.html")

files {"**/**/**/**/**/**/*.*"}