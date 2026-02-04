--[[
    Sequito - LootCouncil Module
    Sistema de Loot Council rápido para grupos de guild
    Version: 8.0.0
]]

local addonName, S = ...
local L = S.L or {}
S.LootCouncil = {}
local LC = S.LootCouncil
local L = S.L or {}

-- Variables locales
local currentSession = nil
local votes = {}
local candidates = {}
local councilMembers = {}

-- Clases y specs que pueden usar cada tipo de item
local CLASS_ARMOR = {
    PLATE = {"WARRIOR", "PALADIN", "DEATHKNIGHT"},
    MAIL = {"HUNTER", "SHAMAN"},
    LEATHER = {"ROGUE", "DRUID"},
    CLOTH = {"MAGE", "WARLOCK", "PRIEST"}
}

-- Helper para obtener configuración
function LC:GetOption(key)
    if S.ModuleConfig then
        return S.ModuleConfig:GetValue("LootCouncil", key)
    end
    return true
end

function LC:Initialize()
    if not self:GetOption("enabled") then
        return
    end
    
    self.frame = self:CreateFrame()
    self:RegisterEvents()
    self:RegisterEvents()
    if S.ModuleConfig then
        S.ModuleConfig:RegisterModule("LootCouncil", {
            name = L["LC_TITLE"],
            description = "Loot Council System",
            icon = "Interface\\Icons\\INV_Box_02",
            category = "raid",
            options = {
                {key = "enabled", type = "checkbox", label = L["CFG_ENABLED"], default = true},
                {key = "announceResults", type = "checkbox", label = L["CFG_ANNOUNCE"], default = true},
            }
        })
    end
end

function LC:CreateFrame()
    local f = CreateFrame("Frame", "SequitoLootCouncilFrame", UIParent)
    f:SetSize(400, 300)
    f:SetPoint("CENTER")
    f:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4}})
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()
    
    -- Título
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("TOP", 0, -10)
    f.title:SetText(L["LC_TITLE"])
    
    -- Item display
    f.itemIcon = f:CreateTexture(nil, "ARTWORK")
    f.itemIcon:SetSize(40, 40)
    f.itemIcon:SetPoint("TOPLEFT", 15, -40)
    
    f.itemName = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.itemName:SetPoint("LEFT", f.itemIcon, "RIGHT", 10, 0)
    
    -- Scroll frame para candidatos
    f.scroll = CreateFrame("ScrollFrame", "SequitoLCLootScroll", f, "UIPanelScrollFrameTemplate")
    f.scroll:SetPoint("TOPLEFT", 15, -90)
    f.scroll:SetPoint("BOTTOMRIGHT", -35, 40)
    
    f.content = CreateFrame("Frame", nil, f.scroll)
    f.content:SetSize(350, 200)
    f.scroll:SetScrollChild(f.content)
    
    -- Botón cerrar
    f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.close:SetPoint("TOPRIGHT", -5, -5)
    
    return f
end

function LC:RegisterEvents()
    local events = CreateFrame("Frame")
    events:RegisterEvent("LOOT_OPENED")
    events:RegisterEvent("CHAT_MSG_ADDON")
    events:SetScript("OnEvent", function(_, event, ...)
        if event == "LOOT_OPENED" then
            LC:OnLootOpened()
        elseif event == "CHAT_MSG_ADDON" then
            LC:OnAddonMessage(...)
        end
    end)
    RegisterAddonMessagePrefix("SeqLC")
end

function LC:StartSession(itemLink)
    if not IsRaidLeader() and not IsRaidOfficer() then
        S:Print(L["LC_ONLY_LEADER"])
        return
    end
    
    -- Verificar si auto-open está habilitado
    if not self:GetOption("autoOpen") then
        return
    end
    
    currentSession = {item = itemLink, startTime = GetTime()}
    votes = {}
    candidates = {}
    
    SendAddonMessage("SeqLC", "START:" .. itemLink, "RAID")
    self:UpdateDisplay()
    self.frame:Show()
end

function LC:Vote(playerName, response)
    if not currentSession then return end
    SendAddonMessage("SeqLC", "VOTE:" .. playerName .. ":" .. response, "RAID")
end

function LC:EndSession(winner)
    if currentSession then
        SendAddonMessage("SeqLC", "END:" .. (winner or ""), "RAID")
        
        -- Anunciar resultados si está habilitado
        if self:GetOption("announceResults") and winner and winner ~= "" then
            SendChatMessage("[Sequito] " .. string.format(L["LC_WINNER"], winner, currentSession.item), "RAID")
        end
        
        currentSession = nil
        self.frame:Hide()
    end
end

function LC:UpdateDisplay()
    if not currentSession then return end
    
    local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(currentSession.item)
    self.frame.itemIcon:SetTexture(texture)
    self.frame.itemName:SetText(currentSession.item)
    
    -- Actualizar lista de candidatos
    local yOffset = 0
    for name, data in pairs(candidates) do
        local row = self:GetCandidateRow(name)
        row:SetPoint("TOPLEFT", self.frame.content, "TOPLEFT", 0, -yOffset)
        row.name:SetText(name)
        row.response:SetText(data.response or "Pendiente")
        row.votes:SetText(tostring(data.voteCount or 0))
        row:Show()
        yOffset = yOffset + 25
    end
end

function LC:GetCandidateRow(name)
    if not self.rows then self.rows = {} end
    if not self.rows[name] then
        local row = CreateFrame("Frame", nil, self.frame.content)
        row:SetSize(350, 24)
        row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.name:SetPoint("LEFT", 5, 0)
        row.response = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.response:SetPoint("LEFT", 120, 0)
        row.votes = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.votes:SetPoint("LEFT", 250, 0)
        
        row.voteBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        row.voteBtn:SetSize(50, 20)
        row.voteBtn:SetPoint("RIGHT", -5, 0)
        row.voteBtn:SetText(L["LC_VOTE_BTN"])
        row.voteBtn:SetScript("OnClick", function() LC:Vote(name, "VOTE") end)
        
        self.rows[name] = row
    end
    return self.rows[name]
end

function LC:OnLootOpened()
    -- Solo líderes/oficiales
    if not (IsRaidLeader() or IsRaidOfficer()) then return end
    if not self:GetOption("enabled") then return end
    
    -- Escanear loot
    local numItems = GetNumLootItems()
    if numItems > 0 then
        -- Por ahora solo debug o preparación
        -- En el futuro: Mostrar ventana para iniciar sesión con items del loot
    end
end

function LC:OnAddonMessage(prefix, msg, channel, sender)
    if prefix ~= "SeqLC" then return end
    
    local cmd, data = strsplit(":", msg, 2)
    if cmd == "START" then
        currentSession = {item = data, startTime = GetTime()}
        candidates = {}
        votes = {}
        self:UpdateDisplay()
        self.frame:Show()
    elseif cmd == "NEED" or cmd == "GREED" or cmd == "PASS" then
        candidates[sender] = {response = cmd, voteCount = 0}
        self:UpdateDisplay()
    elseif cmd == "VOTE" then
        local target = data
        if candidates[target] then
            candidates[target].voteCount = (candidates[target].voteCount or 0) + 1
            self:UpdateDisplay()
        end
    elseif cmd == "END" then
        currentSession = nil
        self.frame:Hide()
    end
end

function LC:Toggle()
    if not self.frame then return end
    if self.frame:IsShown() then
        self.frame:Hide()
    else
        self.frame:Show()
    end
end

-- Slash command
function LC:SlashCommand(msg)
    local cmd, arg = strsplit(" ", msg, 2)
    if cmd == "start" and arg then
        self:StartSession(arg)
    elseif cmd == "end" then
        self:EndSession(arg)
    else
        self:Toggle()
    end
end

-- Registrar configuración en ModuleConfig
if S.ModuleConfig then
    S.ModuleConfig:RegisterModule("LootCouncil", {
        name = "Loot Council",
        icon = "Interface\\Icons\\INV_Misc_Coin_01",
        description = "Sistema de votación para distribución de loot en raids",
        category = "raid",
        options = {
            {
                type = "checkbox",
                key = "enabled",
                label = "Habilitar Loot Council",
                tooltip = "Activa/desactiva el sistema de loot council",
                default = true,
            },
            {
                type = "checkbox",
                key = "autoOpen",
                label = "Abrir Automáticamente",
                tooltip = "Abre la ventana automáticamente cuando hay loot para votar",
                default = true,
            },
            {
                type = "checkbox",
                key = "showOnlyUsable",
                label = "Solo Items Usables",
                tooltip = "Muestra solo items que tu clase puede usar",
                default = false,
            },
            {
                type = "checkbox",
                key = "announceResults",
                label = "Anunciar Resultados",
                tooltip = "Anuncia los resultados de la votación al raid",
                default = true,
            },
            {
                type = "slider",
                key = "votingTime",
                label = "Tiempo de Votación (seg)",
                tooltip = "Tiempo límite para votar",
                min = 30,
                max = 300,
                step = 15,
                default = 60,
            },
        },
    })
end

-- Inicializar
if S.RegisterModule then
    S.RegisterModule("LootCouncil", LC)
else
    local loader = CreateFrame("Frame")
    loader:RegisterEvent("PLAYER_LOGIN")
    loader:SetScript("OnEvent", function() LC:Initialize() end)
end
