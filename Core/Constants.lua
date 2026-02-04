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
    local timers = {}
    
    timerFrame:SetScript("OnUpdate", function(self, elapsed)
        for i = #timers, 1, -1 do
            local timer = timers[i]
            timer.expires = timer.expires - elapsed
            if timer.expires <= 0 then
                table.remove(timers, i)
                if timer.callback then
                    pcall(timer.callback) -- Execute safely
                end
            end
        end
    end)
    
    function C_Timer.After(duration, callback)
        table.insert(timers, { expires = duration, callback = callback })
    end
    
    -- Global access just in case
    _G.C_Timer = C_Timer
end

-- Polyfill for CombatLogGetCurrentEventInfo (doesn't exist in 3.3.5)
-- In WotLK 3.3.5, COMBAT_LOG_EVENT_UNFILTERED passes args directly
-- We create a wrapper that stores the last event args
if not CombatLogGetCurrentEventInfo then
    local combatLogArgs = {}
    
    local combatLogCapture = CreateFrame("Frame")
    combatLogCapture:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    combatLogCapture:SetScript("OnEvent", function(self, event, ...)
        -- Store all arguments from the combat log event
        wipe(combatLogArgs)
        for i = 1, select("#", ...) do
            combatLogArgs[i] = select(i, ...)
        end
    end)
    
    function CombatLogGetCurrentEventInfo()
        return unpack(combatLogArgs)
    end
    
    _G.CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
end

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
