-----------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE ANIMAÇÕES DE ALGEMADO
-----------------------------------------------------------------------------------------------------------------------------------------
local isHandcuffed = false
local handcuffAnimation = "mp_arresting"
local handcuffAnimDict = "idle"

-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTOS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("handcuff:applyAnimation")
AddEventHandler("handcuff:applyAnimation",function()
    print("^2[ALGEMAS]^7 Aplicando animação de algemado")
    isHandcuffed = true
    applyHandcuffAnimation()
end)

RegisterNetEvent("handcuff:removeAnimation")
AddEventHandler("handcuff:removeAnimation",function()
    print("^2[ALGEMAS]^7 Removendo animação de algemado")
    isHandcuffed = false
    removeHandcuffAnimation()
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES
-----------------------------------------------------------------------------------------------------------------------------------------
function applyHandcuffAnimation()
    local ped = PlayerPedId()
    
    print("^2[ALGEMAS]^7 Tentando aplicar animação...")
    
    RequestAnimDict(handcuffAnimation)
    local timeout = 0
    while not HasAnimDictLoaded(handcuffAnimation) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end
    
    if HasAnimDictLoaded(handcuffAnimation) then
        if not IsEntityPlayingAnim(ped, handcuffAnimation, handcuffAnimDict, 3) then
            TaskPlayAnim(ped, handcuffAnimation, handcuffAnimDict, 8.0, -8.0, -1, 1, 0, false, false, false)
            print("^2[ALGEMAS]^7 Animação aplicada com sucesso")
        else
            print("^2[ALGEMAS]^7 Animação já estava rodando")
        end
    else
        print("^1[ALGEMAS]^7 Erro ao carregar animação")
    end
end

function removeHandcuffAnimation()
    local ped = PlayerPedId()
    
    if IsEntityPlayingAnim(ped, handcuffAnimation, handcuffAnimDict, 3) then
        StopAnimTask(ped, handcuffAnimation, handcuffAnimDict, 1.0)
        print("^2[ALGEMAS]^7 Animação removida com sucesso")
    end
    
    RemoveAnimDict(handcuffAnimation)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADS
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        
        if isHandcuffed then
            sleep = 100
            local ped = PlayerPedId()
            
            if not IsEntityPlayingAnim(ped, handcuffAnimation, handcuffAnimDict, 3) then
                applyHandcuffAnimation()
            end
            
            if IsPedDeadOrDying(ped, true) then
                isHandcuffed = false
                removeHandcuffAnimation()
            end
        end
        
        Wait(sleep)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- COMANDO DE TESTE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("testhandcuff",function()
    if not isHandcuffed then
        TriggerEvent("handcuff:applyAnimation")
        TriggerEvent("Notify","verde","Animação de algemado aplicada.",5000)
    else
        TriggerEvent("handcuff:removeAnimation")
        TriggerEvent("Notify","verde","Animação de algemado removida.",5000)
    end
end)

-- Comando para forçar animação
RegisterCommand("forcehandcuff",function()
    local ped = PlayerPedId()
    RequestAnimDict("mp_arresting")
    while not HasAnimDictLoaded("mp_arresting") do
        Wait(10)
    end
    TaskPlayAnim(ped, "mp_arresting", "idle", 8.0, -8.0, -1, 1, 0, false, false, false)
    print("^2[ALGEMAS]^7 Animação forçada aplicada")
end)
