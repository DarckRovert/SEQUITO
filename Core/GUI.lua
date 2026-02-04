--[[
    SEQUITO - GUI Engine
    Handles the Sphere and button creation.
]]--

local addonName, S = ...
S.GUI = {}

-- Helper para obtener configuración
function S.GUI:GetOption(key)
    if S.ModuleConfig then
        return S.ModuleConfig:GetValue("GUI", key)
    end
    return true
end

function S.GUI:Initialize()
    if not self:GetOption("enabled") then
        return
    end
    
    if not S.Sphere then
        self:CreateSphere()
    end
    if not self.MinimapBtn then
        self:CreateMinimapButton()
    end
    -- RaidAssist Integration (v7.1.0)
    if not self.RaidAssistBtn then
        self:CreateRaidAssistButton()
    end
    if not self.RaidStatusIndicator then
        self:CreateRaidStatusIndicator()
    end
end

function S.GUI:CreateSphere()
    if S.Sphere or _G["SequitoSphere"] then
        return
    end
    
    local db = S.db.profile
    
    local f = CreateFrame("Button", "SequitoSphere", UIParent, "SecureActionButtonTemplate")
    f:SetSize(64, 64)
    
    if not db.Position then db.Position = {point="CENTER", relativeTo="UIParent", relativePoint="CENTER", x=0, y=0} end
    
    local finalScale = db.SphereScale or db.Scale or 1.0
    if finalScale <= 0 then finalScale = 1.0 end
    f:SetScale(finalScale)
    f:SetPoint(db.Position.point, db.Position.relativeTo, db.Position.relativePoint, db.Position.x, db.Position.y)
    
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    
    f:SetNormalTexture("Interface\\Icons\\Ability_Racial_Cannibalize") 
    f:SetPushedTexture("Interface\\Icons\\Ability_Racial_Cannibalize")
    f:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    
    if db.ShowSphere then
        f:Show()
    else
        f:Hide()
    end
    
    f:SetScript("OnDragStart", function(self)
        if not S.db.profile.Locked then self:StartMoving() end
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, x, y = self:GetPoint()
        S.db.profile.Position = {point=point, relativeTo="UIParent", relativePoint=relativePoint, x=x, y=y}
    end)
    
    f.countText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    f.countText:SetPoint("CENTER", f, "CENTER", 0, 0)
    f.countText:SetTextColor(1, 1, 1, 1)
    f.countText:SetText("")
    
    f:SetAttribute("type1", "macro")
    
    local mountMacro = ""
    if S.Mounts and S.Mounts.GenerateMountMacro then
        mountMacro = S.Mounts:GenerateMountMacro()
    else
        mountMacro = "/castrandom [nocombat] Caballo, Kodo, Lobo"
    end
    
    local finalMacro = "/cleartarget [dead]\n/targetenemy [noexists][dead]\n/cast [combat] !Auto Attack\n" .. mountMacro
    f:SetAttribute("macrotext1", finalMacro)
    
    f:RegisterForClicks("AnyUp")
    f:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            if S.Menu then
                S.Menu:Toggle()
            end
        end
    end)
    
    local timer = 0
    f:SetScript("OnUpdate", function(self, elapsed)
        if not S.db.profile.ShowSphere then 
             if self:IsShown() then self:Hide() end
             return
        end

        timer = timer + elapsed
        if timer >= 0.2 then
            timer = 0
            
            if S.Universal and S.db.profile.SphereText then
                local count, ctype = S.Universal:GetResourceCount()
                if count and count > 0 then
                    self.countText:SetText(count)
                    
                    if ctype == "COMBO" then
                         self.countText:SetTextColor(1, 0, 0)
                    elseif ctype == "SHARD" then
                         self.countText:SetTextColor(0.8, 0.5, 1)
                    else
                         self.countText:SetTextColor(1, 1, 1)
                    end
                else
                    self.countText:SetText("")
                end
            else
                self.countText:SetText("")
            end
        end
    end)
    
    S.Sphere = f
    
    self:CreateSatellites()
    -- RaidAssist buttons are created in Initialize() to avoid duplicates
end

function S.GUI:CreateSatellites()
    local _, class = UnitClass("player")
    local config = S.Data.Classes[class]
    if not config then return end
    
    local r = 40
    local angles = {135, 45, -45, -135} 
    
    for i=1, 4 do
        local spellID = config[i]
        if spellID then
            local btnName = "SequitoBtn"..i
            if _G[btnName] then return end
            
            local btn = CreateFrame("Button", btnName, S.Sphere, "SecureActionButtonTemplate")
            btn:SetSize(32, 32)
            
            local rad = math.rad(angles[i])
            local x = math.cos(rad) * r
            local y = math.sin(rad) * r
            btn:SetPoint("CENTER", S.Sphere, "CENTER", x, y)
            
            local cd = CreateFrame("Cooldown", btnName.."Cooldown", btn, "CooldownFrameTemplate")
            cd:SetAllPoints()
            btn.cooldown = cd
            btn.spellID = spellID
            
            local name, _, icon = GetSpellInfo(spellID)
            if name then
                btn:SetNormalTexture(icon)
                btn:SetAttribute("type", "spell")
                btn:SetAttribute("spell", name)
                
                btn:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    local link = GetSpellLink(spellID)
                    if link then
                        GameTooltip:SetHyperlink(link)
                    else
                        GameTooltip:SetText(name, 1, 1, 1)
                    end
                    GameTooltip:Show()
                end)
                btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            else
                 btn:SetNormalTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            end
        end
    end
    
    self:RegisterCooldownUpdates()
end

function S.GUI:RegisterCooldownUpdates()
    local f = self.CooldownFrame or CreateFrame("Frame")
    self.CooldownFrame = f
    f:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    f:SetScript("OnEvent", function()
        S.GUI:UpdateCooldowns()
    end)
    self:UpdateCooldowns() 
end

function S.GUI:UpdateCooldowns()
    local _, class = UnitClass("player")
    local config = S.Data.Classes[class]
    if not config then return end
    
    for i=1, 4 do
        local btn = _G["SequitoBtn"..i]
        if btn and btn.spellID and btn.cooldown then
            local start, duration, enabled = GetSpellCooldown(btn.spellID)
            if enabled == 1 and start > 0 and duration > 0 then
                btn.cooldown:SetCooldown(start, duration)
            else
                btn.cooldown:Hide()
            end
        end
    end
end

function S.GUI:CreateMinimapButton()
    if self.MinimapBtn or _G["SequitoMinimapButton"] then
        return
    end
    
    local db = S.db.profile
    
    local btn = CreateFrame("Button", "SequitoMinimapButton", Minimap)
    btn:SetSize(31, 31)
    btn:SetFrameStrata("MEDIUM")
    btn:SetToplevel(true)
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    
    local overlay = btn:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(53, 53)
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetPoint("TOPLEFT", 0, 0)
    
    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(20, 20)
    icon:SetTexture("Interface\\Icons\\Ability_Racial_Cannibalize")
    icon:SetPoint("CENTER", 0, 1)
    
    local angle = 45
    local radius = 80
    
    local function UpdatePosition()
        local r = 80
        local x = math.cos(math.rad(angle)) * r
        local y = math.sin(math.rad(angle)) * r
        btn:SetPoint("CENTER", Minimap, "CENTER", x, y)
    end
    
    UpdatePosition()
    
    btn:SetMovable(true)
    btn:RegisterForDrag("LeftButton")
    btn:SetScript("OnDragStart", function(self) self:LockHighlight() self:SetScript("OnUpdate", function(self)
        local mx, my = Minimap:GetCenter()
        local cx, cy = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        cx, cy = cx / scale, cy / scale
        angle = math.deg(math.atan2(cy - my, cx - mx))
        UpdatePosition()
    end) end)
    
    btn:SetScript("OnDragStop", function(self) self:UnlockHighlight() self:SetScript("OnUpdate", nil) end)
    
    btn:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            if S.Options then S.Options:Toggle() end
        else
            if S.Menu then S.Menu:Toggle() end
        end
    end)
    
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Sequito", 1, 0, 1)
        GameTooltip:AddLine("Click Izquierdo: Menu Esfera", 1, 1, 1)
        GameTooltip:AddLine("Click Derecho: Opciones", 1, 1, 1)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    self.MinimapBtn = btn
    
    if db.ShowMinimap == false then
        btn:Hide()
    else
        btn:Show() 
    end
end

function S.GUI:UpdateMinimap()
    if not self.MinimapBtn then return end
    if S.db.profile.ShowMinimap then
        self.MinimapBtn:Show()
    else
        self.MinimapBtn:Hide()
    end
end

-- ============================================
-- RAID ASSIST INTEGRATION
-- ============================================

function S.GUI:CreateRaidAssistButton()
    if self.RaidAssistBtn or _G["SequitoRaidAssistBtn"] then
        return
    end
    
    local btn = CreateFrame("Button", "SequitoRaidAssistBtn", S.Sphere)
    btn:SetSize(28, 28)
    
    -- Posición: abajo de la esfera
    btn:SetPoint("TOP", S.Sphere, "BOTTOM", 0, -5)
    
    -- Icono de raid
    btn:SetNormalTexture("Interface\\Icons\\Achievement_Dungeon_GlsOculus_Heroic")
    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    
    -- Borde
    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(42, 42)
    border:SetPoint("CENTER", 10, -10)
    
    btn:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            -- Click derecho: Panel de líder
            if S.RaidAssistUI and S.RaidAssistUI.ShowLeaderPanel then
                S.RaidAssistUI:ShowLeaderPanel()
            end
        else
            -- Click izquierdo: Panel principal
            if S.RaidAssistUI and S.RaidAssistUI.Toggle then
                S.RaidAssistUI:Toggle()
            end
        end
    end)
    
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("|cFF00FFFFRaid Assist|r", 1, 1, 1)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Click Izquierdo: Panel Principal", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("Click Derecho: Panel de Líder", 0.8, 0.8, 0.8)
        if S.RaidAssist then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Modo: |cFFFFFF00" .. (S.RaidAssist.mode or "FARM") .. "|r", 1, 1, 1)
            GameTooltip:AddLine("Wipes: |cFFFF6666" .. (S.RaidAssist.wipeCount or 0) .. "|r", 1, 1, 1)
            local userCount = 0
            if S.RaidAssist.users then
                for _ in pairs(S.RaidAssist.users) do userCount = userCount + 1 end
            end
            GameTooltip:AddLine("Usuarios Sequito: |cFF66FF66" .. userCount .. "|r", 1, 1, 1)
        end
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    btn:RegisterForClicks("AnyUp")
    
    self.RaidAssistBtn = btn
    
    -- Solo mostrar si está en grupo/raid
    self:UpdateRaidAssistButton()
end

function S.GUI:UpdateRaidAssistButton()
    if not self.RaidAssistBtn then return end
    
    local inGroup = (GetNumRaidMembers() > 0) or (GetNumPartyMembers() > 0)
    
    if inGroup and S.db.profile.raidAssistEnabled ~= false then
        self.RaidAssistBtn:Show()
    else
        -- Siempre mostrar pero con alpha reducido si no está en grupo
        self.RaidAssistBtn:Show()
        self.RaidAssistBtn:SetAlpha(inGroup and 1.0 or 0.5)
    end
end

function S.GUI:CreateRaidStatusIndicator()
    if self.RaidStatusIndicator then return end
    
    -- Indicador pequeño en la esquina de la esfera
    local indicator = S.Sphere:CreateTexture("SequitoRaidIndicator", "OVERLAY")
    indicator:SetSize(12, 12)
    indicator:SetPoint("TOPRIGHT", S.Sphere, "TOPRIGHT", 2, 2)
    indicator:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
    indicator:Hide()
    
    self.RaidStatusIndicator = indicator
    
    -- Frame para actualizar el indicador
    local updateFrame = CreateFrame("Frame")
    updateFrame:RegisterEvent("RAID_ROSTER_UPDATE")
    updateFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
    updateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    updateFrame:SetScript("OnEvent", function()
        S.GUI:UpdateRaidStatusIndicator()
        S.GUI:UpdateRaidAssistButton()
    end)
end

function S.GUI:UpdateRaidStatusIndicator()
    if not self.RaidStatusIndicator then return end
    
    local inRaid = GetNumRaidMembers() > 0
    local inParty = GetNumPartyMembers() > 0
    
    if inRaid then
        self.RaidStatusIndicator:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
        self.RaidStatusIndicator:Show()
    elseif inParty then
        self.RaidStatusIndicator:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Waiting")
        self.RaidStatusIndicator:Show()
    else
        self.RaidStatusIndicator:Hide()
    end
end

-- Wrapper function for Bindings.xml keybinds
function S.GUI:OnSphereClick(button)
    if button == "RightButton" then
        if S.Menu then
            S.Menu:Toggle()
        end
    else
        -- Left click - try to use mount or execute sphere action
        if S.Mounts then
            S.Mounts:MountUp()
        end
    end
end
