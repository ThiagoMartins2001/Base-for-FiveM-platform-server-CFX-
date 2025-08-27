-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPS = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Hensa = {}
Tunnel.bindInterface("hud",Hensa)
vSERVER = Tunnel.getInterface("hud")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CALLBACK SYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
local Callbacks = {}

function TriggerServerCallback(name, ...)
    local p = promise.new()
    local requestId = tostring(math.random(111111, 999999))

    Callbacks[requestId] = function(result)
        p:resolve(result)
        Callbacks[requestId] = nil
    end

    TriggerServerEvent("callback:trigger", name, requestId, {... or {}})
    return Citizen.Await(p)
end

RegisterNetEvent("callback:response")
AddEventHandler("callback:response", function(requestId, result)
    if Callbacks[requestId] then
        Callbacks[requestId](result)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL
-----------------------------------------------------------------------------------------------------------------------------------------
Display = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Road = ""
local Gemstone = 0
local Crossing = ""
local Hood = false
local PlayerVIP = "none"
local IsDead = false
local LastHealth = 200
-----------------------------------------------------------------------------------------------------------------------------------------
-- PRINCIPAL
-----------------------------------------------------------------------------------------------------------------------------------------
local Health = 999
local Armour = 999
-----------------------------------------------------------------------------------------------------------------------------------------
-- THIRST
-----------------------------------------------------------------------------------------------------------------------------------------
local Thirst = 999
local ThirstTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUNGER
-----------------------------------------------------------------------------------------------------------------------------------------
local Hunger = 999
local HungerTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- STRESS
-----------------------------------------------------------------------------------------------------------------------------------------
local Stress = 0
local StressTimer = 0
local StressAutoTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- WANTED
-----------------------------------------------------------------------------------------------------------------------------------------
local Wanted = 0
local WantedMax = 0
local WantedTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- REPOSED
-----------------------------------------------------------------------------------------------------------------------------------------
local Reposed = 0
local ReposedTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- LUCK
-----------------------------------------------------------------------------------------------------------------------------------------
local Luck = 0
local LuckTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- DEXTERITY
-----------------------------------------------------------------------------------------------------------------------------------------
local Dexterity = 0
local DexterityTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- INITIALIZE VIP STATUS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    Wait(5000) -- Aguarda 5 segundos para carregar tudo
    PlayerVIP = TriggerServerCallback("hud:GetVipGroup")
    print("🔁 Status VIP do jogador:", PlayerVIP)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADTIMER
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		if LocalPlayer["state"]["Active"] then
			local Ped = PlayerPedId()

			if IsPauseMenuActive() then
				SendNUIMessage({ name = "Body", payload = false })
			else
				if Display then
					SendNUIMessage({ name = "Body", payload = true })

					local Coords = GetEntityCoords(Ped)
					local Armouring = GetPedArmour(Ped)
					local Healing = GetEntityHealth(Ped)
					local MinRoad,MinCross = GetStreetNameAtCoord(Coords["x"],Coords["y"],Coords["z"])
					local FullRoad = GetStreetNameFromHashKey(MinRoad)
					local FullCross = GetStreetNameFromHashKey(MinCross)

					if Health ~= Healing then
						if Healing < 0 then
							Healing = 0
						end

						-- Verifica se o jogador está morto (vida <= 100)
						if Healing <= 100 then
							SendNUIMessage({ name = "Health", payload = 0 })
							IsDead = true
						else
							SendNUIMessage({ name = "Health", payload = Healing - 100 })
							IsDead = false
						end
						
						Health = Healing
					end

					-- Verificação adicional de morte
					if IsEntityDead(Ped) or IsPedDeadOrDying(Ped, true) then
						if not IsDead then
							SendNUIMessage({ name = "Health", payload = 0 })
							IsDead = true
							print("💀 Jogador detectado como morto - Vida zerada na HUD")
						end
					else
						if IsDead and Health > 100 then
							IsDead = false
							print("❤️ Jogador revivido - Vida restaurada na HUD")
						end
					end

					if Armour ~= Armouring then
						SendNUIMessage({ name = "Armour", payload = Armouring })
						Armour = Armouring
					end

					if FullRoad ~= "" and Road ~= FullRoad then
						SendNUIMessage({ name = "Road", payload = FullRoad })
						Road = FullRoad
					end

					if FullCross ~= "" and Crossing ~= FullCross then
						SendNUIMessage({ name = "Crossing", payload = FullCross })
						Crossing = FullCross
					end

					SendNUIMessage({ name = "Clock", payload = { GlobalState["Hours"], GlobalState["Minutes"] } })
				end
			end

			if Luck > 0 and LuckTimer <= GetGameTimer() then
				Luck = Luck - 1
				LuckTimer = GetGameTimer() + 1000
				SendNUIMessage({ name = "Luck", payload = Luck })
			end

			if Dexterity > 0 and DexterityTimer <= GetGameTimer() then
				Dexterity = Dexterity - 1
				DexterityTimer = GetGameTimer() + 1000
				SendNUIMessage({ name = "Dexterity", payload = Dexterity })
			end

			if Wanted > 0 and WantedTimer <= GetGameTimer() then
				Wanted = Wanted - 1
				WantedTimer = GetGameTimer() + 1000
				SendNUIMessage({ name = "Wanted", payload = { Wanted,WantedMax } })
			end

			if Reposed > 0 and ReposedTimer <= GetGameTimer() then
				Reposed = Reposed - 1
				ReposedTimer = GetGameTimer() + 1000
				SendNUIMessage({ name = "Reposed", payload = Reposed })
			end

			-- Sistema de Fome
			if HungerTimer <= GetGameTimer() then
				HungerTimer = GetGameTimer() + 90000

				if Hunger < 10 and GetEntityHealth(Ped) > 100 then
					ApplyDamageToPed(Ped,math.random(2),false)
					TriggerEvent("Notify","hunger","Sofrendo de fome.",2500)
				end
			end

			-- Sistema de Sede
			if ThirstTimer <= GetGameTimer() then
				ThirstTimer = GetGameTimer() + 90000

				if Thirst < 10 and GetEntityHealth(Ped) > 100 then
					ApplyDamageToPed(Ped,math.random(2),false)
					TriggerEvent("Notify","thirst","Sofrendo de sede.",2500)
				end
			end

			-- Sistema de Stress Automático
			if StressAutoTimer <= GetGameTimer() then
				StressAutoTimer = GetGameTimer() + 120000 -- 2 minutos

				-- Aumenta stress baseado em ações
				if IsPedInAnyVehicle(Ped, false) then
					local Vehicle = GetVehiclePedIsIn(Ped, false)
					if Vehicle ~= 0 then
						local Speed = GetEntitySpeed(Vehicle)
						if Speed > 30.0 then -- Velocidade alta
							TriggerServerEvent("hud:AddStress", 1)
						end
						
						-- Stress por colisão
						if HasEntityCollidedWithAnything(Vehicle) then
							TriggerServerEvent("hud:AddStress", 5)
						end
					end
				end

				-- Stress por tiro
				if IsPedShooting(Ped) then
					TriggerServerEvent("hud:AddStress", 3)
				end

				-- Stress por corrida
				if IsPedRunning(Ped) then
					TriggerServerEvent("hud:AddStress", 1)
				end
			end

			-- Sistema de Stress (efeitos visuais e redução automática)
			if StressTimer <= GetGameTimer() then
				StressTimer = GetGameTimer() + 20000

				-- Efeitos visuais baseados no nível de stress
				if Stress >= 80 and GetEntityHealth(Ped) > 100 then
					ShakeGameplayCam("LARGE_EXPLOSION_SHAKE",0.75)
					TriggerEvent("Notify","amarelo","Sofrendo de stress.",5000)
				elseif Stress >= 60 and GetEntityHealth(Ped) > 79 then
					ShakeGameplayCam("LARGE_EXPLOSION_SHAKE",0.45)
				elseif Stress >= 40 and GetEntityHealth(Ped) > 59 then
					ShakeGameplayCam("LARGE_EXPLOSION_SHAKE",0.25)
				elseif Stress >= 35 and GetEntityHealth(Ped) > 39 then
					ShakeGameplayCam("LARGE_EXPLOSION_SHAKE",0.12)
					
					SetTimeout(2500,function()
					ShakeGameplayCam("LARGE_EXPLOSION_SHAKE",0.25)
					end)
				end

				-- Redução automática de stress baseada em atividades relaxantes
				if Stress > 0 then
					local stressReduction = 0
					
					-- Redução por estar em casa/hospital (áreas seguras)
					if IsPedInAnyVehicle(Ped, false) then
						local Vehicle = GetVehiclePedIsIn(Ped, false)
						if Vehicle ~= 0 then
							local VehicleClass = GetVehicleClass(Vehicle)
							-- Carros de luxo reduzem stress
							if VehicleClass == 7 or VehicleClass == 12 then -- Super e Vans
								stressReduction = stressReduction + 1
							end
						end
					end

					-- Redução por estar parado/descansando
					if not IsPedRunning(Ped) and not IsPedWalking(Ped) then
						stressReduction = stressReduction + 1
					end

					-- Redução por estar em áreas com água (praia, lago)
					local Coords = GetEntityCoords(Ped)
					local WaterTest = TestVerticalProbeAgainstAllWater(Coords.x, Coords.y, Coords.z, 0, 0)
					if WaterTest then
						stressReduction = stressReduction + 2
					end

					-- Aplica a redução se houver
					if stressReduction > 0 then
						TriggerServerEvent("hud:ReduceStress", stressReduction)
					end
				end
			end
		end

		Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDSTATEBAGCHANGEHANDLER:PASSPORT
-----------------------------------------------------------------------------------------------------------------------------------------
AddStateBagChangeHandler("Passport",("player:%s"):format(LocalPlayer["state"]["Player"]),function(Name,Key,Value)
	SendNUIMessage({ name = "Passport", payload = Value })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDSTATEBAGCHANGEHANDLER:INSAFEZONE
-----------------------------------------------------------------------------------------------------------------------------------------
AddStateBagChangeHandler("SafeZone",("player:%s"):format(LocalPlayer["state"]["Player"]),function(Name,Key,Value)
	SendNUIMessage({ name = "Safezone", payload = (Value or LocalPlayer["state"]["Safezone"] or false) or false })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:VOIP
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Voip")
AddEventHandler("hud:Voip",function(Number)
	local Target = { "Baixo","Normal","Médio","Alto","Megafone" }

	SendNUIMessage({ name = "Voip", payload = Target[Number] })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:VOICE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Voice")
AddEventHandler("hud:Voice",function(Status)
	SendNUIMessage({ name = "Voice", payload = Status })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:WANTED
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Wanted")
AddEventHandler("hud:Wanted",function(Seconds)
	WantedMax = Seconds
	Wanted = Seconds
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- WANTED
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Wanted",function()
	return Wanted > 0 and true or false
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:REPOSED
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Reposed")
AddEventHandler("hud:Reposed",function(Seconds)
	Reposed = Seconds
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REPOSED
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Reposed",function()
	return Reposed > 0 and true or false
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:ACTIVE
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("hud:Active",function(Status)
	SendNUIMessage({ name = "Body", payload = { Status = Display } })
	Display = Status
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("hud",function()
	Display = not Display
	SendNUIMessage({ name = "Body", payload = { Display } })

	if not Display then
		if IsMinimapRendering() then
			DisplayRadar(false)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROGRESS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Progress")
AddEventHandler("Progress",function(Message,Timer)
	SendNUIMessage({ name = "Progress", payload = { Timer } })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MUMBLECONNECTED
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("mumbleConnected",function()
	SendNUIMessage({ name = "Voip", payload = "Online" })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MUMBLEDISCONNECTED
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("mumbleDisconnected",function()
	SendNUIMessage({ name = "Voip", payload = "Offline" })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:THIRST
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Thirst")
AddEventHandler("hud:Thirst",function(Number)
	if Thirst ~= Number then
		SendNUIMessage({ name = "Thirst", payload = Number })
		Thirst = Number
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:HUNGER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Hunger")
AddEventHandler("hud:Hunger",function(Number)
	if Hunger ~= Number then
		SendNUIMessage({ name = "Hunger", payload = Number })
		Hunger = Number
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:STRESS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Stress")
AddEventHandler("hud:Stress",function(Number)
	-- Validação do parâmetro Number
	if not Number or type(Number) ~= "number" then
		print(string.format("[HUD] ERRO: Number inválido no evento Stress: %s", tostring(Number)))
		return
	end
	
	if Stress ~= Number then
		SendNUIMessage({ name = "Stress", payload = Number })
		Stress = Number
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:LUCK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Luck")
AddEventHandler("hud:Luck",function(Seconds)
	Luck = Seconds
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:DEXTERITY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Dexterity")
AddEventHandler("hud:Dexterity",function(Seconds)
	Dexterity = Seconds
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:TOGGLEHOOD
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:toggleHood")
AddEventHandler("hud:toggleHood",function()
	Hood = not Hood

	if Hood then
		SetPedComponentVariation(PlayerPedId(),1,69,0,1)
	else
		SetPedComponentVariation(PlayerPedId(),1,0,0,1)
	end

	SendNUIMessage({ Action = "Hood", Status = Hood })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:REMOVEHOOD
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:RemoveHood")
AddEventHandler("hud:RemoveHood",function()
	if Hood then
		Hood = false
		SendNUIMessage({ Action = "Hood", Status = Hood })
		SetPedComponentVariation(PlayerPedId(),1,0,0,1)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:ADDGEMSTONE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:AddGems")
AddEventHandler("hud:AddGems",function(Number)
	Gemstone = Gemstone + Number

	SendNUIMessage({ name = "Gemstone", payload = Gemstone })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:REMOVEGEMSTONE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:RemoveGems")
AddEventHandler("hud:RemoveGems",function(Number)
	Gemstone = Gemstone - Number

	if Gemstone < 0 then
		Gemstone = 0
	end

	SendNUIMessage({ name = "Gemstone", payload = Gemstone })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:RADIO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Radio")
AddEventHandler("hud:Radio",function(Frequency)
	if type(Frequency) == "number" then
		SendNUIMessage({ name = "Frequency", payload = Frequency })
	else
		SendNUIMessage({ name = "Frequency", payload = Frequency })
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXPORTS PARA OUTROS SCRIPTS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Export para obter valores atuais
exports("GetHunger", function()
	return Hunger
end)

exports("GetThirst", function()
	return Thirst
end)

exports("GetStress", function()
	return Stress
end)

exports("GetHealth", function()
	return Health
end)

-- Export para verificar se está sofrendo
exports("IsSuffering", function()
	return (Hunger < 10 or Thirst < 10 or Stress >= 80)
end)

-- Export para obter nível de stress
exports("GetStressLevel", function()
	return Stress
end)

-- Export para verificar se está com stress alto
exports("IsHighStress", function()
	return Stress >= 60
end)

-- Export para verificar se está com stress crítico
exports("IsCriticalStress", function()
	return Stress >= 80
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DEATH SYSTEM INTEGRATION
-----------------------------------------------------------------------------------------------------------------------------------------
-- Evento quando o jogador morre
RegisterNetEvent("player:DeathUpdate")
AddEventHandler("player:DeathUpdate", function(status)
    if status then
        -- Jogador morreu
        IsDead = true
        SendNUIMessage({ name = "Health", payload = 0 })
        print("💀 Evento de morte detectado - Vida zerada na HUD")
    else
        -- Jogador foi revivido
        IsDead = false
        local currentHealth = GetEntityHealth(PlayerPedId())
        if currentHealth > 100 then
            SendNUIMessage({ name = "Health", payload = currentHealth - 100 })
        end
        print("❤️ Evento de reviver detectado - Vida restaurada na HUD")
    end
end)

-- Evento quando o jogador é revivido
RegisterNetEvent("player:Revive")
AddEventHandler("player:Revive", function()
    IsDead = false
    local currentHealth = GetEntityHealth(PlayerPedId())
    if currentHealth > 100 then
        SendNUIMessage({ name = "Health", payload = currentHealth - 100 })
    end
    print("❤️ Evento de revive detectado - Vida restaurada na HUD")
end)

-- Evento quando o jogador é nocauteado
RegisterNetEvent("player:Knockout")
AddEventHandler("player:Knockout", function()
    IsDead = true
    SendNUIMessage({ name = "Health", payload = 0 })
    print("😵 Evento de nocaute detectado - Vida zerada na HUD")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TEST VIP CALLBACK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:TestVipCallback")
AddEventHandler("hud:TestVipCallback", function()
    print("🧪 Testando callback VIP...")
    
    local vipResult = TriggerServerCallback("hud:GetVipGroup")
    print("🔁 Resultado do callback VIP:", vipResult)
    
    local playerData = TriggerServerCallback("hud:GetPlayerData")
    if playerData then
        print("📊 Dados do jogador:")
        print("  - Vida:", playerData.health)
        print("  - Fome:", playerData.hunger)
        print("  - Sede:", playerData.thirst)
        print("  - Stress:", playerData.stress)
        print("  - VIP:", playerData.vip)
    else
        print("❌ Erro ao obter dados do jogador")
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VIP STATUS UPDATE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:UpdateVipStatus")
AddEventHandler("hud:UpdateVipStatus", function()
    PlayerVIP = TriggerServerCallback("hud:GetVipGroup")
    print("🔄 Status VIP atualizado:", PlayerVIP)
    
    -- Envia o status VIP para a interface
    SendNUIMessage({ name = "VipStatus", payload = PlayerVIP })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE ITENS PARA REDUZIR STRESS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Evento para usar item que reduz stress
RegisterNetEvent("hud:UseStressItem")
AddEventHandler("hud:UseStressItem", function(itemName, reductionAmount)
    -- Validação do parâmetro reductionAmount
    if not reductionAmount or type(reductionAmount) ~= "number" then
        print(string.format("[HUD] ERRO: reductionAmount inválido: %s", tostring(reductionAmount)))
        return
    end
    
    -- Validação da variável Stress
    if not Stress or type(Stress) ~= "number" then
        print(string.format("[HUD] ERRO: Stress inválido: %s", tostring(Stress)))
        return
    end
    
    if Stress > 0 then
        TriggerServerEvent("hud:ReduceStress", reductionAmount)
        TriggerEvent("Notify", "verde", "Você se sentiu mais relaxado.", 3000)
        
        -- Efeitos visuais baseados no item
        if itemName == "cigarette" then
            -- Efeito de fumaça
            local Ped = PlayerPedId()
            local Coords = GetEntityCoords(Ped)
            RequestNamedPtfxAsset("core")
            while not HasNamedPtfxAssetLoaded("core") do
                Wait(0)
            end
            UseParticleAssetNextCall("core")
            StartParticleNonLoopedAtCoord("ent_sht_electrical_box", Coords.x, Coords.y, Coords.z + 1.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
        elseif itemName == "joint" then
            -- Efeito de relaxamento
            SetTimecycleModifier("spectator5")
            SetTimeout(5000, function()
                ClearTimecycleModifier()
            end)
        end
    else
        TriggerEvent("Notify", "amarelo", "Você já está relaxado.", 3000)
    end
end)

-- Evento para usar item que aumenta stress
RegisterNetEvent("hud:UseStressItemIncrease")
AddEventHandler("hud:UseStressItemIncrease", function(itemName, increaseAmount)
    -- Validação do parâmetro increaseAmount
    if not increaseAmount or type(increaseAmount) ~= "number" then
        print(string.format("[HUD] ERRO: increaseAmount inválido: %s", tostring(increaseAmount)))
        return
    end
    
    TriggerServerEvent("hud:AddStress", increaseAmount)
    TriggerEvent("Notify", "vermelho", "Você se sentiu mais agitado.", 3000)
end)