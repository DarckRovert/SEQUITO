--[[
    SEQUITO - Data Module
    Contiene tablas de datos estáticos para la interfaz y utilidades.
]]--

local addonName, S = ...
S.Data = {}
S.Data.Classes = {}

-- Utility Buttons (Satellites) Config
-- Spells to show around the sphere (Clockwise from top-right: 45, -45, -135, 135)
-- These are usually defensive/utility buffs or unique class mechanics.

-- WARLOCK
S.Data.Classes["WARLOCK"] = {
    [1] = 47864, -- Create Healthstone (Crear piedra de salud) - Rank 8
    [2] = 47884, -- Create Soulstone (Crear piedra de alma) - Rank 7
    [3] = 47891, -- Shadow Ward (Resguardo de las Sombras) - Rank 4
    [4] = 5697,  -- Unending Breath (Aliento inagotable) - Placeholder (Swapped for pet in GUI)
}

-- Mapeo de habilidades de mascota para reemplazar botones
S.Data.PetSpells = {
    ["Imp"] = 47982, -- Fire Shield (Escudo de Fuego) - O Blood Pact (Pasiva)
    ["Diablillo"] = 47982,
    
    ["Voidwalker"] = 47985, -- Sacrifice (Sacrificio) - Critico
    ["Abisario"] = 47985,
    
    ["Succubus"] = 6358, -- Seduction (Seducción) - Critico
    ["Súcubo"] = 6358,
    
    ["Felhunter"] = 19647, -- Spell Lock (Bloqueo de hechizo) - Critico
    ["Manáfago"] = 19647,
    
    ["Felguard"] = 30198, -- Intercept (Interceptar) - Utility
    ["Guardia Apocalíptico"] = 30198,
}


-- MAGE
S.Data.Classes["MAGE"] = {
    [1] = 43039, -- Ice Barrier (Barrera de Hielo)
    [2] = 43012, -- Fire Ward (Resguardo contra el Fuego)
    [3] = 43015, -- Frost Ward (Resguardo contra la Escarcha)
    [4] = 43046, -- Molten Armor (Armadura de Arrabio)
}

-- PRIEST
S.Data.Classes["PRIEST"] = {
    [1] = 48066, -- Power Word: Shield
    [2] = 6346,  -- Fear Ward
    [3] = 48168, -- Inner Fire
    [4] = 48073, -- Divine Spirit
}

-- DRUID
S.Data.Classes["DRUID"] = {
    [1] = 48468, -- Insect Swarm
    [2] = 53307, -- Thorns
    [3] = 48469, -- Mark of the Wild
    [4] = 22812, -- Barkskin
}

-- PALADIN
S.Data.Classes["PALADIN"] = {
    [1] = 498,   -- Divine Protection
    [2] = 642,   -- Divine Shield
    [3] = 10278, -- Hand of Protection
    [4] = 1044,  -- Hand of Freedom
}

-- SHAMAN
S.Data.Classes["SHAMAN"] = {
    [1] = 324,   -- Lightning Shield
    [2] = 52127, -- Water Shield
    [3] = 974,   -- Earth Shield
    [4] = 57960, -- Water Walking
}

-- HUNTER
S.Data.Classes["HUNTER"] = {
    [1] = 19263, -- Deterrence
    [2] = 5384,  -- Feign Death
    [3] = 3045,  -- Rapid Fire
    [4] = 34074, -- Aspect of the Viper
}

-- ROGUE
S.Data.Classes["ROGUE"] = {
    [1] = 5277,  -- Evasion
    [2] = 31224, -- Cloak of Shadows
    [3] = 2983,  -- Sprint
    [4] = 14185, -- Preparation
}

-- WARRIOR
S.Data.Classes["WARRIOR"] = {
    [1] = 871,   -- Shield Wall
    [2] = 1719,  -- Recklessness
    [3] = 46924, -- Bladestorm
    [4] = 23920, -- Spell Reflection
}

-- DEATHKNIGHT
S.Data.Classes["DEATHKNIGHT"] = {
    [1] = 48707, -- Anti-Magic Shell
    [2] = 48792, -- Icebound Fortitude
    [3] = 49028, -- Dancing Rune Weapon
    [4] = 49222, -- Bone Shield
}
