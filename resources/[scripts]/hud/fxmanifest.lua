fx_version "bodacious"
game "gta5"
lua54 "yes"
ui_page "web-side/index.html"

shared_scripts {
	"config.lua"
}

client_scripts {
	"@vrp/config/Native.lua",
	"@vrp/config/Item.lua",
	"@vrp/lib/Utils.lua",
	"test.lua",
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