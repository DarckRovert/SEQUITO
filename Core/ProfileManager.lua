--[[
    Sequito - ProfileManager.lua
    Sistema de gestión de perfiles para v10.2.0
]]

local addonName, S = ...
S.ProfileManager = {}
local PM = S.ProfileManager
local L = S.L

-- Estructura de DB esperada:
-- SequitoDB = {
--     profiles = { ["Default"] = { ... }, ["Raid"] = { ... } },
--     profileKeys = { ["PlayerName - Realm"] = "Default" },
--     global = { ... }
-- }

-- Helper: Deep Copy RECURSIVO
local function DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
        end
        setmetatable(copy, DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function PM:Initialize()
    if not SequitoDB then SequitoDB = {} end
    
    -- Migración v10.1 -> v10.2
    if not SequitoDB.profiles then
        -- Crear estructura nueva
        SequitoDB.profiles = {}
        
        -- Si existe profile antiguo, moverlo a Default
        if SequitoDB.profile then
             SequitoDB.profiles["Default"] = SequitoDB.profile
             SequitoDB.profile = nil -- Limpiar old
             S:Print("|cFF00FF00Sequito:|r Configuración migrada al perfil 'Default'.")
        else
             SequitoDB.profiles["Default"] = {}
        end
        
        -- Inicializar keys
        SequitoDB.profileKeys = {}
    end
    
    -- Asignar perfil actual
    self:LoadCurrentProfile()
    
    -- Registrar UI (Deferred)
    C_Timer.After(1, function() self:InitializeUI() end)
end

function PM:LoadCurrentProfile()
    local key = UnitName("player") .. " - " .. GetRealmName()
    local profileName = SequitoDB.profileKeys[key] or "Default"
    
    -- Asegurar que el perfil existe
    if not SequitoDB.profiles[profileName] then
        SequitoDB.profiles[profileName] = {} -- Crear vacío si no existe
    end
    
    -- Apuntar S.db a este perfil
    S.db = {}
    S.db.profile = SequitoDB.profiles[profileName]
    S.db.global = SequitoDB.global or {}
    
    -- Notificar cambio
    S:SendMessage("SEQUITO_PROFILE_CHANGED")
end

function PM:GetProfiles()
    local profiles = {}
    if SequitoDB and SequitoDB.profiles then
        for name, _ in pairs(SequitoDB.profiles) do
            table.insert(profiles, name)
        end
    end
    table.sort(profiles)
    return profiles
end

function PM:GetCurrentProfile()
    local key = UnitName("player") .. " - " .. GetRealmName()
    return SequitoDB.profileKeys[key] or "Default"
end

function PM:CreateProfile(name, copyFrom)
    if not name or name == "" then return end
    if SequitoDB.profiles[name] then return end -- Ya existe
    
    -- Crear copiando defaults (o source)
    local source
    if copyFrom and SequitoDB.profiles[copyFrom] then
        source = SequitoDB.profiles[copyFrom]
    elseif S.defaults and S.defaults.profile then
        source = S.defaults.profile
    else
        source = {} -- Fallback vacio
    end
    
    SequitoDB.profiles[name] = DeepCopy(source)
    
    self:SetProfile(name)
end

function PM:DeleteProfile(name)
    if name == "Default" then return end -- No borrar Default
    if self:GetCurrentProfile() == name then return end -- No borrar activo
    
    SequitoDB.profiles[name] = nil
end

function PM:CopyProfile(sourceName)
    if not SequitoDB.profiles[sourceName] then return end
    
    local current = self:GetCurrentProfile()
    -- Deep copy real
    local source = SequitoDB.profiles[sourceName]
    local dest = SequitoDB.profiles[current]
    
    wipe(dest)
    -- Copia recursiva
    local cleanCopy = DeepCopy(source)
    for k, v in pairs(cleanCopy) do
        dest[k] = v
    end
    
    ReloadUI()
end

function PM:SetProfile(name)
    local key = UnitName("player") .. " - " .. GetRealmName()
    if not SequitoDB.profiles[name] then return end
    
    SequitoDB.profileKeys[key] = name
    self:LoadCurrentProfile()
    ReloadUI() -- Necesario para aplicar cambios profundos limpiamente
end

-- ========================================================
-- UI Registration
-- ========================================================
function PM:InitializeUI()
    if not S.ModuleConfig then return end
    
    S.ModuleConfig:RegisterModule("ProfileManager", {
        name = "Perfiles",
        icon = "Interface\\Icons\\INV_Misc_Book_09",
        description = "Gestión de perfiles de configuración para diferentes personajes o roles.",
        category = "general",
        onLoad = function(db)
            -- No necesitamos cargar nada específico aquí, los botones funcionan directamente
        end,
        options = {
            {
                type = "header",
                label = "Perfil Actual",
            },
            {
                type = "dropdown",
                key = "current_profile",
                label = "Seleccionar Perfil",
                tooltip = "Cambia el perfil activo para este personaje. Requiere recargar UI.",
                default = "Default",
                options = function()
                    local opts = {}
                    local profiles = PM:GetProfiles()
                    for _, p in ipairs(profiles) do
                        table.insert(opts, {text = p, value = p})
                    end
                    return opts
                end,
                onSave = function(val) -- Callback ficticio, el dropdown guarda en db pero necesitamos acción
                    -- Este callback no existe en ModuleConfig.lua estándar :(
                    -- ModuleConfig guarda el valor en db["ProfileManager_current_profile"]
                    -- Pero ProfileManager necesita llamar SetProfile()
                end
            },
            {
                type = "button",
                label = "Aplicar Perfil Seleccionado",
                tooltip = "Carga el perfil seleccionado arriba y recarga la UI.",
                func = function()
                    local val = UIDropDownMenu_GetSelectedValue(S.ModuleConfig.activeDropdown) -- Hacky?
                    -- Mejor: leer de DB
                    local db = S.db.profile
                    if db and db["ProfileManager_current_profile"] then
                         PM:SetProfile(db["ProfileManager_current_profile"])
                    end
                end,
                width = 200,
            },
            {
                type = "header",
                label = "Gestión",
            },
            {
                type = "editbox",
                key = "new_profile_name",
                label = "Nombre Nuevo Perfil",
                tooltip = "Escribe el nombre para crear un nuevo perfil",
                width = 200,
                default = "",
            },
            {
                type = "button",
                label = "Crear Nuevo",
                tooltip = "Crea un nuevo perfil vacío (o con defaults) con el nombre escrito arriba.",
                func = function(btn)
                    -- Necesitamos acceder al editbox. ModuleConfig no expone controles facilmente.
                    -- Workaround: buscar el editbox por key en ConfigFrame.controls
                    local controls = S.ModuleConfig.ConfigFrame.controls
                    for _, c in ipairs(controls) do
                        if c.key == "new_profile_name" and c.editbox then
                            local name = c.editbox:GetText()
                            if name and name ~= "" then
                                PM:CreateProfile(name)
                                S:Print("Perfil '"..name.."' creado.")
                            end
                            break
                        end
                    end
                end,
                width = 120,
            },
            {
                type = "button",
                label = "Copiar de Actual",
                tooltip = "Crea un nuevo perfil copiando la configuración actual.",
                func = function()
                     local controls = S.ModuleConfig.ConfigFrame.controls
                    for _, c in ipairs(controls) do
                        if c.key == "new_profile_name" and c.editbox then
                            local name = c.editbox:GetText()
                            if name and name ~= "" then
                                -- Crear copiando del actual
                                PM:CreateProfile(name, PM:GetCurrentProfile())
                                S:Print("Perfil '"..name.."' creado como copia de " .. PM:GetCurrentProfile() .. ".")
                            end
                            break
                        end
                    end
                end,
                width = 120,
            },
            {
                type = "header",
                label = "Peligro",
            },
             {
                type = "button",
                label = "Borrar Perfil Actual",
                tooltip = "Borra el perfil ACTIVO. ¡Cuidado!",
                func = function()
                    local current = PM:GetCurrentProfile()
                    if current == "Default" then
                        S:Print("No puedes borrar el perfil Default.")
                        return
                    end
                    PM:DeleteProfile(current)
                    PM:SetProfile("Default")
                end,
                width = 200,
            },
        }
    })
end

-- Export/Import Strings (Base64 simulated)
-- ...
