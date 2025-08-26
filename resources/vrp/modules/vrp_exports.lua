-- =====================================================
-- VRP EXPORTS - Para compatibilidade com outros scripts
-- =====================================================

print("^3[INFO] VRP Exports - Carregando eventos de compatibilidade^7")

-- Evento para obter o objeto vRP
RegisterNetEvent("vRP:getSharedObject")
AddEventHandler("vRP:getSharedObject", function(cb)
    print("^3[INFO] vRP:getSharedObject solicitado^7")
    if cb then
        cb(vRP)
        print("^2[SUCESSO] vRP objeto enviado via callback^7")
    end
end)

-- Evento para obter o objeto vRP (alternativo)
RegisterNetEvent("vRP:getSharedObject")
AddEventHandler("vRP:getSharedObject", function()
    print("^3[INFO] vRP:getSharedObject solicitado (sem callback)^7")
    return vRP
end)

-- Export para obter o objeto vRP
exports("GetSharedObject", function()
    print("^3[INFO] VRP GetSharedObject export chamado^7")
    return vRP
end)

-- Export alternativo
exports("getSharedObject", function()
    print("^3[INFO] VRP getSharedObject export chamado^7")
    return vRP
end)

-- Verificação de carregamento
CreateThread(function()
    Wait(2000)
    if vRP then
        print("^2[SUCESSO] VRP Exports - Sistema de compatibilidade carregado^7")
        print("^3[INFO] VRP Exports - Eventos disponíveis: vRP:getSharedObject^7")
        print("^3[INFO] VRP Exports - Exports disponíveis: GetSharedObject, getSharedObject^7")
    else
        print("^1[ERRO] VRP Exports - vRP não encontrado^7")
    end
end)
