--[[
    Sequito - The Coven (Utility & Rituals)
    Modulo v11.0: Gestion de invos, piedras y maldiciones.
]]

local addonName, S = ...
S.Coven = {}
local Coven = S.Coven

-- Config
local SUMMON_KEYWORDS = {"summ", "tp", "123", "summon"}

-- State
Coven.Queue = {} -- {name, class, timestamp}
Coven.ActivePortal = false

function Coven:Initialize()
    self.Frame = CreateFrame("Frame")
    self.Frame:RegisterEvent("CHAT_MSG_RAID")
    self.Frame:RegisterEvent("CHAT_MSG_RAID_LEADER")
    self.Frame:RegisterEvent("CHAT_MSG_PARTY")
    self.Frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    
    self.Frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    
    self.Frame:SetScript("OnEvent", function(self, event, ...)
        if event == "UNIT_SPELLCAST_SUCCEEDED" then
            Coven:OnSpellCast(...)
        elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
            Coven:CheckDoomSacrifice(...)
        else
            Coven:OnChatMsg(...)
        end
    end)
    
    print("|cFF9900FFSequito Coven|r: Rituals ready.")
end

-- ============================================================================
-- SUMMON ASSISTANT
-- ============================================================================

function Coven:OnChatMsg(msg, sender)
    if not S.db.profile.SummonAssistant then return end
    
    msg = string.lower(msg)
    for _, keyword in ipairs(SUMMON_KEYWORDS) do
        if string.find(msg, keyword) then
            self:AddToQueue(sender)
            break
        end
    end
end

function Coven:AddToQueue(sender)
    -- Check if already in queue
    for i, p in ipairs(self.Queue) do
        if p.name == sender then return end
    end
    
    local _, class = UnitClass(sender) -- Only works if in range/group
    
    table.insert(self.Queue, {
        name = sender,
        class = class or "UNKNOWN",
        time = GetTime()
    })
    
    self:UpdateUI()
    print("|cFF9900FFSequito:|r " .. sender .. " añadido a la cola de invocación.")
end

-- ============================================================================
-- RITUAL OF DOOM (RULETA RUSA)
-- ============================================================================
function Coven:OnSpellCast(unit, spellName, rank, lineId, spellId)
    if unit ~= "player" then return end
    
    -- Ritual de Invocación (ID 698)
    if spellId == 698 or spellName == "Ritual de invocación" then
        if UnitExists("target") and UnitIsPlayer("target") and not UnitIsUnit("target", "player") then
            local targetName = UnitName("target")
            SendChatMessage("Invocando a " .. targetName .. " a mi posición. ¡Clic al portal!", "RAID")
        else
            SendChatMessage("Invocando portal de reunión.", "RAID") 
        end
        self:PopQueue()
    -- Ritual de la Perdición (ID 18540)
    elseif spellId == 18540 or spellName == "Ritual de la perdición" then
        self:StartDoomRoulette()
    end
end

function Coven:StartDoomRoulette()
    SendChatMessage("¡RULETA RUSA INICIADA! ¿Quién será el sacrificio?", "RAID_WARNING")
    SendChatMessage("El Ritual de la Perdición ha comenzado. Uno morirá para invocar al Guardia Apocalíptico.", "RAID")
    
    self.DoomActive = true
    self.DoomStartTime = GetTime()
    
    -- Doom logic handled in the main event frame
    
    -- Auto-disable after 20s
    -- WotLK Fix: C_Timer doesn't exist, using OnUpdate frame
    local _tf = CreateFrame("Frame"); _tf.e = 0; _tf:SetScript("OnUpdate", function(f,d) f.e=f.e+d; if f.e>=20 then Coven.DoomActive=false; f:SetScript("OnUpdate",nil) end end) -- WotLK Timer Fix Applied
    --[[ Removed old C_Timer code: 
        self.DoomActive = false 
        -- We keep the hook active to avoid complexity of removing/restoring multiple events ]]
    end)
end

function Coven:CheckDoomSacrifice(...)
    if not self.DoomActive then return end
    
    local timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
    
    -- Detect DEATH
    if subEvent == "UNIT_DIED" then
        -- Check if it's a player in our group
        if UnitInRaid(destName) or UnitInParty(destName) or destName == UnitName("player") then
             -- Announce the winner!
             SendChatMessage("¡" .. destName .. " HA SIDO SACRIFICADO!", "RAID_WARNING")
             SendChatMessage("Gracias por tu ofrenda, " .. destName .. ". El Guardia Apocalíptico te saluda.", "RAID")
             
             self.DoomActive = false 
             PlaySound("RaidWarning")
        end
    end
end
function Coven:PopQueue()
    if #self.Queue > 0 then
        local p = table.remove(self.Queue, 1)
        SendChatMessage("Invocando a " .. p.name .. "...", "RAID")
        self:UpdateUI()
    end
end

function Coven:UpdateUI()
    -- Placeholder: Here we would update a small frame showing the queue list
    -- For now, just print
    if #self.Queue > 0 then
        local list = ""
        for i, p in ipairs(self.Queue) do
            list = list .. p.name .. ", "
        end
        -- print("Cola Summons: " .. list)
    end
end

-- ============================================================================
-- ONE-CLICK MACRO GENERATOR
-- ============================================================================

function Coven:GetNextSummonTarget()
    if #self.Queue > 0 then
        return self.Queue[1].name
    end
    return nil
end

-- Create Secure Button for Summoning next person in queue
function Coven:CreateSummonButton()
    local btn = CreateFrame("Button", "SequitoSummonBtn", UIParent, "SecureActionButtonTemplate")
    btn:SetAttribute("type", "macro")
    btn:SetSize(40, 40)
    btn:SetPoint("CENTER", 0, -100)
    
    btn.tex = btn:CreateTexture(nil, "ARTWORK")
    btn.tex:SetAllPoints()
    btn.tex:SetTexture("Interface\\Icons\\Spell_Shadow_Twilight")
    
    -- Dynamically update macro text based on queue
    -- LIMITATION: Cannot change attributes in combat
    btn:SetScript("PreClick", function()
        if InCombatLockdown() then return end
        
        local target = Coven:GetNextSummonTarget()
        if target then
            local macro = "/target " .. target .. "\n/cast Ritual de invocación"
            btn:SetAttribute("macrotext", macro)
        else
             btn:SetAttribute("macrotext", "/say Cola vacía!")
        end
    end)
    
    btn:Hide() -- Hide by default, show when queue > 0
    self.SummonButton = btn
end

-- ============================================================================
-- CURSE MANAGER (The Coven)
-- ============================================================================

function Coven:GetWarlocks()
    local warlocks = {}
    if GetNumRaidMembers() > 0 then
        for i=1, GetNumRaidMembers() do
            local name, _, _, _, _, class = GetRaidRosterInfo(i)
            if class == "WARLOCK" then
                table.insert(warlocks, name)
            end
        end
    elseif IsInGroup() then
        local name, class = UnitName("player"), select(2, UnitClass("player"))
        if class == "WARLOCK" then table.insert(warlocks, name) end
        for i=1, GetNumPartyMembers() do
            local n, _, _, _, _, c = GetRaidRosterInfo(i) -- Or Party unit check, but RosterInfo works if in raid group
            -- Fallback for 5-man
            local u = "party"..i
            if UnitExists(u) and select(2, UnitClass(u)) == "WARLOCK" then
                table.insert(warlocks, UnitName(u))
            end
        end
    else
         local name, class = UnitName("player"), select(2, UnitClass("player"))
         if class == "WARLOCK" then table.insert(warlocks, name) end
    end
    -- Sort alphabetically for consistent assignment
    table.sort(warlocks)
    return warlocks
end

function Coven:AssignCurses()
    local warlocks = self:GetWarlocks()
    if #warlocks == 0 then 
        print("|cFF9900FFSequito:|r No hay brujos en el grupo.")
        return 
    end
    
    local assignments = {}
    -- Priority: Elements > Doom > Agony > Tongues > Weakness
    local curses = {
        "Maldición de los Elementos", -- Elements
        "Maldición del Apocalipsis",  -- Doom (Bosses)
        "Maldición de Agonía",        -- Agony
        "Maldición de las Lenguas",   -- Tongues
        "Maldición de Debilidad"      -- Weakness
    }
    
    -- Assign
    print("|cFF9900FFSequito Coven:|r Asignación de Maldiciones:")
    local msg = "Sequito: Asignación de Maldiciones -> "
    
    for i, lock in ipairs(warlocks) do
        local curse = curses[i] or "Maldición de Agonía" -- Default to Agony if > 5 locks
        print(string.format("  - %s: %s", lock, curse))
        msg = msg .. string.format("[%s: %s] ", lock, curse)
    end
    
    -- Announce to Raid
    if GetNumRaidMembers() > 0 and (IsRaidLeader() or IsRaidOfficer()) then
        SendChatMessage(msg, "RAID")
    elseif IsInGroup() then
        SendChatMessage(msg, "PARTY")
    end
end

