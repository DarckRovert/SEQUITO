--[[
    SEQUITO - Constants & Config
]]--

local addonName, S = ...

S.Constants = {
    SPHERE_SIZE = 64,
    BUTTON_SIZE = 32,
}

S.Classes = {} -- Module Registry

-- ===========================================================================
-- POLYFILLS FOR WOTLK 3.3.5a
-- ===========================================================================
if not C_Timer then
    C_Timer = {}
    local timerFrame = CreateFrame("Frame")
    timerFrame.tickers = {}
    
    timerFrame:SetScript("OnUpdate", function(self, elapsed)
        for i = #self.tickers, 1, -1 do
            local ticker = self.tickers[i]
            if ticker.cancelled then
                table.remove(self.tickers, i)
            else
                ticker.delay = ticker.delay - elapsed
                if ticker.delay <= 0 then
                    local success, err = pcall(ticker.callback)
                    if not success then
                        geterrorhandler()(err)
                    end
                    
                    if ticker.iterations then
                        ticker.iterations = ticker.iterations - 1
                        if ticker.iterations <= 0 then
                            table.remove(self.tickers, i)
                            ticker.cancelled = true
                        else
                            ticker.delay = ticker.duration
                        end
                    else
                        table.remove(self.tickers, i)
                        ticker.cancelled = true
                    end
                end
            end
        end
    end)

    function C_Timer.After(duration, callback)
        table.insert(timerFrame.tickers, {
            delay = duration,
            callback = callback,
            duration = duration,
            iterations = nil
        })
    end
    
    function C_Timer.NewTicker(duration, callback, iterations)
        local ticker = {
            delay = duration,
            callback = callback,
            duration = duration,
            iterations = iterations 
        }
        table.insert(timerFrame.tickers, ticker)
        return ticker
    end
    
    function C_Timer.CancelTimer(ticker)
        if ticker then
            ticker.cancelled = true
        end
    end
    
    _G.C_Timer = C_Timer
end

-- In WotLK 3.3.5a, COMBAT_LOG_EVENT_UNFILTERED passes args directly to OnEvent(self, event, ...).
-- CombatLogGetCurrentEventInfo does not exist natively and is not needed; individual modules consume arguments directly.

-- Polyfill for IsSpellKnown (doesn't exist in 3.3.5)
if not IsSpellKnown then
    function IsSpellKnown(spellID)
        local name = GetSpellInfo(spellID)
        if not name then return false end
        -- Check if player has the spell in spellbook
        local i = 1
        while true do
            local spellName = GetSpellInfo(i, BOOKTYPE_SPELL)
            if not spellName then break end
            if spellName == name then return true end
            i = i + 1
        end
        return false
    end
    _G.IsSpellKnown = IsSpellKnown
end

-- Polyfill for RegisterAddonMessagePrefix (doesn't exist in 3.3.5)
-- In WotLK 3.3.5, addon messages work without registration
if not RegisterAddonMessagePrefix then
    function RegisterAddonMessagePrefix(prefix)
        -- No-op in 3.3.5, messages work automatically
        return true
    end
    _G.RegisterAddonMessagePrefix = RegisterAddonMessagePrefix
end

-- Polyfill for UnitInRaid (doesn't exist in 3.3.5)
if not UnitInRaid then
    function UnitInRaid(unit)
        if GetNumRaidMembers() == 0 then return nil end
        for i = 1, GetNumRaidMembers() do
            if UnitIsUnit(unit, "raid"..i) then
                return i
            end
        end
        return nil
    end
    _G.UnitInRaid = UnitInRaid
end

-- Polyfill for IsInRaid (doesn't exist in 3.3.5)
if not IsInRaid then
    function IsInRaid()
        return GetNumRaidMembers() > 0
    end
    _G.IsInRaid = IsInRaid
end

-- Polyfill for IsInGroup (doesn't exist in 3.3.5)
if not IsInGroup then
    function IsInGroup()
        return GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0
    end
    _G.IsInGroup = IsInGroup
end

-- Polyfill for GetNumGroupMembers (doesn't exist in 3.3.5)
if not GetNumGroupMembers then
    function GetNumGroupMembers()
        if GetNumRaidMembers() > 0 then
            return GetNumRaidMembers()
        else
            return GetNumPartyMembers()
        end
    end
    _G.GetNumGroupMembers = GetNumGroupMembers
end

-- Polyfill for GetServerTime (doesn't exist in 3.3.5)
if not GetServerTime then
    function GetServerTime()
        return time()
    end
    _G.GetServerTime = GetServerTime
end

-- Polyfill for BackdropTemplateMixin (doesn't exist in 3.3.5)
-- In WotLK, SetBackdrop is called directly on frames, not via template
-- This provides compatibility for code that uses "BackdropTemplate"
if not BackdropTemplateMixin then
    BackdropTemplateMixin = {}
    function BackdropTemplateMixin:OnBackdropLoaded()
        -- No-op, backdrop handled differently in 3.3.5
    end
    function BackdropTemplateMixin:SetupBackdrop()
        -- No-op
    end
    _G.BackdropTemplateMixin = BackdropTemplateMixin
end

-- Polyfill for wipe (should exist but just in case)
if not wipe then
    function wipe(t)
        for k in pairs(t) do
            t[k] = nil
        end
        return t
    end
    _G.wipe = wipe
end

-- Polyfill for GetContainerItemID (doesn't exist in 3.3.5)
-- In WotLK, we parse the item ID from the item link
if not GetContainerItemID then
    function GetContainerItemID(bag, slot)
        local link = GetContainerItemLink(bag, slot)
        if not link then return nil end
        local id = link:match("item:(%d+)")
        return id and tonumber(id) or nil
    end
    _G.GetContainerItemID = GetContainerItemID
end

-- Polyfill for UnitIsGroupLeader (doesn't exist in 3.3.5)
if not UnitIsGroupLeader then
    function UnitIsGroupLeader(unit)
        if GetNumRaidMembers() > 0 then
            for i = 1, GetNumRaidMembers() do
                local name, rank = GetRaidRosterInfo(i)
                if UnitIsUnit(unit, "raid"..i) then
                    return rank == 2
                end
            end
        else
            return IsPartyLeader()
        end
        return false
    end
    _G.UnitIsGroupLeader = UnitIsGroupLeader
end

-- Spell Name/ID Cache and Helpers
S.SpellCache = {}

function S.GetSpellNameByID(spellID)
    if not S.SpellCache[spellID] then
        S.SpellCache[spellID] = GetSpellInfo(spellID)
    end
    return S.SpellCache[spellID]
end

function S.GetSpellIDByName(spellName)
    -- Reverse lookup in cache
    for id, name in pairs(S.SpellCache) do
        if name == spellName then
            return id
        end
    end
    return nil
end
