--[[
    Sequito - PlayerNotes Module
    Sistema de notas de jugadores
    Version: 7.3.0
]]

local addonName, S = ...
S.PlayerNotes = {}
local PN = S.PlayerNotes

SequitoPlayerNotesDB = SequitoPlayerNotesDB or {}

-- Helper para obtener configuración
function PN:GetOption(key)
    if S.ModuleConfig then
        return S.ModuleConfig:GetValue("PlayerNotes", key)
    end
    return true
end

function PN:Initialize()
    if not self:GetOption("enabled") then
        return
    end
    
    self.frame = self:CreateFrame()
    self:RegisterEvents()
end

function PN:CreateFrame()
    local f = CreateFrame("Frame", "SequitoPlayerNotesFrame", UIParent)
    f:SetSize(350, 250)
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
    f.title:SetText("Notas de Jugador")
    
    f.playerName = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.playerName:SetPoint("TOPLEFT", 15, -40)
    
    f.editBox = CreateFrame("EditBox", nil, f)
    f.editBox:SetSize(320, 120)
    f.editBox:SetPoint("TOP", 0, -70)
    f.editBox:SetMultiLine(true)
    f.editBox:SetAutoFocus(false)
    f.editBox:SetFontObject(GameFontNormal)
    f.editBox:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8})
    f.editBox:SetBackdropColor(0, 0, 0, 0.5)
    
    f.saveBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.saveBtn:SetSize(80, 25)
    f.saveBtn:SetPoint("BOTTOMLEFT", 15, 10)
    f.saveBtn:SetText("Guardar")
    f.saveBtn:SetScript("OnClick", function() PN:SaveNote() end)
    
    f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.close:SetPoint("TOPRIGHT", -5, -5)
    
    return f
end

function PN:RegisterEvents()
    local events = CreateFrame("Frame")
    events:RegisterEvent("PLAYER_TARGET_CHANGED")
    events:SetScript("OnEvent", function() PN:OnTargetChanged() end)
end

function PN:SetNote(playerName, note)
    SequitoPlayerNotesDB[playerName] = note
    S:Print("Nota guardada para " .. playerName)
end

function PN:GetNote(playerName)
    return SequitoPlayerNotesDB[playerName]
end

function PN:ShowNote(playerName)
    self.currentPlayer = playerName
    self.frame.playerName:SetText(playerName)
    self.frame.editBox:SetText(self:GetNote(playerName) or "")
    self.frame:Show()
end

function PN:SaveNote()
    if self.currentPlayer then
        local noteText = self.frame.editBox:GetText()
        self:SetNote(self.currentPlayer, noteText)
        
        -- Auto-save si está habilitado
        if self:GetOption("autoSave") then
            -- Ya se guarda automáticamente en SetNote
        end
    end
end

function PN:OnTargetChanged()
    if UnitIsPlayer("target") then
        local name = UnitName("target")
        local note = self:GetNote(name)
        if note and note ~= "" then
            S:Print(name .. ": " .. note)
        end
    end
end

function PN:Toggle()
    if not self.frame then return end
    if self.frame:IsShown() then self.frame:Hide() else self.frame:Show() end
end

function PN:SlashCommand(msg)
    local cmd, rest = strsplit(" ", msg, 2)
    if cmd and rest then
        local name, note = strsplit(" ", rest, 2)
        if name and note then
            self:SetNote(name, note)
        elseif name then
            self:ShowNote(name)
        end
    else
        if UnitIsPlayer("target") then
            self:ShowNote(UnitName("target"))
        else
            self:Toggle()
        end
    end
end

-- Registrar configuración en ModuleConfig
if S.ModuleConfig then
    S.ModuleConfig:RegisterModule("PlayerNotes", {
        name = "Player Notes",
        icon = "Interface\\Icons\\INV_Misc_Note_01",
        description = "Sistema de notas personales sobre jugadores",
        category = "utility",
        options = {
            {
                type = "checkbox",
                key = "enabled",
                label = "Habilitar Player Notes",
                tooltip = "Activa/desactiva el sistema de notas",
                default = true,
            },
            {
                type = "checkbox",
                key = "shareWithGuild",
                label = "Compartir con Guild",
                tooltip = "Permite compartir notas con miembros de la guild",
                default = false,
            },
            {
                type = "checkbox",
                key = "showInTooltip",
                label = "Mostrar en Tooltip",
                tooltip = "Muestra las notas en el tooltip del jugador",
                default = true,
            },
            {
                type = "checkbox",
                key = "autoSave",
                label = "Guardado Automático",
                tooltip = "Guarda las notas automáticamente al cerrar",
                default = true,
            },
        },
    })
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function() PN:Initialize() end)
