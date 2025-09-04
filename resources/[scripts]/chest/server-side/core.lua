-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Creative = {}
Tunnel.bindInterface("chest",Creative)
vKEYBOARD = Tunnel.getInterface("keyboard")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Open = {}

local Webhooks = {
	["Personal"] = {
		"",
	
	},
	["Evidences"] = {
		"",
		
	},
	["Police"] = {
		"",
	
	},
	["Mechanic"] = {
		"",
	
	},


	["LiderFavela01"] = {
		"",
	},
	["Favela01"] = {
		"",
	},


	["LiderFavela02"] = {
		"",
	},
	["Favela02"] = {
		""
	},


	["LiderFavela03"] = {
		"",
	},
	["Favela03"] = {
		"",

	},


	["LiderFavela04"] = {
		"",
	},
	["Favela04"] = {
		"",
	
	},

	["LiderFavela05"] = {
		"",
	},
	["Favela05"] = {
		"",
	},



	["LiderMcdonalds"] = {
		"",
		
	},
	["Mcdonalds"] = {
		"",
		
	},


	
	["LiderIfrut"] = {
		"",
		
	},
	["Ifrut-ilegal"] = {
		"",
		
	},
	["Ifrut"] = {
		"",
		
	},


	["LiderPawnshop"] = {
		"",
		
	},
	["Pawnshop"] = {
		"",
		
	},


	["LiderDesmanche"] = {
		"",
		
	},
	["Desmanche"] = {
		"",
		
	},


	["LiderArmas1"] = {
		"",
		
	},
	["Armas1"] = {
		"",
		
	},


	["LiderArmas2"] = {
		"",
		
	},
	["Armas2"] = {
		"",
		
	},


	["LiderMunicao1"] = {
		"",
		
	},
	["Municao1"] = {
		"",
		
	},


	["LiderMunicao2"] = {
		"",
		
	},
	["Municao2"] = {
		"",
		
	},
	

}


-- FUNÇÃO PERMISSIONS (CORRIGIDA)
function Creative.Permissions(Name, Init, weight)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		if Init == "1" then
			-- Verificar se é um baú da polícia na tabela principal
			local Consult = vRP.Query("chests/GetChests",{ name = Name })
			if Consult[1] then
				-- Baú de evidências - acesso compartilhado entre todos os policiais
				if Name == "Evidences" then
					if vRP.HasService(Passport, "PoliciaMilitar") or vRP.HasService(Passport, "Core") or vRP.HasService(Passport, "PRF") or vRP.HasService(Passport, "PCivil") then
						Open[Passport] = { ["Name"] = Name, ["Weight"] = Consult[1]["weight"], ["Logs"] = Consult[1]["logs"], ["Save"] = true }
						print("^2[chest] Baú de evidências aberto por " .. Passport .. "^7")
						return true
					else
						print("^1[chest] " .. Passport .. " não tem permissão para baú de evidências^7")
						return false
					end
				else
					-- Baús específicos da polícia
					if vRP.HasService(Passport, Consult[1]["perm"]) then
						Open[Passport] = { ["Name"] = Name, ["Weight"] = Consult[1]["weight"], ["Logs"] = Consult[1]["logs"], ["Save"] = true }
						print("^2[chest] Baú " .. Name .. " aberto por " .. Passport .. "^7")
						return true
					else
						print("^1[chest] " .. Passport .. " não está em serviço como " .. Consult[1]["perm"] .. "^7")
						return false
					end
				end
			end
		elseif Init == "2" then
			-- Baús de outros serviços (mecânicos, etc.)
			if vRP.HasService(Passport, Name) then
				Open[Passport] = { ["Name"] = Name, ["Weight"] = weight, ["Logs"] = true, ["Save"] = true }
				return true
			end
		elseif Init == "3" then
			-- Baús de bandejas (trays)
			Open[Passport] = { ["Name"] = Name, ["Weight"] = 200, ["Logs"] = false, ["Save"] = true }
			return true
		elseif Mode == "Custom" then
			Open[Passport] = { ["Name"] = Name, ["Weight"] = 50, ["Logs"] = true, ["Save"] = false }
			return true
		elseif Mode == "SNT" then
			Open[Passport] = { ["Name"] = Name, ["Weight"] = weight, ["Save"] = true }
			return true
		else
			-- Baús de bandejas específicos
			if Name == "trayPwnshp"  or Name == "trayUwuCoff"  or Name == "trayPrls1"  or Name == "trayPrls2" or Name == "trayTql1" or Name == "trayTql2" or Name == "trayShot" or Name == "trayDigital" or Name == "trayPawn" or Name == "trayBlaze" or Name == "trayDigital" then
				Open[Passport] = { ["Name"] = Name, ["Weight"] = 200, ["Logs"] = false, ["Save"] = true }
				return true
			end

			-- Baús do banco de dados
			local Consult = vRP.Query("chests/GetChests",{ name = Name })
			if Consult[1] and vRP.HasService(Passport,Consult[1]["perm"]) then
				Open[Passport] = { ["Name"] = Name, ["Weight"] = Consult[1]["weight"], ["Logs"] = Consult[1]["logs"], ["Save"] = true }
				return true
			end
		end
	end

	return false
end


-----------------------------------------------------------------------------------------------------------------------------------------
-- CHEST
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Chest()
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Open[Passport] then
		local Inventory = {}
		local Inv = vRP.Inventory(Passport)
		for Index,v in pairs(Inv) do
			v["amount"] = parseInt(v["amount"])
			v["name"] = itemName(v["item"])
			v["peso"] = itemWeight(v["item"])
			v["index"] = itemIndex(v["item"])
			v["max"] = itemMaxAmount(v["item"])
			v["desc"] = itemDescription(v["item"])
			v["economy"] = parseFormat(itemEconomy(v["item"]))
			v["key"] = v["item"]
			v["slot"] = Index

			local Split = splitString(v["item"],"-")
			if Split[2] ~= nil then
				if itemDurability(v["item"]) then
					v["durability"] = parseInt(os.time() - Split[2])
					v["days"] = itemDurability(v["item"])
				else
					v["durability"] = 0
					v["days"] = 1
				end
			else
				v["durability"] = 0
				v["days"] = 1
			end

			Inventory[Index] = v
		end

		local Chest = {}
		local Result = vRP.GetSrvData("Chest:"..Open[Passport]["Name"],Open[Passport]["Save"])
		for Index,v in pairs(Result) do
			v["amount"] = parseInt(v["amount"])
			v["name"] = itemName(v["item"])
			v["peso"] = itemWeight(v["item"])
			v["index"] = itemIndex(v["item"])
			v["max"] = itemMaxAmount(v["item"])
			v["economy"] = parseFormat(itemEconomy(v["item"]))
			v["desc"] = itemDescription(v["item"])
			v["key"] = v["item"]
			v["slot"] = Index

			local Split = splitString(v["item"],"-")
			if Split[2] ~= nil then
				if itemDurability(v["item"]) then
					v["durability"] = parseInt(os.time() - Split[2])
					v["days"] = itemDurability(v["item"])
				else
					v["durability"] = 0
					v["days"] = 1
				end
			else
				v["durability"] = 0
				v["days"] = 1
			end

			Chest[Index] = v
		end

		return Inventory,Chest,vRP.InventoryWeight(Passport),vRP.GetWeight(Passport),vRP.ChestWeight(Result),Open[Passport]["Weight"]
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENITENS
-----------------------------------------------------------------------------------------------------------------------------------------
local OpenItens = {
	["mechanicpass"] = {
		["Open"] = "Mechanic",
		["Table"] = {
			{ ["Item"] = "advtoolbox", ["Amount"] = 1 },
			{ ["Item"] = "toolbox", ["Amount"] = 2 },
			{ ["Item"] = "tyres", ["Amount"] = 4 },
			{ ["Item"] = "dollars", ["Amount"] = 200 }
		}
	},
	["uwucoffeepass"] = {
		["Open"] = "Uwucoffee",
		["Table"] = {
			{ ["Item"] = "nigirizushi", ["Amount"] = 3 },
			{ ["Item"] = "sushi", ["Amount"] = 3 },
			{ ["Item"] = "dollars", ["Amount"] = 200 }
		}
	},
	["pizzathispass"] = {
		["Open"] = "PizzaThis",
		["Table"] = {
			{ ["Item"] = "nigirizushi", ["Amount"] = 3 },
			{ ["Item"] = "sushi", ["Amount"] = 3 },
			{ ["Item"] = "dollars", ["Amount"] = 200 }
		}
	},
	["Mcdonaldspass"] = {
		["Open"] = "Mcdonalds",
		["Table"] = {
			{ ["Item"] = "hamburger2", ["Amount"] = 1 },
			{ ["Item"] = "cookedmeat", ["Amount"] = 2 },
			{ ["Item"] = "cookedfishfillet", ["Amount"] = 1 },
			{ ["Item"] = "dollars", ["Amount"] = 200 }
		}
	},
	["paramedicpass"] = {
		["Open"] = "Paramedic",
		["Table"] = {
			{ ["Item"] = "gauze", ["Amount"] = 3 },
			{ ["Item"] = "medkit", ["Amount"] = 1 },
			{ ["Item"] = "analgesic", ["Amount"] = 4 },
			{ ["Item"] = "dollars", ["Amount"] = 200 }
		}
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- STORE
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Store(Item,Slot,Amount,Target)
	local source = source
	local Amount = parseInt(Amount)
	local Passport = vRP.Passport(source)
	if Passport and Open[Passport] then
		if Amount <= 0 then Amount = 1 end

		if itemBlock(Item) then
			TriggerClientEvent("chest:Update",source,"Refresh")

			return true
		end

		if OpenItens[Item] and OpenItens[Item]["Open"] == Open[Passport]["Name"] then
			if vRP.TakeItem(Passport,Item,1) then
				for _,v in pairs(OpenItens[Item]["Table"]) do
					vRP.GenerateItem(Passport,v["Item"],v["Amount"])
				end
			end

			TriggerClientEvent("chest:Update",source,"Refresh")

			return true
		end

		if vRP.StoreChest(Passport,"Chest:"..Open[Passport]["Name"],Amount,Open[Passport]["Weight"],Slot,Target,true) then
			TriggerClientEvent("chest:Update",source,"Refresh")
		else
			local Result = vRP.GetSrvData("Chest:"..Open[Passport]["Name"],Open[Passport]["Save"])
			TriggerClientEvent("chest:Update",source,"Update",vRP.InventoryWeight(Passport),vRP.GetWeight(Passport),vRP.ChestWeight(Result),Open[Passport]["Weight"])

			for k,v in pairs(Webhooks) do
				if string.find(Open[Passport]["Name"], k) then
					for _,webhook in pairs(v) do
						vRP.SendWebhook(webhook, "LOGs BAÚ GUARDOU", "**Passaporte: **"..Passport.."\n**Guardou: **x"..Amount.." "..Item.."\n**Baú: **"..Open[Passport]["Name"], 7065707)
					end
				end
			end

			if Open[Passport]["Logs"] then
				TriggerEvent("Discord",Open[Passport]["Name"],"**Passaporte:** "..Passport.."\n**Guardou:** "..Amount.."x "..itemName(Item),3042892)
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TAKE
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Take(Item,Slot,Amount,Target)
	local source = source
	local Amount = parseInt(Amount)
	local Passport = vRP.Passport(source)
	if Passport and Open[Passport] then
		if Amount <= 0 then Amount = 1 end

		if vRP.TakeChest(Passport,"Chest:"..Open[Passport]["Name"],Amount,Slot,Target,true) then
			TriggerClientEvent("chest:Update",source,"Refresh")
		else
			local Result = vRP.GetSrvData("Chest:"..Open[Passport]["Name"],Open[Passport]["Save"])
			TriggerClientEvent("chest:Update",source,"Update",vRP.InventoryWeight(Passport),vRP.GetWeight(Passport),vRP.ChestWeight(Result),Open[Passport]["Weight"])

			if string.sub(Open[Passport]["Name"],1,9) == "Helicrash" and vRP.ChestWeight(Result) <= 0 then
				TriggerClientEvent("chest:Close",source)
				exports["helicrash"]:Box()
			end
			
			for k,v in pairs(Webhooks) do
				if string.find(Open[Passport]["Name"], k) then
					for _,webhook in pairs(v) do
						vRP.SendWebhook(webhook, "LOGs BAÚ RETIROU", "**Passaporte: **"..Passport.."\n**Retirou: **x"..Amount.." "..Item.."\n**Baú: **"..Open[Passport]["Name"], 16726610)
					end
				end
			end

			if Open[Passport]["Logs"] then
				TriggerEvent("Discord",Open[Passport]["Name"],"**Passaporte:** "..Passport.."\n**Retirou:** "..Amount.."x "..itemName(Item),9317187)
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATE
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Update(Slot,Target,Amount)
	local source = source
	local Amount = parseInt(Amount)
	local Passport = vRP.Passport(source)
	if Passport and Open[Passport] then
		if Amount <= 0 then Amount = 1 end

		if vRP.Update(Passport,"Chest:"..Open[Passport]["Name"],Slot,Target,Amount) then
			TriggerClientEvent("chest:Update",source,"Refresh")
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHEST:UPGRADE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("chest:Upgrade")
AddEventHandler("chest:Upgrade",function(Name)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		if vRP.HasService(Passport,Name) then
			if vRP.Request(source,"Aumentar <b>50Kg</b> por <b>$10.000</b> dólares?","Sim, efetuar pagamento","Não, decido depois") then
				if vRP.PaymentFull(Passport,10000) then
					vRP.Query("chests/UpdateChests",{ name = Name })
					TriggerClientEvent("Notify",source,"verde","Compra concluída.",3000)
				else
					TriggerClientEvent("Notify",source,"vermelho","<b>Dólares</b> insuficientes.",5000)
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport)
	if Open[Passport] then
		Open[Passport] = nil
	end
end)