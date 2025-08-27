# Sistema HUD - FOME, SEDE, VIDA E STRESS

## 📋 Descrição

Este sistema HUD foi configurado seguindo a framework da base Cinelandia, implementando um sistema completo de gerenciamento de FOME, SEDE, VIDA e STRESS com funcionalidades automáticas e configurações personalizáveis.

## 🎯 Funcionalidades

### ✅ Sistema de Fome
- **Consumo Automático**: Diminui automaticamente a cada 90 segundos
- **Dano por Fome**: Causa dano quando fome está abaixo de 10
- **Notificações**: Alerta quando fome está baixa (abaixo de 20)
- **Itens Configuráveis**: Sistema de itens que recuperam fome

### ✅ Sistema de Sede
- **Consumo Automático**: Diminui automaticamente a cada 90 segundos
- **Dano por Sede**: Causa dano quando sede está abaixo de 10
- **Notificações**: Alerta quando sede está baixa (abaixo de 20)
- **Itens Configuráveis**: Sistema de itens que recuperam sede

### ✅ Sistema de Vida
- **Monitoramento**: Acompanha a vida do jogador em tempo real
- **Itens Médicos**: Sistema de itens que recuperam vida
- **Integração**: Funciona com o sistema de morte da base

### ✅ Sistema de Stress
- **Stress Automático**: Aumenta baseado em ações do jogador
- **Ações que Aumentam Stress**:
  - Velocidade alta em veículos
  - Colisões de veículo
  - Tiros
  - Corrida
  - Tempo online
- **Redução de Stress**: Atividades relaxantes e itens específicos
- **Efeitos Visuais**: Tremor na câmera baseado no nível de stress

## ⚙️ Configuração

### Arquivo `config.lua`

O sistema é totalmente configurável através do arquivo `config.lua`:

```lua
Config.Hunger = {
    AutoConsume = true,        -- Sistema automático ativo
    ConsumeAmount = 1,         -- Quantidade consumida por ciclo
    ConsumeInterval = 90000,   -- Intervalo em ms (90 segundos)
    DamageThreshold = 10,      -- Valor mínimo para dano
    NotifyThreshold = 20       -- Valor para notificação
}
```

### Principais Configurações

#### Fome e Sede
- `AutoConsume`: Ativa/desativa consumo automático
- `ConsumeAmount`: Quantidade consumida por ciclo
- `ConsumeInterval`: Intervalo entre consumos
- `DamageThreshold`: Valor mínimo para começar a tomar dano
- `NotifyThreshold`: Valor para notificar quando está baixo

#### Stress
- `AutoStress`: Ativa/desativa sistema de stress automático
- `StressInterval`: Intervalo de verificação de stress
- `Actions`: Configurações de ações que aumentam stress
- `Reduction`: Configurações de atividades que reduzem stress

## 🎮 Comandos

### Comandos de Administração

- `/status [id]` - Verificar status do jogador
- `/resetstatus [id]` - Resetar status do jogador
- `/setstress [id] [valor]` - Definir stress do jogador
- `/sethunger [id] [valor]` - Definir fome do jogador
- `/setthirst [id] [valor]` - Definir sede do jogador
- `/sethealth [id] [valor]` - Definir vida do jogador
- `/addstress [id] [quantidade]` - Adicionar stress ao jogador
- `/reducestress [id] [quantidade]` - Reduzir stress do jogador

### Comandos de VIP

- `/checkvip [id]` - Verificar status VIP do jogador
- `/testvip` - Testar sistema de callback VIP

### Comandos de Teste

- `/testdeath [id]` - Testar sistema de morte (Admin)
- `/testrevive [id]` - Testar sistema de revive (Admin)

### Comandos Gerais

- `/hud` - Ativar/desativar HUD

## 🔧 Exports

O sistema disponibiliza exports para outros scripts:

```lua
-- Obter valores atuais
exports["hud"]:GetHunger()
exports["hud"]:GetThirst()
exports["hud"]:GetStress()
exports["hud"]:GetHealth()

-- Verificar se está sofrendo
exports["hud"]:IsSuffering()
```

## 📦 Itens Configurados

### Itens de Fome
- `hamburger`: +25 fome (5s)
- `hamburger2`: +35 fome (5s)
- `sandwich`: +20 fome (3s)
- `pizza`: +30 fome (4s)
- `hotdog`: +15 fome (2s)
- `taco`: +18 fome (2.5s)
- `donut`: +10 fome (1.5s)
- `apple`: +8 fome (1s)
- `banana`: +8 fome (1s)
- `orange`: +8 fome (1s)

### Itens de Sede
- `water`: +25 sede (3s)
- `coffee`: +15 sede (2s)
- `soda`: +20 sede (2.5s)
- `beer`: +10 sede (1.5s)
- `whiskey`: +5 sede (1s)
- `vodka`: +5 sede (1s)
- `milk`: +30 sede (4s)
- `juice`: +22 sede (3s)

### Itens Médicos
- `bandage`: +25 vida (5s)
- `medkit`: +100 vida (10s)
- `adrenaline`: +50 vida (3s)
- `morphine`: +75 vida (8s)

### Itens Anti-Stress
- `cigarette`: -2 stress (5s)
- `joint`: -5 stress (8s)
- `beer`: -1 stress (3s)
- `whiskey`: -2 stress (4s)
- `vodka`: -2 stress (4s)
- `wine`: -1 stress (2s)

## 🎯 Sistema de Stress Automático

### Ações que Aumentam Stress
- **Velocidade Alta**: +1 stress (acima de 30.0)
- **Colisão de Veículo**: +5 stress
- **Tiro**: +3 stress
- **Corrida**: +1 stress
- **Tempo Online**: +1 stress (a cada 5 minutos)
- **Falta de Sono**: +2 stress (a cada hora)

### Atividades que Reduzem Stress
- **Pescar**: -5 stress (30s)
- **Yoga**: -3 stress (20s)
- **Meditação**: -4 stress (25s)
- **Fumar**: -2 stress (5s)
- **Beber Álcool**: -1 stress (3s)

## 🔄 Integração com VRP

O sistema está totalmente integrado com a framework VRP da base:

- Usa as funções `vRP.UpgradeHunger()`, `vRP.UpgradeThirst()`, `vRP.UpgradeStress()`
- Integra com o sistema de itens da base
- Funciona com o sistema de grupos e permissões
- Compatível com o sistema de notificações

## 💀 Sistema de Morte

### Detecção de Morte

O sistema HUD agora detecta corretamente quando o jogador morre:

- **Vida <= 100**: Considera o jogador como morto
- **IsEntityDead()**: Verificação nativa do GTA V
- **IsPedDeadOrDying()**: Verificação adicional de morte
- **Integração com Survival**: Eventos do sistema de survival

### Comportamento na Morte

Quando o jogador morre:

- ✅ **Vida zerada na HUD**: Mostra 0% de vida
- ✅ **Logs no console**: Registra a morte
- ✅ **Integração com eventos**: Responde aos eventos de morte
- ✅ **Restauração automática**: Quando revivido, restaura a vida

### Eventos de Morte

O sistema responde aos seguintes eventos:

```lua
-- Evento de morte
RegisterNetEvent("player:DeathUpdate")
-- Evento de revive
RegisterNetEvent("player:Revive")
-- Evento de nocaute
RegisterNetEvent("player:Knockout")
```

### Verificação de Morte

O sistema verifica a morte de múltiplas formas:

1. **Verificação de vida**: `GetEntityHealth(Ped) <= 100`
2. **Verificação nativa**: `IsEntityDead(Ped)`
3. **Verificação de estado**: `IsPedDeadOrDying(Ped, true)`
4. **Eventos do sistema**: Eventos do sistema de survival

### Logs de Debug

O sistema gera logs detalhados para morte:

- `💀 Jogador detectado como morto - Vida zerada na HUD`
- `💀 Evento de morte detectado - Vida zerada na HUD`
- `❤️ Jogador revivido - Vida restaurada na HUD`
- `❤️ Evento de revive detectado - Vida restaurada na HUD`
- `😵 Evento de nocaute detectado - Vida zerada na HUD`

## 👑 Sistema VIP

### Grupos VIP Suportados

O sistema HUD suporta os seguintes grupos VIP da base:

- `vipabsolutultimate` - VIP Absolut Ultimate
- `vipabsolut` - VIP Absolut
- `vipadvanced` - VIP Advanced
- `vipdiamond` - VIP Diamond
- `vipplatium` - VIP Platium
- `vipgold` - VIP Gold

### Sistema de Callback VIP

O sistema utiliza callbacks para verificar o status VIP dos jogadores:

```lua
-- No lado do cliente
local vipStatus = TriggerServerCallback("hud:GetVipGroup")
print("Status VIP:", vipStatus)

-- Obter dados completos do jogador
local playerData = TriggerServerCallback("hud:GetPlayerData")
if playerData then
    print("VIP:", playerData.vip)
    print("Vida:", playerData.health)
    print("Fome:", playerData.hunger)
    print("Sede:", playerData.thirst)
    print("Stress:", playerData.stress)
end
```

### Verificação de VIP

Para verificar se um jogador possui VIP:

```lua
-- Comando para verificar VIP
/checkvip [id]

-- Teste de callback VIP
/testvip
```

### Integração com Interface

O status VIP é enviado para a interface NUI:

```lua
SendNUIMessage({ name = "VipStatus", payload = PlayerVIP })
```

## 🐛 Debug

Para ativar o modo debug, edite o arquivo `config.lua`:

```lua
Config.Debug = {
    Enabled = true,
    Logs = {
        Hunger = true,
        Thirst = true,
        Stress = true,
        Health = true,
        Actions = true,
        Items = true
    }
}
```

## 📝 Logs

O sistema gera logs detalhados para:
- Consumo de fome/sede
- Alterações de stress
- Uso de itens
- Ações que afetam stress
- Comandos administrativos

## 🔧 Personalização

### Adicionar Novos Itens

Para adicionar novos itens, edite o arquivo `config.lua`:

```lua
Config.Hunger.Items["novo_item"] = {amount = 20, time = 3000}
Config.Thirst.Items["nova_bebida"] = {amount = 25, time = 4000}
Config.Stress.Reduction.Items["novo_item"] = {amount = 3, time = 5000}
```

### Modificar Intervalos

Para alterar os intervalos de consumo:

```lua
Config.Hunger.ConsumeInterval = 120000  -- 2 minutos
Config.Thirst.ConsumeInterval = 120000  -- 2 minutos
Config.Stress.StressInterval = 600000   -- 10 minutos
```

## 🚀 Instalação

1. Certifique-se de que o script está na pasta `resources/[scripts]/hud/`
2. Adicione `ensure hud` ao seu `server.cfg`
3. Configure o arquivo `config.lua` conforme suas necessidades
4. Reinicie o servidor

## 📞 Suporte

Para suporte ou dúvidas sobre o sistema HUD, consulte a documentação da base ou entre em contato com a equipe de desenvolvimento.
