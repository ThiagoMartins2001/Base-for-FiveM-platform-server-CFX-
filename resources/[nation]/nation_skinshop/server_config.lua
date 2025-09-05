local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
fclient = Tunnel.getInterface("nation_skinshop")
func = {}
Tunnel.bindInterface("nation_skinshop", func)

function func.checkPermission(permission)
    local source = source
    local user_id = vRP.Passport(source)
    if type(permission) == "table" then
        for i, perm in pairs(permission) do
            if vRP.HasPermission(user_id, perm) then
                return true
            end
        end
        return false
    end
    return vRP.HasPermission(user_id, permission)
end

function func.updateClothes()
    local source = source
    local Passport = vRP.Passport(source)
    local clothes = fclient.getCloths(source)
    vRP.Query("playerdata/SetData",{ Passport = Passport, dkey = "Clothings", dvalue = json.encode(clothes) })
end

function func.tryPayClothes(value)
    local source = source
    local Passport = vRP.Passport(source)
    
    if not Passport then
        return false
    end
    
    if value >= 0 then
        -- Se o valor for 0, aprovar automaticamente (itens gratuitos)
        if value == 0 then
            local clothes = fclient.getCloths(source)
            TriggerClientEvent("updateRoupas", source, clothes)
            return true
        end
        
        -- Verificar se o jogador tem dinheiro suficiente antes de tentar pagar
        local playerMoney = vRP.InventoryItemAmount(Passport, "dollars") and vRP.InventoryItemAmount(Passport, "dollars")[1] or 0
        local playerBank = vRP.GetBank(source)
        
        -- Tentar pagar com dinheiro em mãos primeiro
        if playerMoney >= value then
            local moneyResult = vRP.PaymentMoney(Passport, value)
            
            if moneyResult == true then
                local clothes = fclient.getCloths(source)
                TriggerClientEvent("updateRoupas", source, clothes)
                return true
            end
        end
        
        -- Se não conseguiu pagar com dinheiro em mãos, tentar com banco
        if playerBank >= value then
            local bankResult = vRP.PaymentBank(Passport, value)
            
            if bankResult == true then
                local clothes = fclient.getCloths(source)
                TriggerClientEvent("updateRoupas", source, clothes)
                return true
            end
        end
        
        return false
    else
        return false
    end
end
