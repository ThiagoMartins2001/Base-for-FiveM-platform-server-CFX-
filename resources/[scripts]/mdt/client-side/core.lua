print("^3[MDT CLIENT] ==========================================^7")
print("^3[MDT CLIENT] ARQUIVO CLIENT-SIDE CORE.LUA CARREGADO^7")
print("^3[MDT CLIENT] ==========================================^7")

print("^3[MDT CLIENT] Iniciando carregamento do MDT^7")

-- Variáveis globais
local mdtOpen = false
local currentLocation = nil
local isLoggedIn = false
local userData = nil

-- Carregar módulos do vRP
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPS = Tunnel.getInterface("vRP")

print("^3[MDT CLIENT] Módulos carregados^7")

-- Configurar Tunnel do MDT
cRP = {}
Tunnel.bindInterface("mdt",cRP)
vSERVER = Tunnel.getInterface("mdt")

print("^3[MDT CLIENT] VRP carregado^7")
print("^3[MDT CLIENT] cRP: " .. tostring(cRP) .. "^7")
print("^3[MDT CLIENT] vSERVER: " .. tostring(vSERVER) .. "^7")

-- Função para abrir MDT
function openMDT()
    print("^3[MDT CLIENT] Função openMDT chamada^7")
    
    if not mdtOpen then
        mdtOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({ action = "openMDT" })
        print("^3[MDT CLIENT] MDT aberto^7")
    else
        print("^3[MDT CLIENT] MDT já está aberto^7")
    end
end

-- Função para fechar MDT
function closeMDT()
    print("^3[MDT CLIENT] Função closeMDT chamada^7")
    
    if mdtOpen then
        mdtOpen = false
        SetNuiFocus(false, false)
        SendNUIMessage({ action = "closeMDT" })
        print("^3[MDT CLIENT] MDT fechado^7")
    else
        print("^3[MDT CLIENT] MDT já está fechado^7")
    end
end

print("^2[MDT CLIENT] MDT carregado com sucesso^7")

-----------------------------------------------------------------------------------------------------------------------------------------
-- COMMANDS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("mdt", function()
    print("^3[MDT CLIENT] Comando /mdt executado^7")
    print("^3[MDT CLIENT] vSERVER: " .. tostring(vSERVER) .. "^7")
    
    if vSERVER then
        print("^3[MDT CLIENT] vSERVER disponível, verificando permissão^7")
        local hasPermission = vSERVER.checkPermission()
        print("^3[MDT CLIENT] Permissão: " .. tostring(hasPermission) .. "^7")
        
        if hasPermission then
            print("^3[MDT CLIENT] Abrindo MDT^7")
            openMDT()
        else
            print("^1[MDT CLIENT] Sem permissão^7")
            -- Notificação removida para evitar duplicação - a notificação já é exibida no server-side
        end
    else
        print("^1[MDT CLIENT] vSERVER não está disponível^7")
        TriggerEvent("Notify", "negado", "Erro de conexão com o servidor.")
    end
end)

-- Comando de teste para forçar abertura do MDT
RegisterCommand("mdt_test", function()
    print("^3[MDT CLIENT] Comando de teste executado^7")
    print("^3[MDT CLIENT] Forçando abertura do MDT^7")
    openMDT()
end)

-- Comando de teste simples
RegisterCommand("mdt_simple", function()
    print("^3[MDT CLIENT] Teste simples^7")
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "openMDT" })
    print("^3[MDT CLIENT] Teste simples concluído^7")
end)

-- Comando de teste para verificar se o NUI está funcionando
RegisterCommand("mdt_nui_test", function()
    print("^3[MDT CLIENT] Teste NUI^7")
    SetNuiFocus(true, true)
    SendNUIMessage({ 
        action = "test",
        message = "Teste de comunicação NUI"
    })
    print("^3[MDT CLIENT] Teste NUI enviado^7")
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI CALLBACKS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("closeMDT", function(data, cb)
    print("^3[MDT CLIENT] Callback closeMDT recebido^7")
    closeMDT()
    cb("ok")
end)

RegisterNUICallback("searchPerson", function(data, cb)
    print("^3[MDT CLIENT] Callback searchPerson recebido^7")
    if vSERVER then
        local result = vSERVER.searchPerson(data.query)
        cb({ result = result })
    else
        cb({ result = { success = false, message = "Erro de conexão" } })
    end
end)

RegisterNUICallback("searchVehicle", function(data, cb)
    print("^3[MDT CLIENT] Callback searchVehicle recebido^7")
    if vSERVER then
        local result = vSERVER.searchVehicle(data.query)
        cb({ result = result })
    else
        cb({ result = { success = false, message = "Erro de conexão" } })
    end
end)

RegisterNUICallback("createPrison", function(data, cb)
    print("^3[MDT CLIENT] Callback createPrison recebido^7")
    if vSERVER then
        local result = vSERVER.createPrison(data)
        cb({ result = result })
    else
        cb({ result = { success = false, message = "Erro de conexão" } })
    end
end)

RegisterNUICallback("createFine", function(data, cb)
    print("^3[MDT CLIENT] Callback createFine recebido^7")
    if vSERVER then
        local result = vSERVER.createFine(data)
        cb({ result = result })
    else
        cb({ result = { success = false, message = "Erro de conexão" } })
    end
end)

RegisterNUICallback("createWarrant", function(data, cb)
    print("^3[MDT CLIENT] Callback createWarrant recebido^7")
    if vSERVER then
        local result = vSERVER.createWarrant(data)
        cb({ result = result })
    else
        cb({ result = { success = false, message = "Erro de conexão" } })
    end
end)

RegisterNUICallback("createPort", function(data, cb)
    print("^3[MDT CLIENT] Callback createPort recebido^7")
    if vSERVER then
        local result = vSERVER.createPort(data)
        cb({ result = result })
    else
        cb({ result = { success = false, message = "Erro de conexão" } })
    end
end)

RegisterNUICallback("createReport", function(data, cb)
    print("^3[MDT CLIENT] Callback createReport recebido^7")
    if vSERVER then
        local result = vSERVER.createReport(data)
        cb({ result = result })
    else
        cb({ result = { success = false, message = "Erro de conexão" } })
    end
end)

RegisterNUICallback("createAnnouncement", function(data, cb)
    print("^3[MDT CLIENT] Callback createAnnouncement recebido^7")
    if vSERVER then
        local result = vSERVER.createAnnouncement(data)
        cb({ result = result })
    else
        cb({ result = { success = false, message = "Erro de conexão" } })
    end
end)

RegisterNUICallback("getCompleteStats", function(data, cb)
    print("^3[MDT CLIENT] Callback getCompleteStats recebido^7")
    if vSERVER then
        local result = vSERVER.getCompleteStats()
        cb({ result = result })
    else
        cb({ result = { success = false, message = "Erro de conexão" } })
    end
end)

RegisterNUICallback("getAllFines", function(data, cb)
    print("^3[MDT CLIENT] Callback getAllFines recebido^7")
    if vSERVER then
        local result = vSERVER.getAllFines()
        cb({ result = result })
    else
        cb({ result = { success = false, message = "Erro de conexão" } })
    end
end)

RegisterNUICallback("getAllPorts", function(data, cb)
    print("^3[MDT CLIENT] Callback getAllPorts recebido^7")
    if vSERVER then
        local result = vSERVER.getAllPorts()
        cb({ result = result })
    else
        cb({ result = { success = false, message = "Erro de conexão" } })
    end
end)

RegisterNUICallback("getAllReports", function(data, cb)
    print("^3[MDT CLIENT] Callback getAllReports recebido^7")
    if vSERVER then
        local result = vSERVER.getAllReports()
        cb({ result = result })
    else
        cb({ result = { success = false, message = "Erro de conexão" } })
    end
end)

RegisterNUICallback("getAllVehicles", function(data, cb)
    print("^3[MDT CLIENT] Callback getAllVehicles recebido^7")
    if vSERVER then
        local result = vSERVER.getAllVehicles()
        cb({ result = result })
    else
        cb({ result = { success = false, message = "Erro de conexão" } })
    end
end)

RegisterNUICallback("getAllAnnouncements", function(data, cb)
    print("^3[MDT CLIENT] Callback getAllAnnouncements recebido^7")
    if vSERVER then
        local result = vSERVER.getAllAnnouncements()
        cb({ result = result })
    else
        cb({ result = { success = false, message = "Erro de conexão" } })
    end
end)

RegisterNUICallback("getAllWarrants", function(data, cb)
    print("^3[MDT CLIENT] Callback getAllWarrants recebido^7")
    if vSERVER then
        local result = vSERVER.getAllWarrants()
        cb({ result = result })
    else
        cb({ result = { success = false, message = "Erro de conexão" } })
    end
end)

RegisterNUICallback("exportData", function(data, cb)
    print("^3[MDT CLIENT] Callback exportData recebido^7")
    if vSERVER then
        local result = vSERVER.exportData(data.type, data.filters)
        cb({ result = result })
    else
        cb({ result = { success = false, message = "Erro de conexão" } })
    end
end)

RegisterNUICallback("logActivity", function(data, cb)
    print("^3[MDT CLIENT] Callback logActivity recebido^7")
    if vSERVER then
        vSERVER.logActivity(data.action, data.details)
    end
    cb("ok")
end)

RegisterNUICallback("authenticateUser", function(data, cb)
    print("^3[MDT CLIENT] Callback authenticateUser recebido^7")
    print("^3[MDT CLIENT] Passport: " .. tostring(data.passport) .. "^7")
    print("^3[MDT CLIENT] Department: " .. tostring(data.department) .. "^7")
    
    if vSERVER then
        local result = vSERVER.authenticateUser(data.passport, data.department)
        print("^3[MDT CLIENT] Resultado da autenticação: " .. tostring(result.success) .. "^7")
        print("^3[MDT CLIENT] Resultado completo: " .. json.encode(result) .. "^7")
        cb({ result = result })
    else
        print("^1[MDT CLIENT] vSERVER não está disponível^7")
        cb({ result = { success = false, message = "Erro de conexão com o servidor" } })
    end
end)

RegisterNUICallback("getServiceStatus", function(data, cb)
    print("^3[MDT CLIENT] Callback getServiceStatus recebido^7")
    if vSERVER then
        local result = vSERVER.getServiceStatus()
        cb({ success = true, inService = result.inService })
    else
        cb({ success = false, message = "Erro de conexão" })
    end
end)

-- Alternar serviço via NUI (entrar/sair de serviço)
RegisterNUICallback("toggleService", function(data, cb)
    print("^3[MDT CLIENT] Callback toggleService recebido^7")
    if vSERVER then
        local result = vSERVER.toggleService()
        -- Retorna para a NUI o status atualizado
        if result then
            cb({ inService = result.inService })
        else
            cb({ inService = false })
        end
    else
        cb({ inService = false })
    end
end)

RegisterNUICallback("getUserInfo", function(data, cb)
    print("^3[MDT CLIENT] Callback getUserInfo recebido^7")
    if vSERVER then
        local result = vSERVER.getUserInfo()
        cb({ success = true, user = result })
    else
        cb({ success = false, message = "Erro de conexão" })
    end
end)

RegisterNUICallback("searchCitizenByName", function(data, cb)
    print("^3[MDT CLIENT] Callback searchCitizenByName recebido^7")
    if vSERVER then
        local result = vSERVER.searchCitizenByName(data.name)
        cb({ result = result })
    else
        cb({ result = { success = false, message = "Erro de conexão" } })
    end
end)

RegisterNUICallback("searchCitizenByPhone", function(data, cb)
    print("^3[MDT CLIENT] Callback searchCitizenByPhone recebido^7")
    if vSERVER then
        local result = vSERVER.searchCitizenByPhone(data.phone)
        cb({ result = result })
    else
        cb({ result = { success = false, message = "Erro de conexão" } })
    end
end)

RegisterNUICallback("getDashboardStats", function(data, cb)
    print("^3[MDT CLIENT] Callback getDashboardStats recebido^7")
    if vSERVER then
        local stats = vSERVER.getDashboardStats()
        cb({ result = stats })
    else
        cb({ result = { success = false, message = "Erro de conexão" } })
    end
end)

RegisterNUICallback("searchCitizenComplete", function(data, cb)
    print("^3[MDT CLIENT] Callback searchCitizenComplete recebido^7")
    if vSERVER then
        local result = vSERVER.searchCitizenComplete(data.passport)
        cb({ result = result })
    else
        cb({ result = { success = false, message = "Erro de conexão" } })
    end
end)



RegisterNUICallback("closeMDT", function(data, cb)
    print("^3[MDT CLIENT] Callback closeMDT recebido^7")
    closeMDT()
    cb({})
end)

RegisterNUICallback("searchCitizenById", function(data, cb)
    print("^3[MDT CLIENT] Callback searchCitizenById recebido^7")
    print("^3[MDT CLIENT] Dados recebidos: " .. json.encode(data) .. "^7")
    
    if vSERVER then
        print("^3[MDT CLIENT] vSERVER disponível, chamando função^7")
        local result = vSERVER.searchCitizenById(data.passport)
        print("^3[MDT CLIENT] Resultado recebido: " .. json.encode(result) .. "^7")
        print("^3[MDT CLIENT] Tipo do resultado: " .. type(result) .. "^7")
        print("^3[MDT CLIENT] Resultado.success: " .. tostring(result.success) .. "^7")
        print("^3[MDT CLIENT] Enviando callback para NUI^7")
        cb({ result = result })
        print("^3[MDT CLIENT] Callback enviado com sucesso^7")
    else
        print("^1[MDT CLIENT] vSERVER não disponível^7")
        cb({ result = { success = false, message = "Erro de conexão" } })
    end
end)

RegisterNUICallback("getCitizenPrisonRecords", function(data, cb)
    print("^3[MDT CLIENT] Callback getCitizenPrisonRecords recebido^7")
    if vSERVER then
        local result = vSERVER.getCitizenPrisonRecords(data.passport)
        cb(result)
    else
        cb({ success = false, message = "Erro de conexão" })
    end
end)

RegisterNUICallback("getCitizenFines", function(data, cb)
    print("^3[MDT CLIENT] Callback getCitizenFines recebido^7")
    if vSERVER then
        local result = vSERVER.getCitizenFines(data.passport)
        cb(result)
    else
        cb({ success = false, message = "Erro de conexão" })
    end
end)

RegisterNUICallback("getCitizenWarrants", function(data, cb)
    print("^3[MDT CLIENT] Callback getCitizenWarrants recebido^7")
    if vSERVER then
        local result = vSERVER.getCitizenWarrants(data.passport)
        cb(result)
    else
        cb({ success = false, message = "Erro de conexão" })
    end
end)

RegisterNUICallback("initFine", function(data, cb)
    print("^3[MDT CLIENT] Callback initFine recebido^7")
    if vSERVER then
        vSERVER.initFine(data.passport, data.fines, data.text, data.license, data.article, data.infraction, data.description)
    end
    cb("ok")
end)

RegisterNUICallback("initPrisonFine", function(data, cb)
    print("^3[MDT CLIENT] Callback initPrisonFine recebido^7")
    if vSERVER then
        vSERVER.initPrisonFine(data.passport, data.fines, data.text, data.license, data.article, data.infraction, data.description, data.prisonTime)
    end
    cb("ok")
end)

RegisterNUICallback("initPrison", function(data, cb)
    print("^3[MDT CLIENT] Callback initPrison recebido^7")
    if vSERVER then
        vSERVER.initPrison(data.passport, data.prisonTime, data.text, data.license, data.article, data.infraction, data.description)
    end
    cb("ok")
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("mdt:open")
AddEventHandler("mdt:open", function()
    if vSERVER then
        local hasPermission = vSERVER.checkPermission()
        
        if hasPermission then
            -- Fechar a NUI do dynamic antes de abrir o MDT
            TriggerEvent("dynamic:Close")
            openMDT()
        end
    else
        TriggerEvent("Notify", "negado", "Erro de conexão com o servidor.")
    end
end)

RegisterNetEvent("mdt:close")
AddEventHandler("mdt:close", function()
    print("^3[MDT CLIENT] Evento mdt:close recebido^7")
    closeMDT()
end)

RegisterNetEvent("mdt:updateData")
AddEventHandler("mdt:updateData", function(data)
    print("^3[MDT CLIENT] Evento mdt:updateData recebido^7")
    if mdtOpen then
        SendNUIMessage({ action = "updateData", data = data })
    end
end)

RegisterNetEvent("mdt:updateFines")
AddEventHandler("mdt:updateFines", function(passport, amount, name)
    print("^3[MDT CLIENT] Evento mdt:updateFines recebido^7")
    print("^3[MDT CLIENT] Passport: " .. tostring(passport) .. ", Amount: " .. tostring(amount) .. ", Name: " .. tostring(name) .. "^7")
    if mdtOpen then
        SendNUIMessage({ 
            action = "updateFines", 
            data = {
                passport = passport,
                amount = amount,
                name = name
            }
        })
    end
end)

RegisterNetEvent("mdt:updatePrison")
AddEventHandler("mdt:updatePrison", function(passport, time, name)
    print("^3[MDT CLIENT] Evento mdt:updatePrison recebido^7")
    print("^3[MDT CLIENT] Passport: " .. tostring(passport) .. ", Time: " .. tostring(time) .. ", Name: " .. tostring(name) .. "^7")
    if mdtOpen then
        SendNUIMessage({ 
            action = "updatePrison", 
            data = {
                passport = passport,
                time = time,
                name = name
            }
        })
    end
end)

-- Atualização de serviço vinda do servidor
RegisterNetEvent("police:updateService")
AddEventHandler("police:updateService", function(inService)
    print("^3[MDT CLIENT] Evento police:updateService recebido. inService=" .. tostring(inService) .. "^7")
    if mdtOpen then
        SendNUIMessage({ type = "updateServiceStatus", inService = inService })
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    while true do
        Wait(1000)
        
        -- Verificar se o MDT está aberto e atualizar dados se necessário
        if mdtOpen and vSERVER then
            -- Aqui você pode adicionar lógica para atualizar dados em tempo real
            -- Por exemplo, verificar se há novas notificações
        end
    end
end)

print("^2[MDT TEST] Arquivo de teste carregado com sucesso^7") 