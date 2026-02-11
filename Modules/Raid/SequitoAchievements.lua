--[[
    SEQUITO - Achievements & Gamification
    Sistema de logros internos para gamificar la experiencia de guild.
    Parte del sistema "Economy & Gamification" (v9.0)
]]

local addonName, S = ...
S.Achievements = {}
local SA = S.Achievements

-- ===========================================================================
-- BASE DE DATOS DE LOGROS
-- ===========================================================================
SA.AchievementList = {
    [1] = { id = 1, title = S.L["ACH_INITIATE"] or "Iniciado", desc = S.L["ACH_INITIATE_DESC"], icon = "Interface\\Icons\\Inv_Misc_Book_09", points = 10 },
    [2] = { id = 2, title = S.L["ACH_MACRO_MASTER"] or "Maestro Macros", desc = S.L["ACH_MACRO_MASTER_DESC"], icon = "Interface\\Icons\\Spell_Holy_Dizzy", points = 10 },
    [3] = { id = 3, title = S.L["ACH_WIPE_SAVIOR"] or "Salvador", desc = S.L["ACH_WIPE_SAVIOR_DESC"], icon = "Interface\\Icons\\Spell_Holy_DivineHymn", points = 20 },
    [4] = { id = 4, title = "Alpha Striker", desc = "Estar presente durante una orden de Alpha Strike", icon = "Interface\\Icons\\Ability_Warrior_SavageBlow", points = 15 },
    [5] = { id = 5, title = S.L["ACH_CANNON_FODDER"] or "Carne Cañón", desc = S.L["ACH_CANNON_FODDER_DESC"], icon = "Interface\\Icons\\Ability_Creature_Cursed_03", points = 5 },
}

-- ===========================================================================
-- INICIALIZACIÓN
-- ===========================================================================
function SA:Initialize()
    -- DB Check
    if not SequitoStatsDB then SequitoStatsDB = {} end
    if not SequitoStatsDB.Achievements then SequitoStatsDB.Achievements = {} end
    
    self.db = SequitoStatsDB.Achievements
    self:CreateToastFrame()
    self:RegisterEvents()
    
    -- Check "First Login" Achievement
    self:Unlock(1)
    
    print("|cFFFF00FFSequito|r: [Gamification] Sistema de logros iniciado.")
end

-- ===========================================================================
-- LOGICA DE DESBLOQUEO
-- ===========================================================================
function SA:Unlock(id)
    if self.db[id] then return end -- Ya desbloqueado
    
    local ach = self.AchievementList[id]
    if not ach then return end
    
    -- Marcar como completado
    self.db[id] = { date = date("%d/%m/%y"), timestamp = time() }
    
    -- Show Toast
    self:ShowToast(ach)
    
    -- Play Sound
    PlaySound("LFG_RoleCheck") 
end

-- ===========================================================================
-- EVENT TRACKING
-- ===========================================================================
function SA:RegisterEvents()
    local f = CreateFrame("Frame")
    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    f:RegisterEvent("PLAYER_DEAD")
    
    f:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_DEAD" then
             -- Logic for "Carne de Cañón" (simplified: just dying for now)
             -- Real implementation needs to check if it's a boss fight and if first death
             SA:Unlock(5)
        end
    end)
    
    -- Hook Macro Generator
    hooksecurefunc(S.MacroGen, "GenerateClassMacros", function()
        SA:Unlock(2)
    end)
end

-- ===========================================================================
-- UI: TOAST NOTIFICATION (Estilo Blizzard pero personalizado)
-- ===========================================================================
function SA:CreateToastFrame()
    local f = CreateFrame("Frame", "SequitoToastFrame", UIParent)
    f:SetSize(300, 64)
    f:SetPoint("BOTTOM", 0, 180)
    f:SetFrameStrata("DIALOG")
    f:Hide()
    
    -- Background
    f.bg = f:CreateTexture(nil, "BACKGROUND")
    f.bg:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Background")
    f.bg:SetTexCoord(0, 0.605, 0, 0.703)
    f.bg:SetAllPoints(f)
    
    -- Icon
    f.icon = f:CreateTexture(nil, "ARTWORK")
    f.icon:SetSize(50, 50)
    f.icon:SetPoint("LEFT", 8, 0)
    
    -- Titles
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.title:SetPoint("TOPLEFT", 65, -15)
    f.title:SetText(S.L["ACHIEVEMENT_UNLOCKED"] or "Logro Desbloqueado")
    
    f.name = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.name:SetPoint("BOTTOMLEFT", 65, 15)
    f.name:SetWidth(220)
    f.name:SetJustifyH("LEFT")
    
    f.points = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.points:SetPoint("BOTTOMRIGHT", -15, 15)
    
    -- Animation
    f.anim = f:CreateAnimationGroup()
    local a1 = f.anim:CreateAnimation("Alpha")
    a1:SetChange(1)
    a1:SetDuration(0.5)
    a1:SetOrder(1)
    local a2 = f.anim:CreateAnimation("Alpha")
    a2:SetChange(-1)
    a2:SetStartDelay(4)
    a2:SetDuration(1.0)
    a2:SetOrder(2)
    
    f.anim:SetScript("OnFinished", function() f:Hide() end)
    
    self.toast = f
end

function SA:ShowToast(ach)
    local f = self.toast
    f:Show()
    f:SetAlpha(0)
    
    f.icon:SetTexture(ach.icon)
    f.name:SetText(ach.title)
    f.points:SetText(ach.points)
    
    f.anim:Stop()
    f.anim:Play()
    
    print(string.format("|cFFFFD700[Sequito] ¡Logro Desbloqueado! %s (%d pts)|r", ach.title, ach.points))
end

-- Registrar en ModuleConfig
if S.ModuleConfig then
    S.ModuleConfig:RegisterModule("SequitoAchievements", {
        name = "Achievements",
        description = "Logros de Guild y Gamificación",
        category = "general",
        icon = "Interface\\Icons\\Inv_Misc_Wreath_01",
        options = {}
    })
end
