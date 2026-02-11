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
    btn:SetPoint("CENTER", S.Sphere, "CENTER", 0, -58)
    
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
    f:RegisterEvent("PLAYER_REGEN_DISABLED")
    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    f:RegisterEvent("UNIT_HEALTH")
    
    f:SetScript("OnEvent", function(self, event, ...)
        if event == "UNIT_PET" or event == "PLAYER_ENTERING_WORLD" then
            PM:UpdateVisibility()
            PM:UpdateIcon()
        elseif event == "PLAYER_REGEN_DISABLED" then
            PM:Speak("COMBAT")
        elseif event == "UNIT_HEALTH" then
            local unit = ...
            if unit == "pet" then
                local hp = UnitHealth("pet")
                local max = UnitHealthMax("pet")
                if max > 0 and (hp/max) < 0.2 then
                    PM:Speak("LOW_HP")
                end
            end
        elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
            local _, subEvent, sourceGUID = ...
            if subEvent == "PARTY_KILL" and sourceGUID == UnitGUID("pet") then
                PM:Speak("KILL")
            end
        end
    end)
end

function PM:UpdateVisibility()
    if not self.Button then return end
    
    local raBtn = _G["SequitoRaidAssistBtn"]
    
    if UnitExists("pet") then
        self.Button:Show()
        self:UpdateIcon()
        
        -- Evitar superposición: Mover botón de RaidAssist abajo del botón de mascota
        if raBtn then
            raBtn:ClearAllPoints()
            raBtn:SetPoint("TOP", self.Button, "BOTTOM", 0, -5)
        end
    else
        self.Button:Hide()
        
        -- Restaurar posición original de RaidAssist (pegado a la esfera)
        if raBtn and S.Sphere then
            raBtn:ClearAllPoints()
            raBtn:SetPoint("TOP", S.Sphere, "BOTTOM", 0, -5)
        end
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
-- PET SPEECH (Flavor)
-- ===========================================================================
-- ===========================================================================
-- PET SPEECH (Flavor - Demon Specific)
-- ===========================================================================
PM.Speeches = {
    -- Default / Fallback
    ["DEFAULT"] = {
        COMBAT = {"¡A por ellos!", "¡Muere!", "¡Ataque!"},
        LOW_HP = {"¡Ayuda!", "¡Me muero!", "¡Cúrame!"},
        KILL = {"¡Muerto!", "¡Jaja!", "¡Uno menos!"}
    },
    -- Imp / Diablillo
    ["IMP"] = {
        COMBAT = {"¿Podemos quemarlo ya?", "¡Fuego, fuego!", "¡Esto me gusta!", "¡Sí, amo!"},
        LOW_HP = {"¡Oye, que me pegan!", "¡Ayuda, inútil!", "¡No quiero morir!", "¡Cúrame o no disparo!"},
        KILL = {"¡Quemado!", "¡Jajaja, mira como arde!", "¡Demasiado fácil!", "¡Siguiente!"}
    },
    -- Voidwalker / Abisario
    ["VOIDWALKER"] = {
        COMBAT = {"Enviadlos al vacío...", "Tu orden es mi voluntad...", "No me gusta este lugar...", "Protejo..."},
        LOW_HP = {"Me desvanezco...", "La oscuridad me llama...", "No aguanto mucho más...", "¡Socoorro...!"},
        KILL = {"Uno más al vacío...", "Consumido...", "Silencio...", "Adiós..."}
    },
    -- Succubus / Súcubo
    ["SUCCUBUS"] = {
        COMBAT = {"¿Quién quiere un beso?", "¡No toques las mercancías!", "¡Ven aquí, grandullón!", "¡Dolor y placer!"},
        LOW_HP = {"¡Me estás estropeando el maquillaje!", "¡Ayuda al la dama!", "¡No dejes que me peguen!", "¡Ahhh!"},
        KILL = {"Mmm, delicioso...", "Pobrecito...", "¿Ya terminaste?", "Qué aburrido..."}
    },
    -- Felhunter / Manáfago
    ["FELHUNTER"] = {
        COMBAT = {"¡Magia...!", "¡Comer...!", "*Gruñido*", "¡Sniff sniff!"},
        LOW_HP = {"*Gemido*", "¡Dolor...!", "¡Amo... ayuda!", "*Aullido*"},
        KILL = {"*Masticar*", "¡Rico!", "¡Más magia!", "*Eructo*"}
    },
    -- Felguard / Guardia
    ["FELGUARD"] = {
        COMBAT = {"¡POR LA LEGIÓN!", "¡MORIRÁS!", "¡MI HACHA TIENE SED!", "¡DESTRUCCIÓN!"},
        LOW_HP = {"¡ESTAS HERIDAS NO SON NADA!", "¡MÉDICO!", "¡NO CAERÉ!", "¡AAGHH!"},
        KILL = {"¡APLASTADO!", "¡VICTORIA!", "¡DÉBIL!", "¡OTRO MENOS!"}
    }
}

function PM:Speak(trigger)
    if not self:GetOption("enableSpeech") then return end
    if not S.db.profile.ShowSpeech then return end -- Global toggle check
    if not UnitExists("pet") then return end
    
    -- 20% chance
    if math.random() > 0.2 then return end
    
    local family = UnitCreatureFamily("pet")
    local type = "DEFAULT"
    
    if family == "Imp" or family == "Diablillo" then type = "IMP"
    elseif family == "Voidwalker" or family == "Abisario" then type = "VOIDWALKER"
    elseif family == "Succubus" or family == "Súcubo" then type = "SUCCUBUS"
    elseif family == "Felhunter" or family == "Manáfago" then type = "FELHUNTER"
    elseif family == "Felguard" or family == "Guardia Apocalíptico" then type = "FELGUARD"
    end
    
    local list = self.Speeches[type] and self.Speeches[type][trigger] or self.Speeches["DEFAULT"][trigger]
    
    if list then
        local msg = list[math.random(#list)]
        SendChatMessage(msg, "SAY")
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
        icon = "Interface\\Icons\\Ability_Hunter_BeastCall",
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
                key = "enableSpeech",
                type = "checkbox",
                label = "Charla de Mascota",
                tooltip = "La mascota dice frases aleatorias en combate",
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
