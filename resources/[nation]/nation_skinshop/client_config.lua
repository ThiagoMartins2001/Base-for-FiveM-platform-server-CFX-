local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
func = Tunnel.getInterface("nation_skinshop")
fclient = {}
Tunnel.bindInterface("nation_skinshop", fclient)

---------------------------------------------------------------------------
------------------------------ANIMAÇÃO DE PARADO---------------------------
---------------------------------------------------------------------------
function LoadAnim(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end

function freezeAnim(dict, anim, flag, keep)
    if not keep then
        ClearPedTasks(PlayerPedId())
    end
    LoadAnim(dict)
    TaskPlayAnim(PlayerPedId(), dict, anim, 2.0, 2.0, -1, flag or 1, 0, false, false, false)
    RemoveAnimDict(dict)
end

handsUp = false
handsup = function()
    handsUp = not handsUp
    if handsUp then
        freezeAnim("random@mugging3", "handsup_standing_base", 49)
    else
        freezeAnim("move_f@multiplayer", "idle")
    end
end

---------------------------------------------------------------------------
----------------------------CÂMERAS----------------------------------------
---------------------------------------------------------------------------
local cameras = {
    ["body"] = { coords = vec3(0.4, 2.1, 0.9), point = vec3(0.5, -0.1, -0.1) },
    ["head"] = { coords = vec3(0.0, 0.7, 0.8), point = vec3(0.2, 0.0, 0.6) },
    ["chest"] = { coords = vec3(0.0, 1.4, 0.7), point = vec3(0.4, 0.0, 0.2) },
    ["legs"] = { coords = vec3(0.0, 1.3, 0.2), point = vec3(0.4, 0.0, -0.5) },
    ["feet"] = { coords = vec3(0.0, 0.8, -0.5), point = vec3(0.25, 0.0, -1.0) }
}

componentCams = {
    ["masks"] = "head",
    ["torsos"] = "chest",
    ["legs"] = "legs",
    ["bags"] = "chest",
    ["shoes"] = "feet",
    ["accessories"] = "body",
    ["undershirts"] = "chest",
    ["bodyArmors"] = "chest",
    ["decals"] = "body",
    ["tops"] = "chest",
    ["hats"] = "head",
    ["glasses"] = "head",
    ["ears"] = "head",
    ["watches"] = "legs",
    ["bracelets"] = "legs",
}

local activeCam

function interpCamera(cameraName)
    if cameras[cameraName] then
        if cameraName == activeCam then return end
        activeCam = cameraName
        local ped = PlayerPedId()
        local cam = cameras[cameraName]
        local coord = GetOffsetFromEntityInWorldCoords(ped, cam.coords)
        local tempCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coord, 0, 0, 0, 50.0)
        local pointCoords = GetOffsetFromEntityInWorldCoords(ped, cam.point)
        SetCamActive(tempCam, true)
        SetCamActiveWithInterp(tempCam, fixedCam, 600, true, true)
        PointCamAtCoord(tempCam, pointCoords)
        CreateThread(function()
            Wait(600)
            DestroyCam(fixedCam)
            fixedCam = tempCam
        end)
    end
end

function createCamera()
    local ped = PlayerPedId()
    local groundCam = CreateCam("DEFAULT_SCRIPTED_CAMERA")
    if store and store.coords then
        SetEntityCoords(ped, store.coords.x, store.coords.y, store.coords.z - 0.97)
        if store.h then
            SetEntityHeading(ped, store.h)
        end
    end
    AttachCamToEntity(groundCam, ped, 0.5, -1.6, 0.0)
    SetCamRot(groundCam, 0, 0.0, 0.0)
    SetCamActive(groundCam, true)
    RenderScriptCams(true, false, 1, true, true)
    activeCam = "body"
    local cam = cameras[activeCam]
    local coord = GetOffsetFromEntityInWorldCoords(ped, cam.coords)
    fixedCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coord, 0, 0, 0, 50.0)
    local pointCoords = GetOffsetFromEntityInWorldCoords(ped, cam.point)
    PointCamAtCoord(fixedCam, pointCoords)
    SetCamActive(fixedCam, true)
    SetCamActiveWithInterp(fixedCam, groundCam, 1000, true, true)
    CreateThread(function()
        Wait(1000)
        DestroyCam(groundCam)
    end)
end

---------------------------------------------------------------------------
-----------------------DEIXAR OUTROS PLAYERS INVISÍVEIS--------------------
---------------------------------------------------------------------------
function setPlayersVisible(bool)
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, not bool)
    SetEntityInvincible(ped, false) --mqcu
    if bool then
        for _, player in ipairs(GetActivePlayers()) do
            local otherPlayer = GetPlayerPed(player)
            if ped ~= otherPlayer then
                SetEntityVisible(otherPlayer, bool)
            end
        end
    else
        CreateThread(function()
            while inMenu do
                for _, player in ipairs(GetActivePlayers()) do
                    local otherPlayer = GetPlayerPed(player)
                    if ped ~= otherPlayer then
                        SetEntityVisible(otherPlayer, bool)
                    end
                end
                InvalidateIdleCam()
                Wait(1)
            end
        end)
    end
end

---------------------------------------------------------------------------
-----------------------LOJAS DE ROUPAS--------------------------
---------------------------------------------------------------------------
defaultPrices = {
    ["masks"] = 50,
    ["torsos"] = 20,
    ["legs"] = 200,
    ["bags"] = 150,
    ["shoes"] = 200,
    ["accessories"] = 90,
    ["undershirts"] = 100,
    ["bodyArmors"] = 300,
    ["decals"] = 50,
    ["tops"] = 300,
    ["hats"] = 120,
    ["glasses"] = 180,
    ["ears"] = 40,
    ["watches"] = 40,
    ["bracelets"] = 35,
}

customClothes = {
    ["test"] = {
        ['tops'] = {
            male = {
                defaultPrice = 500,
                type = "insert",
                [0] = true,
                [1] = true,
                [2] = 1000,
                [3] = true,
            }
        },

        ['glasses'] = {
            male = {
                defaultPrice = 500,
                type = "insert",
                [1] = {
                    price = 250,
                    textures = {
                        [0] = { blocked = true }
                    }
                },
            }
        },

        ['legs'] = {
            male = {
                type = "remove",
                [0] = 5000,
                [1] = true,
                [2] = true,
                [3] = true,
            }
        },
    },
}

function format(n)
    local left, num, right = string.match(n, '^([^%d]*%d)(%d*)(.-)$')
    return left .. (num:reverse():gsub('(%d%d%d)', '%1.'):reverse()) .. right
end

function isCloth(index, value)
    return type(index) == "number" and type(value) == "table" -- verificar se está acessando o indice de uma roupa
end

isComponentBlocked = function(id, component)
    -- if component == "bags" then return true end
    return customClothes[id] and customClothes[id][component] and customClothes[id][component].blocked
end

isClothBlocked = function(id, component, index, gender)
    if customClothes[id] and customClothes[id][component] and customClothes[id][component][gender] then
        local c = customClothes[id][component][gender]
        return (c.type == "insert" and (not c[index] or (type(c[index]) == "table" and c[index].blocked))) or
            (c.type == "remove" and c[index] and (type(c[index]) == "boolean" or (type(c[index]) == "table" and c[index].blocked)))
    end
    return false
end

getBlockedComponentTextures = function(cloth, id, component, index, gender)
    for i = 0, cloth.textures do
        if not cloth[i] then
            cloth[i] = { blocked = false }
        else
            cloth[i].blocked = false
        end
        if customClothes[id] and customClothes[id][component] and customClothes[id][component][gender] and customClothes[id][component][gender][index] then
            local c = customClothes[id][component][gender][index]
            if type(c) == "table" and c.textures and c.textures[i] then
                cloth[i].blocked = c.textures[i].blocked
            end
        end
    end
    return cloth
end

getClothPrice = function(id, component, index, gender)
    if id == "nation_creator" then return 0 end
    if customClothes[id] and customClothes[id][component] and customClothes[id][component][gender] then
        local c = customClothes[id][component][gender]
        if c[index] then
            local price = c[index]
            if type(price) == "table" then
                price = price.price or c.defaultPrice or defaultPrices[component]
            elseif type(price) == "boolean" then
                price = c.defaultPrice
            end
            return price
        else
            return c.defaultPrice or defaultPrices[component]
        end
    end
    return defaultPrices[component]
end

getClothes = function(id)
    local clothes = getAllClothes()
    local gender = getGender()
    for component, v in pairs(clothes) do
        v.blocked = isComponentBlocked(id, component)
        for index, j in pairs(v) do
            if isCloth(index, j) then
                j.price = getClothPrice(id, component, index, gender)
                j.blocked = isClothBlocked(id, component, index, gender)
                j = getBlockedComponentTextures(j, id, component, index, gender)
            end
        end
    end
    return clothes
end

getCartTotal = function(cart, initialClothes, storeId)
    local total = 0
    local gender = getGender()
    for component, index in pairs(cart) do
        if initialClothes[component] then
            local i = initialClothes[component][1]
            if index >= 0 and index ~= i then
                total = total + getClothPrice(storeId, component, index, gender)
            end
        end
    end
    return math.floor(total)
end

getPopupText = function(total) -- TEXTO QUE VAI APARECER NO POPUP NA HORA DE COMPRAR
    return "você deseja pagar o valor de R$ <b>" .. format(total or 0) .. "</b> ?"
end

skinshops = {
    --Hospital
    [1] = {
        clothes = getClothes, permission = Paramedic, coords = vec3(306.05,-585.57,38.33),
    },
     --Mansao01 Barragem
    [2] = {
        clothes = getClothes, permission = Mansao02, coords = vec3(1269.83,-879.83,71.79),
    },
      --Mansao01 Barragem
    [3] = {
        clothes = getClothes, permission = Mansao02, coords = vec3(1239.27,-853.00,79.12),
    },
    --Antares
    [4] = {
        clothes = getClothes, permission = nil, coords = vec3(2385.18, 897.46, 111.76),
    },
    --CidadeDeDeus
    [5] = {
        clothes = getClothes, permission = nil, coords = vec3(1721.79, 1064.05, 146.0),
    },
    --Morrodo18
    [6] = {
        clothes = getClothes, permission = nil, coords = vec3(884.64, 1045.32, 277.15),
    },
    --Complexo da Arte
    [7] = {
        clothes = getClothes, permission = nil, coords = vec3(599.86, 887.86, 233.82),
    },
    --Vidigal
    [8] = {
        clothes = getClothes, permission = nil, coords = vec3(-1642.62, 889.01, 177.66),
    },
    --Complexo do Lixao
    [9] = {
        clothes = getClothes, permission = nil, coords = vec3(-276.27, 1851.82, 194.48),
    },
    --Complexo Do PPG
    [10] = {
        clothes = getClothes, permission = nil, coords = vec3(-629.92, 2155.55, 126.26),
    },
    --Morro Do Sapo
    [11] = {
        clothes = getClothes, permission = nil, coords = vec3(-1401.74, 1619.71, 161.4),
    },
    --Fallet
    [12] = {
        clothes = getClothes, permission = nil, coords = vec3(2550.36, 2411.91, 53.85),
    },
    -- Favela Do Dick
    [13] = {
        clothes = getClothes, permission = nil, coords = vec3(3014.0, 3018.91, 90.5),
    },
    --Cidade Alta
    [14] = {
        clothes = getClothes, permission = nil, coords = vec3(2621.69, 3311.58, 57.27),
    },
    --NovaHolanda
    [15] = {
        clothes = getClothes, permission = nil, coords = vec3(-1522.66, 618.86, 206.21),
    },
    -- CITY
    [16] = {
        clothes = getClothes, permission = nil, coords = vec3(-1204.5, -1453.87, 4.38),
    },
    -- CITY
    [17] = {
        clothes = getClothes, permission = nil, coords = vec3(-827.36, -1076.83, 11.32),
    },
    -- CITY
    [18] = {
        clothes = getClothes, permission = nil, coords = vec3(73.67, -1399.06, 29.37),
    },
    -- CITY
    [19] = {
        clothes = getClothes, permission = nil, coords = vec3(-715.93, -147.74, 37.41),
    },
    -- CITY
    [20] = {
        clothes = getClothes, permission = nil, coords = vec3(-163.55, -311.01, 39.73),
    },
    -- CITY
    [21] = {
        clothes = getClothes, permission = nil, coords = vec3(-1193.28, -772.23, 17.32),
    },
    -- CITY
    [22] = {
        clothes = getClothes, permission = nil, coords = vec3(-1446.79, -230.54, 49.81),
    },
    -- CITY
    [23] = {
        clothes = getClothes, permission = nil, coords = vec3(12.06, 6514.16, 31.88),
    },
    -- CITY
    [24] = {
        clothes = getClothes, permission = nil, coords = vec3(1695.22, 4829.57, 42.06),
    },
    -- CITY
    [25] = {
        clothes = getClothes, permission = nil, coords = vec3(123.22, -221.32, 54.56),
    },
    -- CITY
    [26] = {
        clothes = getClothes, permission = nil, coords = vec3(617.66, 2760.76, 42.09),
    },
    -- CITY
    [27] = {
        clothes = getClothes, permission = nil, coords = vec3(1190.3, 2712.35, 38.22),
    },
    -- CITY
    [28] = {
        clothes = getClothes, permission = nil, coords = vec3(-3173.03, 1046.71, 20.86),
    },
    -- CITY
    [29] = {
        clothes = getClothes, permission = nil, coords = vec3(-1107.44, 2707.65, 19.11),
    },
    -- CITY
    [30] = {
        clothes = getClothes, permission = nil, coords = vec3(427.42, -799.81, 29.49),
    },
    -- PMERJ
    [31] = {
        clothes = getClothes, permission = nil, coords = vec3(956.23, -3209.51, 6.2),
    },
    -- PCERJ
    [32] = {
        clothes = getClothes, permission = nil, coords = vec3(-2185.95, -510.98, 12.96),
    },
    -- UPA 24 HRS
    [33] = {
        clothes = getClothes, permission = nil, coords = vec3(458.51, -1146.43, 30.75),
    },
    -- Police FEDERAL
    [34] = {
        clothes = getClothes, permission = nil, coords = vec3(2138.73, 3847.69, 34.1),
    },
    -- MECANICA
    [35] = {
        clothes = getClothes, permission = nil, coords = vec3(-337.08, -166.54, 44.58),
    },
    -- EXERCITO
    [36] = {
        clothes = getClothes, permission = nil, coords = vec3(-2357.59, 3254.54, 32.81),
    },
    -- CHOQUE
    [37] = {
        clothes = getClothes, permission = nil, coords = vec3(-558.71, -2409.85, 19.12),
    },
    -- VIGARIO GERAL
    [38] = {
        clothes = getClothes, permission = nil, coords = vec3(963.18, 1611.82, 212.39),
    },
    -- VILA DO JOAO
    [39] = {
        clothes = getClothes, permission = nil, coords = vec3(1360.98, -1315.17, 66.35),
    },
    -- BOPE
    [40] = {
        clothes = getClothes, permission = nil, coords = vec3(-244.04, 1560.97, 349.82),
    },
    -- PRF
    [41] = {
        clothes = getClothes, permission = nil, coords = vec3(-1414.93, 5132.64, 66.05),
    },
    -- PRF 2
    [42] = {
        clothes = getClothes, permission = nil, coords = vec3(-316.68, 6097.96, 33.62),
    },
    -- Rodo
    [43] = {
        clothes = getClothes, permission = nil, coords = vec3(138.51, 1251.72, 254.63),
    },
    --Vila Kennedy
    [44] = {
        clothes = getClothes, permission = nil, coords = vec3(850.16, 1850.48, 140.27),
    },
    [45] = {
        clothes = getClothes, permission = Police, coords = vec3(-340.72,-253.14,32.71), --Police 
    },
    [46] = {
        clothes = getClothes, permission = Prf, coords = vec3(1516.54,792.87,78.43), --PRF
    },
    [47] = {
        clothes = getClothes, permission = Prf, coords = vec3(2917.97,4181.04,52.50), --PRF
    },
    [48] = {
        clothes = getClothes, permission = Prf, coords = vec3(-276.87,6055.45,33.06), --PRF
    },
    [49] = {
        clothes = getClothes, permission = Prf, coords = vec3(-3019.98,384.03,16.64), --PRF
    },

    ["admin"] = {
        clothes = getClothes
    },

    ["nation_creator"] = {
        clothes = getClothes
    },
}

RegisterNetEvent("skinshop:openShop")
AddEventHandler("skinshop:openShop", function()
    toggleMenu("admin")
end)

nearestSkinshops = {}
mainThread = function()
    local getNearestSkinshops = function()
        while true do
            if not inMenu then
                local myCoords = GetEntityCoords(PlayerPedId())
                for k, v in pairs(skinshops) do
                    if v and v.coords then
                        local distance = #(myCoords - v.coords)
                        if nearestSkinshops[k] then
                            if distance > 10 then
                                nearestSkinshops[k] = nil
                            end
                        else
                            if distance <= 10 then
                                nearestSkinshops[k] = v
                            end
                        end
                    end
                end
            end
            Wait(500)
        end
    end

    --    addBlips()
    CreateThread(getNearestSkinshops)

    while true do
        local idle = 500
        local ped = PlayerPedId()
        local myCoords = GetEntityCoords(ped)
        if not inMenu then
            for skinShopId, v in pairs(nearestSkinshops) do
                if v and v.coords and GetEntityHealth(ped) > 101 then
                    idle = 0
                    local coords = v.coords
                    local distance = #(myCoords - v.coords)
                    if IsDisabledControlJustPressed(0, 38) and distance < 1.6 then
                        if v.permission then
                            if func.checkPermission(v.permission) then
                                SetEntityHeading(ped, (GetEntityHeading(ped) + 180.0) % 360.0)
                                toggleMenu(skinShopId)
                            end
                        else
                            SetEntityHeading(ped, (GetEntityHeading(ped) + 180.0) % 360.0)
                            toggleMenu(skinShopId)
                        end
                    end
                end
            end
        end
        Wait(idle)
    end
end

CreateThread(function()
    local Tables = {}
    for Number = 1, #skinshops do
        Tables[#Tables + 1] = { skinshops[Number]["coords"]["x"], skinshops[Number]["coords"]["y"], skinshops[Number]
            ["coords"]["z"], 2.0, "E", "Loja de Roupas", "Pressione para abrir" }
    end
    TriggerEvent("hoverfy:Insert", Tables)
end)

function addBlips()
    for _, v in pairs(skinshops) do
        local coords = v.coords
        if coords and v.blip ~= false then
            local blip = AddBlipForCoord(coords)
            SetBlipSprite(blip, v.id or 73)
            SetBlipColour(blip, v.color or 13)
            SetBlipScale(blip, 0.4)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.name or "Loja de Roupas")
            EndTextCommandSetBlipName(blip)
        end
    end
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    SetTextScale(0.45, 0.45)
    SetTextFont(6)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
end

RegisterNetEvent("nation_skinshop:toggleMenu")
AddEventHandler("nation_skinshop:toggleMenu", function(menu)
    toggleMenu(menu)
end)

--------- CREATIVE V3 ------------
mySkinData = {}

local skinData = {
    ["pants"] = "legs",
    ["arms"] = "torsos",
    ["tshirt"] = "undershirts",
    ["torso"] = "tops",
    ["vest"] = "bodyArmors",
    ["backpack"] = "bags",
    ["shoes"] = "shoes",
    ["mask"] = "masks",
    ["hat"] = "hats",
    ["glass"] = "glasses",
    ["ear"] = "ears",
    ["watch"] = "watches",
    ["bracelet"] = "bracelets",
    ["accessory"] = "accessories",
    ["decals"] = "decals"
}

function fclient.getCloths()
    local myCloths = getMyClothes()
    local cloths = {}
    for cloth, comp in pairs(skinData) do
        local item = myCloths[comp][1]
        local texture = myCloths[comp][2]
        cloths[cloth] = { item = item, texture = texture }
    end
    mySkinData = cloths
    return cloths
end

RegisterNetEvent("updateRoupas")
AddEventHandler("updateRoupas", function(custom)
    mySkinData = custom
    func.updateClothes()
end)

RegisterCommand('skinshop', function()
    if func.checkPermission({ "Admin" }) or func.checkPermission({ "Owner" }) then
        toggleMenu("admin")
    end
end)
