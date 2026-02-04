--[[
    SEQUITO - Visual FX
    Efectos inmersivos (Latido, Procs, Soul Siphon).
]]--

local addonName, S = ...
S.Visuals = {}
local FX = S.Visuals

-- Config
FX.HeartbeatEnabled = true
FX.ProcGlowEnabled = true

-- Procs importantes por clase (Buff Name -> Spell Name on Button)
FX.Procs = {
    ["WARLOCK"] = {
        ["Trance de las Sombras"] = "Descarga de las Sombras", -- Nightfall
        ["Shadow Trance"] = "Shadow Bolt",
        ["Contragolpe"] = "Incinerar", -- Backlash
        ["Backlash"] = "Incinerate",
        ["Núcleo de Magma"] = "Incinerar", -- Molten Core (Demo)
        ["Molten Core"] = "Incinerate",
    },
    ["MAGE"] = {
        ["Buena racha"] = "Piroexplosión", -- Hot Streak
        ["Hot Streak"] = "Pyroblast",
        ["Congelación cerebral"] = "Descarga de Pirofrío", -- Brain Freeze
        ["Brain Freeze"] = "Frostfire Bolt",
        ["Dedos de Escarcha"] = "Lanza de hielo", -- Fingers of Frost
        ["Fingers of Frost"] = "Ice Lance",
        ["Barrera de hielo"] = "Barrera de hielo", -- Para saber si está activa
    },
    ["PALADIN"] = {
        ["El arte de la guerra"] = "Exorcismo", -- Art of War
        ["The Art of War"] = "Exorcism",
    },
    ["DRUID"] = {
        ["Eclipse (Lunar)"] = "Fuego estelar",
        ["Eclipse (Solar)"] = "Cólera",
        ["Depredador presto"] = "Toque de sanación", -- Predatory Strikes
    },
    ["SHAMAN"] = {
        ["Arma Vorágine"] = "Descarga de relámpagos", -- Maelstrom Weapon (5 stacks usually, but simple check here)
        ["Maelstrom Weapon"] = "Lightning Bolt",
    },
    -- Add more as needed
}

-- Helper para obtener configuración
function FX:GetOption(key)
    if S.ModuleConfig then
        return S.ModuleConfig:GetValue("Visuals", key)
    end
    return true
end

function FX:Initialize()
    if not self:GetOption("enabled") then
        return
    end
    
    self.Frame = CreateFrame("Frame")
    self.Frame:RegisterEvent("UNIT_HEALTH")
    self.Frame:RegisterEvent("UNIT_AURA")
    self.Frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.Frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    
    self.Frame:SetScript("OnEvent", function(self, event, ...)
        if event == "UNIT_HEALTH" then
            FX:CheckHeartbeat(...)
        elseif event == "UNIT_AURA" then
            FX:CheckProcs(...)
        end
    end)
    
    -- Heartbeat Animation Loop
    self.Frame:SetScript("OnUpdate", function(self, elapsed)
        FX:OnUpdate(elapsed)
    end)
    

end

-- ===========================================================================
-- HEARTBEAT (Latido en HP Baja)
-- ===========================================================================
function FX:CheckHeartbeat(unit)
    if unit ~= "player" then return end
    -- La logica real ocurre en OnUpdate para suavidad
end

function FX:OnUpdate(elapsed)
    if not self:GetOption("heartbeatEnabled") then return end
    
    local hp = UnitHealth("player")
    local max = UnitHealthMax("player")
    local pct = (hp / max) * 100
    
    local sphere = S.Sphere
    if not sphere then return end
    
    if pct <= 35 and not UnitIsDeadOrGhost("player") then
        -- Pulsar Rojo
        local speed = 5
        if pct < 20 then speed = 10 end -- Más rápido si es crítico
        
        local sine = math.sin(GetTime() * speed)
        local red = 1.0
        local others = 0.5 + (0.5 * sine) -- Oscila entre 0 y 1
        
        -- En realidad queremos que el rojo sea dominante y lo demás baje
        -- Rojo fijo (1), Verde/Azul bajan a 0
        others = (sine + 1) / 2 -- 0 a 1
        
        sphere:GetNormalTexture():SetVertexColor(1, others, others)
    else
        -- Restaurar color normal
        sphere:GetNormalTexture():SetVertexColor(1, 1, 1)
    end
end

-- ===========================================================================
-- PROC WATCHER (Brillo en Botones)
-- ===========================================================================
function FX:CheckProcs(unit)
    if unit ~= "player" then return end
    if not self:GetOption("procGlowEnabled") then return end
    
    local _, class = UnitClass("player")
    local map = self.Procs[class]
    if not map then return end
    
    -- Buscar buffs activos
    for i=1, 40 do
        local name, _, _, _, _, _, _, _, _, _, spellID = UnitBuff("player", i)
        if not name then break end
        
        local targetSpell = map[name]
        if targetSpell then
            self:GlowButtonForSpell(targetSpell, true)
        end
    end
    
    -- Limpiar brillos de buffs que ya no están?
    -- Esto es costoso de comprobar (ausencia).
    -- Simplificación: Apagar todos y re-encender los activos.
    self:ClearAllGlows()
    for i=1, 40 do
        local name = UnitBuff("player", i)
        if not name then break end
        local targetSpell = map[name]
        if targetSpell then
            self:GlowButtonForSpell(targetSpell, true)
        end
    end
end

function FX:GlowButtonForSpell(spellName, show)
    -- Buscar si algún botón satélite tiene ese hechizo
    for i=1, 4 do
        local btn = _G["SequitoBtn"..i]
        if btn then
            local type = btn:GetAttribute("type")
            local spell = btn:GetAttribute("spell")
            if type == "spell" and spell == spellName then
                if show then
                    if not btn.glow then
                        btn.glow = btn:CreateTexture(nil, "OVERLAY")
                        btn.glow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
                        btn.glow:SetBlendMode("ADD")
                        btn.glow:SetVertexColor(1, 1, 0) -- Amarillo
                        btn.glow:SetAllPoints()
                    end
                    btn.glow:Show()
                    UIFrameFlash(btn.glow, 0.5, 0.5, 5, true, 0, 0)
                else
                    if btn.glow then 
                        btn.glow:Hide()
                        UIFrameFlashStop(btn.glow)
                    end
                end
            end
        end
    end
end

function FX:ClearAllGlows()
    for i=1, 4 do
        local btn = _G["SequitoBtn"..i]
        if btn and btn.glow then
            btn.glow:Hide()
            UIFrameFlashStop(btn.glow)
        end
    end
end

-- Registrar módulo en ModuleConfig
if S.ModuleConfig then
    S.ModuleConfig:RegisterModule({
        id = "Visuals",
        name = "Efectos Visuales",
        description = "Efectos visuales inmersivos: latido de corazón, brillo de procs, y efectos especiales.",
        category = "utility",
        icon = "Interface\\\\Icons\\\\Spell_Shadow_SoulGem",
        options = {
            {key = "enabled", type = "checkbox", name = "Habilitar Efectos Visuales", description = "Activar todos los efectos visuales", default = true},
            {key = "heartbeatEnabled", type = "checkbox", name = "Latido de Corazón", description = "Efecto de latido cuando la vida está baja", default = true},
            {key = "procGlowEnabled", type = "checkbox", name = "Brillo de Procs", description = "Resaltar habilidades cuando hay procs activos", default = true},
            {key = "soulSiphonEnabled", type = "checkbox", name = "Soul Siphon", description = "Efecto visual de absorción de alma (Warlock)", default = true},
            {key = "glowIntensity", type = "slider", name = "Intensidad del Brillo", description = "Intensidad del efecto de brillo en procs", min = 0.5, max = 2.0, step = 0.1, default = 1.0}
        }
    })
end
