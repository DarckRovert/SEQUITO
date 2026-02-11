--[[
    SEQUITO - Dashboard (GUI 2.0)
    Panel principal de configuración y control.
]]

local addonName, S = ...
S.Dashboard = {}
local DB = S.Dashboard

function DB:Initialize()
    -- GUARD: Prevent double initialization
    if self.initialized then 
        print("|cFFFF9900Sequito|r: [Dashboard] Ya inicializado, ignorando...")
        return 
    end
    self.initialized = true
    
    self.frame = self:CreateDashboardFrame()
    self.tabs = {}
    self.tabCount = 0
    print("|cFFFF00FFSequito|r: [GUI] Dashboard unificado listo.")
end

function DB:Toggle()
    if self.frame:IsShown() then
        self.frame:Hide()
    else
        self.frame:Show()
    end
end

function DB:CreateDashboardFrame()
    local f = CreateFrame("Frame", "SequitoDashboard", UIParent)
    f:SetSize(800, 500)
    f:SetPoint("CENTER")
    f:SetFrameStrata("HIGH")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    
    -- Background
    f:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(0, 0, 0, 0.9)
    f:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    
    -- Header
    f.header = f:CreateTexture(nil, "ARTWORK")
    f.header:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    f.header:SetSize(300, 64)
    f.header:SetPoint("TOP", 0, 12)
    
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.title:SetPoint("TOP", f.header, "TOP", 0, -14)
    f.title:SetText("Sequito Dashboard v" .. (S.Version or "10.1.0"))
    
    -- Close Button
    f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.close:SetPoint("TOPRIGHT", -5, -5)
    
    -- Tab container (left side bar)
    f.tabBar = CreateFrame("Frame", nil, f)
    f.tabBar:SetPoint("TOPLEFT", f, "TOPLEFT", 5, -40)
    f.tabBar:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 5, 10)
    f.tabBar:SetWidth(70)
    f.tabBar:SetFrameLevel(f:GetFrameLevel() + 5)
    
    -- Content container
    f.content = CreateFrame("Frame", nil, f)
    f.content:SetPoint("TOPLEFT", f, "TOPLEFT", 80, -40)
    f.content:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 10)
    f.content:SetFrameLevel(f:GetFrameLevel() + 1)
    
    f:Hide()
    return f
end

-- API for Modules to add tabs
function DB:RegisterTab(name, icon, contentFrame)
    -- Increment counter FIRST
    self.tabCount = (self.tabCount or 0) + 1
    local tabIndex = self.tabCount
    
    -- Create Button with unique name
    local btn = CreateFrame("Button", "SequitoDashboardTab" .. tabIndex, self.frame.tabBar)
    btn:SetSize(60, 60)
    btn:SetPoint("TOPLEFT", self.frame.tabBar, "TOPLEFT", 0, -((tabIndex-1) * 70))
    btn:SetFrameLevel(self.frame:GetFrameLevel() + 10)
    btn:Show()
    
    -- Background
    btn.bg = btn:CreateTexture(nil, "BACKGROUND")
    btn.bg:SetAllPoints()
    btn.bg:SetTexture(0.15, 0.15, 0.2, 1)
    
    -- Icon
    btn.icon = btn:CreateTexture(nil, "ARTWORK")
    btn.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    btn.icon:SetSize(44, 44)
    btn.icon:SetPoint("CENTER")
    btn.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    
    -- Border
    btn.border = btn:CreateTexture(nil, "OVERLAY")
    btn.border:SetTexture("Interface\\Buttons\\UI-Quickslot2")
    btn.border:SetSize(64, 64)
    btn.border:SetPoint("CENTER")
    
    -- Highlight
    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    
    -- Store BEFORE setting scripts
    self.tabs = self.tabs or {}
    self.tabs[tabIndex] = {
        name = name,
        btn = btn,
        content = contentFrame
    }
    
    -- Scripts
    local idx = tabIndex -- capture for closure
    btn:SetScript("OnClick", function()
        DB:SelectTab(idx)
    end)
    
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(name)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    -- Setup content frame
    contentFrame:ClearAllPoints()
    contentFrame:SetParent(self.frame.content)
    contentFrame:SetAllPoints(self.frame.content)
    contentFrame:SetFrameLevel(self.frame.content:GetFrameLevel() + 1)
    contentFrame:Hide()
    
    -- Select first tab
    if tabIndex == 1 then
        self:SelectTab(1)
    end
end

function DB:SelectTab(index)
    for i, tab in ipairs(self.tabs) do
        if tab and tab.btn and tab.content then
            if i == index then
                tab.content:Show()
                tab.btn.bg:SetTexture(0.3, 0.2, 0.5, 1)
                tab.btn.icon:SetVertexColor(1, 1, 1)
            else
                tab.content:Hide()
                tab.btn.bg:SetTexture(0.15, 0.15, 0.2, 1)
                tab.btn.icon:SetVertexColor(0.6, 0.6, 0.6)
            end
        end
    end
end
