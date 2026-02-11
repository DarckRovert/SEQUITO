--[[
    Sequito - AlertHub.lua
    Sistema Centralizado de Alertas (Visual & Audio)
    Version: 10.2.0
]]

local addonName, S = ...
S.AlertHub = {}
local AH = S.AlertHub

AH.Frame = nil
AH.Queue = {}

-- Tipos de Alerta
AH.Types = {
    INFO = {color = {1, 1, 0}, sound = nil, duration = 3},
    WARNING = {color = {1, 0.5, 0}, sound = "RaidWarning", duration = 4},
    CRITICAL = {color = {1, 0, 0}, sound = "RaidWarning", duration = 5, flash = true},
    SUCCESS = {color = {0, 1, 0}, sound = "ReadyCheck", duration = 3},
}

function AH:Initialize()
    self:CreateFrame()
    -- Hook simple print if needed, or expose API
end

function AH:CreateFrame()
    if self.Frame then return end
    
    local f = CreateFrame("Frame", "SequitoAlertFrame", UIParent)
    f:SetSize(400, 100)
    f:SetPoint("TOP", UIParent, "TOP", 0, -200)
    -- f:SetFrameStrata("FULLSCREEN_DIALOG") -- Muy alto
    
    -- Texto Principal
    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    f.text:SetPoint("CENTER", f, "CENTER", 0, 0)
    f.text:SetShadowOffset(2, -2)
    
    -- Icono
    f.icon = f:CreateTexture(nil, "OVERLAY")
    f.icon:SetSize(48, 48)
    f.icon:SetPoint("RIGHT", f.text, "LEFT", -10, 0)
    
    -- Animaciones
    f.ag = f:CreateAnimationGroup()
    local fadeIn = f.ag:CreateAnimation("Alpha")
    fadeIn:SetChange(1)
    fadeIn:SetDuration(0.2)
    fadeIn:SetOrder(1)
    
    local hold = f.ag:CreateAnimation("Alpha")
    hold:SetChange(0)
    hold:SetDuration(3) -- Dynamic
    hold:SetOrder(2)
    
    local fadeOut = f.ag:CreateAnimation("Alpha")
    fadeOut:SetChange(-1)
    fadeOut:SetDuration(0.5)
    fadeOut:SetOrder(3)
    
    f.ag:SetScript("OnFinished", function() f:Hide() end)
    
    self.Frame = f
    
    -- Movilidad
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        if S.SmartDefaults then
            S.SmartDefaults:SavePosition("AlertHub", self)
        end
    end)
    
    -- Restaurar posición
    if S.SmartDefaults then
        if S.SmartDefaults:RestorePosition("AlertHub") then
            -- Posición restaurada
        else
            f:SetPoint("TOP", UIParent, "TOP", 0, -200)
        end
    else
        f:SetPoint("TOP", UIParent, "TOP", 0, -200)
    end
    
    f:Hide()
end

function AH:Show(msg, type, icon, colorOverride)
    if not self.Frame then self:Initialize() end
    
    local config = self.Types[type] or self.Types.INFO
    
    -- Visual
    self.Frame.text:SetText(msg)
    
    if colorOverride then
        self.Frame.text:SetTextColor(unpack(colorOverride))
    else
        self.Frame.text:SetTextColor(unpack(config.color))
    end
    
    if icon then
        self.Frame.icon:SetTexture(icon)
        self.Frame.icon:Show()
    else
        self.Frame.icon:Hide()
    end
    
    self.Frame:Show()
    self.Frame:SetAlpha(1)
    
    -- Audio
    if config.sound then
        PlaySound(config.sound)
    end
    
    -- Screen Flash (para CRITICAL)
    if config.flash then
        self:FlashScreen()
    end
    
    -- Reiniciar animacion
    self.Frame.ag:Stop()
    -- Ajustar duracion hold
    self.Frame.ag:GetAnimations()[2]:SetDuration(config.duration)
    self.Frame.ag:Play()
end

function AH:FlashScreen()
    if not self.FlashFrame then
        self.FlashFrame = CreateFrame("Frame", "SequitoFlash", UIParent)
        self.FlashFrame:SetFrameStrata("BACKGROUND")
        self.FlashFrame:SetAllPoints()
        self.FlashFrame.t = self.FlashFrame:CreateTexture(nil, "BACKGROUND")
        self.FlashFrame.t:SetAllPoints()
        self.FlashFrame.t:SetTexture(1, 0, 0, 0.3)
        self.FlashFrame:Hide()
        
        self.FlashAG = self.FlashFrame:CreateAnimationGroup()
        local a = self.FlashAG:CreateAnimation("Alpha")
        a:SetChange(-1)
        a:SetDuration(0.8)
        a:SetOrder(1)
        self.FlashAG:SetScript("OnFinished", function() self.FlashFrame:Hide() end)
    end
    
    self.FlashFrame:Show()
    self.FlashFrame:SetAlpha(1)
    self.FlashAG:Play()
end

-- Init
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function() AH:Initialize() end)
