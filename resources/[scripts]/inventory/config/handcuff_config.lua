-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGURAÇÃO DAS ANIMAÇÕES DE ALGEMADO
-----------------------------------------------------------------------------------------------------------------------------------------
HandcuffConfig = {
    -- Animações de algemar
    Cuffing = {
        Police = {
            dict = "mp_arrest_paired",
            anim = "cop_p2_back_left",
            flag = false
        },
        Suspect = {
            dict = "mp_arrest_paired", 
            anim = "crook_p2_back_left",
            flag = false
        }
    },
    
    -- Animação de estar algemado
    Handcuffed = {
        dict = "mp_arresting",
        anim = "idle",
        flag = true
    },
    
    -- Animação de cortar algemas (alicate)
    Cutting = {
        dict = "mini@repair",
        anim = "fixing_a_player",
        flag = false
    },
    
    -- Tempos de animação (em milissegundos)
    Timers = {
        Cuffing = 3500,    -- Tempo para algemar
        Uncuffing = 3000,  -- Tempo para desalgemar
        Cutting = 5000     -- Tempo para cortar com alicate
    },
    
    -- Distâncias
    Distances = {
        Cuffing = 2.0,     -- Distância máxima para algemar
        Cutting = 2.0      -- Distância máxima para cortar
    },
    
    -- Sons
    Sounds = {
        Cuff = {
            name = "cuff",
            volume = 0.5
        },
        Uncuff = {
            name = "uncuff", 
            volume = 0.5
        }
    },
    
    -- Notificações
    Messages = {
        NoPermission = "Você não tem permissão para usar algemas.",
        InVehicle = "Não é possível usar algemas dentro de um veículo.",
        NoPlayerNearby = "Nenhum jogador próximo encontrado.",
        SelfCuff = "Você não pode algemar a si mesmo.",
        PlayerUnconscious = "Não é possível algemar um jogador inconsciente.",
        PlayerNotHandcuffed = "Este jogador não está algemado.",
        CuffSuccess = "Jogador algemado com sucesso.",
        UncuffSuccess = "Jogador desalgemado com sucesso.",
        CutSuccess = "Algemas cortadas com sucesso.",
        YouWereCuffed = "Você foi algemado.",
        YouWereUncuffed = "Você foi desalgemado.",
        YourCuffsCut = "Suas algemas foram cortadas."
    }
}
