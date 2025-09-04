local vehData = {}

-- Prepara as queries
vRP.Prepare('sjr/selectAll', "SELECT * FROM 0r_mechanics")
vRP.Prepare('sjr/selectUnique', 'SELECT * FROM 0r_mechanics WHERE plate = @plate')
vRP.Prepare('sjr/updateVeh', "UPDATE 0r_mechanics SET data = @data WHERE plate = @plate")
vRP.Prepare('sjr/insertVeh', "INSERT INTO 0r_mechanics (plate, data) VALUES (@plate, @data)")
vRP.Prepare('sjr/createTable', [[
    CREATE TABLE IF NOT EXISTS 0r_mechanics (
        id INT AUTO_INCREMENT PRIMARY KEY,
        plate VARCHAR(20) NOT NULL,
        data TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    )
]])

Citizen.CreateThread(function()
    -- Tenta criar a tabela se ela não existir
    local success = pcall(function()
        vRP.Query('sjr/createTable', {})
    end)
    
    if not success then
        print("^1[ERROR] 0r-mechanic: Não foi possível criar a tabela 0r_mechanics^7")
        return
    end
    
    -- Carrega os dados existentes
    local result = vRP.Query('sjr/selectAll', {})
    if result and #result > 0 then
        for _, data in pairs(result) do
            if data.plate and data.data then
                local success, decoded = pcall(json.decode, data.data)
                if success then
                    vehData[data.plate] = decoded
                else
                    print("^3[WARNING] 0r-mechanic: Dados inválidos para placa " .. tostring(data.plate) .. "^7")
                end
            end
        end
    end
    
    print("^2[INFO] 0r-mechanic: Sistema carregado com sucesso^7")
end)

addElement = function(section, data)
    -- Validação dos parâmetros
    if not section or not data or not data.plate then
        print("^1[ERROR] 0r-mechanic: Parâmetros inválidos em addElement^7")
        return false
    end
    
    -- Inicializa a estrutura de dados para a placa se não existir
    if not vehData[data.plate] then
        vehData[data.plate] = {}
    end

    -- Atualiza os dados conforme a seção
    if section == "fitment" then
        vehData[data.plate][section] = data.fitment
    elseif data.mod == "Stock" then
        vehData[data.plate][section] = nil
    else
        vehData[data.plate][section] = data.mod
    end

    -- Salva no banco de dados
    local success = pcall(function()
        local output = vRP.Query('sjr/selectUnique', { plate = data.plate})
        if output and #output > 0 then
            vRP.Query('sjr/updateVeh', { plate = data.plate, data = json.encode(vehData[data.plate])})
        else
            vRP.Query('sjr/insertVeh', { plate = data.plate, data = json.encode(vehData[data.plate])})
        end
    end)
    
    if not success then
        print("^1[ERROR] 0r-mechanic: Erro ao salvar dados no banco para placa " .. tostring(data.plate) .. "^7")
        return false
    end

    -- Sincroniza com os clientes
    TriggerClientEvent("0r-mechanic:client:updateVehData", -1, vehData)
    return true
end

RegisterServerEvent("0r-mechanic:server:syncFitment", function(vehicleId, fitmentData)
    TriggerClientEvent("0r-mechanic:client:syncFitment", -1, vehicleId, fitmentData)
end)

RegisterServerEvent("0r-mechanic:server:useNitro", function(vehicleId)
    TriggerClientEvent("0r-mechanic:client:useNitro", -1, vehicleId)
end)

RegisterServerEvent("0r-mechanic:server:addElement", addElement)

RegisterServerEvent("tunning:syncApplyMods")
AddEventHandler("tunning:syncApplyMods",function(vehicle,vehicle_tuning)
    TriggerClientEvent("tunning:applyTunning",-1,vehicle, vehicle_tuning)
end)

-- RegisterServerEvent("tunning:applyTunning")
-- AddEventHandler("tunning:applyTunning",function(vehicle,plate)
-- 	local user_id = vRP.getUserByRegistration(plate)
-- 	local data = vRP.getSData("custom:u"..user_id.."veh_"..tostring(vehname))
-- 	local custom = json.decode(data)
--     if custom then
-- 		TriggerClientEvent("tunning:applyTunning",-1,vehicle, custom)
--     end
-- end)

Citizen.CreateThread(function()

    src.checkPermission = function(perm)
        local source = source
        local user_id = vRP.Passport(source)
        if user_id then
            return vRP.HasPermission(user_id, perm)
        end
        return false
    end

    src.buyComponent = function(data, mods)
        local source = source
        local xPlayer = GetPlayer(source)

        if not xPlayer then
            return
        end
        if vRP.PaymentFull(xPlayer,data.price) then
           -- vRP.setSData("custom:u" .. nuser_id .. "veh_" .. tostring(data.model),json.encode(mods))
            vRP.Query("entitydata/SetData",{ dkey = "Mods:"..data.plate, dvalue = json.encode(mods) })
            return {status = true}
        end


        Notification(Config.Locale["dont_have_money"])
        return {status = false}
    end

    src.buyBasketData = function(data, mods)
        local source = source
        local user_id = vRP.Passport(source)
        if user_id then
            local type = data[1]
            local basketData = data[2]
            local currentMechanic = data[3]
            local plate = data[4]
            local totalPrice = 0
            if next(basketData) then
                for k,v in pairs(basketData) do
                    if v.component.price then
                        totalPrice += v.component.price
                    end
                end
            end


            if vRP.PaymentFull(user_id,totalPrice) then
                vRP.Query("entitydata/SetData",{ dkey = "Mods:"..plate, dvalue = json.encode(mods) })
                -- local nuser_id = vRP.getUserByRegistration(plate)
                -- if nuser_id then
                --     vRP.setSData("custom:u" .. nuser_id .. "veh_" .. tostring(model),json.encode(mods))
                -- end
                return {status = true}
            end
        


            Notification(Config.Locale["dont_have_money"])
            return {status = false}
        end
        return {status = false}
    end
    src.getVehData = function()
        return vehData
    end
end)






