fx_version 'adamant'
game 'gta5'
author 'kacpherek#9918' -- https://github.com/Kacpherek
description 'skrypt na boombox! by kacpherek#9918 '
version '1.0'

server_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    'server/*.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    'config/config.lua',
    'client/main.lua'
}

dependencies {
    'es_extended',
    'xsound'
}

