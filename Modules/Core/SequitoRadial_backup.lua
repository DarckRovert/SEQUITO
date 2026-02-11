--[[
    Sequito - Radial Menu
    Menu circular de acceso rapido (Middle Click)
]]

local addonName, S = ...
S.Radial = {}
local R = S.Radial

-- Config
local RADIUS = 80
local BUTTON_SIZE = 36

function R:Initialize()
    if not S.db.profile.RadialEnabled then return end
    
    self.Buttons = {}
    self.IsVisible = false
    
    -- Main Frame (Invisible, holds buttons)
    self.Frame = CreateFrame("Frame", "SequitoRadialFrame", UIParent)
    self.Frame:SetFrameStrata("DIALOG")
    self.Frame:SetSize(1, 1)
    self.Frame:Hide()
end

function R:Toggle()
    if not S.Sphere then return end
    if not self.Frame then self:Initialize() end
    if not self.Frame then return end
    
    if self.IsVisible then
        self:Hide()
    else
        self:Show()
    end
end

function R:Show()
    if InCombatLockdown() then 
        print("|cFFFF0000Sequito:|r No se puede abrir el menú radial en combate.")
        return 
    end
    
    self:UpdateButtons()
    
    -- Position center at sphere center
    local x, y = S.Sphere:GetCenter()
    if x and y then
        self.Frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    end
    
    self.Frame:Show()
    self.IsVisible = true
end

function R:Hide()
    self.Frame:Hide()
    self.IsVisible = false
end

function R:UpdateButtons()
    -- Clear old buttons (Hit Hide)
    for _, btn in pairs(self.Buttons) do btn:Hide() end
    
    local actions = self:GetActions()
    local num = #actions
    if num == 0 then return end
    
    local angleStep = 360 / num
    local startAngle = 90 -- Start at top
    
    for i, action in ipairs(actions) do
        local btn = self.Buttons[i]
        if not btn then
            btn = CreateFrame("Button", "SequitoRadialBtn"..i, self.Frame, "SecureActionButtonTemplate")
            btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
            
            btn.icon = btn:CreateTexture(nil, "BACKGROUND")
            btn.icon:SetAllPoints()
            
            btn.border = btn:CreateTexture(nil, "OVERLAY")
            btn.border:SetAllPoints()
            btn.border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
            btn.border:SetBlendMode("ADD")
            
            btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
            
            self.Buttons[i] = btn
        end
        
        -- Position
        local angle = math.rad(startAngle - ((i-1) * angleStep))
        local bx = math.cos(angle) * RADIUS
        local by = math.sin(angle) * RADIUS
        
        btn:ClearAllPoints()
        btn:SetPoint("CENTER", self.Frame, "CENTER", bx, by)
        
        -- Setup Attributes
        btn:SetAttribute("type", action.type)
        if action.type == "spell" then
            btn:SetAttribute("spell", action.spell)
            btn.icon:SetTexture(GetSpellTexture(action.spell))
        elseif action.type == "item" then
            btn:SetAttribute("item", action.item)
            btn.icon:SetTexture(GetItemIcon(action.item))
        elseif action.type == "macro" then
            btn:SetAttribute("macrotext", action.macro)
            btn.icon:SetTexture(action.icon)
        end
        
        -- Tooltip
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(action.text, 1, 1, 1)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        
        -- Auto-close on click
        btn:SetScript("PostClick", function()
             -- Can't hide secure frames in combat, but we blocked opening in combat anyway
             if not InCombatLockdown() then
                 R:Hide()
             end
        end)
        
        btn:Show()
    end
end

function R:GetActions()
    local list = {}
    local _, class = UnitClass("player")
    
    if class == "WARLOCK" then
        -- 1. Healthstone (ID 47878 Rank 6)
        table.insert(list, {type="spell", spell=47878, text="Piedra de Salud"})
        
        -- 2. Soulstone (ID 47884 Rank 6)
        table.insert(list, {type="spell", spell=47884, text="Piedra de Alma"})
        
        -- 3. Ritual of Summoning (ID 698)
        table.insert(list, {type="spell", spell=698, text="Ritual de Invocación"})
        
        -- 4. Ritual of Souls (ID 29893)
        table.insert(list, {type="spell", spell=29893, text="Ritual de Almas"})
        
        -- 5. Demons (Check availability)
        if IsSpellKnown(688) then -- Imp
            table.insert(list, {type="spell", spell=688, text="Invocar Diablillo"})
        end
        if IsSpellKnown(697) then -- Voidwalker
            table.insert(list, {type="spell", spell=697, text="Invocar Abisario"})
        end
        if IsSpellKnown(712) then -- Succubus
            table.insert(list, {type="spell", spell=712, text="Invocar Súcubo"})
        end
        if IsSpellKnown(691) then -- Felhunter
            table.insert(list, {type="spell", spell=691, text="Invocar Manáfago"})
        end
        if IsSpellKnown(30146) then -- Felguard
            table.insert(list, {type="spell", spell=30146, text="Invocar Guardia Apocalíptico"})
        end
        
        -- 6. Weapon Buffs (Firestone/Spellstone)
        -- We default to Grand (Highest Rank 6? ID 2354? No, create spell IDs vary)
        -- Let's use name "Crear piedra de..." safer for ranks
        -- But wait, user is on 3.3.5 where ranks exist but max usually auto-selects.
        -- Spell IDs for "Create Firestone" (Rank 7): 60220
        -- Spell IDs for "Create Spellstone" (Rank 6): 47888
        
        if IsSpellKnown(60220) then
            table.insert(list, {type="spell", spell=60220, text="Crear Piedra de Fuego"})
        elseif IsSpellKnown(47888) then
             table.insert(list, {type="spell", spell=47888, text="Crear Piedra de Hechizo"})
        end
        
    elseif class == "MAGE" then
         -- Tables & Portals
         table.insert(list, {type="spell", spell=42955, text="Mesa de Comida"}) -- Conjure Refreshment Table
         table.insert(list, {type="spell", spell=53140, text="TP Dalaran"})
         table.insert(list, {type="spell", spell=32271, text="TP Shattrath"})
    end
    
    -- General
    -- Hearthstone (Item 6948)
    if GetItemCount(6948) > 0 then
        table.insert(list, {type="item", item=6948, text="Piedra de Hogar"})
    end
    
    -- Mount (Smart Macro)
    local mountMacro = "/castrandom [flyable] Grifo"
    
    if class == "WARLOCK" then
        if IsSpellKnown(23161) then -- Dreadsteed (100%)
            mountMacro = "/cast [flyable] Alfombra voladora magnífica; [nomounted] Invocar corcel de la muerte"
        elseif IsSpellKnown(5784) then -- Felsteed (60%)
            mountMacro = "/cast [flyable] Alfombra voladora magnífica; [nomounted] Invocar corcel vil"
        else
            mountMacro = "/castrandom [flyable] Grifo; Caballo"
        end
    else
        mountMacro = "/castrandom [flyable] Grifo; Caballo"
    end

    table.insert(list, {
        type="macro", 
        macro=mountMacro, 
        icon="Interface\\Icons\\Ability_Mount_Charger", 
        text="Montura de Clase"
    })
    
    return list
end

-- Config
if S.ModuleConfig then
    S.ModuleConfig:RegisterModule("Radial", {
        name = "Menú Radial",
        description = "Acceso rápido (Click Central)",
        category = "general",
        icon = "Interface\\Icons\\Ability_Spy",
        options = {
            {key = "RadialEnabled", type = "checkbox", label = "Habilitar Menú Radial", default = true}
        }
    })
end
