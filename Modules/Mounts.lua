--[[
    SEQUITO - Smart Mount
    Lógica de montura inteligente (Voladora/Terrestre/Acuática).
    Versión mejorada con SavedVariables.
]]--

local addonName, S = ...
S.Mounts = {}

-- Helper para obtener configuración
function S.Mounts:GetOption(key)
    if S.ModuleConfig then
        return S.ModuleConfig:GetValue("Mounts", key)
    end
    return true
end

function S.Mounts:Initialize()
    if not self:GetOption("enabled") then
        return
    end
    
    -- Inicializar configuración de monturas en DB
    if not S.db.profile.Mounts then
        S.db.profile.Mounts = {
            FlyingMount = nil,  -- Nombre de montura voladora favorita
            GroundMount = nil,  -- Nombre de montura terrestre favorita
            AquaticMount = nil, -- Nombre de montura acuática favorita
            UseRandom = true,   -- Usar monturas aleatorias si no hay favoritas
        }
    end
    
    -- Escanear monturas disponibles
    self:ScanMounts()
end

function S.Mounts:ScanMounts()
    -- Escanear todas las monturas del jugador
    self.AvailableMounts = {
        Flying = {},
        Ground = {},
        Aquatic = {},
    }
    
    for i=1, GetNumCompanions("MOUNT") do
        local creatureID, creatureName, spellID, icon, issummoned = GetCompanionInfo("MOUNT", i)
        if creatureName then
            -- Heurística simple: detectar tipo por nombre
            -- En WotLK 3.3.5 no hay API directa para tipo de montura
            local name = creatureName:lower()
            
            if name:find("drake") or name:find("proto") or name:find("wyrm") or 
               name:find("wind rider") or name:find("gryphon") or name:find("hippogryph") or
               name:find("nether ray") or name:find("flying") or name:find("carpet") then
                table.insert(self.AvailableMounts.Flying, creatureName)
            elseif name:find("turtle") or name:find("ray") or name:find("seahorse") then
                table.insert(self.AvailableMounts.Aquatic, creatureName)
            else
                table.insert(self.AvailableMounts.Ground, creatureName)
            end
        end
    end
end

function S.Mounts:GetBestMount()
    -- Prioridad: Voladora > Terrestre > Class Specific
    local flyable = IsFlyableArea()
    local swimming = IsSwimming()
    
    local mountName = nil
    
    if swimming and S.db.profile.Mounts.AquaticMount then
        -- Usar montura acuática favorita
        mountName = S.db.profile.Mounts.AquaticMount
    elseif flyable and S.db.profile.Mounts.FlyingMount then
        -- Usar montura voladora favorita
        mountName = S.db.profile.Mounts.FlyingMount
    elseif not flyable and S.db.profile.Mounts.GroundMount then
        -- Usar montura terrestre favorita
        mountName = S.db.profile.Mounts.GroundMount
    else
        -- Usar aleatoria
        if S.db.profile.Mounts.UseRandom then
            if flyable and #self.AvailableMounts.Flying > 0 then
                mountName = self.AvailableMounts.Flying[math.random(#self.AvailableMounts.Flying)]
            elseif swimming and #self.AvailableMounts.Aquatic > 0 then
                mountName = self.AvailableMounts.Aquatic[math.random(#self.AvailableMounts.Aquatic)]
            elseif #self.AvailableMounts.Ground > 0 then
                mountName = self.AvailableMounts.Ground[math.random(#self.AvailableMounts.Ground)]
            end
        end
    end
    
    return mountName
end

function S.Mounts:GenerateMountMacro()
    -- Esta función genera el cuerpo de una macro inteligente
    local body = "#showtooltip\n/dismount [mounted]\n/leavevehicle [vehicleui]\n"
    
    -- Detectar clases con montura propia
    local _, class = UnitClass("player")
    if class == "WARLOCK" and IsSpellKnown(23161) then -- Dreadsteed
        body = body .. "/cast [noflyable] " .. GetSpellInfo(23161) .. "\n"
    elseif class == "PALADIN" and IsSpellKnown(23214) then -- Charger
        body = body .. "/cast [noflyable] " .. GetSpellInfo(23214) .. "\n"
    elseif class == "DEATHKNIGHT" and IsSpellKnown(48778) then -- Acherus charger
        body = body .. "/cast [noflyable] " .. GetSpellInfo(48778) .. "\n"
    end
    
    -- Usar monturas configuradas o aleatorias
    -- Safety check: Ensure DB initialized
    if not S.db.profile.Mounts then S.db.profile.Mounts = { UseRandom = true } end
    
    local flyingMount = S.db.profile.Mounts.FlyingMount
    local groundMount = S.db.profile.Mounts.GroundMount
    
    -- Ensure scan ran
    if not self.AvailableMounts then self:ScanMounts() end
    
    if flyingMount then
        body = body .. "/cast [flyable] " .. flyingMount .. "\n"
    else
        -- Usar primera montura voladora disponible o random
        if #self.AvailableMounts.Flying > 0 then
            local mounts = table.concat(self.AvailableMounts.Flying, ", ")
            body = body .. "/castrandom [flyable] " .. mounts .. "\n"
        end
    end
    
    if groundMount then
        body = body .. "/cast [noflyable] " .. groundMount
    else
        -- Usar primera montura terrestre disponible o random
        if #self.AvailableMounts.Ground > 0 then
            local mounts = table.concat(self.AvailableMounts.Ground, ", ")
            body = body .. "/castrandom [noflyable] " .. mounts
        end
    end
    
    return body
end

function S.Mounts:MountUp()
    -- Llamado directo (no seguro en combate)
    if IsMounted() then
        Dismount()
        return
    end
    
    local mountName = self:GetBestMount()
    if mountName then
        -- Buscar el índice de la montura
        for i=1, GetNumCompanions("MOUNT") do
            local _, name = GetCompanionInfo("MOUNT", i)
            if name == mountName then
                CallCompanion("MOUNT", i)
                return
            end
        end
    end
end

-- Wrapper method for Bindings.xml keybinds
function S.Mounts:Summon()
    self:MountUp()
end

-- Comandos para configurar monturas favoritas
function S.Mounts:SetFavorite(mountType, mountName)
    if mountType == "flying" then
        S.db.profile.Mounts.FlyingMount = mountName
        print("|cFFFF00FFSequito|r: Montura voladora favorita: " .. (mountName or "Ninguna"))
    elseif mountType == "ground" then
        S.db.profile.Mounts.GroundMount = mountName
        print("|cFFFF00FFSequito|r: Montura terrestre favorita: " .. (mountName or "Ninguna"))
    elseif mountType == "aquatic" then
        S.db.profile.Mounts.AquaticMount = mountName
        print("|cFFFF00FFSequito|r: Montura acuática favorita: " .. (mountName or "Ninguna"))
    end
    
    -- Regenerar macro
    if S.MacroGen then
        S.MacroGen:GenerateClassMacros()
    end
end

function S.Mounts:ListMounts()
    print("|cFFFF00FFSequito|r - Monturas Disponibles:")
    
    if #self.AvailableMounts.Flying > 0 then
        print("|cFF00FFFFVoladoras:|r")
        for _, name in ipairs(self.AvailableMounts.Flying) do
            print("  - " .. name)
        end
    end
    
    if #self.AvailableMounts.Ground > 0 then
        print("|cFF00FFFFTerrestres:|r")
        for _, name in ipairs(self.AvailableMounts.Ground) do
            print("  - " .. name)
        end
    end
    
    if #self.AvailableMounts.Aquatic > 0 then
        print("|cFF00FFFFAcuáticas:|r")
        for _, name in ipairs(self.AvailableMounts.Aquatic) do
            print("  - " .. name)
        end
    end
    
    print(" ")
    print("|cFFFFFF00Favoritas:|r")
    print("  Voladora: " .. (S.db.profile.Mounts.FlyingMount or "Ninguna"))
    print("  Terrestre: " .. (S.db.profile.Mounts.GroundMount or "Ninguna"))
    print("  Acuática: " .. (S.db.profile.Mounts.AquaticMount or "Ninguna"))
end

-- Registrar módulo en ModuleConfig
if S.ModuleConfig then
    S.ModuleConfig:RegisterModule({
        id = "Mounts",
        name = "Monturas Inteligentes",
        description = "Sistema de selección inteligente de monturas",
        category = "utility",
        icon = "Interface\\Icons\\Ability_Mount_RidingHorse",
        options = {
            {
                key = "enabled",
                type = "checkbox",
                name = "Habilitar Monturas",
                description = "Habilitar/deshabilitar sistema de monturas",
                default = true
            },
            {
                key = "useRandom",
                type = "checkbox",
                name = "Usar Aleatorias",
                description = "Usar monturas aleatorias si no hay favoritas",
                default = true
            },
            {
                key = "autoDetect",
                type = "checkbox",
                name = "Auto-Detectar Zona",
                description = "Detectar automáticamente si usar voladora/terrestre",
                default = true
            },
            {
                key = "preferFlying",
                type = "checkbox",
                name = "Preferir Voladoras",
                description = "Usar monturas voladoras cuando sea posible",
                default = true
            }
        }
    })
end
