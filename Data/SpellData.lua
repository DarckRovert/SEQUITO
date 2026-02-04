--[[
    SEQUITO - Spell Data for WotLK 3.3.5
    Tablas de hechizos por clase para RaidAssist
]]--

local addonName, S = ...

S.SpellData = {}

-- ===========================================================================
-- INTERRUPCIONES POR CLASE
-- ===========================================================================
S.SpellData.Interrupts = {
    DEATHKNIGHT = {
        { id = 47528, name = "Mind Freeze" },
        { id = 49576, name = "Death Grip" }, -- Puede interrumpir casts
    },
    DRUID = {
        -- Druidas no tienen interrupción directa en 3.3.5
    },
    HUNTER = {
        { id = 34490, name = "Silencing Shot" },
    },
    MAGE = {
        { id = 2139, name = "Counterspell" },
    },
    PALADIN = {
        -- Paladines no tienen interrupción en 3.3.5 (Rebuke es de Cata+)
    },
    PRIEST = {
        { id = 15487, name = "Silence" }, -- Shadow
    },
    ROGUE = {
        { id = 1766, name = "Kick" },
    },
    SHAMAN = {
        { id = 57994, name = "Wind Shear" },
    },
    WARLOCK = {
        { id = 19647, name = "Spell Lock" }, -- Felhunter
    },
    WARRIOR = {
        { id = 72, name = "Shield Bash" },
        { id = 23922, name = "Shield Slam" }, -- Puede interrumpir
        { id = 6552, name = "Pummel" },
    },
}

-- ===========================================================================
-- COOLDOWNS IMPORTANTES POR CLASE
-- ===========================================================================
S.SpellData.ImportantCooldowns = {
    DEATHKNIGHT = {
        { id = 48707, name = "Anti-Magic Shell" },
        { id = 48792, name = "Icebound Fortitude" },
        { id = 49222, name = "Bone Shield" },
        { id = 51052, name = "Anti-Magic Zone" },
        { id = 49016, name = "Hysteria" },
        { id = 49203, name = "Hungering Cold" },
    },
    DRUID = {
        { id = 22812, name = "Barkskin" },
        { id = 61336, name = "Survival Instincts" },
        { id = 17116, name = "Nature's Swiftness" },
        { id = 29166, name = "Innervate" },
        { id = 50334, name = "Berserk" },
        { id = 18562, name = "Swiftmend" },
    },
    HUNTER = {
        { id = 19263, name = "Deterrence" },
        { id = 5384, name = "Feign Death" },
        { id = 34490, name = "Silencing Shot" },
        { id = 19574, name = "Bestial Wrath" },
        { id = 3045, name = "Rapid Fire" },
    },
    MAGE = {
        { id = 45438, name = "Ice Block" },
        { id = 12472, name = "Icy Veins" },
        { id = 12043, name = "Presence of Mind" },
        { id = 11958, name = "Cold Snap" },
        { id = 12051, name = "Evocation" },
    },
    PALADIN = {
        { id = 498, name = "Divine Protection" },
        { id = 642, name = "Divine Shield" },
        { id = 6940, name = "Hand of Sacrifice" },
        { id = 1022, name = "Hand of Protection" },
        { id = 1044, name = "Hand of Freedom" },
        { id = 31821, name = "Aura Mastery" },
        { id = 54428, name = "Divine Plea" },
        { id = 31884, name = "Avenging Wrath" },
    },
    PRIEST = {
        { id = 33206, name = "Pain Suppression" },
        { id = 47585, name = "Dispersion" },
        { id = 10060, name = "Power Infusion" },
        { id = 64843, name = "Divine Hymn" },
        { id = 64901, name = "Hymn of Hope" },
        { id = 6346, name = "Fear Ward" },
    },
    ROGUE = {
        { id = 31224, name = "Cloak of Shadows" },
        { id = 5277, name = "Evasion" },
        { id = 14185, name = "Preparation" },
        { id = 51690, name = "Killing Spree" },
        { id = 13750, name = "Adrenaline Rush" },
    },
    SHAMAN = {
        { id = 16188, name = "Nature's Swiftness" },
        { id = 30823, name = "Shamanistic Rage" },
        { id = 2825, name = "Bloodlust" },
        { id = 32182, name = "Heroism" },
        { id = 51490, name = "Thunderstorm" },
        { id = 16166, name = "Elemental Mastery" },
    },
    WARLOCK = {
        { id = 47893, name = "Fel Armor" },
        { id = 18708, name = "Fel Domination" },
        { id = 47986, name = "Sacrifice" }, -- Voidwalker
    },
    WARRIOR = {
        { id = 871, name = "Shield Wall" },
        { id = 12975, name = "Last Stand" },
        { id = 55694, name = "Enraged Regeneration" },
        { id = 1719, name = "Recklessness" },
        { id = 12292, name = "Death Wish" },
        { id = 23920, name = "Spell Reflection" },
        { id = 46924, name = "Bladestorm" },
    },
}

-- ===========================================================================
-- CONSUMIBLES (BUFFS)
-- ===========================================================================
S.SpellData.Consumables = {
    -- Flasks (WotLK)
    { id = 53755, name = "Flask of the Frost Wyrm", type = "Flask" },
    { id = 53758, name = "Flask of Stoneblood", type = "Flask" },
    { id = 54212, name = "Flask of Pure Mojo", type = "Flask" },
    { id = 53760, name = "Flask of Endless Rage", type = "Flask" },
    { id = 17627, name = "Flask of the Titans", type = "Flask" }, -- TBC flask
    { id = 28520, name = "Flask of Relentless Assault", type = "Flask" }, -- TBC flask
    
    -- Elixirs (Battle) - Cuentan como Flask para el check
    { id = 53746, name = "Elixir of Mighty Strength", type = "Flask" },
    { id = 53748, name = "Elixir of Mighty Agility", type = "Flask" },
    { id = 53749, name = "Elixir of Mighty Thoughts", type = "Flask" },
    { id = 53747, name = "Elixir of Expertise", type = "Flask" },
    { id = 53751, name = "Elixir of Mighty Fortitude", type = "Flask" },
    { id = 53764, name = "Elixir of Mighty Mageblood", type = "Flask" },
    
    -- Elixirs (Guardian)
    { id = 53752, name = "Lesser Flask of Toughness", type = "Flask" },
    { id = 53763, name = "Elixir of Protection", type = "Flask" },
    
    -- Food Buffs
    { id = 57399, name = "Well Fed", type = "Food" }, -- Generic food buff
    { id = 57371, name = "Fish Feast", type = "Food" },
    { id = 57356, name = "Great Feast", type = "Food" },
    { id = 57325, name = "Tender Shoveltusk Steak", type = "Food" },
    { id = 57327, name = "Mighty Rhino Dogs", type = "Food" },
    { id = 57332, name = "Spicy Fried Herring", type = "Food" },
    { id = 57334, name = "Rhinolicious Wormsteak", type = "Food" },
}

-- ===========================================================================
-- DIMINISHING RETURNS (DR) - Para CCCoordinator
-- ===========================================================================
S.SpellData.DiminishingReturns = {
    -- Stuns
    ["stun"] = {
        { id = 853, name = "Hammer of Justice" },       -- Paladin
        { id = 408, name = "Kidney Shot" },             -- Rogue
        { id = 1833, name = "Cheap Shot" },             -- Rogue
        { id = 5211, name = "Bash" },                   -- Druid
        { id = 22570, name = "Maim" },                  -- Druid
        { id = 30283, name = "Shadowfury" },            -- Warlock
        { id = 20549, name = "War Stomp" },             -- Tauren Racial
        { id = 46968, name = "Shockwave" },             -- Warrior
        { id = 12809, name = "Concussion Blow" },       -- Warrior
        { id = 49203, name = "Hungering Cold" },        -- DK
        { id = 47481, name = "Gnaw" },                  -- DK Ghoul
        { id = 19577, name = "Intimidation" },          -- Hunter
        { id = 44572, name = "Deep Freeze" },           -- Mage
        { id = 64044, name = "Psychic Horror" },        -- Priest
    },
    -- Fears
    ["fear"] = {
        { id = 5782, name = "Fear" },                   -- Warlock
        { id = 6215, name = "Fear" },                   -- Warlock (rank 2)
        { id = 6213, name = "Fear" },                   -- Warlock (rank 3)
        { id = 5484, name = "Howl of Terror" },         -- Warlock
        { id = 8122, name = "Psychic Scream" },         -- Priest
        { id = 1513, name = "Scare Beast" },            -- Hunter
        { id = 5246, name = "Intimidating Shout" },     -- Warrior
    },
    -- Roots
    ["root"] = {
        { id = 339, name = "Entangling Roots" },        -- Druid
        { id = 19975, name = "Entangling Roots" },      -- Druid (Nature's Grasp)
        { id = 122, name = "Frost Nova" },              -- Mage
        { id = 33395, name = "Freeze" },                -- Mage Water Elemental
        { id = 64695, name = "Earthgrab" },             -- Shaman (Earthbind totem talent)
    },
    -- Silences
    ["silence"] = {
        { id = 15487, name = "Silence" },               -- Priest
        { id = 1330, name = "Garrote - Silence" },      -- Rogue
        { id = 18469, name = "Silenced - Improved Counterspell" }, -- Mage
        { id = 34490, name = "Silencing Shot" },        -- Hunter
        { id = 18425, name = "Silenced - Improved Kick" }, -- Rogue
        { id = 47476, name = "Strangulate" },           -- DK
    },
    -- Polymorphs/Incapacitates
    ["incapacitate"] = {
        { id = 118, name = "Polymorph" },               -- Mage
        { id = 28272, name = "Polymorph: Pig" },        -- Mage
        { id = 28271, name = "Polymorph: Turtle" },     -- Mage
        { id = 61305, name = "Polymorph: Black Cat" },  -- Mage
        { id = 61721, name = "Polymorph: Rabbit" },     -- Mage
        { id = 61780, name = "Polymorph: Turkey" },     -- Mage
        { id = 2637, name = "Hibernate" },              -- Druid
        { id = 3355, name = "Freezing Trap" },          -- Hunter
        { id = 19386, name = "Wyvern Sting" },          -- Hunter
        { id = 20066, name = "Repentance" },            -- Paladin
        { id = 1776, name = "Gouge" },                  -- Rogue
        { id = 6770, name = "Sap" },                    -- Rogue
        { id = 51514, name = "Hex" },                   -- Shaman
        { id = 710, name = "Banish" },                  -- Warlock
        { id = 6358, name = "Seduction" },              -- Warlock Succubus
    },
    -- Disarms
    ["disarm"] = {
        { id = 676, name = "Disarm" },                  -- Warrior
        { id = 51722, name = "Dismantle" },             -- Rogue
        { id = 64058, name = "Psychic Horror" },        -- Priest (disarm component)
    },
    -- Cyclone (own category)
    ["cyclone"] = {
        { id = 33786, name = "Cyclone" },               -- Druid
    },
    -- Horrors
    ["horror"] = {
        { id = 6789, name = "Death Coil" },             -- Warlock
        { id = 64044, name = "Psychic Horror" },        -- Priest
    },
}

-- ===========================================================================
-- TRINKETS PVP - Para TrinketTracker
-- ===========================================================================
S.SpellData.PvPTrinkets = {
    -- Spell ID del efecto de trinket PvP (Will of the Forsaken / Every Man for Himself / Trinket)
    { id = 42292, name = "PvP Trinket" },               -- Generic PvP Trinket effect
    { id = 59752, name = "Every Man for Himself" },     -- Human Racial
    { id = 7744, name = "Will of the Forsaken" },       -- Undead Racial
}

-- ===========================================================================
-- BATTLE RES - Para CooldownMonitor
-- ===========================================================================
S.SpellData.BattleRes = {
    { id = 48477, name = "Rebirth", class = "DRUID", cooldown = 600 },
    { id = 20707, name = "Soulstone Resurrection", class = "WARLOCK", cooldown = 900 },
    { id = 61999, name = "Raise Ally", class = "DEATHKNIGHT", cooldown = 600 },
}

-- ===========================================================================
-- HEROISM/BLOODLUST - Para CooldownMonitor
-- ===========================================================================
S.SpellData.Heroism = {
    { id = 2825, name = "Bloodlust", class = "SHAMAN", faction = "Horde" },
    { id = 32182, name = "Heroism", class = "SHAMAN", faction = "Alliance" },
}

-- ===========================================================================
-- HELPER FUNCTIONS
-- ===========================================================================

-- Obtener interrupciones de una clase
function S.SpellData:GetInterruptsForClass(class)
    return self.Interrupts[class] or {}
end

-- Obtener cooldowns importantes de una clase
function S.SpellData:GetCooldownsForClass(class)
    return self.ImportantCooldowns[class] or {}
end

-- Verificar si un spell es una interrupción
function S.SpellData:IsInterruptSpell(spellName)
    for class, spells in pairs(self.Interrupts) do
        for _, spell in ipairs(spells) do
            if spell.name == spellName then
                return true
            end
        end
    end
    return false
end

-- Verificar si un spell es un cooldown importante
function S.SpellData:IsImportantCooldown(spellName)
    for class, spells in pairs(self.ImportantCooldowns) do
        for _, spell in ipairs(spells) do
            if spell.name == spellName then
                return true
            end
        end
    end
    return false
end

-- Verificar si un buff es de consumible
function S.SpellData:IsConsumableBuff(buffName)
    if not self.Consumables then return nil end
    if not buffName then return nil end
    
    for _, buff in ipairs(self.Consumables) do
        if buff.name and buff.name == buffName then
            return buff.type
        end
    end
    return nil
end

-- Pre-cachear todos los spell names
function S.SpellData:CacheAllSpells()
    local count = 0
    
    -- Cache interrupts
    for class, spells in pairs(self.Interrupts) do
        for _, spell in ipairs(spells) do
            S.GetSpellNameByID(spell.id)
            count = count + 1
        end
    end
    
    -- Cache cooldowns
    for class, spells in pairs(self.ImportantCooldowns) do
        for _, spell in ipairs(spells) do
            S.GetSpellNameByID(spell.id)
            count = count + 1
        end
    end
    
    -- Cache consumables
    for _, buff in ipairs(self.Consumables) do
        S.GetSpellNameByID(buff.id)
        count = count + 1
    end
    
    return count
end
