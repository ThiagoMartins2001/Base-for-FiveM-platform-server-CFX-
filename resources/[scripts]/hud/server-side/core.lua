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
Tunnel.bindInterface("hud",Creative)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
GlobalState["Work"] = 0
GlobalState["Hours"] = 12
GlobalState["Minutes"] = 0
GlobalState["Weather"] = "EXTRASUNNY"
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSYNC
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		GlobalState["Work"] = GlobalState["Work"] + 1
		GlobalState["Minutes"] = GlobalState["Minutes"] + 1

		if GlobalState["Minutes"] >= 60 then
			GlobalState["Hours"] = GlobalState["Hours"] + 1
			GlobalState["Minutes"] = 0

			if GlobalState["Hours"] >= 24 then
				GlobalState["Hours"] = 0
			end
		end

		Wait(10000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TIMESET
-----------------------------------------------------------------------------------------------------------------------------------------
-- Tradução de climas para facilitar o uso
local climaTraduzido = {
    ["ensolarado"] = "EXTRASUNNY",
    ["limpo"] = "CLEAR",
    ["nublado"] = "CLOUDS",
    ["poluido"] = "SMOG",
    ["neblina"] = "FOGGY",
    ["encoberto"] = "OVERCAST",
    ["chuva"] = "RAIN",
    ["tempestade"] = "THUNDER",
    ["limpando"] = "CLEARING",
    ["neve"] = "SNOW",
    ["nevasca"] = "BLIZZARD",
    ["neveleve"] = "SNOWLIGHT",
    ["natal"] = "XMAS"
}

-- Comando para mudar hora, clima e blackout
RegisterCommand("clima", function(source, Message)
    local Passport = vRP.Passport(source)
    if Passport then
        if vRP.HasGroup(Passport, "Admin") then
            -- Caso apenas o clima seja fornecido
            if Message[1] and not tonumber(Message[1]) then
                local climaInput = Message[1]:lower()
                local clima = climaTraduzido[climaInput] or climaInput:upper()
                GlobalState["Weather"] = clima

                -- Mensagem de sucesso para alteração do clima
                TriggerClientEvent("chat:addMessage", source, {
                    args = { "Sistema", "Clima alterado para: " .. climaInput }
                })

            -- Caso hora, minuto e opcionalmente clima sejam fornecidos
            elseif Message[1] and Message[2] then
                GlobalState["Hours"] = tonumber(Message[1])
                GlobalState["Minutes"] = tonumber(Message[2])

                -- Alteração de clima, se fornecido
                if Message[3] then
                    local climaInput = Message[3]:lower()
                    local clima = climaTraduzido[climaInput] or climaInput:upper()
                    GlobalState["Weather"] = clima
                end

                -- Mensagem de sucesso para alteração de horário
                TriggerClientEvent("chat:addMessage", source, {
                    args = { "Sistema", "Horário alterado para: " .. Message[1] .. ":" .. Message[2] }
                })

            -- Caso nada seja passado ou o formato esteja incorreto
            else
                TriggerClientEvent("chat:addMessage", source, {
                    args = { "Sistema", "Uso: /clima [hora minuto clima] ou /clima [clima]" }
                })
            end

            -- Definindo blackout (opcional)
            if Message[4] then
                GlobalState["Blackout"] = tonumber(Message[4])
            end
        else
            TriggerClientEvent("chat:addMessage", source, {
                args = { "Sistema", "Você não tem permissão para usar este comando." }
            })
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE STRESS AUTOMÁTICO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Thread para gerenciar stress automático baseado em ações
CreateThread(function()
    while true do
        Wait(300000) -- 5 minutos
        
        -- Verifica todos os jogadores online
        local Players = GetPlayers()
        for _, playerId in ipairs(Players) do
            local Passport = vRP.Passport(tonumber(playerId))
            if Passport then
                local Datatable = vRP.Datatable(Passport)
                if Datatable then
                    -- Stress por tempo online (1 ponto a cada 5 minutos)
                    if Datatable.Stress and Datatable.Stress < 100 then
                        vRP.UpgradeStress(Passport, 1)
                    end
                    
                    -- Stress por falta de sono (se implementado)
                    if Datatable.SleepTime then
                        local currentTime = os.time()
                        if (currentTime - Datatable.SleepTime) > 3600 then -- 1 hora sem dormir
                            vRP.UpgradeStress(Passport, 2)
                        end
                    end
                end
            end
        end
    end
end)

-- Thread para redução automática de stress (baseada no script Survival)
CreateThread(function()
    while true do
        Wait(600000) -- 10 minutos
        
        -- Verifica todos os jogadores online
        local Players = GetPlayers()
        for _, playerId in ipairs(Players) do
            local Passport = vRP.Passport(tonumber(playerId))
            if Passport then
                local Datatable = vRP.Datatable(Passport)
                if Datatable and Datatable.Stress and type(Datatable.Stress) == "number" and Datatable.Stress > 0 then
                    -- Redução base de stress por tempo (1 ponto a cada 10 minutos)
                    local reductionAmount = 1
                    
                    -- Verifica se o jogador tem VIP que aumenta a redução
                    if vRP.HasGroup(Passport, "vipabsolutultimate") then
                        reductionAmount = 3 -- VIP reduz 3 pontos
                    elseif vRP.HasGroup(Passport, "vipehp") then
                        reductionAmount = 2 -- VIP reduz 2 pontos
                    elseif vRP.HasGroup(Passport, "vipadvanced") then
                        reductionAmount = 2 -- VIP reduz 2 pontos
                    elseif vRP.HasGroup(Passport, "vipdiamond") then
                        reductionAmount = 2 -- VIP reduz 2 pontos
                    elseif vRP.HasGroup(Passport, "vipplatium") then
                        reductionAmount = 1 -- VIP reduz 1 ponto extra
                    elseif vRP.HasGroup(Passport, "vipgold") then
                        reductionAmount = 1 -- VIP reduz 1 ponto extra
                    end
                    
                    vRP.DowngradeStress(Passport, reductionAmount)
                    
                    -- Log da redução automática
                    print(string.format("[HUD] Redução automática de stress: Jogador %s (%s) reduziu %d de stress", 
                        Passport, playerId, reductionAmount))
                end
            end
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES DE GERENCIAMENTO DE STRESS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Função para adicionar stress por ação específica
function Creative.AddStressByAction(source, action, amount)
    local Passport = vRP.Passport(source)
    if Passport then
        local Datatable = vRP.Datatable(Passport)
        if Datatable then
            -- Verifica se o jogador tem algum item que reduz stress
            local cigaretteAmount = vRP.GetItemAmount(Passport, "cigarette") or 0
            if cigaretteAmount > 0 then
                amount = math.floor(amount * 0.5) -- Reduz stress pela metade se tiver cigarro
            end
            
            vRP.UpgradeStress(Passport, amount)
            
            -- Log da ação
            print(string.format("[HUD] Jogador %s (%s) recebeu %d de stress por ação: %s", 
                Passport, source, amount, action))
        end
    end
end

-- Função para reduzir stress por atividade relaxante
function Creative.ReduceStressByActivity(source, activity, amount)
    local Passport = vRP.Passport(source)
    if Passport then
        local Datatable = vRP.Datatable(Passport)
        if Datatable and Datatable.Stress and type(Datatable.Stress) == "number" and Datatable.Stress > 0 then
            vRP.DowngradeStress(Passport, amount)
            
            -- Log da atividade
            print(string.format("[HUD] Jogador %s (%s) reduziu %d de stress por atividade: %s", 
                Passport, source, amount, activity))
        end
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- CALLBACKS DO SISTEMA
-----------------------------------------------------------------------------------------------------------------------------------------
local Callbacks = {}

RegisterNetEvent("callback:trigger", function(name, requestId, args)
    local src = source
    if Callbacks[name] then
        Callbacks[name](src, function(result)
            TriggerClientEvent("callback:response", src, requestId, result)
        end, table.unpack(args or {}))
    else
        TriggerClientEvent("callback:response", src, requestId, nil)
    end
end)

-- Callback para obter grupo VIP do jogador
Callbacks["hud:GetVipGroup"] = function(source, cb)
    local user_id = vRP.Passport(source)
    if user_id then
        if vRP.HasGroup(user_id, "vipabsolutultimate") then
            cb("vipabsolutultimate")
        elseif vRP.HasGroup(user_id, "vipehp") then
            cb("vipehp")
        elseif vRP.HasGroup(user_id, "vipadvanced") then
            cb("vipadvanced")
        elseif vRP.HasGroup(user_id, "vipdiamond") then
            cb("vipdiamond")
        elseif vRP.HasGroup(user_id, "vipplatium") then
            cb("vipplatium")
        elseif vRP.HasGroup(user_id, "vipgold") then
            cb("vipgold")
        else
            cb("none")
        end
    else
        cb("none")
    end
end

-- Callback para obter dados do jogador
Callbacks["hud:GetPlayerData"] = function(source, cb)
    local user_id = vRP.Passport(source)
    if user_id then
        local Datatable = vRP.Datatable(user_id)
        if Datatable then
            cb({
                health = vRP.GetHealth(source),
                hunger = Datatable.Hunger or 0,
                thirst = Datatable.Thirst or 0,
                stress = Datatable.Stress or 0,
                vip = Callbacks["hud:GetVipGroup"](source, function(vip) return vip end)
            })
        else
            cb(nil)
        end
    else
        cb(nil)
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTOS DE STRESS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Evento para adicionar stress (chamado pelo cliente)
RegisterServerEvent("hud:AddStress")
AddEventHandler("hud:AddStress", function(amount)
    local source = source
    local Passport = vRP.Passport(source)
    
    -- Validação do parâmetro amount
    if not amount or type(amount) ~= "number" then
        print(string.format("[HUD] ERRO: amount inválido para jogador %s (%s): %s", 
            Passport or "desconhecido", source, tostring(amount)))
        return
    end
    
    if Passport then
        local Datatable = vRP.Datatable(Passport)
        if Datatable then
            -- Verifica se o jogador tem algum item que reduz stress
            local cigaretteAmount = vRP.GetItemAmount(Passport, "cigarette") or 0
            if cigaretteAmount > 0 then
                amount = math.floor(amount * 0.5) -- Reduz stress pela metade se tiver cigarro
            end
            
            -- Verifica se o jogador tem VIP que reduz stress
            if vRP.HasGroup(Passport, "vipabsolutultimate") then
                amount = math.floor(amount * 0.3) -- VIP reduz stress em 70%
            elseif vRP.HasGroup(Passport, "vipehp") then
                amount = math.floor(amount * 0.4) -- VIP reduz stress em 60%
            elseif vRP.HasGroup(Passport, "vipadvanced") then
                amount = math.floor(amount * 0.5) -- VIP reduz stress em 50%
            elseif vRP.HasGroup(Passport, "vipdiamond") then
                amount = math.floor(amount * 0.6) -- VIP reduz stress em 40%
            elseif vRP.HasGroup(Passport, "vipplatium") then
                amount = math.floor(amount * 0.7) -- VIP reduz stress em 30%
            elseif vRP.HasGroup(Passport, "vipgold") then
                amount = math.floor(amount * 0.8) -- VIP reduz stress em 20%
            end
            
            vRP.UpgradeStress(Passport, amount)
            
            -- Log da ação
            print(string.format("[HUD] Jogador %s (%s) recebeu %d de stress por ação automática", 
                Passport, source, amount))
        end
    end
end)

-- Evento para reduzir stress (chamado pelo cliente)
RegisterServerEvent("hud:ReduceStress")
AddEventHandler("hud:ReduceStress", function(amount)
    local source = source
    local Passport = vRP.Passport(source)
    
    -- Validação do parâmetro amount
    if not amount or type(amount) ~= "number" then
        print(string.format("[HUD] ERRO: amount inválido para jogador %s (%s): %s", 
            Passport or "desconhecido", source, tostring(amount)))
        return
    end
    
    if Passport then
        local Datatable = vRP.Datatable(Passport)
        if Datatable and Datatable.Stress and type(Datatable.Stress) == "number" and Datatable.Stress > 0 then
            -- Verifica se o jogador tem VIP que aumenta a redução de stress
            if vRP.HasGroup(Passport, "vipabsolutultimate") then
                amount = math.floor(amount * 1.7) -- VIP aumenta redução em 70%
            elseif vRP.HasGroup(Passport, "vipehp") then
                amount = math.floor(amount * 1.6) -- VIP aumenta redução em 60%
            elseif vRP.HasGroup(Passport, "vipadvanced") then
                amount = math.floor(amount * 1.5) -- VIP aumenta redução em 50%
            elseif vRP.HasGroup(Passport, "vipdiamond") then
                amount = math.floor(amount * 1.4) -- VIP aumenta redução em 40%
            elseif vRP.HasGroup(Passport, "vipplatium") then
                amount = math.floor(amount * 1.3) -- VIP aumenta redução em 30%
            elseif vRP.HasGroup(Passport, "vipgold") then
                amount = math.floor(amount * 1.2) -- VIP aumenta redução em 20%
            end
            
            vRP.DowngradeStress(Passport, amount)
            
            -- Log da atividade
            print(string.format("[HUD] Jogador %s (%s) reduziu %d de stress por atividade", 
                Passport, source, amount))
        end
    end
end)

-- Evento para usar item que reduz stress
RegisterServerEvent("hud:UseStressReductionItem")
AddEventHandler("hud:UseStressReductionItem", function(itemName)
    local source = source
    local Passport = vRP.Passport(source)
    if Passport then
        local Datatable = vRP.Datatable(Passport)
        if Datatable and Datatable.Stress and type(Datatable.Stress) == "number" and Datatable.Stress > 0 then
            local reductionAmount = 0
            
            -- Define a quantidade de redução baseada no item
            if itemName == "cigarette" then
                reductionAmount = 5
            elseif itemName == "joint" then
                reductionAmount = 10
            elseif itemName == "beer" then
                reductionAmount = 3
            elseif itemName == "whiskey" then
                reductionAmount = 5
            elseif itemName == "vodka" then
                reductionAmount = 7
            elseif itemName == "coffee" then
                reductionAmount = 2
            elseif itemName == "tea" then
                reductionAmount = 3
            else
                reductionAmount = 1 -- Redução padrão para outros itens
            end
            
            -- Verifica se o jogador tem VIP que aumenta a redução
            if vRP.HasGroup(Passport, "vipabsolutultimate") then
                reductionAmount = math.floor(reductionAmount * 1.7)
            elseif vRP.HasGroup(Passport, "vipehp") then
                reductionAmount = math.floor(reductionAmount * 1.6)
            elseif vRP.HasGroup(Passport, "vipadvanced") then
                reductionAmount = math.floor(reductionAmount * 1.5)
            elseif vRP.HasGroup(Passport, "vipdiamond") then
                reductionAmount = math.floor(reductionAmount * 1.4)
            elseif vRP.HasGroup(Passport, "vipplatium") then
                reductionAmount = math.floor(reductionAmount * 1.3)
            elseif vRP.HasGroup(Passport, "vipgold") then
                reductionAmount = math.floor(reductionAmount * 1.2)
            end
            
            vRP.DowngradeStress(Passport, reductionAmount)
            
            -- Log do uso do item
            print(string.format("[HUD] Jogador %s (%s) usou item %s e reduziu %d de stress", 
                Passport, source, itemName, reductionAmount))
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMANDOS DE ADMINISTRAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Comando para verificar status do jogador
RegisterCommand("status", function(source, args)
    local Passport = vRP.Passport(source)
    if Passport then
        if vRP.HasGroup(Passport, "Admin") then
            local targetId = tonumber(args[1]) or source
            local targetPassport = vRP.Passport(targetId)
            
            if targetPassport then
                local Datatable = vRP.Datatable(targetPassport)
                if Datatable then
                    TriggerClientEvent("chat:addMessage", source, {
                        args = { "Status", string.format("Jogador %s - Vida: %d, Fome: %d, Sede: %d, Stress: %d", 
                            targetPassport, 
                            vRP.GetHealth(targetId), 
                            Datatable.Hunger or 0, 
                            Datatable.Thirst or 0, 
                            Datatable.Stress or 0) }
                    })
                end
            end
        else
            TriggerClientEvent("chat:addMessage", source, {
                args = { "Sistema", "Você não tem permissão para usar este comando." }
            })
        end
    end
end)

-- Comando para resetar status do jogador
RegisterCommand("resetstatus", function(source, args)
    local Passport = vRP.Passport(source)
    if Passport then
        if vRP.HasGroup(Passport, "Admin") then
            local targetId = tonumber(args[1]) or source
            local targetPassport = vRP.Passport(targetId)
            
            if targetPassport then
                vRP.UpgradeHunger(targetPassport, 100)
                vRP.UpgradeThirst(targetPassport, 100)
                vRP.DowngradeStress(targetPassport, 100)
                vRPC.SetHealth(targetId, 200)
                
                TriggerClientEvent("chat:addMessage", source, {
                    args = { "Sistema", string.format("Status do jogador %s foi resetado.", targetPassport) }
                })
            end
        else
            TriggerClientEvent("chat:addMessage", source, {
                args = { "Sistema", "Você não tem permissão para usar este comando." }
            })
        end
    end
end)

-- Comando para definir stress do jogador
RegisterCommand("setstress", function(source, args)
    local Passport = vRP.Passport(source)
    if Passport then
        if vRP.HasGroup(Passport, "Admin") then
            local targetId = tonumber(args[1]) or source
            local targetPassport = vRP.Passport(targetId)
            local stressValue = tonumber(args[2]) or 0
            
            if targetPassport and stressValue >= 0 and stressValue <= 100 then
                local Datatable = vRP.Datatable(targetPassport)
                if Datatable then
                    Datatable.Stress = stressValue
                    TriggerClientEvent("hud:Stress", targetId, stressValue)
                    
                    TriggerClientEvent("chat:addMessage", source, {
                        args = { "Sistema", string.format("Stress do jogador %s definido para %d.", targetPassport, stressValue) }
                    })
                end
            else
                TriggerClientEvent("chat:addMessage", source, {
                    args = { "Sistema", "Uso: /setstress [id] [valor 0-100]" }
                })
            end
        else
            TriggerClientEvent("chat:addMessage", source, {
                args = { "Sistema", "Você não tem permissão para usar este comando." }
            })
        end
    end
end)

-- Comando para definir fome do jogador
RegisterCommand("sethunger", function(source, args)
    local Passport = vRP.Passport(source)
    if Passport then
        if vRP.HasGroup(Passport, "Admin") then
            local targetId = tonumber(args[1]) or source
            local targetPassport = vRP.Passport(targetId)
            local hungerValue = tonumber(args[2]) or 0
            
            if targetPassport and hungerValue >= 0 and hungerValue <= 100 then
                local Datatable = vRP.Datatable(targetPassport)
                if Datatable then
                    Datatable.Hunger = hungerValue
                    TriggerClientEvent("hud:Hunger", targetId, hungerValue)
                    
                    TriggerClientEvent("chat:addMessage", source, {
                        args = { "Sistema", string.format("Fome do jogador %s definida para %d.", targetPassport, hungerValue) }
                    })
                end
            else
                TriggerClientEvent("chat:addMessage", source, {
                    args = { "Sistema", "Uso: /sethunger [id] [valor 0-100]" }
                })
            end
        else
            TriggerClientEvent("chat:addMessage", source, {
                args = { "Sistema", "Você não tem permissão para usar este comando." }
            })
        end
    end
end)

-- Comando para definir sede do jogador
RegisterCommand("setthirst", function(source, args)
    local Passport = vRP.Passport(source)
    if Passport then
        if vRP.HasGroup(Passport, "Admin") then
            local targetId = tonumber(args[1]) or source
            local targetPassport = vRP.Passport(targetId)
            local thirstValue = tonumber(args[2]) or 0
            
            if targetPassport and thirstValue >= 0 and thirstValue <= 100 then
                local Datatable = vRP.Datatable(targetPassport)
                if Datatable then
                    Datatable.Thirst = thirstValue
                    TriggerClientEvent("hud:Thirst", targetId, thirstValue)
                    
                    TriggerClientEvent("chat:addMessage", source, {
                        args = { "Sistema", string.format("Sede do jogador %s definida para %d.", targetPassport, thirstValue) }
                    })
                end
            else
                TriggerClientEvent("chat:addMessage", source, {
                    args = { "Sistema", "Uso: /setthirst [id] [valor 0-100]" }
                })
            end
        else
            TriggerClientEvent("chat:addMessage", source, {
                args = { "Sistema", "Você não tem permissão para usar este comando." }
            })
        end
    end
end)

-- Comando para definir vida do jogador
RegisterCommand("sethealth", function(source, args)
    local Passport = vRP.Passport(source)
    if Passport then
        if vRP.HasGroup(Passport, "Admin") then
            local targetId = tonumber(args[1]) or source
            local targetPassport = vRP.Passport(targetId)
            local healthValue = tonumber(args[2]) or 200
            
            if targetPassport and healthValue >= 100 and healthValue <= 200 then
                vRPC.SetHealth(targetId, healthValue)
                
                TriggerClientEvent("chat:addMessage", source, {
                    args = { "Sistema", string.format("Vida do jogador %s definida para %d.", targetPassport, healthValue) }
                })
            else
                TriggerClientEvent("chat:addMessage", source, {
                    args = { "Sistema", "Uso: /sethealth [id] [valor 100-200]" }
                })
            end
        else
            TriggerClientEvent("chat:addMessage", source, {
                args = { "Sistema", "Você não tem permissão para usar este comando." }
            })
        end
    end
end)

-- Comando para adicionar stress ao jogador
RegisterCommand("addstress", function(source, args)
    local Passport = vRP.Passport(source)
    if Passport then
        if vRP.HasGroup(Passport, "Admin") then
            local targetId = tonumber(args[1]) or source
            local targetPassport = vRP.Passport(targetId)
            local stressAmount = tonumber(args[2]) or 1
            
            if targetPassport and stressAmount > 0 then
                vRP.UpgradeStress(targetPassport, stressAmount)
                
                TriggerClientEvent("chat:addMessage", source, {
                    args = { "Sistema", string.format("Adicionado %d de stress ao jogador %s.", stressAmount, targetPassport) }
                })
            else
                TriggerClientEvent("chat:addMessage", source, {
                    args = { "Sistema", "Uso: /addstress [id] [quantidade]" }
                })
            end
        else
            TriggerClientEvent("chat:addMessage", source, {
                args = { "Sistema", "Você não tem permissão para usar este comando." }
            })
        end
    end
end)

-- Comando para reduzir stress do jogador
RegisterCommand("reducestress", function(source, args)
    local Passport = vRP.Passport(source)
    if Passport then
        if vRP.HasGroup(Passport, "Admin") then
            local targetId = tonumber(args[1]) or source
            local targetPassport = vRP.Passport(targetId)
            local stressAmount = tonumber(args[2]) or 1
            
            if targetPassport and stressAmount > 0 then
                vRP.DowngradeStress(targetPassport, stressAmount)
                
                TriggerClientEvent("chat:addMessage", source, {
                    args = { "Sistema", string.format("Reduzido %d de stress do jogador %s.", stressAmount, targetPassport) }
                })
            else
                TriggerClientEvent("chat:addMessage", source, {
                    args = { "Sistema", "Uso: /reducestress [id] [quantidade]" }
                })
            end
        else
            TriggerClientEvent("chat:addMessage", source, {
                args = { "Sistema", "Você não tem permissão para usar este comando." }
            })
        end
    end
end)

-- Comando para verificar VIP do jogador
RegisterCommand("checkvip", function(source, args)
    local Passport = vRP.Passport(source)
    if Passport then
        local targetId = tonumber(args[1]) or source
        local targetPassport = vRP.Passport(targetId)
        
        if targetPassport then
            local vipGroups = {
                "vipabsolutultimate",
                "vipabsolut", 
                "vipadvanced",
                "vipdiamond",
                "vipplatium",
                "vipgold"
            }
            
            local hasVip = false
            local vipType = "Nenhum"
            
            for _, vipGroup in ipairs(vipGroups) do
                if vRP.HasGroup(targetPassport, vipGroup) then
                    hasVip = true
                    vipType = vipGroup
                    break
                end
            end
            
            TriggerClientEvent("chat:addMessage", source, {
                args = { "VIP", string.format("Jogador %s - VIP: %s", targetPassport, vipType) }
            })
            
            -- Log no console
            print(string.format("[HUD] Jogador %s (%s) - VIP: %s", targetPassport, targetId, vipType))
        else
            TriggerClientEvent("chat:addMessage", source, {
                args = { "Sistema", "Jogador não encontrado." }
            })
        end
    end
end)

-- Comando para testar callback VIP
RegisterCommand("testvip", function(source, args)
    local Passport = vRP.Passport(source)
    if Passport then
        TriggerClientEvent("hud:TestVipCallback", source)
        TriggerClientEvent("chat:addMessage", source, {
            args = { "Sistema", "Teste de callback VIP iniciado. Verifique o console." }
        })
    end
end)

-- Comando para testar sistema de morte
RegisterCommand("testdeath", function(source, args)
    local Passport = vRP.Passport(source)
    if Passport then
        if vRP.HasGroup(Passport, "Admin") then
            local targetId = tonumber(args[1]) or source
            local targetPassport = vRP.Passport(targetId)
            
            if targetPassport then
                -- Simula morte do jogador
                TriggerClientEvent("player:DeathUpdate", targetId, true)
                TriggerClientEvent("chat:addMessage", source, {
                    args = { "Sistema", string.format("Teste de morte aplicado ao jogador %s.", targetPassport) }
                })
            end
        else
            TriggerClientEvent("chat:addMessage", source, {
                args = { "Sistema", "Você não tem permissão para usar este comando." }
            })
        end
    end
end)

-- Comando para testar sistema de revive
RegisterCommand("testrevive", function(source, args)
    local Passport = vRP.Passport(source)
    if Passport then
        if vRP.HasGroup(Passport, "Admin") then
            local targetId = tonumber(args[1]) or source
            local targetPassport = vRP.Passport(targetId)
            
            if targetPassport then
                -- Simula revive do jogador
                TriggerClientEvent("player:Revive", targetId)
                TriggerClientEvent("chat:addMessage", source, {
                    args = { "Sistema", string.format("Teste de revive aplicado ao jogador %s.", targetPassport) }
                })
            end
        else
            TriggerClientEvent("chat:addMessage", source, {
                args = { "Sistema", "Você não tem permissão para usar este comando." }
            })
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CALLBACKS
-----------------------------------------------------------------------------------------------------------------------------------------
local Callbacks = {}

RegisterNetEvent("callback:trigger", function(name, requestId, args)
    local src = source
    if Callbacks[name] then
        Callbacks[name](src, function(result)
            TriggerClientEvent("callback:response", src, requestId, result)
        end, table.unpack(args or {}))
    else
        print("[HUD] Callback '"..name.."' não encontrado.")
        TriggerClientEvent("callback:response", src, requestId, nil)
    end
end)

-- Callback para obter grupo VIP do jogador
Callbacks["hud:GetVipGroup"] = function(source, cb)
    local user_id = vRP.Passport(source)
    if user_id then
        -- Verifica todos os grupos VIP possíveis
        if vRP.HasGroup(user_id, "vipabsolutultimate") then
            cb("vipabsolutultimate")
        elseif vRP.HasGroup(user_id, "vipabsolut") then
            cb("vipabsolut")
        elseif vRP.HasGroup(user_id, "vipadvanced") then
            cb("vipadvanced")
        elseif vRP.HasGroup(user_id, "vipdiamond") then
            cb("vipdiamond")
        elseif vRP.HasGroup(user_id, "vipplatium") then
            cb("vipplatium")
        elseif vRP.HasGroup(user_id, "vipgold") then
            cb("vipgold")
        else
            cb("none")
        end
    else
        cb("none")
    end
end

-- Callback para obter dados do jogador
Callbacks["hud:GetPlayerData"] = function(source, cb)
    local user_id = vRP.Passport(source)
    if user_id then
        local Datatable = vRP.Datatable(user_id)
        if Datatable then
            cb({
                health = vRP.GetHealth(source),
                hunger = Datatable.Hunger or 0,
                thirst = Datatable.Thirst or 0,
                stress = Datatable.Stress or 0,
                vip = vRP.HasGroup(user_id, "vipabsolutultimate") and "vipabsolutultimate" or
                      vRP.HasGroup(user_id, "vipabsolut") and "vipabsolut" or
                      vRP.HasGroup(user_id, "vipadvanced") and "vipadvanced" or
                      vRP.HasGroup(user_id, "vipdiamond") and "vipdiamond" or
                      vRP.HasGroup(user_id, "vipplatium") and "vipplatium" or
                      vRP.HasGroup(user_id, "vipgold") and "vipgold" or "none"
            })
        else
            cb(nil)
        end
    else
        cb(nil)
    end
end

