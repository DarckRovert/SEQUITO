--[[
    SEQUITO - Pet Manager
    Control y monitorización de mascotas (Hunter/Warlock/DK/Mage).
]]--

local addonName, S = ...
S.PetManager = {}
local PM = S.PetManager

-- Helper para obtener configuración
function PM:GetOption(key)
    if S.ModuleConfig then
        return S.ModuleConfig:GetValue("PetManager", key)
    end
    return true
end

function PM:Initialize()
    if not self:GetOption("enabled") then
        return
    end
    
    self:CreatePetButton()
    self:RegisterEvents()
end

function PM:CreatePetButton()
    if self.Button then return end
    
    -- Botón orbital (Satélite especial)
    local btn = CreateFrame("Button", "SequitoPetBtn", S.Sphere, "SecureActionButtonTemplate")
    btn:SetSize(36, 36)
    -- Posición: Abajo del todo (Angulo -90 o 270)
    btn:SetPoint("CENTER", S.Sphere, "CENTER", 0, -50)
    
    -- Textura
    btn.icon = btn:CreateTexture(nil, "BACKGROUND")
    btn.icon:SetAllPoints()
    btn.icon:SetTexture("Interface\\Icons\\Ability_Hunter_BeastCall") -- Default
    
    -- Borde de Salud
    btn.border = btn:CreateTexture(nil, "OVERLAY")
    btn.border:SetAllPoints()
    btn.border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    btn.border:SetBlendMode("ADD")
    btn.border:SetVertexColor(0, 1, 0) -- Verde (Vida OK)
    btn.border:Hide()
    
    -- Lógica de Click (Secure)
    btn:RegisterForClicks("AnyUp")
    btn:SetAttribute("type1", "macro") -- Left Click
    btn:SetAttribute("macrotext1", "/petattack")
    
    btn:SetAttribute("type2", "macro") -- Right Click
    btn:SetAttribute("macrotext2", "/petfollow")
    
    -- Scripts visuales
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if UnitExists("pet") then
            GameTooltip:SetUnit("pet")
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("|cFF00FF00Click Izq:|r Atacar", 1, 1, 1)
            GameTooltip:AddLine("|cFF00FFFFClick Der:|r Seguir", 1, 1, 1)
        else
            GameTooltip:AddLine("Sin Mascota")
        end
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    -- OnUpdate para monitorizar vida
    btn:SetScript("OnUpdate", function(self, elapsed)
        PM:UpdateHealth()
    end)
    
    self.Button = btn
    self:UpdateVisibility()
end

function PM:RegisterEvents()
    local f = CreateFrame("Frame")
    f:RegisterEvent("UNIT_PET")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", function()
        self:UpdateVisibility()
        self:UpdateIcon()
    end)
end

function PM:UpdateVisibility()
    if not self.Button then return end
    
    if UnitExists("pet") then
        self.Button:Show()
        self:UpdateIcon()
    else
        self.Button:Hide()
    end
end

function PM:UpdateIcon()
    if not self.Button then return end
    
    -- Intentar obtener el icono real de la mascota (portrait es complejo en botones, usaremos iconos de familia)
    local icon = "Interface\\Icons\\Ability_Hunter_BeastCall"
    
    -- Detección básica por clase
    local _, class = UnitClass("player")
    if class == "WARLOCK" then
        local creatureFamily = UnitCreatureFamily("pet")
        if creatureFamily == "Imp" or creatureFamily == "Diablillo" then
            icon = "Interface\\Icons\\Spell_Shadow_SummonImp"
        elseif creatureFamily == "Voidwalker" or creatureFamily == "Abisario" then
            icon = "Interface\\Icons\\Spell_Shadow_SummonVoidWalker"
        elseif creatureFamily == "Succubus" or creatureFamily == "Súcubo" then
            icon = "Interface\\Icons\\Spell_Shadow_SummonSuccubus"
        elseif creatureFamily == "Felhunter" or creatureFamily == "Manáfago" then
            icon = "Interface\\Icons\\Spell_Shadow_SummonFelHunter"
        elseif creatureFamily == "Felguard" or creatureFamily == "Guardia Apocalíptico" then
            icon = "Interface\\Icons\\Spell_Shadow_SummonFelGuard"
        else
            icon = "Interface\\Icons\\Spell_Nature_RemoveCurse" -- Generic Warlock
        end
    elseif class == "HUNTER" then
         icon = GetSpellTexture("Call Pet") or "Interface\\Icons\\Ability_Hunter_BeastCall"
    elseif class == "MAGE" then
         icon = "Interface\\Icons\\Spell_Frost_SummonWaterElemental"
    elseif class == "DEATHKNIGHT" then
         icon = "Interface\\Icons\\Spell_DeathKnight_GhoulFrenzy"
    end
    
    self.Button.icon:SetTexture(icon)
end

function PM:UpdateHealth()
    if not self.Button or not UnitExists("pet") then return end
    
    -- Verificar si mostrar salud está habilitado
    if not self:GetOption("showHealth") then
        self.Button.border:Hide()
        return
    end
    
    local hp = UnitHealth("pet")
    local max = UnitHealthMax("pet")
    local pct = (hp / max) * 100
    
    local threshold = self:GetOption("healthThreshold") or 60
    
    if pct < 30 then
        self.Button.border:SetVertexColor(1, 0, 0) -- Rojo Critico
        self.Button.border:Show()
    elseif pct < threshold then
        self.Button.border:SetVertexColor(1, 1, 0) -- Amarillo Warning
        self.Button.border:Show()
    else
        self.Button.border:Hide()
    end
end

-- ===========================================================================
-- REGISTRO EN MODULECONFIG
-- ===========================================================================
if S.ModuleConfig then
    S.ModuleConfig:RegisterModule("PetManager", {
        name = "Gestor de Mascotas",
        description = "Control y monitorización de mascotas para Hunter, Warlock, Death Knight y Mage.",
        category = "class",
        icon = "Interface\\\\Icons\\\\Ability_Hunter_BeastCall",
        options = {
            {
                key = "enabled",
                type = "checkbox",
                label = "Habilitar PetManager",
                tooltip = "Activa el botón orbital de mascota",
                default = true
            },
            {
                key = "showHealth",
                type = "checkbox",
                label = "Mostrar salud",
                tooltip = "Muestra borde de color según la salud de la mascota",
                default = true
            },
            {
                key = "healthThreshold",
                type = "slider",
                label = "Umbral de salud baja",
                tooltip = "Porcentaje de vida para considerar salud baja",
                min = 10,
                max = 50,
                step = 5,
                default = 30
            }
        }
    })
end
