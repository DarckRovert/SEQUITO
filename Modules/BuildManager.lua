--[[
    Sequito - BuildManager Module
    Perfil de Builds/Specs con UI completa
    Version: 7.3.0
]]

local addonName, S = ...
S.BuildManager = {}
local BM = S.BuildManager

SequitoBuildDB = SequitoBuildDB or {}

-- Helper para obtener configuración
function BM:GetOption(key)
    if S.ModuleConfig then
        return S.ModuleConfig:GetValue("BuildManager", key)
    end
    return true
end

function BM:Initialize()
    if not self:GetOption("enabled") then
        return
    end
    
    self.frame = self:CreateFrame()
end

function BM:CreateFrame()
    local f = CreateFrame("Frame", "SequitoBuildManagerFrame", UIParent)
    f:SetSize(350, 350)
    f:SetPoint("CENTER")
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()
    
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("TOP", 0, -12)
    f.title:SetText("|cff00ff00Sequito|r - Build Manager")
    
    f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.close:SetPoint("TOPRIGHT", -5, -5)
    
    -- Current spec info
    f.specInfo = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.specInfo:SetPoint("TOPLEFT", 15, -40)
    f.specInfo:SetText("Clase: " .. (select(1, UnitClass("player")) or "Desconocida"))
    
    -- Save build section
    f.saveLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.saveLabel:SetPoint("TOPLEFT", 15, -65)
    f.saveLabel:SetText("Nombre del build:")
    
    f.saveEditBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    f.saveEditBox:SetSize(150, 20)
    f.saveEditBox:SetPoint("TOPLEFT", 15, -80)
    f.saveEditBox:SetAutoFocus(false)
    
    f.saveBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.saveBtn:SetSize(80, 22)
    f.saveBtn:SetPoint("LEFT", f.saveEditBox, "RIGHT", 10, 0)
    f.saveBtn:SetText("Guardar")
    f.saveBtn:SetScript("OnClick", function()
        local name = f.saveEditBox:GetText()
        if name and name ~= "" then
            BM:SaveBuild(name)
            f.saveEditBox:SetText("")
            BM:UpdateBuildList()
        end
    end)
    
    -- Build list
    f.listLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.listLabel:SetPoint("TOPLEFT", 15, -115)
    f.listLabel:SetText("Builds guardados:")
    
    f.scrollFrame = CreateFrame("ScrollFrame", "SequitoBMScroll", f, "UIPanelScrollFrameTemplate")
    f.scrollFrame:SetPoint("TOPLEFT", 10, -135)
    f.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)
    
    f.scrollChild = CreateFrame("Frame", nil, f.scrollFrame)
    f.scrollChild:SetSize(290, 150)
    f.scrollFrame:SetScrollChild(f.scrollChild)
    
    -- Delete all button
    f.deleteAllBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.deleteAllBtn:SetSize(100, 22)
    f.deleteAllBtn:SetPoint("BOTTOMLEFT", 15, 15)
    f.deleteAllBtn:SetText("Borrar Todo")
    f.deleteAllBtn:SetScript("OnClick", function()
        StaticPopup_Show("SEQUITO_CONFIRM_DELETE_ALL_BUILDS")
    end)
    
    self.buildRows = {}
    
    return f
end

function BM:UpdateBuildList()
    for _, row in ipairs(self.buildRows) do
        row:Hide()
    end
    
    local yOffset = 0
    local index = 1
    local playerClass = select(2, UnitClass("player"))
    
    for name, data in pairs(SequitoBuildDB) do
        local row = self.buildRows[index]
        if not row then
            row = CreateFrame("Frame", nil, self.frame.scrollChild)
            row:SetSize(280, 28)
            
            row.bg = row:CreateTexture(nil, "BACKGROUND")
            row.bg:SetAllPoints()
            row.bg:SetTexture(0.1, 0.1, 0.1, 0.5)
            
            row.icon = row:CreateTexture(nil, "ARTWORK")
            row.icon:SetSize(20, 20)
            row.icon:SetPoint("LEFT", 5, 0)
            
            row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            row.name:SetPoint("LEFT", 30, 0)
            row.name:SetWidth(120)
            row.name:SetJustifyH("LEFT")
            
            row.classText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            row.classText:SetPoint("LEFT", 155, 0)
            row.classText:SetWidth(50)
            
            row.loadBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            row.loadBtn:SetSize(50, 20)
            row.loadBtn:SetPoint("RIGHT", -55, 0)
            row.loadBtn:SetText("Ver")
            
            row.deleteBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            row.deleteBtn:SetSize(45, 20)
            row.deleteBtn:SetPoint("RIGHT", -5, 0)
            row.deleteBtn:SetText("X")
            
            self.buildRows[index] = row
        end
        
        row:SetPoint("TOPLEFT", 0, -yOffset)
        row:Show()
        
        row.name:SetText(name)
        row.classText:SetText(data.class or "?")
        
        -- Class color
        local classColor = RAID_CLASS_COLORS[data.class] or {r = 1, g = 1, b = 1}
        row.classText:SetTextColor(classColor.r, classColor.g, classColor.b)
        
        -- Class icon
        local coords = CLASS_ICON_TCOORDS[data.class]
        if coords then
            row.icon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
            row.icon:SetTexCoord(unpack(coords))
        end
        
        -- Highlight if same class
        if data.class == playerClass then
            row.bg:SetTexture(0.2, 0.4, 0.2, 0.5)
        else
            row.bg:SetTexture(0.1, 0.1, 0.1, 0.5)
        end
        
        local buildName = name
        row.loadBtn:SetScript("OnClick", function()
            BM:ShowBuildDetails(buildName)
        end)
        
        row.deleteBtn:SetScript("OnClick", function()
            BM:DeleteBuild(buildName)
            BM:UpdateBuildList()
        end)
        
        yOffset = yOffset + 30
        index = index + 1
    end
    
    self.frame.scrollChild:SetHeight(math.max(150, yOffset))
end

function BM:ShowBuildDetails(name)
    local build = SequitoBuildDB[name]
    if not build then return end
    
    S:Print("=== Build: " .. name .. " ===")
    S:Print("Clase: " .. (build.class or "Desconocida"))
    
    if build.talents then
        for tab, talents in pairs(build.talents) do
            local points = 0
            for _, rank in pairs(talents) do
                points = points + rank
            end
            S:Print("  Tab " .. tab .. ": " .. points .. " puntos")
        end
    end
    
    if build.glyphs then
        local glyphCount = 0
        for _, glyph in pairs(build.glyphs) do
            if glyph then glyphCount = glyphCount + 1 end
        end
        S:Print("  Glyphs: " .. glyphCount)
    end
end

function BM:DeleteBuild(name)
    SequitoBuildDB[name] = nil
    S:Print("Build '" .. name .. "' eliminado")
end

function BM:SaveBuild(name)
    local talents = {}
    for tab = 1, GetNumTalentTabs() do
        talents[tab] = {}
        for i = 1, GetNumTalents(tab) do
            local _, _, _, _, rank = GetTalentInfo(tab, i)
            talents[tab][i] = rank
        end
    end
    
    local glyphs = {}
    for i = 1, 6 do
        local _, _, _, glyphID = GetGlyphSocketInfo(i)
        glyphs[i] = glyphID
    end
    
    SequitoBuildDB[name] = {talents = talents, glyphs = glyphs, class = select(2, UnitClass("player"))}
    S:Print("Build '" .. name .. "' guardado")
end

function BM:ListBuilds()
    S:Print("Builds guardados:")
    for name, data in pairs(SequitoBuildDB) do
        S:Print("  - " .. name .. " (" .. data.class .. ")")
    end
end

function BM:ShareBuild(name, target)
    local build = SequitoBuildDB[name]
    if build then
        local encoded = name .. ":" .. build.class
        SendAddonMessage("SeqBuild", encoded, "WHISPER", target)
        S:Print("Build compartido con " .. target)
    end
end

function BM:Toggle()
    if not self.frame then return end
    if self.frame:IsShown() then
        self.frame:Hide()
    else
        self.frame:Show()
        self:UpdateBuildList()
    end
end

function BM:SlashCommand(msg)
    local cmd, arg = strsplit(" ", msg, 2)
    if cmd == "save" and arg then
        self:SaveBuild(arg)
    elseif cmd == "list" then
        self:ListBuilds()
    elseif cmd == "share" then
        local name, target = strsplit(" ", arg or "", 2)
        if name and target then self:ShareBuild(name, target) end
    else
        self:Toggle()
    end
end

-- Registrar módulo en ModuleConfig
if S.ModuleConfig then
    S.ModuleConfig:RegisterModule({
        id = "BuildManager",
        name = "Gestor de Builds",
        description = "Administrador de builds y especializaciones",
        category = "utility",
        icon = "Interface\\Icons\\INV_Misc_Book_11",
        options = {
            {
                key = "enabled",
                type = "checkbox",
                name = "Habilitar Gestor",
                description = "Habilitar/deshabilitar el gestor de builds",
                default = true
            },
            {
                key = "autoSave",
                type = "checkbox",
                name = "Auto-Guardar",
                description = "Guardar automáticamente al cambiar spec",
                default = false
            },
            {
                key = "notifyChanges",
                type = "checkbox",
                name = "Notificar Cambios",
                description = "Notificar cuando se detecten cambios en el build",
                default = true
            },
            {
                key = "shareToGuild",
                type = "checkbox",
                name = "Compartir con Guild",
                description = "Permitir compartir builds con miembros del guild",
                default = true
            }
        }
    })
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function() BM:Initialize() end)
