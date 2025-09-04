-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES QUE ESTAVAM FALTANDO
-----------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------
-- getAllUsers
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.getAllUsers()
    local source = source
    local user_id = vRP.Passport(source)
    
    if not user_id or user_id == 0 then
        return {}
    end
    
    -- Verificar se o usuário tem permissão
    if not psRP.checkPermission() then
        return {}
    end
    
    local users = {}
    
    -- Buscar todos os usuários online
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local playerUserId = vRP.Passport(tonumber(playerId))
        if playerUserId and playerUserId > 0 then
            users[tostring(playerUserId)] = {
                user_id = playerUserId,
                name = "Player #" .. tostring(playerUserId),
                online = true
            }
        end
    end
    
    return users
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- getAllGroups
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.getAllGroups()
    local source = source
    local user_id = vRP.Passport(source)
    
    if not user_id or user_id == 0 then
        return {}
    end
    
    -- Verificar se o usuário tem permissão
    if not psRP.checkPermission() then
        return {}
    end
    
    local groups = getAllGroups()
    return groups
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- getAllVehicles
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.getAllVehicles()
    local source = source
    local user_id = vRP.Passport(source)
    
    if not user_id or user_id == 0 then
        return {}
    end
    
    -- Verificar se o usuário tem permissão
    if not psRP.checkPermission() then
        return {}
    end
    
    local vehicles = getAllVehicles()
    return vehicles
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- getAllItems
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.getAllItems()
    local source = source
    local user_id = vRP.Passport(source)
    
    if not user_id or user_id == 0 then
        return {}
    end
    
    -- Verificar se o usuário tem permissão
    if not psRP.checkPermission() then
        return {}
    end
    
    local items = getAllItems()
    return items
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- getChatMessages
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.getChatMessages()
    local source = source
    local user_id = vRP.Passport(source)
    
    if not user_id or user_id == 0 then
        return {}
    end
    
    -- Verificar se o usuário tem permissão
    if not psRP.checkPermission() then
        return {}
    end
    
    -- Retornar mensagens vazias por enquanto
    local messages = {}
    return messages
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- getChatStaffMessages
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.getChatStaffMessages()
    local source = source
    local user_id = vRP.Passport(source)
    
    if not user_id or user_id == 0 then
        return {}
    end
    
    -- Verificar se o usuário tem permissão
    if not psRP.checkPermission() then
        return {}
    end
    
    -- Retornar mensagens vazias por enquanto
    local messages = {}
    return messages
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- getUser
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.getUser(id)
    local source = source
    local user_id = vRP.Passport(source)

    if not user_id or user_id == 0 then
        return false
    end

    if not id or tonumber(id) == 0 then
        return false
    end

    if user_id then
        local userdata = getUserInfo(tonumber(id))
        
        -- VERIFICAÇÃO CRÍTICA ADICIONADA AQUI
        if not userdata or type(userdata) ~= "table" then
            return false
        end
        
        -- Inicializar warnings como tabela vazia
        userdata.warnings = {}

        -- Buscar warnings do banco de dados
        local warnings = DB.query("ps_staff/get_warnings", { user_id = tonumber(id) })
        if warnings and #warnings > 0 then
            userdata.warnings = warnings
        end

        return userdata
    end

    print("^1[PS_STAFF] getUser retornando false - user_id inválido")
    return false
end
