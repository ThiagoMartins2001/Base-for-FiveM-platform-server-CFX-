fx_version "bodacious"
game "gta5"

ui_page "web-side/index.html"

shared_scripts {
	"config.lua"
}

client_scripts {
	"@vrp/lib/utils.lua",
	"client-side/*"
}

server_scripts {
	"@vrp/lib/Utils.lua",
	"server-side/*"
}

files {
	"web-side/*",
	"web-side/**/*"
} 