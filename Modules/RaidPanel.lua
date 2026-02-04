--[[
    Sequito - RaidPanel.lua
    Panel Visual de Raid con información de todos los miembros
    Muestra clase, spec, rol, HP, mana y estado de cada jugador
]]--

local addonName, Sequito = ...
Sequito.RaidPanel = Sequito.RaidPanel or {}

local RaidPanel = Sequito.RaidPanel
local Universal = Sequito.Universal
local RaidSync = Sequito.RaidSync

-- Helper para obtener configuración
function RaidPanel:GetOption(key)
    if Sequito.ModuleConfig then
        return Sequito.ModuleConfig:GetValue("RaidPanel", key)
    end
    return true
end

-- Configuración del panel
local PANEL_CONFIG = {
    width = 320,
    height = 450,
    rowHeight = 18,
    maxRows = 40,
    headerHeight = 25,
    padding = 5,
    updateInterval = 1.0, -- Actualizar cada segundo
}

-- Colores de clase (RGBA)
local CLASS_COLORS = {
    ["WARRIOR"] = {0.78, 0.61, 0.43, 1},
    ["PALADIN"] = {0.96, 0.55, 0.73, 1},
    ["HUNTER"] = {0.67, 0.83, 0.45, 1},
    ["ROGUE"] = {1.00, 0.96, 0.41, 1},
    ["PRIEST"] = {1.00, 1.00, 1.00, 1},
    ["DEATHKNIGHT"] = {0.77, 0.12, 0.23, 1},
    ["SHAMAN"] = {0.00, 0.44, 0.87, 1},
    ["MAGE"] = {0.41, 0.80, 0.94, 1},
    ["WARLOCK"] = {0.58, 0.51, 0.79, 1},
    ["DRUID"] = {1.00, 0.49, 0.04, 1},
}

-- Iconos de rol
local ROLE_ICONS = {
    ["TANK"] = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES",
    ["HEALER"] = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES",
    ["DPS"] = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES",
}

local ROLE_TEXCOORDS = {
    ["TANK"] = {0, 0.25, 0.25, 0.5},
    ["HEALER"] = {0.25, 0.5, 0, 0.25},
    ["DPS"] = {0.25, 0.5, 0.25, 0.5},
}

-- Variables del panel
local mainFrame = nil
local memberRows = {}
local isVisible = false
local lastUpdate = 0

-- Crear el frame principal del panel
local function CreateMainFrame()
    if mainFrame then return mainFrame end
    
    -- Frame principal
    mainFrame = CreateFrame("Frame", "SequitoRaidPanel", UIParent)
    mainFrame:SetSize(PANEL_CONFIG.width, PANEL_CONFIG.height)
    mainFrame:SetPoint("RIGHT", UIParent, "RIGHT", -20, 0)
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
    mainFrame:SetClampedToScreen(true)
    mainFrame:Hide()
    
    -- Fondo
    mainFrame.bg = mainFrame:CreateTexture(nil, "BACKGROUND")
    mainFrame.bg:SetAllPoints()
    mainFrame.bg:SetTexture(0.05, 0.05, 0.1, 0.9)
    
    -- Borde
    mainFrame.border = CreateFrame("Frame", nil, mainFrame)
    mainFrame.border:SetAllPoints()
    mainFrame.border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4},
    })
    mainFrame.border:SetBackdropBorderColor(0.6, 0.4, 0.8, 1)
    
    -- Título
    mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    mainFrame.title:SetPoint("TOP", mainFrame, "TOP", 0, -8)
    mainFrame.title:SetText("|cff9966ffSequito|r - Raid Panel")
    
    -- Botón de cerrar
    mainFrame.closeBtn = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
    mainFrame.closeBtn:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -2, -2)
    mainFrame.closeBtn:SetScript("OnClick", function()
        RaidPanel:Hide()
    end)
    
    -- Header con columnas
    mainFrame.header = CreateFrame("Frame", nil, mainFrame)
    mainFrame.header:SetSize(PANEL_CONFIG.width - 20, PANEL_CONFIG.headerHeight)
    mainFrame.header:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 10, -30)
    
    -- Columnas del header
    local headers = {
        {text = "#", width = 20},
        {text = "Nombre", width = 100},
        {text = "Clase", width = 70},
        {text = "Rol", width = 40},
        {text = "HP%", width = 40},
        {text = "Estado", width = 50},
    }
    
    local xOffset = 0
    for i, h in ipairs(headers) do
        local headerText = mainFrame.header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        headerText:SetPoint("LEFT", mainFrame.header, "LEFT", xOffset, 0)
        headerText:SetText(h.text)
        headerText:SetTextColor(0.8, 0.8, 0.2, 1)
        xOffset = xOffset + h.width
    end
    
    -- Línea separadora
    mainFrame.separator = mainFrame:CreateTexture(nil, "ARTWORK")
    mainFrame.separator:SetSize(PANEL_CONFIG.width - 20, 1)
    mainFrame.separator:SetPoint("TOPLEFT", mainFrame.header, "BOTTOMLEFT", 0, -2)
    mainFrame.separator:SetTexture(0.5, 0.5, 0.5, 0.5)
    
    -- ScrollFrame para la lista de miembros
    mainFrame.scrollFrame = CreateFrame("ScrollFrame", "SequitoRaidPanelScroll", mainFrame, "UIPanelScrollFrameTemplate")
    mainFrame.scrollFrame:SetSize(PANEL_CONFIG.width - 30, PANEL_CONFIG.height - 80)
    mainFrame.scrollFrame:SetPoint("TOPLEFT", mainFrame.separator, "BOTTOMLEFT", 0, -5)
    
    -- Content frame dentro del scroll
    mainFrame.content = CreateFrame("Frame", nil, mainFrame.scrollFrame)
    mainFrame.content:SetSize(PANEL_CONFIG.width - 30, PANEL_CONFIG.maxRows * PANEL_CONFIG.rowHeight)
    mainFrame.scrollFrame:SetScrollChild(mainFrame.content)
    
    -- Crear filas para miembros
    for i = 1, PANEL_CONFIG.maxRows do
        local row = CreateMemberRow(mainFrame.content, i)
        row:SetPoint("TOPLEFT", mainFrame.content, "TOPLEFT", 0, -((i-1) * PANEL_CONFIG.rowHeight))
        memberRows[i] = row
    end
    
    -- Footer con estadísticas
    mainFrame.footer = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    mainFrame.footer:SetPoint("BOTTOM", mainFrame, "BOTTOM", 0, 8)
    mainFrame.footer:SetText("Total: 0 | Tanks: 0 | Healers: 0 | DPS: 0")
    mainFrame.footer:SetTextColor(0.7, 0.7, 0.7, 1)
    
    -- Script de actualización
    mainFrame:SetScript("OnUpdate", function(self, elapsed)
        lastUpdate = lastUpdate + elapsed
        if lastUpdate >= PANEL_CONFIG.updateInterval then
            lastUpdate = 0
            RaidPanel:UpdateMembers()
        end
    end)
    
    return mainFrame
end

-- Crear una fila para un miembro de raid
function CreateMemberRow(parent, index)
    local row = CreateFrame("Button", "SequitoRaidRow"..index, parent, "SecureUnitButtonTemplate")
    row:SetSize(PANEL_CONFIG.width - 30, PANEL_CONFIG.rowHeight)
    row:EnableMouse(true)
    
    -- Fondo alternado
    row.bg = row:CreateTexture(nil, "BACKGROUND")
    row.bg:SetAllPoints()
    if index % 2 == 0 then
        row.bg:SetTexture(0.1, 0.1, 0.15, 0.5)
    else
        row.bg:SetTexture(0.05, 0.05, 0.1, 0.3)
    end
    
    -- Highlight al pasar el mouse
    row:SetScript("OnEnter", function(self)
        self.bg:SetTexture(0.2, 0.2, 0.3, 0.7)
    end)
    row:SetScript("OnLeave", function(self)
        if index % 2 == 0 then
            self.bg:SetTexture(0.1, 0.1, 0.15, 0.5)
        else
            self.bg:SetTexture(0.05, 0.05, 0.1, 0.3)
        end
    end)
    
    -- Click para target (Manejado por SecureUnitButtonTemplate)
    row:RegisterForClicks("AnyUp")
    row:SetAttribute("type", "target")
    
    -- Número de índice
    row.indexText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.indexText:SetPoint("LEFT", row, "LEFT", 2, 0)
    row.indexText:SetWidth(18)
    row.indexText:SetJustifyH("RIGHT")
    
    -- Nombre del jugador
    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.nameText:SetPoint("LEFT", row, "LEFT", 22, 0)
    row.nameText:SetWidth(98)
    row.nameText:SetJustifyH("LEFT")
    
    -- Clase
    row.classText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.classText:SetPoint("LEFT", row, "LEFT", 122, 0)
    row.classText:SetWidth(68)
    row.classText:SetJustifyH("LEFT")
    
    -- Icono de rol
    row.roleIcon = row:CreateTexture(nil, "ARTWORK")
    row.roleIcon:SetSize(14, 14)
    row.roleIcon:SetPoint("LEFT", row, "LEFT", 192, 0)
    
    -- HP%
    row.hpText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.hpText:SetPoint("LEFT", row, "LEFT", 232, 0)
    row.hpText:SetWidth(38)
    row.hpText:SetJustifyH("RIGHT")
    
    -- Estado (Online/Dead/AFK)
    row.statusText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.statusText:SetPoint("LEFT", row, "LEFT", 272, 0)
    row.statusText:SetWidth(48)
    row.statusText:SetJustifyH("CENTER")
    
    row:Hide()
    return row
end

-- Obtener información de un miembro de raid
local function GetMemberInfo(unit)
    if not UnitExists(unit) then return nil end
    
    local name = UnitName(unit)
    local _, classToken = UnitClass(unit)
    local hp = UnitHealth(unit)
    local hpMax = UnitHealthMax(unit)
    local hpPercent = hpMax > 0 and math.floor((hp / hpMax) * 100) or 0
    local isDead = UnitIsDead(unit) or UnitIsGhost(unit)
    local isOnline = UnitIsConnected(unit)
    local isAFK = UnitIsAFK(unit)
    
    -- Determinar estado
    local status = "OK"
    local statusColor = {0.2, 1, 0.2, 1} -- Verde
    
    if not isOnline then
        status = "OFF"
        statusColor = {0.5, 0.5, 0.5, 1}
    elseif isDead then
        status = "DEAD"
        statusColor = {1, 0.2, 0.2, 1}
    elseif isAFK then
        status = "AFK"
        statusColor = {1, 0.8, 0.2, 1}
    elseif hpPercent < 30 then
        status = "LOW"
        statusColor = {1, 0.5, 0.2, 1}
    end
    
    -- Obtener rol (si RaidSync tiene la info)
    local role = "DPS"
    if RaidSync and RaidSync.raidMembers and RaidSync.raidMembers[name] then
        role = RaidSync.raidMembers[name].role or "DPS"
    elseif Universal and Universal.GetPlayerRole then
        -- Intentar determinar rol por clase/spec
        role = Universal:GetPlayerRole() or "DPS"
    end
    
    return {
        unit = unit,
        name = name,
        class = classToken,
        hp = hpPercent,
        status = status,
        statusColor = statusColor,
        role = role,
        isOnline = isOnline,
    }
end

-- Actualizar la lista de miembros
function RaidPanel:UpdateMembers()
    if not mainFrame or not mainFrame:IsVisible() then return end
    
    local members = {}
    local numMembers = 0
    local tankCount, healerCount, dpsCount = 0, 0, 0
    
    -- Configs from DB
    local showHP = Sequito.db.profile.RaidPanelHP
    local showRoles = Sequito.db.profile.RaidPanelRoles
    local sortMethod = Sequito.db.profile.RaidPanelSort or "class"
    
    -- Verificar si estamos en raid o grupo
    local inRaid = (GetNumRaidMembers() > 0)
    local inParty = GetNumPartyMembers() > 0
    
    if inRaid then
        for i = 1, 40 do
            local unit = "raid"..i
            local info = GetMemberInfo(unit)
            if info then
                numMembers = numMembers + 1
                info.index = numMembers
                table.insert(members, info)
                
                -- Contar roles
                if info.role == "TANK" then
                    tankCount = tankCount + 1
                elseif info.role == "HEALER" then
                    healerCount = healerCount + 1
                else
                    dpsCount = dpsCount + 1
                end
            end
        end
    elseif inParty then
        -- Añadir al jugador
        local playerInfo = GetMemberInfo("player")
        if playerInfo then
            numMembers = numMembers + 1
            playerInfo.index = numMembers
            table.insert(members, playerInfo)
        end
        
        -- Añadir miembros del grupo
        for i = 1, 4 do
            local unit = "party"..i
            local info = GetMemberInfo(unit)
            if info then
                numMembers = numMembers + 1
                info.index = numMembers
                table.insert(members, info)
            end
        end
    else
        -- Solo el jugador
        local playerInfo = GetMemberInfo("player")
        if playerInfo then
            numMembers = 1
            playerInfo.index = 1
            table.insert(members, playerInfo)
        end
    end
    
    -- Ordenar
    table.sort(members, function(a, b)
        if sortMethod == "name" then
            return a.name < b.name
        elseif sortMethod == "role" then
            if a.role == b.role then return a.name < b.name end
            return a.role < b.role -- Alphabetical roles sadly, but works
        else -- class (default)
            if a.class == b.class then return a.name < b.name end
            return a.class < b.class
        end
    end)
    
    -- Actualizar filas
    for i = 1, PANEL_CONFIG.maxRows do
        local row = memberRows[i]
        local member = members[i]
        
        if member then
            -- Actualizar atributos seguros (Solo fuera de combate)
            if not InCombatLockdown() then
                row:SetAttribute("unit", member.unit)
            end

            row.unitName = member.name
            row.indexText:SetText(i)
            row.nameText:SetText(member.name)
            
            -- Color de clase para el nombre
            local classColor = CLASS_COLORS[member.class] or {1, 1, 1, 1}
            row.nameText:SetTextColor(unpack(classColor))
            
            -- Clase abreviada
            local classAbbrev = {
                ["WARRIOR"] = "War",
                ["PALADIN"] = "Pal",
                ["HUNTER"] = "Hun",
                ["ROGUE"] = "Rog",
                ["PRIEST"] = "Pri",
                ["DEATHKNIGHT"] = "DK",
                ["SHAMAN"] = "Sha",
                ["MAGE"] = "Mag",
                ["WARLOCK"] = "Lock",
                ["DRUID"] = "Dru",
            }
            row.classText:SetText(classAbbrev[member.class] or member.class)
            row.classText:SetTextColor(unpack(classColor))
            
            -- Icono de rol
            if showRoles and ROLE_ICONS[member.role] then
                row.roleIcon:SetTexture(ROLE_ICONS[member.role])
                local coords = ROLE_TEXCOORDS[member.role]
                if coords then
                    row.roleIcon:SetTexCoord(unpack(coords))
                end
                row.roleIcon:Show()
            else
                row.roleIcon:Hide()
            end
            
            -- HP con color
            if showHP then
                row.hpText:SetText(member.hp.."%")
                if member.hp >= 80 then
                    row.hpText:SetTextColor(0.2, 1, 0.2, 1)
                elseif member.hp >= 50 then
                    row.hpText:SetTextColor(1, 1, 0.2, 1)
                elseif member.hp >= 30 then
                    row.hpText:SetTextColor(1, 0.5, 0.2, 1)
                else
                    row.hpText:SetTextColor(1, 0.2, 0.2, 1)
                end
                row.hpText:Show()
            else
                row.hpText:Hide()
            end
            
            -- Estado
            row.statusText:SetText(member.status)
            row.statusText:SetTextColor(unpack(member.statusColor))
            
            row:Show()
        else
            row:Hide()
        end
    end
    
    -- Actualizar footer
    mainFrame.footer:SetText(string.format(
        "Total: %d | Tanks: %d | Healers: %d | DPS: %d",
        numMembers, tankCount, healerCount, dpsCount
    ))
end

-- Mostrar el panel
function RaidPanel:Show()
    if not Sequito.db.profile.ShowRaidPanel then return end

    if not mainFrame then
        CreateMainFrame()
    end
    
    -- Apply Scale
    local scale = Sequito.db.profile.RaidPanelScale or 1.0
    mainFrame:SetScale(scale)
    
    mainFrame:Show()
    isVisible = true
    self:UpdateMembers()
    Sequito:Print("Raid Panel abierto.")
end

-- Ocultar el panel
function RaidPanel:Hide()
    if mainFrame then
        mainFrame:Hide()
    end
    isVisible = false
end

-- Toggle del panel
function RaidPanel:Toggle()
    if isVisible then
        self:Hide()
    else
        self:Show()
    end
end

-- Verificar si está visible
function RaidPanel:IsVisible()
    return isVisible
end

-- Inicialización

-- Helper para obtener configuración
function RaidPanel:GetOption(key)
    if Sequito.ModuleConfig then
        return Sequito.ModuleConfig:GetValue("RaidPanel", key)
    end
    return true
end

function RaidPanel:Initialize()
    if not self:GetOption("enabled") then
        return
    end
    
    -- Eventos para AutoShow
    local f = CreateFrame("Frame")
    f:RegisterEvent("RAID_ROSTER_UPDATE")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", function(self, event)
        if Sequito.db.profile.ShowRaidPanel and Sequito.db.profile.RaidPanelAuto and (GetNumRaidMembers() > 0) then
            if not RaidPanel:IsVisible() then
                 RaidPanel:Show()
            end
        end
    end)
    
    -- Check initial state
    if Sequito.db.profile.ShowRaidPanel and Sequito.db.profile.RaidPanelAuto and (GetNumRaidMembers() > 0) then
         self:Show()
    end
end

-- Registrar en Sequito
Sequito.RaidPanel = RaidPanel

-- Registrar módulo en ModuleConfig
if Sequito.ModuleConfig then
    Sequito.ModuleConfig:RegisterModule("RaidPanel", {
        name = "Raid Panel",
        description = "Panel visual de raid con información de todos los miembros",
        category = "raid",
        icon = "Interface\\\\Icons\\\\INV_Misc_GroupLooking",
        options = {
            {key = "enabled", type = "checkbox", label = "Habilitar Raid Panel", default = true},
            {key = "autoShow", type = "checkbox", label = "Mostrar automáticamente en raid", default = false},
            {key = "showHP", type = "checkbox", label = "Mostrar HP%", default = true},
            {key = "showRoles", type = "checkbox", label = "Mostrar iconos de rol", default = true},
            {key = "scale", type = "slider", label = "Escala del panel", min = 0.5, max = 1.5, step = 0.1, default = 1.0},
        }
    })
end

