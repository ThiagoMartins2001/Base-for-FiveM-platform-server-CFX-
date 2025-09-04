-----------------------------------------------------------------------------------------------------------------------------------------
-- TESTE DO SISTEMA DE ADRENALINA
-----------------------------------------------------------------------------------------------------------------------------------------

-- Comando para testar se o sistema está funcionando
RegisterCommand("testadrenaline", function()
    print("=== TESTE DO SISTEMA DE ADRENALINA ===")
    
    -- Teste 1: Verificar se os arquivos estão carregados
    if exports["paramedic"]:IsInAdrenalineLocation then
        print("[OK] Funcao IsInAdrenalineLocation carregada")
    else
        print("[ERRO] Funcao IsInAdrenalineLocation nao encontrada")
    end
    
    if exports["paramedic"]:GetAdrenalineConfig then
        print("[OK] Funcao GetAdrenalineConfig carregada")
    else
        print("[ERRO] Funcao GetAdrenalineConfig nao encontrada")
    end
    
    if exports["paramedic"]:GetAdrenalineLocations then
        print("[OK] Funcao GetAdrenalineLocations carregada")
    else
        print("[ERRO] Funcao GetAdrenalineLocations nao encontrada")
    end
    
    -- Teste 2: Verificar configuração
    local config = exports["paramedic"]:GetAdrenalineConfig()
    if config then
        print("[OK] Configuracao carregada:")
        print("   - Tempo de aplicacao: " .. config.ApplicationTime .. "ms")
        print("   - Vida apos reanimacao: " .. config.ReviveHealth)
        print("   - Distancia maxima: " .. config.MaxDistance .. "m")
    else
        print("[ERRO] Configuracao nao encontrada")
    end
    
    -- Teste 3: Verificar locais
    local locations = exports["paramedic"]:GetAdrenalineLocations()
    if locations then
        print("[OK] " .. #locations .. " locais configurados:")
        for i, location in ipairs(locations) do
            print("   " .. i .. ". " .. location.Name .. " (Raio: " .. location.Radius .. "m)")
            print("      Coordenadas: " .. location.Coords.x .. ", " .. location.Coords.y .. ", " .. location.Coords.z)
        end
    else
        print("[ERRO] Locais nao encontrados")
    end
    
    -- Teste 4: Verificar posição atual
    local playerCoords = GetEntityCoords(PlayerPedId())
    local isInLocation, locationName = exports["paramedic"]:IsInAdrenalineLocation(playerCoords)
    
    print("[INFO] Sua posicao atual: " .. playerCoords.x .. ", " .. playerCoords.y .. ", " .. playerCoords.z)
    
    if isInLocation then
        print("[OK] Voce esta em local permitido: " .. locationName)
    else
        print("[ERRO] Voce NAO esta em local permitido")
    end
    
    print("=== FIM DO TESTE ===")
end, false)

-- Comando para debug detalhado
RegisterCommand("debugadrenaline", function()
    print("=== DEBUG DETALHADO ADRENALINA ===")
    
    local playerCoords = GetEntityCoords(PlayerPedId())
    print("[INFO] Sua posicao: " .. playerCoords.x .. ", " .. playerCoords.y .. ", " .. playerCoords.z)
    
    -- Testar manualmente a verificação
    local locations = exports["paramedic"]:GetAdrenalineLocations()
    if locations then
        for i, location in ipairs(locations) do
            local distance = #(playerCoords - location.Coords)
            print("[INFO] Distancia ate " .. location.Name .. ": " .. distance .. "m")
            print("   Coordenadas do local: " .. location.Coords.x .. ", " .. location.Coords.y .. ", " .. location.Coords.z)
            print("   Raio permitido: " .. location.Radius .. "m")
            
            if distance <= location.Radius then
                print("   [OK] DENTRO DO RAIO PERMITIDO")
            else
                print("   [ERRO] FORA DO RAIO PERMITIDO")
            end
        end
    end
    
    print("=== FIM DO DEBUG ===")
end, false)

-- Comando para simular uso de adrenalina (apenas para teste)
RegisterCommand("simulateadrenaline", function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local isInLocation, locationName = exports["paramedic"]:IsInAdrenalineLocation(playerCoords)
    
    if isInLocation then
        print("[INFO] Simulando uso de adrenalina em: " .. locationName)
        
        -- Simular animação
        local config = exports["paramedic"]:GetAdrenalineConfig()
        TriggerEvent("Progress", "Aplicando Adrenalina (SIMULACAO)", 3000)
        
        -- Simular notificação
        SetTimeout(3000, function()
            TriggerEvent("Notify", "verde", "Adrenalina aplicada com sucesso em " .. locationName .. "! (SIMULACAO)", 5000)
        end)
    else
        print("[ERRO] Nao e possivel simular uso fora de local permitido")
        TriggerEvent("Notify", "vermelho", "Voce so pode usar adrenalina em locais medicos autorizados! (SIMULACAO)", 5000)
    end
end, false)

-- Comando para mostrar informações detalhadas
RegisterCommand("adrenalineinfo", function()
    print("=== INFORMACOES DO SISTEMA DE ADRENALINA ===")
    
    local config = exports["paramedic"]:GetAdrenalineConfig()
    local locations = exports["paramedic"]:GetAdrenalineLocations()
    
    print("[INFO] CONFIGURACAO:")
    print("   Tempo de aplicacao: " .. config.ApplicationTime .. "ms")
    print("   Vida apos reanimacao: " .. config.ReviveHealth)
    print("   Pontos de sede/fome: " .. config.ThirstPoints .. "/" .. config.HungerPoints)
    print("   Distancia maxima: " .. config.MaxDistance .. "m")
    print("   Verificar paramedicos: " .. tostring(config.Security.CheckParamedics))
    print("   Logs habilitados: " .. tostring(config.Security.EnableLogs))
    
    print("\n[INFO] LOCAIS AUTORIZADOS:")
    for i, location in ipairs(locations) do
        print("   " .. i .. ". " .. location.Name)
        print("      Coordenadas: " .. location.Coords.x .. ", " .. location.Coords.y .. ", " .. location.Coords.z)
        print("      Raio: " .. location.Radius .. "m")
    end
    
    print("\n[INFO] COMO USAR:")
    print("   1. Va ate um local autorizado")
    print("   2. Tenha o item 'Adrenalina' no inventario")
    print("   3. Clique no item proximo a uma pessoa desacordada")
    print("   4. Aguarde 8 segundos para a aplicacao")
    
    print("\n[INFO] COMANDOS DISPONIVEIS:")
    print("   /testadrenalinelocation - Testa se esta em local permitido")
    print("   /testadrenaline - Testa o sistema completo")
    print("   /simulateadrenaline - Simula uso de adrenalina")
    print("   /adrenalineinfo - Mostra estas informacoes")
    
    print("=== FIM DAS INFORMACOES ===")
end, false)
