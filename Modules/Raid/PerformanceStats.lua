--[[
    Sequito - PerformanceStats Module
    Estadísticas de Rendimiento
    Version: 7.3.0
]]

local addonName, S = ...
S.PerformanceStats = {}
local PS = S.PerformanceStats

SequitoStatsDB = SequitoStatsDB or {}

local currentCombat = nil

-- Helper para obtener configuración
function PS:GetOption(key)
    if S.ModuleConfig then
        return S.ModuleConfig:GetValue("PerformanceStats", key)
    end
    return true
end

function PS:Initialize()
    if not self:GetOption("enabled") then
        return
    end
    
    self.frame = self:CreateFrame()
    self:RegisterEvents()
end

function PS:CreateFrame()
    local f = CreateFrame("Frame", "SequitoPerformanceStatsFrame", UIParent)
    f:SetSize(400, 350)
    f:SetPoint("CENTER")
    f:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4}})
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()
    
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("TOP", 0, -10)
    f.title:SetText("Estadísticas de Rendimiento")
    
    f.scroll = CreateFrame("ScrollFrame", "SequitoPSStatsScroll", f, "UIPanelScrollFrameTemplate")
    f.scroll:SetPoint("TOPLEFT", 10, -40)
    f.scroll:SetPoint("BOTTOMRIGHT", -30, 40)
    
    f.content = CreateFrame("Frame", nil, f.scroll)
    f.content:SetSize(360, 500)
    f.scroll:SetScrollChild(f.content)
    
    f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.close:SetPoint("TOPRIGHT", -5, -5)
    
    return f
end

function PS:RegisterEvents()
    local events = CreateFrame("Frame")
    events:RegisterEvent("PLAYER_REGEN_DISABLED")
    events:RegisterEvent("PLAYER_REGEN_ENABLED")
    events:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    events:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_REGEN_DISABLED" then
            PS:StartCombat()
        elseif event == "PLAYER_REGEN_ENABLED" then
            PS:EndCombat()
        elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
            PS:ProcessCombatLog(...)
        end
    end)
end

function PS:StartCombat()
    -- Verificar si tracking está habilitado
    if not self:GetOption("autoTrack") then
        return
    end
    
    currentCombat = {
        startTime = GetTime(),
        damage = 0,
        healing = 0,
        target = UnitName("target") or "Unknown"
    }
end

function PS:EndCombat()
    if currentCombat then
        local duration = GetTime() - currentCombat.startTime
        if duration > 5 then
            local dps = currentCombat.damage / duration
            local hps = currentCombat.healing / duration
            
            local record = {
                target = currentCombat.target,
                duration = duration,
                dps = dps,
                hps = hps,
                date = date("%Y-%m-%d %H:%M")
            }
            
            table.insert(SequitoStatsDB, record)
            if #SequitoStatsDB > 100 then table.remove(SequitoStatsDB, 1) end
        end
        currentCombat = nil
    end
end

function PS:ProcessCombatLog(...)
    if not currentCombat then return end
    local _, event, _, sourceGUID, _, _, _, destGUID, destName = ...
    local playerGUID = UnitGUID("player")
    
    if sourceGUID == playerGUID then
        if currentCombat.target == "Unknown" and destName and destName ~= UnitName("player") then
            currentCombat.target = destName
        end
        
        if event == "SWING_DAMAGE" then
            local amount = select(9, ...) or 0
            currentCombat.damage = currentCombat.damage + (tonumber(amount) or 0)
        elseif event == "SPELL_DAMAGE" or event == "SPELL_PERIODIC_DAMAGE" or event == "RANGE_DAMAGE" then
            local amount = select(12, ...) or 0
            currentCombat.damage = currentCombat.damage + (tonumber(amount) or 0)
        elseif event == "SPELL_HEAL" or event == "SPELL_PERIODIC_HEAL" then
            local amount = select(12, ...) or 0
            local overheal = select(13, ...) or 0
            local effectiveHeal = math.max(0, (tonumber(amount) or 0) - (tonumber(overheal) or 0))
            currentCombat.healing = currentCombat.healing + effectiveHeal
        end
    end
end

function PS:ClearStats()
    wipe(SequitoStatsDB)
    if self.statLines then
        for _, fs in ipairs(self.statLines) do
            fs:Hide()
        end
    end
    if S.Print then
        S:Print("Estadísticas de rendimiento reiniciadas.")
    end
end

function PS:CompareRaids()
    if S.Print then
        S:Print("Comparación de combate: registros totales guardados = " .. #SequitoStatsDB)
    end
    self:ShowStats()
end

function PS:ShowStats()
    if not self.frame then return end
    self.statLines = self.statLines or {}
    for _, fs in ipairs(self.statLines) do
        fs:Hide()
    end
    
    local yOffset = 0
    local lineIdx = 1
    for i = #SequitoStatsDB, math.max(1, #SequitoStatsDB - 20), -1 do
        local record = SequitoStatsDB[i]
        local text = self.statLines[lineIdx]
        if not text then
            text = self.frame.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            self.statLines[lineIdx] = text
        end
        text:ClearAllPoints()
        text:SetPoint("TOPLEFT", 5, -yOffset)
        text:SetText(string.format("%s - %s: %.1f DPS, %.1f HPS (%.0fs)", 
            record.date or "-", record.target or "Unknown", record.dps or 0, record.hps or 0, record.duration or 0))
        text:Show()
        yOffset = yOffset + 15
        lineIdx = lineIdx + 1
    end
    self.frame:Show()
end

function PS:Toggle()
    if not self.frame then return end
    if self.frame:IsShown() then self.frame:Hide() else self:ShowStats() end
end

function PS:SlashCommand(msg)
    self:Toggle()
end

-- Registrar módulo en ModuleConfig
if S.ModuleConfig then
    S.ModuleConfig:RegisterModule({
        id = "PerformanceStats",
        name = "Estadísticas de Rendimiento",
        description = "Trackeo de DPS/HPS y estadísticas de combate",
        category = "utility",
        icon = "Interface\\Icons\\INV_Misc_PocketWatch_01",
        options = {
            {
                key = "enabled",
                type = "checkbox",
                name = "Habilitar Stats",
                description = "Habilitar/deshabilitar tracking de estadísticas",
                default = true
            },
            {
                key = "autoTrack",
                type = "checkbox",
                name = "Auto-Track",
                description = "Trackear automáticamente en combate",
                default = true
            },
            {
                key = "showInTooltip",
                type = "checkbox",
                name = "Mostrar en Tooltip",
                description = "Mostrar estadísticas en tooltip de jugadores",
                default = false
            },
            {
                key = "trackBosses",
                type = "checkbox",
                name = "Solo Bosses",
                description = "Trackear solo combates contra bosses",
                default = true
            },
            {
                key = "maxRecords",
                type = "slider",
                name = "Máximo de Registros",
                description = "Número máximo de registros a guardar",
                min = 10,
                max = 100,
                step = 10,
                default = 50
            }
        }
    })
end
