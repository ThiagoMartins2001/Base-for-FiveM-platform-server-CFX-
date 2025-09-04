# Script Doors - Sistema de Controle de Portas

## 📋 Descrição

O **Script Doors** é um sistema avançado de controle de portas para servidores FiveM que permite gerenciar o acesso a portas específicas baseado em permissões do vRP. O script oferece uma experiência imersiva com interface visual, animações e sincronização em tempo real.

## 🏗️ Estrutura do Projeto

```
doors/
├── fxmanifest.lua          # Manifesto do recurso
├── client-side/
│   └── core.lua            # Lógica do lado cliente
├── server-side/
│   └── core.lua            # Lógica do lado servidor
├── web-side/
│   ├── index.html          # Interface HTML
│   ├── style.css           # Estilos CSS
│   └── jquery.js           # Lógica da interface
└── README.md               # Esta documentação
```

## 🔧 Funcionamento Técnico

### Arquitetura do Sistema

O script utiliza uma arquitetura cliente-servidor com três componentes principais:

1. **Client-side**: Gerencia a detecção de proximidade e interface do usuário
2. **Server-side**: Controla permissões e sincronização de estado
3. **Web-side**: Fornece a interface visual para interação

### Fluxo de Funcionamento

1. **Inicialização**: Todas as portas são registradas no sistema do GTA V
2. **Detecção**: O cliente monitora constantemente a proximidade do jogador
3. **Interação**: Quando próximo, o jogador pode pressionar E para interagir
4. **Validação**: O servidor verifica permissões do jogador
5. **Execução**: Se autorizado, o estado da porta é alterado
6. **Sincronização**: O novo estado é propagado para todos os jogadores

## 📁 Análise dos Arquivos

### fxmanifest.lua
```lua
fx_version "bodacious"
game "gta5"
lua54 "yes"

ui_page "web-side/index.html"

client_scripts {
    "@vrp/lib/Utils.lua",
    "client-side/*"
}

server_scripts {
    "@vrp/lib/Utils.lua",
    "server-side/*"
}

files {
    "web-side/*"
}
```

**Funções:**
- Define a versão do FX e jogo
- Configura a interface web
- Carrega scripts cliente e servidor
- Inclui dependências do vRP

### client-side/core.lua

**Principais Funcionalidades:**

1. **Registro de Portas**
```lua
CreateThread(function()
    for Number,v in pairs(GlobalState["Doors"]) do
        if IsDoorRegisteredWithSystem(Number) then
            RemoveDoorFromSystem(Number)
        end
        AddDoorToSystem(Number,v["Hash"],v["Coords"],false,false,true)
        DoorSystemSetOpenRatio(Number,0.0,false,false)
        DoorSystemSetAutomaticRate(Number,2.0,false,false)
        DoorSystemSetDoorState(Number,v["Lock"] and 1 or 0,true)
    end
end)
```

2. **Detecção de Proximidade**
```lua
CreateThread(function()
    while true do
        local TimeDistance = 999
        if LocalPlayer["state"]["Route"] < 900000 then
            local Ped = PlayerPedId()
            local Coords = GetEntityCoords(Ped)
            
            for Number,v in pairs(GlobalState["Doors"]) do
                local Distance = #(Coords - v["Coords"])
                if Distance <= v["Distance"] then
                    TimeDistance = 1
                    -- Mostra interface e permite interação
                end
            end
        end
        Wait(TimeDistance)
    end
end)
```

3. **Atualização de Estado**
```lua
RegisterNetEvent("doors:Update")
AddEventHandler("doors:Update",function(Number,Status)
    DoorSystemSetDoorState(Number,Status and 1 or 0,true)
    -- Atualiza porta relacionada se existir
    if GlobalState["Doors"][Number]["Other"] ~= nil then
        local Second = GlobalState["Doors"][Number]["Other"]
        DoorSystemSetDoorState(Second,Status and 1 or 0,true)
    end
end)
```

### server-side/core.lua

**Principais Funcionalidades:**

1. **Configuração de Portas**
```lua
GlobalState["Doors"] = {
    [1] = { 
        Coords = vec3(-366.42,-354.63,31.66), 
        Hash = -1603028996, 
        Lock = true, 
        Distance = 1.5, 
        Perm = "Police" 
    },
    -- ... mais portas
}
```

**Parâmetros das Portas:**
- `Coords`: Coordenadas XYZ da porta
- `Hash`: Identificador único da porta no GTA V
- `Lock`: Estado inicial (true = trancada)
- `Distance`: Distância máxima para interação
- `Perm`: Permissão necessária
- `Other`: ID de porta relacionada (opcional)

2. **Sistema de Permissões**
```lua
function Creative.DoorsPermission(Number)
    local source = source
    local Passport = vRP.Passport(source)
    if Passport then
        if GlobalState["Doors"][Number]["Perm"] ~= nil then
            if vRP.HasService(Passport,GlobalState["Doors"][Number]["Perm"]) or vRP.hasPermission(Passport,'Admin',2) then
                -- Executa ação na porta
            end
        end
    end
end
```

### web-side/

**Interface Visual:**

1. **index.html**: Estrutura básica da interface
2. **style.css**: Estilização com tema escuro e indicador vermelho
3. **jquery.js**: Lógica para mostrar/ocultar interface

## 🚀 Instalação e Configuração

### Pré-requisitos

- FiveM Server
- vRP Framework
- Permissões configuradas no vRP

### Passos de Instalação

1. **Copie a pasta `doors`** para `resources/[scripts]/`

2. **Adicione ao server.cfg:**
```cfg
ensure doors
```

3. **Configure as permissões no vRP:**
```lua
-- Exemplo de permissões necessárias
"Police"    -- Para policiais
"Paramedic" -- Para paramédicos
"Emergency" -- Para serviços de emergência
"Admin"     -- Para administradores
```

4. **Reinicie o servidor**

### Configuração de Portas

Para adicionar uma nova porta, edite `server-side/core.lua`:

```lua
[ID] = { 
    Coords = vec3(X, Y, Z),           -- Coordenadas da porta
    Hash = HASH_DA_PORTA,             -- Hash da porta
    Lock = true,                      -- Estado inicial
    Distance = 1.5,                   -- Distância de interação
    Perm = "PERMISSAO_NECESSARIA",    -- Permissão requerida
    Other = ID_PORTA_RELACIONADA      -- Porta dupla (opcional)
}
```

### Como Encontrar o Hash de uma Porta

1. Use o comando `/coords` no jogo
2. Posicione-se na porta
3. Use ferramentas como o **Door Hash Finder** ou **Native Trainer**
4. Ou consulte listas de hashes de portas do GTA V

## 🎮 Como Usar

### Para Jogadores

1. **Aproxime-se** de uma porta configurada
2. **Aguarde** a interface aparecer
3. **Pressione E** para interagir
4. **Verifique** se tem a permissão necessária

### Para Administradores

1. **Acesse** o arquivo `server-side/core.lua`
2. **Adicione** novas portas seguindo o padrão
3. **Configure** as permissões adequadas
4. **Reinicie** o recurso

## 🔧 Personalização

### Alterando a Interface

Para modificar a aparência:

1. **Edite `web-side/style.css`** para mudar cores e layout
2. **Modifique `web-side/index.html`** para alterar textos
3. **Ajuste `web-side/jquery.js`** para mudar comportamentos

### Exemplo de Personalização CSS

```css
#Doors {
    background: rgba(0,100,200,.75); /* Cor azul */
    border-radius: 10px;             /* Bordas arredondadas */
}

#Doors::before {
    background: #00ff00;             /* Indicador verde */
}
```

### Adicionando Novas Permissões

1. **No vRP**, configure a nova permissão
2. **No script**, use a permissão nas portas:
```lua
[999] = { 
    Coords = vec3(100, 200, 30), 
    Hash = 123456789, 
    Lock = true, 
    Distance = 2.0, 
    Perm = "NOVA_PERMISSAO" 
}
```

## 🐛 Troubleshooting

### Problemas Comuns

1. **Porta não funciona**
   - Verifique se o hash está correto
   - Confirme se as coordenadas estão precisas
   - Teste se a permissão está configurada

2. **Interface não aparece**
   - Verifique se o arquivo `fxmanifest.lua` está correto
   - Confirme se os arquivos web-side estão presentes
   - Teste se o jQuery está carregando

3. **Permissões não funcionam**
   - Verifique se o vRP está funcionando
   - Confirme se a permissão existe no vRP
   - Teste com permissão de admin

### Logs de Debug

Para debug, adicione prints no código:

```lua
-- No client-side
print("Jogador próximo da porta: " .. Number)

-- No server-side
print("Tentativa de acesso: " .. Passport .. " na porta " .. Number)
```

## 📊 Tipos de Portas Configuradas

O script inclui portas para:

| Tipo | Permissão | Descrição |
|------|-----------|-----------|
| Police | "Police" | Delegacias e departamentos policiais |
| Paramedic | "Paramedic" | Hospitais e centros médicos |
| Emergency | "Emergency" | Serviços de emergência |
| Bennys | "Bennys" | Oficina mecânica |
| Mafia | "Mafia" | Locais da máfia |
| Bloods/Ballas | "Bloods"/"Ballas" | Territórios de gangues |
| Uwucoffee | "Uwucoffee" | Cafeteria |
| Yakuza | "Yakuza" | Locais da Yakuza |
| Mansao | "Mansao" | Mansões exclusivas |
| Admin | "Admin" | Áreas administrativas |

## 🔄 Atualizações

### Versão Atual
- **v1.0**: Sistema básico de portas
- Suporte a portas duplas
- Interface visual responsiva
- Integração completa com vRP

### Próximas Funcionalidades
- Sistema de logs de acesso
- Configuração via arquivo externo
- Suporte a múltiplas permissões por porta
- Interface administrativa web

## 📞 Suporte

Para suporte técnico:
- Verifique esta documentação
- Consulte os comentários no código
- Teste em ambiente de desenvolvimento
- Verifique logs do servidor

## 📄 Licença

Este script foi desenvolvido para uso em servidores FiveM com vRP Framework.

---

**Desenvolvido para Creative Network**
*Sistema de Controle de Portas v1.0*
