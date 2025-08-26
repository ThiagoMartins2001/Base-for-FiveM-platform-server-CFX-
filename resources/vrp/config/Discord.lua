-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCORDS
-----------------------------------------------------------------------------------------------------------------------------------------
Discords = {
	["Connect"] = "",
	["Disconnect"] = "",
	["Airport"] = "",
	["Deaths"] = "",
	["Police"] = "",
	["Paramedic"] = "",
	["Gemstone"] = "",
	["Login"] = "",
	["bau-casa-colocou"] = "",
	["bau-casa-tirou"] = "",
	["bvida"] = "",

	["wl"] = "",
	["unwl"] = "",
	["remcar"] = "",


	["group"] = "",
	["ungroup"] = "",
	["dv"] = ""
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCORD
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Discord",function(Hook,Message,Color)
	PerformHttpRequest(Discords[Hook],function(err,text,headers) end,"POST",json.encode({
		username = ServerName,
		embeds = { { color = Color, description = Message } }
	}),{ ["Content-Type"] = "application/json" })
end)

