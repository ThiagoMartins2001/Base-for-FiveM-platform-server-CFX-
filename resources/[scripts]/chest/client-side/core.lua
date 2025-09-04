-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vSERVER = Tunnel.getInterface("chest")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHESTS
-----------------------------------------------------------------------------------------------------------------------------------------
local Chests = {
	-- Polícia
	{ ["Name"] = "PoliciaMilitar", ["Coords"] = vec3(485.51,-995.29,30.69), ["Mode"] = "1" }, -- PoliciaMilitar (PMESP/GCM/BAEP)
	{ ["Name"] = "Core", ["Coords"] = vec3(842.27,-1307.16,24.32), ["Mode"] = "1" }, -- Core
	{ ["Name"] = "PCivil", ["Coords"] = vec3(-944.52,-2041.25,9.40), ["Mode"] = "1" }, -- CIVIL
	{ ["Name"] = "PRF", ["Coords"] = vec3(-283.44,6047.53,33.07), ["Mode"] = "1" }, -- PRF
	
	-- Baús de Evidências (apenas PCivil)
	--{ ["Name"] = "Evidences", ["Coords"] = vec3(485.43,-999.10,30.69), ["Mode"] = "1" }, -- PoliciaMilitar
	--{ ["Name"] = "Evidences", ["Coords"] = vec3(842.27,-1307.16,24.32), ["Mode"] = "1" }, -- Core
	--{ ["Name"] = "Evidences", ["Coords"] = vec3(-944.52,-2041.25,9.40), ["Mode"] = "1" }, -- CIVIL
	--{ ["Name"] = "Evidences", ["Coords"] = vec3(-283.44,6047.53,33.07), ["Mode"] = "1" }, -- PRF

	--Mecanicas
	{ ["Name"] = "Bennys", ["Coords"] = vec3(799.02,-2089.8,31.74), ["Mode"] = "2" },
	{ ["Name"] = "Mechanic", ["Coords"] = vec3(898.5,-2100.06,34.88), ["Mode"] = "2" },
	{ ["Name"] = "LiderMechanic", ["Coords"] = vec3(886.17,-2097.45,34.88), ["Mode"] = "2" },
	-- Hospitais
	{ ["Name"] = "LiderParamedic", ["Coords"] = vec3(1141.68,-1539.66,35.03), ["Mode"] = "2" }, --- Shandy Shores
	{ ["Name"] = "Paramedic", ["Coords"] = vec3(359.46,-1421.1,32.5), ["Mode"] = "2" }, --- HP SUL

	-- Restaurantes
	{ ["Name"] = "Mcdonalds", ["Coords"] = vec3(-86.57,21.41,72.93), ["Mode"] = "2" },
	{ ["Name"] = "Hornys", ["Coords"] = vec3(1249.34,-351.62,69.27), ["Mode"] = "2" },

	-- Ilegal Sul
	{ ["Name"] = "Favela01", ["Coords"] = vec3(1270.48,-126.17,87.64), ["Mode"] = "2" }, --- BARRAGEM --------- COCAINA
	{ ["Name"] = "LiderFavela01", ["Coords"] = vec3(1272.18,-124.28,87.65), ["Mode"] = "2" }, --- BARRAGEM LIDER  --------- COCAINA

	{ ["Name"] = "Favela02", ["Coords"] = vec3(2125.01,414.93,218.79), ["Mode"] = "2" }, --- BARRAGEM2 --------- LEAN
	{ ["Name"] = "LiderFavela02", ["Coords"] = vec3(2122.37,411.04,221.69), ["Mode"] = "2" }, --- BARRAGEM2 LIDER  --------- LEAN

	{ ["Name"] = "Favela03", ["Coords"] = vec3(875.04,1035.97,283.67), ["Mode"] = "2" }, --- PLACA VINEWOOD --------- META
	{ ["Name"] = "LiderFavela03", ["Coords"] = vec3(876.85,1036.55,280.72), ["Mode"] = "2" }, --- PLACA VINEWOOD LIDER  --------- META

	{ ["Name"] = "Favela04", ["Coords"] = vec3(799.47,-293.85,69.45), ["Mode"] = "2" }, --- CAMPINHO --------- ECSTASY
	{ ["Name"] = "LiderFavela04", ["Coords"] = vec3(802.45,-291.85,66.52), ["Mode"] = "2" }, --- CAMPINHO --------- ECSTASY

 	{ ["Name"] = "Favela05", ["Coords"] = vec3(-1866.85,2065.68,135.44), ["Mode"] = "2" }, --- VINÍCOLA --------- MACONHA
	 { ["Name"] = "LiderFavela05", ["Coords"] = vec3(-1870.25,2059.18,135.44), ["Mode"] = "2" }, --- VINÍCOLA --------- MACONHA

	{ ["Name"] = "Municao1", ["Coords"] = vec3(-309.57,1520.19,367.73), ["Mode"] = "2" }, --- OBSERVATORIO --------- MUNICAO1
	{ ["Name"] = "LiderMunicao1", ["Coords"] = vec3(-313.04,1516.91,364.78), ["Mode"] = "2" }, --- OBSERVATORIO --------- MUNICAO1

	{ ["Name"] = "Municao2", ["Coords"] = vec3(1331.36,-676.43,75.86), ["Mode"] = "2" }, --- HELIPE --------- MUNICAO2
	{ ["Name"] = "LiderMunicao2", ["Coords"] = vec3(1332.78,-685.99,75.86), ["Mode"] = "2" }, --- HELIPA --------- MUNICAO2

	{ ["Name"] = "Thelost", ["Coords"] = vec3(2521.67,4104.24,35.59), ["Mode"] = "2" }, --- THELOST NORT --------- MUNICAO2
	{ ["Name"] = "LiderThelost", ["Coords"] = vec3(2517.41,4106.15,35.59), ["Mode"] = "2" }, --- THELOST NORT --------- MUNICAO2

	{ ["Name"] = "Favela06", ["Coords"] = vec3(404.64,1724.31,188.48), ["Mode"] = "2" }, --- FAVELA TUNEL
	{ ["Name"] = "LiderFavela06", ["Coords"] = vec3(388.74,1745.9,188.57), ["Mode"] = "2" }, ---  FAVELA TUNEL desmanche
	


	{ ["Name"] = "Armas1", ["Coords"] = vec3(1377.6,-1297.52,75.62), ["Mode"] = "2" }, --- Armas1
	{ ["Name"] = "LiderArmas1", ["Coords"] = vec3(1379.44,-1294.36,75.62), ["Mode"] = "2" }, --- LiderArmas1

	{ ["Name"] = "Armas2", ["Coords"] = vec3(-1866.85,2065.68,135.44), ["Mode"] = "2" }, --- Armas2
	{ ["Name"] = "LiderArmas2", ["Coords"] = vec3(1331.5,-676.47,75.86), ["Mode"] = "2" }, --- LiderArmas2

	-- { ["Name"] = "Desmanche", ["Coords"] = vec3(2879.71,4396.29,56.53), ["Mode"] = "2" }, --- Armas2
	-- { ["Name"] = "LiderDesmanche", ["Coords"] = vec3(2883.29,4401.46,56.53), ["Mode"] = "2" }, --- LiderArmas2


	-- { ["Name"] = "Favela02", ["Coords"] = vec3(1270.71,-126.39,87.64), ["Mode"] = "2" }, --- META
	-- { ["Name"] = "Favela03", ["Coords"] = vec3(1270.71,-126.39,87.64), ["Mode"] = "2" }, --- META
	-- { ["Name"] = "Favela04", ["Coords"] = vec3(1270.71,-126.39,87.64), ["Mode"] = "2" }, --- META
	-- { ["Name"] = "Favela05", ["Coords"] = vec3(1270.71,-126.39,87.64), ["Mode"] = "2" }, --- META
	-- { ["Name"] = "Favela06", ["Coords"] = vec3(1270.71,-126.39,87.64), ["Mode"] = "2" }, --- META
	-- { ["Name"] = "Favela07", ["Coords"] = vec3(1270.71,-126.39,87.64), ["Mode"] = "2" }, --- META
	-- { ["Name"] = "Favela08", ["Coords"] = vec3(1270.71,-126.39,87.64), ["Mode"] = "2" }, --- META


	-- Bandejas
	{ ["Name"] = "trayShot", ["Coords"] = vec3(-74.14,24.14,72.94), ["Mode"] = "3" },
	{ ["Name"] = "trayPrls1", ["Coords"] = vec3(-77.65,25.97,72.93), ["Mode"] = "3" },
	{ ["Name"] = "trayPrls2", ["Coords"] = vec3(-584.8,-1062.01,22.34), ["Mode"] = "3" },
	{ ["Name"] = "trayTql1", ["Coords"] = vec3(-584.8,-1059.46,22.34), ["Mode"] = "3" },
	{ ["Name"] = "trayTql2", ["Coords"] = vec3(-564.2,285.62,85.5), ["Mode"] = "3" },

	{ ["Name"] = "Ifrut", ["Coords"] = vec3(-1246.64,-809.07,17.83), ["Mode"] = "2" },
	{ ["Name"] = "Ifrut-ilegal", ["Coords"] = vec3(-578.58,229.81,74.88), ["Mode"] = "2" },
	{ ["Name"] = "LiderIfrut", ["Coords"] = vec3(-574.56,243.3,74.88), ["Mode"] = "2" },

	{ ["Name"] = "LiderPawnshop", ["Coords"] = vec3(157.79,-1316.18,29.35), ["Mode"] = "2" },
	{ ["Name"] = "Pawnshop", ["Coords"] = vec3(161.9,-1315.87,29.35), ["Mode"] = "2" },

	{ ["Name"] = "Mechanic68", ["Coords"] = vec3(1189.7,2636.52,38.39), ["Mode"] = "2" },
	{ ["Name"] = "Uwucoffee", ["Coords"] = vec3(-590.41,-1067.82,22.9), ["Mode"] = "2" },
	{ ["Name"] = "LSCustoms", ["Coords"] = vec3(-350.19,-128.68,38.91), ["Mode"] = "2" },
	{ ["Name"] = "Yakuza", ["Coords"] = vec3(-1019.85,-1490.42,-3.34), ["Mode"] = "2" },


	

}
-----------------------------------------------------------------------------------------------------------------------------------------
-- LABELS
-----------------------------------------------------------------------------------------------------------------------------------------
local Labels = {
	["1"] = {
		{
			event = "chest:Open",
			label = "Compartimento Geral",
			tunnel = "shop",
			service = "Normal"
		},{
			event = "chest:Open",
			label = "Compartimento Pessoal",
			tunnel = "shop",
			service = "Personal"
		},{
			event = "chest:Open",
			label = "Compartimento Evidências",
			tunnel = "shop",
			service = "Evidences"
		},{
			event = "chest:Upgrade",
			label = "Aumentar",
			tunnel = "server"
		}
	},
	["2"] = {
		{
			event = "chest:Open",
			label = "Abrir",
			tunnel = "shop",
			service = "Normal"
		},{
			event = "chest:Upgrade",
			label = "Aumentar",
			tunnel = "server"
		}
	},
	["3"] = {
		{
			event = "chest:Open",
			label = "Balcão",
			tunnel = "shop",
			service = "Normal"
		}
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADINIT
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	for Name,v in pairs(Chests) do
		exports["target"]:AddCircleZone("Chest:"..Name,v["Coords"],1.0,{
			name = "Chest:"..Name,
			heading = 3374176
		},{
			Distance = 1.7,
			shop = v["Name"],
			options = Labels[v["Mode"]]
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHEST:OPEN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('chest:Open')
AddEventHandler("chest:Open",function(Name,Init,weight)
	if LocalPlayer["state"]["Route"] < 900000 then
		if vSERVER.Permissions(Name,Init,weight) then
			SetNuiFocus(true,true)
			SendNUIMessage({ Action = "Open" })
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHESTCLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Close",function(Data,Callback)
	SendNUIMessage({ Action = "Close" })
	SetNuiFocus(false,false)

	Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TAKE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Take",function(Data,Callback)
	vSERVER.Take(Data["item"],Data["slot"],Data["amount"],Data["target"])

	Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- STORE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Store",function(Data,Callback)
	vSERVER.Store(Data["item"],Data["slot"],Data["amount"],Data["target"])

	Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Update",function(Data,Callback)
	vSERVER.Update(Data["slot"],Data["target"],Data["amount"])

	Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHEST
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Chest",function(Data,Callback)
	local Inventory,Chest,invPeso,invMaxpeso,chestPeso,chestMaxpeso = vSERVER.Chest()
	if Inventory then
		Callback({ Inventory = Inventory, Chest = Chest, invPeso = invPeso, invMaxpeso = invMaxpeso, chestPeso = chestPeso, chestMaxpeso = chestMaxpeso })
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHEST:UPDATE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("chest:Update")
AddEventHandler("chest:Update",function(Action,invPeso,invMaxpeso,chestPeso,chestMaxpeso)
	SendNUIMessage({ Action = Action, invPeso = invPeso, invMaxpeso = invMaxpeso, chestPeso = chestPeso, chestMaxpeso = chestMaxpeso })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHEST:CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("chest:Close")
AddEventHandler("chest:Close",function(Action)
	SendNUIMessage({ Action = "Close" })
	SetNuiFocus(false,false)
end)



