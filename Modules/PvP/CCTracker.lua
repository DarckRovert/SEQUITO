--[[
    SEQUITO - CC Tracker
    Rastreo de Banish, Enslave, Fear, Polymorph.
]]--

local addonName, S = ...
S.CCTracker = {}
local CC = S.CCTracker

CC.TrackedSpells = {
    -- Warlock
    ["Enslave Demon"] = 300,
    ["Esclavizar demonio"] = 300,
    ["Banish"] = 30,
    ["Desterrar"] = 30,
    ["Fear"] = 20,
    ["Miedo"] = 20,
    ["Seduction"] = 15,
    ["Seducción"] = 15,
    -- Mage
    ["Polymorph"] = 50,
    ["Polimorfia"] = 50,
    -- Priest
    ["Shackle Undead"] = 50,
    ["Encadenar no-muerto"] = 50,
    -- Hunter
    ["Freezing Trap"] = 60, -- Debuff name usually "Freezing Trap Effect"
    ["Trampa congelante"] = 60,
    -- Druid
    ["Hibernate"] = 40,
    ["Hibernar"] = 40,
    ["Roots"] = 30,
    ["Raíces"] = 30,
}

-- Helper para obtener configuración
function CC:GetOption(key)
    if S.ModuleConfig then
        return S.ModuleConfig:GetValue("CCTracker", key)
    end
    return true
end

function CC:Initialize()
    if not self:GetOption("enabled") then
        return
    end
    
    self.Bars = {}
    self:CreateAnchor()
    self:RegisterEvents()
end

function CC:CreateAnchor()
    local f = CreateFrame("Frame", "SequitoCCAnchor", UIParent)
    f:SetSize(200, 20)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self) if not S.db.profile.Locked then self:StartMoving() end end)
    f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    
    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.text:SetPoint("CENTER")
    f.text:SetText("Sequito CC Tracker")
    f.text:SetAlpha(0) -- Hidden by default unless configuring
    
    self.Anchor = f
end

function CC:RegisterEvents()
    local f = CreateFrame("Frame")
    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    f:SetScript("OnEvent", function(self, event, ...)
        CC:OnCombatLog(...)
    end)
    
    f:SetScript("OnUpdate", function(self, elapsed)
        CC:OnUpdate(elapsed)
    end)
end

function CC:OnCombatLog(...)
    local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, 
          sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, 
          spellID, spellName = ...
          
    if sourceGUID ~= UnitGUID("player") and sourceGUID ~= UnitGUID("pet") then return end
    
    -- Check spell name variations (Rank X exclusion)
    -- In 3.3.5a spellName usually comes clean
    
    if eventType == "SPELL_AURA_APPLIED" or eventType == "SPELL_AURA_REFRESH" then
        if self:IsTracked(spellName) then
            local duration = self:GetDuration(spellName)
            self:StartTimer(destGUID, destName, spellName, duration, spellID)
        end
    elseif eventType == "SPELL_AURA_REMOVED" then
        if self:IsTracked(spellName) then
            self:StopTimer(destGUID, spellName, true)
        end
    end
end

function CC:IsTracked(name)
    return self.TrackedSpells[name] ~= nil
end

function CC:GetDuration(name)
    return self.TrackedSpells[name] or 20
end

function CC:StartTimer(guid, targetName, spellName, duration, spellID)
    -- Verificar si mostrar barras está habilitado
    if not self:GetOption("showBars") then
        return
    end
    
    local id = guid .. spellName
    
    local bar = self:GetBar(id)
    bar.duration = duration
    bar.endTime = GetTime() + duration
    bar.spellName = spellName
    bar.targetName = targetName
    bar.active = true
    
    local _, _, icon = GetSpellInfo(spellID)
    bar.icon:SetTexture(icon)
    bar.label:SetText(targetName .. " (" .. spellName .. ")")
    
    -- Sonido si está habilitado
    if self:GetOption("playSound") then
        PlaySound("igPVPUpdate")
    end
    
    bar:Show()
    self:LayoutBars()
end

function CC:StopTimer(guid, spellName, alert)
    local id = guid .. spellName
    if self.Bars[id] and self.Bars[id].active then
        local bar = self.Bars[id]
        
        -- Check remaining time. If > 3s, it was broken early -> ALERT
        local remaining = bar.endTime - GetTime()
        if alert and remaining > 3 then
            self:BreakAlert(bar.targetName, bar.spellName)
        end
        
        bar.active = false
        bar:Hide()
        self:LayoutBars()
    end
end

function CC:BreakAlert(target, spell)
    -- Anunciar si está habilitado
    if not self:GetOption("announceBreak") then
        return
    end
    
    -- Sound si está habilitado
    if self:GetOption("playSound") then
        PlaySound("RaidWarning")
    end
    
    print(string.format("|cFFFF0000[Sequito] ¡SE ROMPIÓ %s en %s!|r", string.upper(spell), target))
    
    if RaidWarningFrame then
        RaidNotice_AddMessage(RaidWarningFrame, "¡" .. string.upper(spell) .. " ROTO: " .. target .. "!", {r=1, g=0, b=0})
    end
end

function CC:GetBar(id)
    if self.Bars[id] then return self.Bars[id] end
    
    local barHeight = self:GetOption("barHeight") or 20
    local bar = CreateFrame("StatusBar", nil, UIParent)
    bar:SetSize(200, barHeight)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bar:SetStatusBarColor(1, 0.5, 0) -- Orange
    
    bar.bg = bar:CreateTexture(nil, "BACKGROUND")
    bar.bg:SetAllPoints()
    bar.bg:SetTexture(0, 0, 0, 0.5)
    
    bar.icon = bar:CreateTexture(nil, "OVERLAY")
    bar.icon:SetSize(20, 20)
    bar.icon:SetPoint("LEFT", -22, 0)
    
    bar.label = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bar.label:SetPoint("LEFT", 5, 0)
    
    bar.time = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bar.time:SetPoint("RIGHT", -5, 0)
    
    self.Bars[id] = bar
    return bar
end

function CC:LayoutBars()
    local index = 0
    for id, bar in pairs(self.Bars) do
        if bar.active then
            bar:ClearAllPoints()
            bar:SetPoint("TOP", self.Anchor, "BOTTOM", 0, -index * 25)
            index = index + 1
        end
    end
end

function CC:OnUpdate(elapsed)
    local now = GetTime()
    for id, bar in pairs(self.Bars) do
        if bar.active then
            local remaining = bar.endTime - now
            if remaining <= 0 then
                bar.active = false
                bar:Hide()
                self:LayoutBars()
            else
                bar:SetValue(remaining / bar.duration)
                bar.time:SetText(string.format("%.1f", remaining))
                
                if remaining < 5 then
                    bar:SetStatusBarColor(1, 0, 0)
                else
                    bar:SetStatusBarColor(1, 0.5, 0)
                end
            end
        end
    end
end

-- Registrar módulo en ModuleConfig
if S.ModuleConfig then
    S.ModuleConfig:RegisterModule({
        id = "CCTracker",
        name = "Rastreador de CC",
        description = "Rastrea duración de control de masas (Polymorph, Banish, Fear, etc.) con barras visuales.",
        category = "pvp",
        icon = "Interface\\\\Icons\\\\Spell_Frost_FreezingBreath",
        options = {
            {key = "enabled", type = "checkbox", name = "Habilitar CC Tracker", description = "Rastrear duración de hechizos de control", default = true},
            {key = "showBars", type = "checkbox", name = "Mostrar Barras", description = "Mostrar barras de duración de CC", default = true},
            {key = "playSound", type = "checkbox", name = "Sonido de Alerta", description = "Reproducir sonido cuando un CC está por terminar", default = true},
            {key = "announceBreak", type = "checkbox", name = "Anunciar CC Roto", description = "Anunciar en chat cuando se rompe un CC prematuramente", default = false},
            {key = "warningTime", type = "slider", name = "Tiempo de Advertencia", description = "Segundos antes del fin del CC para alertar", min = 1, max = 10, step = 1, default = 5},
            {key = "barHeight", type = "slider", name = "Altura de Barras", description = "Altura de las barras de CC", min = 16, max = 32, step = 2, default = 20}
        }
    })
end
