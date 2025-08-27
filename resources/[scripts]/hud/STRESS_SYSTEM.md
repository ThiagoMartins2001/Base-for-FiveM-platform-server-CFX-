# Sistema de Stress - HUD

## Visão Geral
O sistema de stress da HUD foi mapeado e ajustado baseado no script Survival, mantendo a funcionalidade original mas corrigindo os problemas de comunicação entre cliente e servidor.

## Funcionalidades

### 1. Sistema Automático de Stress
- **Aumento automático**: Stress aumenta por ações como dirigir rápido, colisões, tiros e corrida
- **Redução automática**: Stress diminui por estar parado, em veículos de luxo, próximo à água
- **Redução por tempo**: Stress diminui automaticamente a cada 10 minutos

### 2. Sistema VIP
- **VIPs recebem menos stress** por ações automáticas
- **VIPs reduzem mais stress** por atividades relaxantes
- **VIPs têm redução automática maior** por tempo

### 3. Sistema de Itens
- **Cigarro**: Reduz 5 pontos de stress
- **Joint**: Reduz 10 pontos de stress
- **Bebidas alcoólicas**: Reduzem stress (cerveja: 3, whiskey: 5, vodka: 7)
- **Bebidas quentes**: Reduzem stress (café: 2, chá: 3)

### 4. Efeitos Visuais
- **Stress baixo (35-39)**: Tremor leve na câmera
- **Stress médio (40-59)**: Tremor moderado na câmera
- **Stress alto (60-79)**: Tremor forte na câmera
- **Stress crítico (80+)**: Tremor muito forte + notificação

## Eventos Disponíveis

### Cliente → Servidor
```lua
-- Aumentar stress
TriggerServerEvent("hud:AddStress", amount)

-- Reduzir stress
TriggerServerEvent("hud:ReduceStress", amount)

-- Usar item que reduz stress
TriggerServerEvent("hud:UseStressReductionItem", itemName)
```

### Servidor → Cliente
```lua
-- Atualizar stress na HUD
TriggerClientEvent("hud:Stress", source, stressValue)

-- Usar item com efeitos visuais
TriggerClientEvent("hud:UseStressItem", source, itemName, reductionAmount)
```

## Exports Disponíveis

```lua
-- Obter nível de stress atual
local stress = exports["hud"]:GetStressLevel()

-- Verificar se está com stress alto
local isHighStress = exports["hud"]:IsHighStress()

-- Verificar se está com stress crítico
local isCriticalStress = exports["hud"]:IsCriticalStress()

-- Verificar se está sofrendo (fome/sede/stress)
local isSuffering = exports["hud"]:IsSuffering()
```

## Callbacks Disponíveis

```lua
-- Obter grupo VIP do jogador
local vipGroup = TriggerServerCallback("hud:GetVipGroup")

-- Obter dados completos do jogador
local playerData = TriggerServerCallback("hud:GetPlayerData")
```

## Comandos de Administração

```lua
-- Verificar status do jogador
/status [id]

-- Resetar status do jogador
/resetstatus [id]

-- Definir stress do jogador
/setstress [id] [valor 0-100]

-- Definir fome do jogador
/sethunger [id] [valor 0-100]

-- Definir sede do jogador
/setthirst [id] [valor 0-100]
```

## Integração com Outros Scripts

### Para usar em outros scripts:
```lua
-- Aumentar stress do jogador
TriggerServerEvent("hud:AddStress", 5)

-- Reduzir stress do jogador
TriggerServerEvent("hud:ReduceStress", 10)

-- Verificar nível de stress
local stress = exports["hud"]:GetStressLevel()
if stress > 80 then
    -- Ações para stress crítico
end
```

## Configurações VIP

| VIP | Redução de Stress | Aumento de Redução |
|-----|------------------|-------------------|
| vipabsolutultimate | 70% | 70% |
| vipehp | 60% | 60% |
| vipadvanced | 50% | 50% |
| vipdiamond | 40% | 40% |
| vipplatium | 30% | 30% |
| vipgold | 20% | 20% |

## Logs do Sistema

O sistema registra todas as ações de stress no console do servidor:
- Aumento de stress por ações automáticas
- Redução de stress por atividades
- Uso de itens para reduzir stress
- Redução automática por tempo

## Compatibilidade

O sistema é totalmente compatível com:
- Script Survival
- Sistema vRP
- Sistema de inventário
- Sistema de VIPs
- Outros scripts que usam stress
