local config = {}

config.Token      = "94gttuR0hC4cXhb3xBlE9uLBT0PnudsDoyUav4vfcZad9Gd0fCGd1Gehd9oz"
config.LicenseKey = "TQG4-Z3ZP-QBIN-TDT1"
config.IPItems    = "http://201.7.213.132/inventory/"
config.IPVehicles = "http://201.7.213.132/Vehicles/"
config.UserImage  = "https://files.mastodon.social/media_attachments/files/113/550/046/084/784/712/original/bf888cb2e5aa9e9a.png"

config.permissions = {
    ["Admin"] = {
        ["players"]       = true,
        ["groups"]        = true,
        ["punishments"]   = true,
        ["deleteban"]     = true,
        ["messages"]      = true,
        ["spawnitems"]    = true,
        ["spawnvehicles"] = true,
        ["addvehicles"]   = true,
    }
     -- ["manager.permissao"] = { 
    --     ["players"]       = true,
    --     ["groups"]        = true,
    --     ["punishments"]   = true,
    --     ["messages"]      = true,
    --     ["spawnitems"]    = true,
    --     ["spawnvehicles"] = true,
    --     ["addvehicles"]   = true
    -- },
    -- ["coordenador.permissao"] = {
    --     ["players"]       = true,
    --     ["groups"]        = true,
    --     ["punishments"]   = true,
    --     ["messages"]      = true,
    --     ["spawnitems"]    = true,
    --     ["spawnvehicles"] = true,
    --     ["addvehicles"]   = true
    -- },
    -- ["administrador.permissao"] = {
    --     ["players"]       = true,
    --     ["groups"]        = true,
    --     ["punishments"]   = true,
    --     ["messages"]      = true,
    --     ["spawnitems"]    = false,
    --     ["spawnvehicles"] = true,
    --     ["addvehicles"]   = false
    -- },
    -- ["moderador.permissao"] = {
    --     ["players"]       = true,
    --     ["groups"]        = true,
    --     ["punishments"]   = true,
    --     ["messages"]      = true,
    --     ["spawnitems"]    = false,
    --     ["spawnvehicles"] = false,
    --     ["addvehicles"]   = false
    -- },
    -- ["suporte.permissao"] = {
    --     ["players"]       = true,
    --     ["groups"]        = false,
    --     ["punishments"]   = true,
    --     ["messages"]      = true,
    --     ["spawnitems"]    = false,
    --     ["spawnvehicles"] = false,
    --     ["addvehicles"]   = false
    -- },
}

config.commands = {
    opentablet = "admin",
    openchat   = "chatstaff"
}

config.webhooks = {
    addgroup          = "",
    remgroup          = "",
    addban            = "",
    deleteban         = "",
    editban           = "",
    spawnitem         = "",
    spawnvehicle      = "",
    addvehicle        = "",
    removevehicle     = "",
    webhookimage      = "",
    webhooktext       = "",
    webhookcolor      = 16431885
}

config.starttablet = function()
    vRP.CreateObjects("amb@code_human_in_bus_passenger_idles@female@tablet@idle_a","idle_b","prop_cs_tablet",49,60309)
end

config.stoptablet = function()
	vRP.Destroy()
end

return config