--[[
    SEQUITO - Event Manager
    Handles game events to trigger speech and visuals.
]]--

local addonName, S = ...
S.Events = {}

-- Helper para obtener configuración
function S.Events:GetOption(key)
    if S.ModuleConfig then
        return S.ModuleConfig:GetValue("EventManager", key)
    end
    return true
end

local f = CreateFrame("Frame")
f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
f:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED") 

f:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, spellName, rank, lineID, spellID = ...
        if unit == "player" and spellName then
            S.Events:OnSpellCast(spellName, spellID)
        end
    end
end)

function S.Events:OnSpellCast(spellName, spellID)
    if not self:GetOption("enabled") then return end
    
    -- Logic to detect what triggered
    -- Summoning Ritual
    if spellID == 698 then -- Ritual of Summoning
        S:Speak("Summon")
    -- Soulstone
    elseif spellName:match("Piedra del alma") or spellID == 20707 then 
        S:Speak("Soulstone", UnitName("target"))
    -- Resurrection
    elseif spellID == 20484 or spellID == 7328 then -- Rebirth / Redemption (Generic examples)
        S:Speak("Resurrect", UnitName("target"))
    end
end

function S:Speak(category, target)
    if not S.Events:GetOption("enabled") then return end
    if not S.db.profile.ShowSpeech then return end -- Global toggle check
    
    local msg = S:GetRandomSpeech(category)
    if msg then
        if target then
             msg = msg:gsub("<target>", target)
        else
             msg = msg:gsub("<target>", "alguien")
        end
        
        -- Send to Chat
        local chatType = S.Events:GetOption("chatChannel") or "SAY"
        if IsInRaid() and chatType == "RAID" then
            -- Fallback if not in raid but user selected raid? SendChatMessage handles warnings usually
        elseif IsInGroup() and chatType == "PARTY" then
            -- ok
        end
        
        -- Safety check for instance channels
        local instanceType = select(2, IsInInstance())
        if instanceType == "pvp" or instanceType == "arena" then
            if chatType == "SAY" then chatType = "INSTANCE_CHAT" end
        end

        SendChatMessage(msg, chatType)
    end
end

-- Registrar en ModuleConfig
if S.ModuleConfig then
    S.ModuleConfig:RegisterModule("EventManager", {
        name = "Event Manager",
        description = "Maneja eventos del juego para activar diálogos y efectos visuales automáticamente.",
        category = "utility",
        icon = "Interface\\Icons\\Spell_Holy_PrayerOfHealing",
        options = {
            {
                key = "enabled",
                type = "checkbox",
                label = "Habilitar Event Manager",
                tooltip = "Activa el sistema de eventos automáticos",
                default = true
            },
            {
                key = "chatChannel",
                type = "dropdown",
                label = "Canal de Anuncio",
                tooltip = "Canal donde se anuncian los eventos",
                options = {
                    {text = "Decir (SAY)", value = "SAY"},
                    {text = "Grupo (PARTY)", value = "PARTY"},
                    {text = "Banda (RAID)", value = "RAID"},
                },
                default = "SAY"
            }
        }
    })
end
