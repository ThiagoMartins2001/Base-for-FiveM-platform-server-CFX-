-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGURAÇÕES DO HUD - FOME, SEDE, VIDA E STRESS
-----------------------------------------------------------------------------------------------------------------------------------------

Config = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGURAÇÕES GERAIS
-----------------------------------------------------------------------------------------------------------------------------------------
Config.Debug = false -- Ativa logs de debug
Config.Language = "pt-BR" -- Idioma do sistema

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGURAÇÕES DE FOME
-----------------------------------------------------------------------------------------------------------------------------------------
Config.Hunger = {
    -- Configurações de consumo automático
    AutoConsume = true, -- Se o sistema de fome automático está ativo
    ConsumeAmount = 1, -- Quantidade consumida por ciclo
    ConsumeInterval = 90000, -- Intervalo de consumo em ms (90 segundos)
    
    -- Configurações de dano
    DamageThreshold = 10, -- Valor mínimo para começar a tomar dano
    DamageAmount = {min = 1, max = 3}, -- Quantidade de dano (aleatório)
    DamageInterval = 90000, -- Intervalo de dano em ms
    
    -- Configurações de notificação
    NotifyLow = true, -- Notifica quando fome está baixa
    NotifyThreshold = 20, -- Valor para notificar fome baixa
    
    -- Configurações de itens
    Items = {
        ["hamburger"] = {amount = 25, time = 5000},
        ["hamburger2"] = {amount = 35, time = 5000},
        ["sandwich"] = {amount = 20, time = 3000},
        ["pizza"] = {amount = 30, time = 4000},
        ["hotdog"] = {amount = 15, time = 2000},
        ["taco"] = {amount = 18, time = 2500},
        ["donut"] = {amount = 10, time = 1500},
        ["apple"] = {amount = 8, time = 1000},
        ["banana"] = {amount = 8, time = 1000},
        ["orange"] = {amount = 8, time = 1000}
    }
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGURAÇÕES DE SEDE
-----------------------------------------------------------------------------------------------------------------------------------------
Config.Thirst = {
    -- Configurações de consumo automático
    AutoConsume = true, -- Se o sistema de sede automático está ativo
    ConsumeAmount = 1, -- Quantidade consumida por ciclo
    ConsumeInterval = 90000, -- Intervalo de consumo em ms (90 segundos)
    
    -- Configurações de dano
    DamageThreshold = 10, -- Valor mínimo para começar a tomar dano
    DamageAmount = {min = 1, max = 3}, -- Quantidade de dano (aleatório)
    DamageInterval = 90000, -- Intervalo de dano em ms
    
    -- Configurações de notificação
    NotifyLow = true, -- Notifica quando sede está baixa
    NotifyThreshold = 20, -- Valor para notificar sede baixa
    
    -- Configurações de itens
    Items = {
        ["water"] = {amount = 25, time = 3000},
        ["coffee"] = {amount = 15, time = 2000},
        ["soda"] = {amount = 20, time = 2500},
        ["beer"] = {amount = 10, time = 1500},
        ["whiskey"] = {amount = 5, time = 1000},
        ["vodka"] = {amount = 5, time = 1000},
        ["milk"] = {amount = 30, time = 4000},
        ["juice"] = {amount = 22, time = 3000}
    }
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGURAÇÕES DE VIDA
-----------------------------------------------------------------------------------------------------------------------------------------
Config.Health = {
    -- Configurações de regeneração
    AutoRegen = false, -- Se a vida regenera automaticamente
    RegenAmount = 1, -- Quantidade regenerada por ciclo
    RegenInterval = 30000, -- Intervalo de regeneração em ms (30 segundos)
    RegenThreshold = 150, -- Vida máxima para regeneração (200 - 50)
    
    -- Configurações de dano
    MinHealth = 100, -- Vida mínima (morte)
    MaxHealth = 200, -- Vida máxima
    
    -- Configurações de itens
    Items = {
        ["bandage"] = {amount = 25, time = 5000},
        ["medkit"] = {amount = 100, time = 10000},
        ["adrenaline"] = {amount = 50, time = 3000},
        ["morphine"] = {amount = 75, time = 8000}
    }
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGURAÇÕES DE STRESS
-----------------------------------------------------------------------------------------------------------------------------------------
Config.Stress = {
    -- Configurações de stress automático
    AutoStress = true, -- Se o sistema de stress automático está ativo
    StressInterval = 300000, -- Intervalo de verificação de stress (5 minutos)
    
    -- Configurações de aumento de stress
    Actions = {
        -- Stress por ações de veículo
        VehicleSpeed = {enabled = true, amount = 1, threshold = 30.0}, -- Velocidade alta
        VehicleCollision = {enabled = true, amount = 5}, -- Colisão
        VehicleBraking = {enabled = true, amount = 1}, -- Frenagem brusca
        
        -- Stress por ações de combate
        Shooting = {enabled = true, amount = 3}, -- Tiro
        TakingDamage = {enabled = true, amount = 2}, -- Tomar dano
        Killing = {enabled = true, amount = 10}, -- Matar alguém
        
        -- Stress por ações físicas
        Running = {enabled = true, amount = 1}, -- Correr
        Swimming = {enabled = true, amount = 2}, -- Nadar
        Climbing = {enabled = true, amount = 1}, -- Escalar
        
        -- Stress por tempo
        TimeOnline = {enabled = true, amount = 1, interval = 300000}, -- 5 minutos online
        NoSleep = {enabled = true, amount = 2, interval = 3600000} -- 1 hora sem dormir
    },
    
    -- Configurações de redução de stress
    Reduction = {
        -- Atividades relaxantes
        Fishing = {enabled = true, amount = 5, time = 30000}, -- Pescar
        Yoga = {enabled = true, amount = 3, time = 20000}, -- Yoga
        Meditation = {enabled = true, amount = 4, time = 25000}, -- Meditação
        Smoking = {enabled = true, amount = 2, time = 5000}, -- Fumar
        Drinking = {enabled = true, amount = 1, time = 3000}, -- Beber álcool
        
        -- Itens que reduzem stress
        Items = {
            ["cigarette"] = {amount = 2, time = 5000},
            ["joint"] = {amount = 5, time = 8000},
            ["beer"] = {amount = 1, time = 3000},
            ["whiskey"] = {amount = 2, time = 4000},
            ["vodka"] = {amount = 2, time = 4000},
            ["wine"] = {amount = 1, time = 2000}
        }
    },
    
    -- Configurações de efeitos visuais
    VisualEffects = {
        enabled = true,
        levels = {
            {threshold = 35, shake = 0.12, duration = 2500},
            {threshold = 40, shake = 0.25, duration = 2000},
            {threshold = 60, shake = 0.45, duration = 1500},
            {threshold = 80, shake = 0.75, duration = 1000}
        }
    },
    
    -- Configurações de notificação
    NotifyHigh = true, -- Notifica quando stress está alto
    NotifyThreshold = 80 -- Valor para notificar stress alto
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGURAÇÕES DE NOTIFICAÇÕES
-----------------------------------------------------------------------------------------------------------------------------------------
Config.Notifications = {
    -- Tipos de notificação
    Types = {
        ["hunger"] = {color = "#FF6B35", icon = "🍔"},
        ["thirst"] = {color = "#4ECDC4", icon = "💧"},
        ["stress"] = {color = "#FFE66D", icon = "😰"},
        ["health"] = {color = "#FF6B6B", icon = "❤️"},
        ["success"] = {color = "#95E1D3", icon = "✅"},
        ["warning"] = {color = "#F7DC6F", icon = "⚠️"},
        ["error"] = {color = "#EC7063", icon = "❌"}
    },
    
    -- Configurações gerais
    Duration = 3000, -- Duração padrão das notificações
    Position = "top-right", -- Posição das notificações
    Sound = true -- Se as notificações têm som
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGURAÇÕES DE EXPORTS
-----------------------------------------------------------------------------------------------------------------------------------------
Config.Exports = {
    -- Se os exports estão disponíveis para outros scripts
    Enabled = true,
    
    -- Lista de exports disponíveis
    Available = {
        "GetHunger",
        "GetThirst", 
        "GetStress",
        "GetHealth",
        "IsSuffering",
        "AddStress",
        "ReduceStress",
        "SetHunger",
        "SetThirst",
        "SetHealth"
    }
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGURAÇÕES DE ADMINISTRAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
Config.Admin = {
    -- Grupos que podem usar comandos administrativos
    Groups = {
        "Admin",
        "Moderator",
        "Helper"
    },
    
    -- Comandos administrativos disponíveis
    Commands = {
        ["status"] = {description = "Verificar status do jogador", usage = "/status [id]"},
        ["resetstatus"] = {description = "Resetar status do jogador", usage = "/resetstatus [id]"},
        ["setstress"] = {description = "Definir stress do jogador", usage = "/setstress [id] [valor]"},
        ["sethunger"] = {description = "Definir fome do jogador", usage = "/sethunger [id] [valor]"},
        ["setthirst"] = {description = "Definir sede do jogador", usage = "/setthirst [id] [valor]"},
        ["sethealth"] = {description = "Definir vida do jogador", usage = "/sethealth [id] [valor]"}
    }
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGURAÇÕES DE DEBUG
-----------------------------------------------------------------------------------------------------------------------------------------
Config.Debug = {
    -- Se o modo debug está ativo
    Enabled = false,
    
    -- Logs específicos
    Logs = {
        Hunger = true,
        Thirst = true,
        Stress = true,
        Health = true,
        Actions = true,
        Items = true
    },
    
    -- Console output
    Console = {
        Enabled = true,
        Level = "info" -- debug, info, warning, error
    }
}

return Config
