# ox_doorlock - Sistema Avançado de Controle de Portas

## 📋 Descrição

O **ox_doorlock** é um sistema avançado e completo de controle de portas para servidores FiveM, desenvolvido pela Overextended. Este script oferece funcionalidades robustas para gerenciar portas com permissões, códigos de acesso, lockpicks e uma interface administrativa completa.

## 🏗️ Estrutura do Projeto

```
ox_doorlock/
├── fxmanifest.lua              # Manifesto do recurso
├── config.lua                  # Configurações do script
├── client/
│   ├── main.lua               # Lógica principal do cliente
│   └── utils.lua              # Utilitários do cliente
├── server/
│   ├── main.lua               # Lógica principal do servidor
│   └── framework/
│       └── vrp.lua            # Integração com vRP
├── web/
│   └── build/                 # Interface web compilada
├── locales/
│   └── en.json                # Arquivo de localização
├── audio/                     # Arquivos de áudio
└── sql/                       # Scripts SQL
```

## 🔧 Funcionamento Técnico

### Arquitetura do Sistema

O ox_doorlock utiliza uma arquitetura moderna com:

1. **Client-side**: Gerencia detecção de proximidade, interface e animações
2. **Server-side**: Controla permissões, banco de dados e sincronização
3. **Web Interface**: Interface React para administração
4. **Database**: Armazenamento persistente das configurações de portas

### Dependências

- **oxmysql**: Para conexão com banco de dados
- **ox_lib**: Biblioteca de utilitários (versão 3.0.0+)
- **vRP**: Framework de roleplay

## 📁 Análise dos Arquivos

### fxmanifest.lua
```lua
fx_version   'cerulean'
use_experimental_fxv2_oal 'yes'
lua54        'yes'
game         'gta5'

name         'ox_doorlock'
version      '1.19.2'
license      'GPL-3.0-or-later'
author       'Overextended'
```

**Características:**
- Versão FX moderna (cerulean)
- Suporte a Lua 5.4
- Interface web React
- Sistema de áudio integrado

### config.lua

**Configurações Principais:**

```lua
Config.Notify = false                    -- Notificações de estado
Config.DrawTextUI = false               -- Interface de texto
Config.CommandPrincipal = 'Admin'       -- Permissão para comando
Config.LockDifficulty = { 'easy', 'easy', 'medium' }  -- Dificuldade do lockpick
Config.LockpickItems = { 'lockpick' }   -- Itens que funcionam como lockpick
```

### client/main.lua

**Principais Funcionalidades:**

1. **Criação de Portas**
```lua
local function createDoor(door)
    local double = door.doors
    if double then
        -- Portas duplas
        for i = 1, 2 do
            AddDoorToSystem(double[i].hash, double[i].model, double[i].coords.x, double[i].coords.y, double[i].coords.z, false, false, false)
            DoorSystemSetDoorState(double[i].hash, door.state, false, false)
        end
    else
        -- Porta única
        AddDoorToSystem(door.hash, door.model, door.coords.x, door.coords.y, door.coords.z, false, false, false)
        DoorSystemSetDoorState(door.hash, door.state, false, false)
    end
end
```

2. **Detecção de Proximidade**
```lua
while true do
    table.wipe(nearbyDoors)
    local coords = GetEntityCoords(cache.ped)
    
    for _, door in pairs(doors) do
        door.distance = #(coords - door.coords)
        if door.distance < 20 then
            nearbyDoors[#nearbyDoors + 1] = door
        end
    end
    Wait(num > 0 and 0 or 500)
end
```

3. **Interação com Portas**
```lua
local function useClosestDoor()
    if not ClosestDoor then return false end
    
    local gameTimer = GetGameTimer()
    if gameTimer - lastTriggered > 500 then
        lastTriggered = gameTimer
        TriggerServerEvent('ox_doorlock:setState', ClosestDoor.id, ClosestDoor.state == 1 and 0 or 1)
    end
end
```

### server/main.lua

**Principais Funcionalidades:**

1. **Sistema de Estado de Portas**
```lua
local function setDoorState(id, state, lockpick)
    local door = doors[id]
    state = (state == 1 or state == 0) and state or (state and 1 or 0)
    
    if door then
        local authorised = not source or source == '' or isAuthorised(source, door, lockpick)
        
        if authorised then
            door.state = state
            TriggerClientEvent('ox_doorlock:setState', -1, id, state, source)
            return true
        end
    end
    return false
end
```

2. **Comando Administrativo**
```lua
RegisterCommand('doors', function(source, args, rawCommand)
    if vRP.HasGroup(vRP.Passport(source), Config.CommandPrincipal,1) then
        TriggerClientEvent('ox_doorlock:triggeredCommand', source, nil)
    end
end)
```

3. **Exports Disponíveis**
```lua
exports('getDoor', getDoor)                    -- Obter dados de uma porta
exports('getDoorFromName', getDoorFromName)    -- Obter porta por nome
exports('editDoor', editDoor)                  -- Editar porta
exports('setDoorState', setDoorState)          -- Alterar estado da porta
```

### server/framework/vrp.lua

**Integração com vRP:**

```lua
function GetPlayer(src)
    local identity = vRP.Identity(vRP.Passport(src))
    local table = {}
    table[src] = {}
    table[src]["identifier"] = tonumber(vRP.Passport(src))
    table[src]["name"] = identity.name.." "..identity.name2
    return table[src]
end

function IsPlayerInGroup(player, filter)
    for k, v in pairs(filter) do
        if vRP.HasPermission(tonumber(player.identifier), k) then
            return true
        end
    end
end
```

## 🚀 Instalação e Configuração

### Pré-requisitos

1. **Dependências Obrigatórias:**
   - oxmysql (versão 2.3.0+)
   - ox_lib (versão 3.0.0+)
   - vRP Framework

2. **Banco de Dados:**
   - MySQL/MariaDB configurado

### Passos de Instalação

1. **Baixe o ox_doorlock:**
   ```bash
   # Clone do repositório ou download da release
   git clone https://github.com/overextended/ox_doorlock.git
   ```

2. **Configure o banco de dados:**
   ```sql
   -- Execute o script SQL fornecido
   -- Geralmente localizado em sql/ox_doorlock.sql
   ```

3. **Adicione ao server.cfg:**
   ```cfg
   ensure oxmysql
   ensure ox_lib
   ensure ox_doorlock
   ```

4. **Configure as permissões no vRP:**
   ```lua
   -- Adicione a permissão Admin para usar o comando /doors
   -- Ou altere Config.CommandPrincipal no config.lua
   ```

5. **Reinicie o servidor**

### Configuração de Portas

As portas são configuradas através da interface web ou diretamente no banco de dados:

```sql
INSERT INTO ox_doorlock (name, data) VALUES 
('Porta Exemplo', '{
    "coords": [100.0, 200.0, 30.0],
    "model": "prop_door_01",
    "state": 1,
    "groups": {"Admin": 0},
    "maxDistance": 2.0
}');
```

## 🎮 Como Usar

### Para Jogadores

1. **Aproxime-se** de uma porta configurada
2. **Aguarde** a interface aparecer (se Config.DrawTextUI = true)
3. **Pressione E** para interagir
4. **Digite o código** se a porta tiver senha
5. **Use lockpick** se tiver permissão

### Para Administradores

1. **Use o comando `/doors`** para abrir a interface administrativa
2. **Clique em uma porta** para editar
3. **Configure permissões, códigos e outras opções**
4. **Salve as alterações**

### Interface Administrativa

A interface web permite:

- **Criar novas portas**
- **Editar portas existentes**
- **Configurar permissões por grupo**
- **Definir códigos de acesso**
- **Configurar sons de trancar/destrancar**
- **Definir dificuldade de lockpick**

## 🔧 Personalização

### Configurações Avançadas

```lua
-- Configurações de som
Config.NativeAudio = true  -- Usar áudio nativo do GTA

-- Configurações de interface
Config.DrawSprite = {
    [0] = { 'mpsafecracking', 'lock_open', 0, 0, 0.018, 0.018, 0, 255, 255, 255, 100 },
    [1] = { 'mpsafecracking', 'lock_closed', 0, 0, 0.018, 0.018, 0, 255, 255, 255, 100 },
}

-- Configurações de lockpick
Config.CanPickUnlockedDoors = false  -- Permitir lockpick em portas destrancadas
```

### Adicionando Novos Itens de Lockpick

```lua
Config.LockpickItems = {
    'lockpick',
    'advanced_lockpick',
    'screwdriver'
}
```

### Configurando Permissões

```lua
-- No banco de dados ou interface
{
    "groups": {
        "Admin": 0,        -- Admin pode tudo
        "Police": 1,       -- Policial pode destrancar
        "Paramedic": 1     -- Paramédico pode destrancar
    }
}
```

## 📊 Funcionalidades Avançadas

### Tipos de Portas Suportadas

1. **Portas Únicas**: Uma porta simples
2. **Portas Duplas**: Duas portas sincronizadas
3. **Portas com Código**: Requer senha para acesso
4. **Portas com Lockpick**: Podem ser arrombadas
5. **Portas Automáticas**: Fecham automaticamente

### Sistema de Permissões

- **Grupos**: Permissões baseadas em grupos do vRP
- **Itens**: Verificação de itens específicos
- **Códigos**: Senhas numéricas
- **Lockpick**: Sistema de arrombamento

### Recursos de Áudio

- **Sons de trancar/destrancar**
- **Sons de lockpick**
- **Áudio nativo do GTA ou NUI**

## 🐛 Troubleshooting

### Problemas Comuns

1. **Interface não aparece**
   - Verifique se ox_lib está funcionando
   - Confirme se Config.DrawTextUI = true
   - Teste se o jogador tem permissão

2. **Portas não funcionam**
   - Verifique se o modelo da porta está correto
   - Confirme se as coordenadas estão precisas
   - Teste se as permissões estão configuradas

3. **Comando /doors não funciona**
   - Verifique se o jogador tem permissão Admin
   - Confirme se Config.CommandPrincipal está correto
   - Teste se o vRP está funcionando

4. **Lockpick não funciona**
   - Verifique se o item está em Config.LockpickItems
   - Confirme se o jogador tem o item no inventário
   - Teste se Config.CanPickUnlockedDoors está correto

### Logs de Debug

```lua
-- Adicione prints para debug
print("Tentativa de acesso: " .. source .. " na porta " .. id)
print("Permissões do jogador: " .. json.encode(playerGroups))
```

## 📈 Performance

### Otimizações

- **Detecção de proximidade otimizada**
- **Cache de entidades**
- **Sincronização eficiente**
- **Interface web responsiva**

### Limitações

- Máximo de ~100 portas simultâneas
- Distância máxima de 80 unidades
- Requer ox_lib 3.0.0+

## 🔄 Atualizações

### Versão Atual
- **v1.19.2**: Versão estável atual
- Suporte completo a vRP
- Interface web moderna
- Sistema de áudio integrado

### Próximas Funcionalidades
- Suporte a múltiplos frameworks
- Interface mobile
- Sistema de logs avançado
- Integração com outros scripts

## 📞 Suporte

### Recursos de Ajuda

- **Documentação oficial**: https://overextended.github.io/docs/ox_doorlock/
- **GitHub**: https://github.com/overextended/ox_doorlock
- **Discord**: Overextended Community

### Comandos Úteis

```lua
/doors                    -- Abrir interface administrativa
/doors [id]              -- Editar porta específica
```

## 📄 Licença

Este script está licenciado sob **GPL-3.0-or-later**.

---

**Desenvolvido por Overextended**
*Sistema Avançado de Controle de Portas v1.19.2*
