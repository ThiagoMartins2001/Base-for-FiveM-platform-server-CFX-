-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Creative = {}
Tunnel.bindInterface("tencode",Creative)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local codes = {
	[10] = {
		text = "Confronto em andamento",
		blip = 6
	},
	[13] = {
		text = "Oficial ferido",
		blip = 1
	},
	[20] = {
		text = "Localização",
		blip = 38
	},
	[78] = {
		text = "Reforço solicitado",
		blip = 4
	},
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- SENDCODE
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.sendCode(code)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		local Ped = GetPlayerPed(source)
		local Coords = GetEntityCoords(Ped)
		local Identity = vRP.Identity(Passport)
		
		-- Busca todos os policiais em serviço
		local Service = {}
		local policeGroups = {"PoliciaMilitar", "Core", "PRF", "PCivil"}
		local totalPolice = 0
		
		for _, group in pairs(policeGroups) do
			local groupService, count = vRP.NumPermission(group)
			if groupService then
				for passport, playerSource in pairs(groupService) do
					Service[passport] = playerSource
					totalPolice = totalPolice + 1
				end
			end
		end
		
		print("^2[tencode] Código " .. code .. " enviado por " .. Identity["name"] .. " " .. Identity["name2"] .. "^7")
		print("^3[tencode] Enviando para " .. totalPolice .. " policiais em serviço^7")
		
		for Passports,Sources in pairs(Service) do
			async(function()
				if code ~= 13 then
					vRPC.PlaySound(Sources,"Event_Start_Text","GTAO_FM_Events_Soundset")
				end

				TriggerClientEvent("NotifyPush",Sources,{ code = code, title = codes[parseInt(code)]["text"], x = Coords["x"], y = Coords["y"], z = Coords["z"], name = Identity["name"].." "..Identity["name2"], time = "Recebido às "..os.date("%H:%M"), blipColor = codes[parseInt(code)]["blip"] })
			end)
		end
		
		if totalPolice == 0 then
			print("^1[tencode] AVISO: Nenhum policial em serviço para receber o código^7")
		end
	else
		print("^1[tencode] ERRO: Passport não encontrado para source " .. source .. "^7")
	end
end