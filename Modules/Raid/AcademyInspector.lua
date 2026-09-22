--[[
    SEQUITO - Academy Inspector
    Módulo de auditoría de jugadores (Talentos, Glifos, GearScore simplificado)
    Parte del sistema "Academy Mode" (v9.0)
]]

local addonName, S = ...
S.AcademyInspector = {}
local AI = S.AcademyInspector

-- Slash Command Handler
SLASH_SEQUITOINSPECT1 = "/sinspect"
SLASH_SEQUITOINSPECT2 = "/seqinspect"
SlashCmdList["SEQUITOINSPECT"] = function(msg)
    AI:InspectUnit("target")
end

-- ===========================================================================
-- CONFIGURACIÓN
-- ===========================================================================
function AI:Initialize()
    self.frame = self:CreateInspectorFrame()
    print("|cFFFF00FFSequito|r: [Academy] Inspector de Academia iniciado.")
end

-- ===========================================================================
-- LÓGICA DE INSPECCIÓN
-- ===========================================================================
function AI:InspectUnit(unit)
    if not UnitExists(unit) or not UnitIsPlayer(unit) then return end
    
    -- Request Inspection
    NotifyInspect(unit)
    
    self.currentUnit = unit
    self.currentName = UnitName(unit)
    
    -- Wait a bit for server response (simple delay for WotLK 3.3.5)
    C_Timer.After(1, function()
        AI:ProcessInspection()
    end)
end

function AI:ProcessInspection()
    if not self.currentUnit then return end
    
    local unit = self.currentUnit
    
    -- 1. TALENTOS
    -- En 3.3.5 GetActiveTalentGroup, GetTalentTabInfo
    local activeGroup = GetActiveTalentGroup(true, true) -- inspect=true
    local t1 = 0
    local t2 = 0
    local t3 = 0
    
    -- Intentar leer tabs (a veces falla si no está en rango)
    -- Simplificación: Asumimos que podemos leer si está cerca
    for i=1, 3 do
        local _, _, points = GetTalentTabInfo(i, true, nil, activeGroup)
        if i == 1 then t1 = points or 0 end
        if i == 2 then t2 = points or 0 end
        if i == 3 then t3 = points or 0 end
    end
    
    local talentString = string.format("%d/%d/%d", t1, t2, t3)
    
    -- 2. GLIFOS (Más complejo en 3.3.5 remote, omitido por simplicidad inicial)
    local glyphString = "N/A" 
    
    -- 3. GEAR SUMMARY (Item Level promedio muy basico)
    local totalILvl = 0
    local itemCount = 0
    
    for i=1, 18 do
        if i ~= 4 then -- Skip shirt
            local link = GetInventoryItemLink(unit, i)
            if link then
                local _, _, _, ilvl = GetItemInfo(link)
                if ilvl then
                    totalILvl = totalILvl + ilvl
                    itemCount = itemCount + 1
                end
            end
        end
    end
    
    local avgILvl = 0
    if itemCount > 0 then avgILvl = totalILvl / itemCount end
    
    -- UPDATE UI
    self:UpdateUI(self.currentName, talentString, math.floor(avgILvl))
end

-- ===========================================================================
-- INTERFAZ (UI)
-- ===========================================================================
function AI:CreateInspectorFrame()
    local f = CreateFrame("Frame", "SequitoInspectorFrame", UIParent)
    f:SetSize(300, 200)
    f:SetPoint("CENTER")
    f:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4}})
    f:Hide()
    
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("TOP", 0, -15)
    f.title:SetText(S.L["ACADEMY_INSPECTOR"] or "Academy Inspector")
    
    f.nameText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    f.nameText:SetPoint("TOP", 0, -40)
    f.nameText:SetText("-")
    
    f.talentsText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.talentsText:SetPoint("LEFT", 20, 20)
    f.talentsText:SetText((S.L["TALENTS"] or "Talentos:") .. " -")
    
    f.ilvlText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.ilvlText:SetPoint("LEFT", 20, -10)
    f.ilvlText:SetText((S.L["ILVL_APPROX"] or "iLvl:") .. " -")
    
    f.close = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.close:SetSize(80, 25)
    f.close:SetPoint("BOTTOM", 0, 15)
    f.close:SetText("Cerrar")
    f.close:SetScript("OnClick", function() f:Hide() end)
    
    return f
end

function AI:UpdateUI(name, talents, ilvl)
    if not self.frame then return end
    
    self.frame.nameText:SetText(name)
    self.frame.talentsText:SetText("Talentos: " .. talents)
    self.frame.ilvlText:SetText("iLvl (Aprox): " .. ilvl)
    
    self.frame:Show()
end

-- Registrar en ModuleConfig
if S.ModuleConfig then
    S.ModuleConfig:RegisterModule("AcademyInspector", {
        name = "Academy Inspector",
        description = "Herramienta de auditoría para oficiales (Talentos/Gear)",
        category = "general", -- O 'raid'
        icon = "Interface\\Icons\\Inv_Misc_Spyglass_02",
        options = {}
    })
end
