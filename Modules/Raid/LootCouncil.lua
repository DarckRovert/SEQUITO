--[[
    Sequito - LootCouncil Module
    Sistema de Loot Council rápido para grupos de guild
    Version: 8.0.0
]]

local addonName, S = ...
local L = S.L or {}
S.LootCouncil = {}
local LC = S.LootCouncil

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
    
    -- Botones de respuesta (Need/Greed/Pass)
    f.needBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.needBtn:SetSize(60, 24)
    f.needBtn:SetPoint("BOTTOMLEFT", 15, 10)
    f.needBtn:SetText("Need")
    f.needBtn:SetScript("OnClick", function() LC:Respond("NEED") end)
    
    f.greedBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.greedBtn:SetSize(60, 24)
    f.greedBtn:SetPoint("LEFT", f.needBtn, "RIGHT", 5, 0)
    f.greedBtn:SetText("Greed")
    f.greedBtn:SetScript("OnClick", function() LC:Respond("GREED") end)
    
    f.passBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.passBtn:SetSize(60, 24)
    f.passBtn:SetPoint("LEFT", f.greedBtn, "RIGHT", 5, 0)
    f.passBtn:SetText("Pass")
    f.passBtn:SetScript("OnClick", function() LC:Respond("PASS") end)
    
    return f
end

function LC:Respond(response)
    if not currentSession then return end
    SendAddonMessage("SeqLC", response .. ":" .. currentSession.item, "RAID")
    self.frame.needBtn:Disable()
    self.frame.greedBtn:Disable()
    self.frame.passBtn:Disable()
end

function LC:IsOfficer(name)
    if not name then return false end
    if name == UnitName("player") then
        return IsRaidLeader() or IsRaidOfficer() or (GetNumPartyMembers() > 0 and UnitIsPartyLeader("player"))
    end
    for i = 1, GetNumRaidMembers() do
        local n, rank = GetRaidRosterInfo(i)
        if n == name then
            return rank >= 1
        end
    end
    if GetNumPartyMembers() > 0 and UnitIsPartyLeader(name) then
        return true
    end
    return false
end

function LC:RegisterEvents()
    local events = CreateFrame("Frame")
    events:RegisterEvent("LOOT_OPENED")
    events:RegisterEvent("CHAT_MSG_ADDON")
    events:RegisterEvent("CHAT_MSG_SYSTEM")
    events:SetScript("OnEvent", function(_, event, ...)
        if event == "LOOT_OPENED" then
            LC:OnLootOpened()
        elseif event == "CHAT_MSG_ADDON" then
            LC:OnAddonMessage(...)
        elseif event == "CHAT_MSG_SYSTEM" then
            LC:OnSystemMessage(...)
        end
    end)
    RegisterAddonMessagePrefix("SeqLC")
end

function LC:OnSystemMessage(msg)
    if not currentSession or not msg then return end
    
    -- Interceptar tiradas de dados en esMX, esES y enUS:
    -- es: "Nombre tira los dados (1-100) y obtiene 85"
    -- en: "Name rolls 85 (1-100)"
    local roller, minR, maxR, rollVal = msg:match("([^%s]+)%s+tira los dados%s+%(?(%d+)%-(%d+)%)?%s+y obtiene%s+(%d+)")
    if not roller then
        roller, rollVal, minR, maxR = msg:match("([^%s]+)%s+rolls%s+(%d+)%s+%(?(%d+)%-(%d+)%)?")
    end
    
    if roller and rollVal then
        local rNum = tonumber(rollVal) or 0
        candidates[roller] = candidates[roller] or { response = "Roll: " .. rNum, voteCount = 0 }
        candidates[roller].response = "Roll: " .. rNum
        candidates[roller].roll = rNum
        self:UpdateDisplay()
    end
end

function LC:StartSession(itemLink)
    if not IsRaidLeader() and not IsRaidOfficer() then
        if S.Print then S:Print(L["LC_ONLY_LEADER"]) end
        return
    end
    
    -- Verificar si auto-open está deshabilitado explícitamente
    if self:GetOption("autoOpen") == false then
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
    if not self:IsOfficer(UnitName("player")) then
        if S.Print then S:Print("|cFFFF0000[LootCouncil] Solo oficiales pueden emitir votos.|r") end
        return
    end
    SendAddonMessage("SeqLC", "VOTE:" .. playerName .. ":" .. (response or "VOTE"), "RAID")
end

function LC:EndSession(winner)
    if currentSession then
        SendAddonMessage("SeqLC", "END:" .. (winner or ""), "RAID")
        
        -- Anunciar resultados si está habilitado
        if self:GetOption("announceResults") and winner and winner ~= "" then
            SendChatMessage("[Sequito] " .. string.format(L["LC_WINNER"] or "Ganador de %s: %s", winner, currentSession.item), "RAID")
        end
        
        if S.SendMessage and winner and winner ~= "" then
            S:SendMessage("LOOT_AWARDED", currentSession.item, winner)
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
    
    local isOfficer = self:IsOfficer(UnitName("player"))
    
    -- Actualizar lista de candidatos
    local yOffset = 0
    for name, data in pairs(candidates) do
        local row = self:GetCandidateRow(name)
        row:SetPoint("TOPLEFT", self.frame.content, "TOPLEFT", 0, -yOffset)
        row.name:SetText(name)
        row.response:SetText(data.response or "Pendiente")
        row.votes:SetText(tostring(data.voteCount or 0))
        if isOfficer then
            row.voteBtn:Show()
        else
            row.voteBtn:Hide()
        end
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
        row.voteBtn:SetText(L["LC_VOTE_BTN"] or "Votar")
        row.voteBtn:SetScript("OnClick", function() LC:Vote(name, "VOTE") end)
        
        self.rows[name] = row
    end
    return self.rows[name]
end

function LC:OnLootOpened()
    -- Solo líderes/oficiales
    if not (IsRaidLeader() or IsRaidOfficer()) then return end
    if not self:GetOption("enabled") then return end
    
    -- Escanear loot en busca de piezas épicas o legendarias
    local numItems = GetNumLootItems()
    for slot = 1, numItems do
        if LootSlotIsItem(slot) then
            local link = GetLootSlotLink(slot)
            if link then
                local _, _, quality = GetItemInfo(link)
                if quality and quality >= 4 and not currentSession then
                    -- Iniciar automáticamente sesión de LootCouncil para el primer ítem épico
                    self:StartSession(link)
                    break
                end
            end
        end
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
        candidates[sender] = candidates[sender] or {response = cmd, voteCount = 0}
        candidates[sender].response = cmd
        self:UpdateDisplay()
    elseif cmd == "VOTE" then
        if not self:IsOfficer(sender) then return end
        local target, votePayload = strsplit(":", data, 2)
        if target and candidates[target] then
            -- 1 voto por oficial: si ya votó por otro, restar el anterior
            local prevTarget = votes[sender]
            if prevTarget and candidates[prevTarget] and prevTarget ~= target then
                candidates[prevTarget].voteCount = math.max(0, (candidates[prevTarget].voteCount or 1) - 1)
            end
            if prevTarget ~= target then
                votes[sender] = target
                candidates[target].voteCount = (candidates[target].voteCount or 0) + 1
            end
            self:UpdateDisplay()
        end
    elseif cmd == "END" then
        if data and data ~= "" and currentSession and S.SendMessage then
            S:SendMessage("LOOT_AWARDED", currentSession.item, data)
        end
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
