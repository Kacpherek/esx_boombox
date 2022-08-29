fx_version "cerulean"
games {"gta5"}
lua54 "yes"

client_scripts {
    "@es_extended/locale.lua",
    "locales/*.lua",
    "config/*.lua",
    "client/*.lua"
}

server_scripts {
    "server/*.lua"
}
dependencies {
    "es_extended",
    "xsound"
}

author "kacpherek#9918" -- https://github.com/Kacpherek
description "skrypt na boombox! by kacpherek#9918 "
version "1.0"
