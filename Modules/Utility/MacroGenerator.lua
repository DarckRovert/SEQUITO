--[[
    SEQUITO - Macro Generator (Necrosis Replication Edition)
    Replica EXACTAMENTE la lógica de macros de Necrosis (Smart Pet, Smart Heal, Smart CC).
    INCLUDES: Rotaciones Inteligentes (Portado de NecrosisBrain.lua + NecrosisUniversal.lua)
    World of Warcraft 3.3.5a
]]--

local addonName, S = ...
S.MacroGen = {}

-- ===========================================================================
-- 1. HELPERS: RACIALS & SPELLS
-- ===========================================================================

S.MacroGen.Races = {
    ["Human"]     = { ID = 59752 }, 
    ["Dwarf"]     = { ID = 20594 }, 
    ["NightElf"]  = { ID = 58984 }, 
    ["Gnome"]     = { ID = 20589 }, 
    ["Draenei"]   = { ID = 59542 }, 
    ["Orc"]       = { ID = 20572 }, 
    ["Scourge"]   = { ID = 7744 },  
    ["Tauren"]    = { ID = 20549 }, 
    ["Troll"]     = { ID = 26297 }, 
    ["BloodElf"]  = { ID = 28730 }, 
}

function S.MacroGen:CreateMacro(name, icon, body, perChar)
    if not name or not body then return nil end
    local isPerChar = perChar or 1
    local macroID = GetMacroIndexByName(name)
    if macroID > 0 then
        EditMacro(macroID, name, icon or 1, body)
        return macroID
    else
        local numAccount, numChar = GetNumMacros()
        if (isPerChar == 1 and numChar < 18) or (isPerChar ~= 1 and numAccount < 36) then
            return CreateMacro(name, icon or 1, body, isPerChar)
        else
            print("|cFFFF0000Sequito Error:|r Espacio de macros lleno. No se pudo crear: " .. tostring(name))
            return nil
        end
    end
end

function S.MacroGen:GetSmartSpell(id, defaultName)
    local name = GetSpellInfo(id)
    if name and IsSpellKnown(id) then
        return name
    end
    -- Fallback for specific hardcoded IDs that might be replacers
    return defaultName or name 
end

function S.MacroGen:GetSmartItem(id, defaultName)
    local name = GetItemInfo(id)
    if name then return name end
    return defaultName
end

function S.MacroGen:GetRacialSpell()
    local _, raceEn = UnitRace("player")
    local data = self.Races[raceEn]
    if data then
        return self:GetSmartSpell(data.ID)
    end
    return nil
end

-- ===========================================================================
-- 2. UTILITY GENERATORS (Smart Macros)
-- ===========================================================================

-- 1. Smart Interrupt
function S.MacroGen:GetSmartInterrupt(class)
    local spellId = 0
    if class == "WARRIOR" then spellId = 6552 -- Pummel
    elseif class == "PALADIN" then return nil 
    elseif class == "ROGUE" then spellId = 1766 -- Kick
    elseif class == "PRIEST" then spellId = 15487 -- Silence
    elseif class == "DEATHKNIGHT" then spellId = 47528 -- Mind Freeze
    elseif class == "SHAMAN" then spellId = 57994 -- Wind Shear
    elseif class == "MAGE" then spellId = 2139 -- Counterspell
    elseif class == "WARLOCK" then spellId = 19647 -- Spell Lock
    elseif class == "HUNTER" then spellId = 34490 -- Silencing Shot
    end
    
    if spellId > 0 and IsSpellKnown(spellId) then
        local name = GetSpellInfo(spellId)
        return "#showtooltip " .. name .. "\n/stopcasting\n/cast [mod:shift, target=focus] " .. name .. "; " .. name
    elseif class == "WARLOCK" then
         return "#showtooltip Bloqueo de hechizo\n/cast [mod:shift, target=focus] Bloqueo de hechizo; Bloqueo de hechizo"
    end
    return nil
end

-- 2. Smart CC
function S.MacroGen:GetSmartCC(class)
    local spellId = 0
    if class == "WARLOCK" then spellId = 5782 -- Fear
    elseif class == "MAGE" then spellId = 118 -- Polymorph
    elseif class == "PRIEST" then spellId = 9484 -- Shackle Undead
    elseif class == "DRUID" then spellId = 33786 -- Cyclone
    elseif class == "ROGUE" then spellId = 2094 -- Blind
    elseif class == "HUNTER" then spellId = 19503 -- Scatter Shot
    elseif class == "PALADIN" then spellId = 853 -- Hammer of Justice
    end
    
    if spellId > 0 and IsSpellKnown(spellId) then
        local name = GetSpellInfo(spellId)
        return "#showtooltip " .. name .. "\n/cast [mod:ctrl, target=mouseover] " .. name .. "; [mod:shift, target=focus] " .. name .. "; " .. name
    end
    return nil
end

-- 3. Smart Mount
function S.MacroGen:GetSmartMount()
    return "#showtooltip\n/dismount [mounted]\n/cast [flyable] Montura Voladora; Montura Terrestre"
end

-- ===========================================================================
-- 3. ROTATION BRAIN (The "Intel" Core)
-- ============================================================================
function S.MacroGen:GetNecrosisRotation(class, spec)
    local function GetIfKnown(id, defaultName)
        return self:GetSmartSpell(id, defaultName)
    end
    
    -- -----------------------------------------------------------------------
    -- 1. WARLOCK (3 Specs)
    -- -----------------------------------------------------------------------
    if class == "WARLOCK" then
        if spec == 1 then -- Affliction
            local haunt = GetIfKnown(48181, "Poseer")
            local ua = GetIfKnown(30108, "Aflicción inestable")
            local corr = GetIfKnown(172, "Corrupción")
            local sb = GetIfKnown(686, "Descarga de las Sombras")
            local drain = GetIfKnown(1120, "Drenar alma")
            return string.format("#showtooltip\n/cast [mod:alt, nochanneling] %s\n/cast [mod:ctrl] %s\n/cast [mod:shift] %s\n/cast %s",
                drain, corr, (haunt or ua), sb)
        elseif spec == 2 then -- Demonology
            local meta = GetIfKnown(47241, "Metamorfosis")
            local aura = GetIfKnown(50589, "Aura de inmolación")
            local cleave = GetIfKnown(50581, "Hender sombras")
            local immo = GetIfKnown(348, "Inmolar")
            local sf = GetIfKnown(6353, "Fuego de alma")
            local incin = GetIfKnown(29722, "Incinerar") or GetIfKnown(686, "Descarga de las Sombras")
            local prefix = "#showtooltip\n"
            if meta then
                prefix = prefix .. string.format("/cast [form:1] %s\n/cast [form:1] %s\n", aura, cleave)
            end
            return prefix .. string.format("/cast [mod:shift] %s\n/cast [mod:ctrl] %s\n/cast %s", immo, sf, incin)
        else -- Destruction
            local immo = GetIfKnown(348, "Inmolar")
            local conflag = GetIfKnown(17962, "Conflagrar")
            local cb = GetIfKnown(50796, "Descarga de Caos")
            local incin = GetIfKnown(29722, "Incinerar")
            return string.format("#showtooltip\n/cast [mod:shift] %s\n/cast [mod:ctrl] %s\n/cast [mod:alt] %s\n/cast %s",
                immo, conflag, cb, incin)
        end
        
    -- -----------------------------------------------------------------------
    -- 2. DEATH KNIGHT (3 Specs)
    -- -----------------------------------------------------------------------
    elseif class == "DEATHKNIGHT" then
        local it = GetIfKnown(45477, "Toque helado")
        local ps = GetIfKnown(45462, "Golpe de peste")
        local rs = GetIfKnown(56815, "Golpe con runa")
        local suffix = rs and ("\n/cast !" .. rs) or ""
        
        if spec == 1 then -- Blood
            local hs = GetIfKnown(55050, "Golpe en el corazón") or GetIfKnown(45902, "Golpe sangriento")
            local ds = GetIfKnown(49998, "Golpe mortal")
            return string.format("#showtooltip\n/cast [mod:shift] %s\n/cast [mod:ctrl] %s\n/cast [mod:alt] %s\n/cast %s%s",
                it, ps, ds, hs, suffix)
        elseif spec == 2 then -- Frost
            local ob = GetIfKnown(49020, "Asolar")
            local fs = GetIfKnown(49143, "Golpe de Escarcha")
            local hb = GetIfKnown(49184, "Explosión aullante")
            return string.format("#showtooltip\n/cast [mod:shift] %s\n/cast [mod:ctrl] %s\n/cast [mod:alt] %s\n/cast %s%s",
                it, ps, (hb or fs), ob, suffix)
        else -- Unholy
            local ss = GetIfKnown(55090, "Golpe de la Plaga")
            local dc = GetIfKnown(47541, "Espiral de la muerte")
            local pest = GetIfKnown(50842, "Pestilencia")
            return string.format("#showtooltip\n/cast [mod:shift] %s\n/cast [mod:ctrl] %s\n/cast [mod:alt] %s\n/cast %s%s",
                it, ps, dc, (ss or pest), suffix)
        end

    -- -----------------------------------------------------------------------
    -- 3. PALADIN (3 Specs)
    -- -----------------------------------------------------------------------
    elseif class == "PALADIN" then
        if spec == 1 then -- Holy
            local hs = GetIfKnown(48782, "Choque Sagrado")
            local hl = GetIfKnown(48782, "Luz Sagrada")
            local fol = GetIfKnown(48785, "Destello de Luz")
            return string.format("#showtooltip\n/cast [mod:shift, @mouseover,help][mod:shift] %s\n/cast [mod:ctrl, @mouseover,help][mod:ctrl] %s\n/cast [@mouseover,help][help][@player] %s",
                hs, hl, fol)
        elseif spec == 2 then -- Protection
            local hotr = GetIfKnown(53595, "Martillo de rectitud")
            local sor = GetIfKnown(53600, "Escudo de rectitud")
            local cons = GetIfKnown(26573, "Consagración")
            local hs = GetIfKnown(20925, "Escudo sagrado")
            return string.format("#showtooltip\n/cast [mod:shift] %s\n/cast [mod:ctrl] %s\n/cast [mod:alt] %s\n/cast %s",
                hotr, cons, hs, sor)
        else -- Retribution
            local cs = GetIfKnown(35395, "Golpe de cruzado")
            local ds = GetIfKnown(53385, "Tormenta divina")
            local judge = GetIfKnown(53408, "Sentencia de sabiduría") or GetIfKnown(20271, "Sentencia de luz")
            local exo = GetIfKnown(879, "Exorcismo")
            return string.format("#showtooltip\n/cast [mod:shift] %s\n/cast [mod:ctrl] %s\n/cast [mod:alt] %s\n/cast %s",
                ds, judge, exo, cs)
        end

    -- -----------------------------------------------------------------------
    -- 4. MAGE (3 Specs)
    -- -----------------------------------------------------------------------
    elseif class == "MAGE" then
        if spec == 1 then -- Arcane
            local ab = GetIfKnown(30451, "Descarga Arcana")
            local am = GetIfKnown(5143, "Misiles Arcanos")
            local abarr = GetIfKnown(44425, "Tromba Arcana")
            return string.format("#showtooltip\n/cast [mod:shift] %s\n/cast [mod:ctrl] %s\n/cast %s",
                am, abarr, ab)
        elseif spec == 2 then -- Fire
            local fb = GetIfKnown(133, "Bola de Fuego")
            local lb = GetIfKnown(44457, "Bomba viva")
            local pyro = GetIfKnown(11366, "Piroexplosión")
            local scorch = GetIfKnown(2948, "Agostar")
            return string.format("#showtooltip\n/cast [mod:shift] %s\n/cast [mod:ctrl] %s\n/cast [mod:alt] %s\n/cast %s",
                lb, pyro, scorch, fb)
        else -- Frost
            local fb = GetIfKnown(116, "Descarga de Escarcha")
            local il = GetIfKnown(30455, "Lanza de hielo")
            local df = GetIfKnown(44572, "Congelación profunda")
            return string.format("#showtooltip\n/cast [mod:shift] %s\n/cast [mod:ctrl] %s\n/cast %s",
                il, df, fb)
        end

    -- -----------------------------------------------------------------------
    -- 5. ROGUE (3 Specs)
    -- -----------------------------------------------------------------------
    elseif class == "ROGUE" then
        if spec == 1 then -- Assassination
            local mut = GetIfKnown(1329, "Mutilar")
            local env = GetIfKnown(32645, "Envenenar")
            local hfb = GetIfKnown(63848, "Hambre de sangre")
            return string.format("#showtooltip\n/cast [mod:shift] %s\n/cast [mod:ctrl] %s\n/cast %s",
                env, hfb, mut)
        elseif spec == 2 then -- Combat
            local ss = GetIfKnown(1752, "Golpe siniestro")
            local evis = GetIfKnown(2098, "Eviscerar")
            local snd = GetIfKnown(5171, "Hacer picadillo")
            local ks = GetIfKnown(51690, "Asesinato múltiple")
            return string.format("#showtooltip\n/cast [mod:shift] %s\n/cast [mod:ctrl] %s\n/cast [mod:alt] %s\n/cast %s",
                evis, snd, ks, ss)
        else -- Subtlety
            local hemo = GetIfKnown(16511, "Hemorragia")
            local evis = GetIfKnown(2098, "Eviscerar")
            local step = GetIfKnown(36554, "Paso de las Sombras")
            return string.format("#showtooltip\n/cast [mod:shift] %s\n/cast [mod:ctrl] %s\n/cast %s",
                evis, step, hemo)
        end

    -- -----------------------------------------------------------------------
    -- 6. HUNTER (3 Specs)
    -- -----------------------------------------------------------------------
    elseif class == "HUNTER" then
        local steady = GetIfKnown(56641, "Disparo firme")
        local serpent = GetIfKnown(1978, "Picadura de serpiente")
        local kill = GetIfKnown(53351, "Disparo mortal")
        
        if spec == 1 then -- Beast Mastery
            local bw = GetIfKnown(19574, "Cólera de las bestias")
            local kc = GetIfKnown(34026, "Matar")
            return string.format("#showtooltip\n/cast [mod:shift] %s\n/cast [mod:shift] %s\n/cast [mod:ctrl] %s\n/cast [mod:alt] %s\n/cast %s",
                bw, kc, serpent, kill, steady)
        elseif spec == 2 then -- Marksmanship
            local chim = GetIfKnown(53209, "Disparo de quimera")
            local aimed = GetIfKnown(19434, "Disparo de puntería")
            return string.format("#showtooltip\n/cast [mod:shift] %s\n/cast [mod:ctrl] %s\n/cast [mod:alt] %s\n/cast %s",
                chim, aimed, serpent, steady)
        else -- Survival
            local exp = GetIfKnown(53301, "Disparo explosivo")
            local ba = GetIfKnown(3674, "Flecha negra")
            return string.format("#showtooltip\n/cast [mod:shift] %s\n/cast [mod:ctrl] %s\n/cast [mod:alt] %s\n/cast %s",
                exp, ba, serpent, steady)
        end

    -- -----------------------------------------------------------------------
    -- 7. WARRIOR (3 Specs)
    -- -----------------------------------------------------------------------
    elseif class == "WARRIOR" then
        if spec == 1 then -- Arms
            local ms = GetIfKnown(12294, "Golpe mortal")
            local op = GetIfKnown(7384, "Abrumar")
            local rend = GetIfKnown(772, "Desgarrar")
            local exe = GetIfKnown(5308, "Ejecutar")
            return string.format("#showtooltip\n/cast [mod:shift] %s\n/cast [mod:ctrl] %s\n/cast [mod:alt] %s\n/cast %s",
                ms, op, rend, exe)
        elseif spec == 2 then -- Fury
            local bt = GetIfKnown(23881, "Sed de sangre")
            local ww = GetIfKnown(1680, "Torbellino")
            local slam = GetIfKnown(1464, "Embate")
            local hs = GetIfKnown(78, "Golpe heroico")
            return string.format("#showtooltip\n/cast [mod:shift] %s\n/cast [mod:ctrl] %s\n/cast %s\n/cast !%s",
                ww, slam, bt, hs)
        else -- Protection
            local ss = GetIfKnown(23922, "Embate con escudo")
            local rev = GetIfKnown(6572, "Revancha")
            local shock = GetIfKnown(46968, "Ola de choque")
            local dev = GetIfKnown(20243, "Devastar") or GetIfKnown(7386, "Hender armadura")
            return string.format("#showtooltip\n/cast [mod:shift] %s\n/cast [mod:ctrl] %s\n/cast [mod:alt] %s\n/cast %s",
                ss, rev, shock, dev)
        end

    -- -----------------------------------------------------------------------
    -- 8. SHAMAN (3 Specs)
    -- -----------------------------------------------------------------------
    elseif class == "SHAMAN" then
        if spec == 1 then -- Elemental
            local lv = GetIfKnown(51505, "Ráfaga de lava")
            local fs = GetIfKnown(8050, "Choque de llamas")
            local cl = GetIfKnown(421, "Cadena de relámpagos")
            local lb = GetIfKnown(403, "Descarga de relámpagos")
            return string.format("#showtooltip\n/cast [mod:shift] %s\n/cast [mod:ctrl] %s\n/cast [mod:alt] %s\n/cast %s",
                lv, fs, cl, lb)
        elseif spec == 2 then -- Enhancement
            local ss = GetIfKnown(17364, "Golpe de tormenta")
            local ll = GetIfKnown(60103, "Látigo de lava")
            local es = GetIfKnown(8042, "Choque de tierra")
            local lb = GetIfKnown(403, "Descarga de relámpagos")
            return string.format("#showtooltip\n/cast [mod:shift] %s\n/cast [mod:ctrl] %s\n/cast [mod:alt] %s\n/cast %s",
                ll, es, lb, ss)
        else -- Restoration
            local ch = GetIfKnown(1064, "Sanación en cadena")
            local rip = GetIfKnown(61295, "Mareas vivas")
            local lhw = GetIfKnown(8004, "Ola de sanación menor")
            return string.format("#showtooltip\n/cast [mod:shift, @mouseover,help][mod:shift] %s\n/cast [mod:ctrl, @mouseover,help][mod:ctrl] %s\n/cast [@mouseover,help][help][@player] %s",
                ch, rip, lhw)
        end

    -- -----------------------------------------------------------------------
    -- 9. PRIEST (3 Specs)
    -- -----------------------------------------------------------------------
    elseif class == "PRIEST" then
        if spec == 1 then -- Discipline
            local pws = GetIfKnown(17, "Palabra de poder: escudo")
            local pen = GetIfKnown(47540, "Penitencia")
            local fh = GetIfKnown(2061, "Sanación relámpago")
            local pom = GetIfKnown(33076, "Rezo de alivio")
            return string.format("#showtooltip\n/cast [mod:shift, @mouseover,help][mod:shift] %s\n/cast [mod:ctrl, @mouseover,help][mod:ctrl] %s\n/cast [mod:alt, @mouseover,help][mod:alt] %s\n/cast [@mouseover,help][help][@player] %s",
                pws, pen, pom, fh)
        elseif spec == 2 then -- Holy
            local coh = GetIfKnown(34861, "Círculo de sanación")
            local pom = GetIfKnown(33076, "Rezo de alivio")
            local renew = GetIfKnown(139, "Renovar")
            local fh = GetIfKnown(2061, "Sanación relámpago")
            return string.format("#showtooltip\n/cast [mod:shift, @mouseover,help][mod:shift] %s\n/cast [mod:ctrl, @mouseover,help][mod:ctrl] %s\n/cast [mod:alt, @mouseover,help][mod:alt] %s\n/cast [@mouseover,help][help][@player] %s",
                coh, pom, renew, fh)
        else -- Shadow
            local mf = GetIfKnown(15407, "Tortura mental")
            local vt = GetIfKnown(34914, "Toque vampírico")
            local dp = GetIfKnown(2944, "Peste devoradora")
            local mb = GetIfKnown(8092, "Explosión mental")
            return string.format("#showtooltip\n/cast [mod:shift] %s\n/cast [mod:ctrl] %s\n/cast [mod:alt] %s\n/cast [nochanneling] %s",
                vt, dp, mb, mf)
        end

    -- -----------------------------------------------------------------------
    -- 10. DRUID (3 Specs)
    -- -----------------------------------------------------------------------
    elseif class == "DRUID" then
        if spec == 1 then -- Balance
            local wrath = GetIfKnown(5176, "Cólera")
            local sf = GetIfKnown(2912, "Fuego estelar")
            local mf = GetIfKnown(8921, "Fuego lunar")
            local is = GetIfKnown(5570, "Enjambre de insectos")
            return string.format("#showtooltip\n/cast [mod:shift] %s\n/cast [mod:ctrl] %s\n/cast [mod:alt] %s\n/cast %s",
                sf, mf, is, wrath)
        elseif spec == 2 then -- Feral (Bear & Cat Form Support)
            local bearMaul = GetIfKnown(6807, "Magullar")
            local bearMangle = GetIfKnown(33878, "Destrozar (oso)")
            local catMangle = GetIfKnown(33876, "Destrozar (gato)")
            local catRip = GetIfKnown(1079, "Destripar")
            local catBite = GetIfKnown(22568, "Mordedura feroz")
            local catRoar = GetIfKnown(52610, "Rugido salvaje")
            return string.format("#showtooltip\n/cast [form:1, mod:shift] %s\n/cast [form:1] %s\n/cast [form:3, mod:shift] %s\n/cast [form:3, mod:ctrl] %s\n/cast [form:3, mod:alt] %s\n/cast [form:3] %s\n/cast [noform] %s",
                bearMangle, bearMaul, catRip, catBite, catRoar, catMangle, GetIfKnown(5176, "Cólera"))
        else -- Restoration
            local rej = GetIfKnown(774, "Rejuvenecimiento")
            local lb = GetIfKnown(33763, "Flor de vida")
            local wg = GetIfKnown(48438, "Crecimiento salvaje") or GetIfKnown(18562, "Alivio presto")
            local reg = GetIfKnown(8936, "Recrecimiento")
            return string.format("#showtooltip\n/cast [mod:shift, @mouseover,help][mod:shift] %s\n/cast [mod:ctrl, @mouseover,help][mod:ctrl] %s\n/cast [mod:alt, @mouseover,help][mod:alt] %s\n/cast [@mouseover,help][help][@player] %s",
                rej, lb, wg, reg)
        end
    end
    
    return "/startattack"
end

-- ===========================================================================
-- 3. CLASS DATABASE
-- ===========================================================================

function S.MacroGen:GetClassMacros(class, spec)
    local macros = {}

    -- ITEM IDS
    local healthstone = self:GetSmartItem(5512, "Piedra de salud vil")
    local potion = self:GetSmartItem(33447, "Poción de sanación rúnica")
    local hearthstone = self:GetSmartItem(6948, "Piedra de hogar")

    -- [NEW v8.0.0] Smart Utilities Integration
    local intBody = self:GetSmartInterrupt(class)
    if intBody then table.insert(macros, { Name = "SeqInt", Body = intBody }) end
    
    local ccBody = self:GetSmartCC(class)
    if ccBody then table.insert(macros, { Name = "SeqCC", Body = ccBody }) end
    
    local mntBody = self:GetSmartMount()
    if mntBody then table.insert(macros, { Name = "SeqMount", Body = mntBody }) end

     -- WARLOCK
    if class == "WARLOCK" then
        local opener = self:GetSmartSpell(172, "Corrupción") 
        if spec == 2 then opener = "Metaformosis" end 
        if spec == 3 then opener = self:GetSmartSpell(348, "Inmolar") end 

        table.insert(macros, { Name = "SeqStart",  Body = "#showtooltip " .. opener .. "\n/cleartarget [dead][help]\n/targetenemy\n/petattack\n/startattack\n/cast " .. opener })
        table.insert(macros, { Name = "SeqHeal",   Body = "#showtooltip " .. healthstone .. "\n/cast [btn:2] Crear piedra de salud\n/cast [mod:shift] Canalizar salud\n/use [nomod] " .. healthstone .. "\n/use [nomod] " .. potion })
        table.insert(macros, { Name = "SeqPet",    Body = "#showtooltip\n/petattack [nomod,btn:1]\n/petfollow [nomod,btn:2]\n/cast [mod:shift,target=mouseover,exists] Devorar magia; [mod:shift,target=focus,exists] Devorar magia; [mod:shift] Devorar magia\n/cast [mod:shift,target=mouseover,exists] Seducción; [mod:shift,target=focus,exists] Seducción; [mod:shift] Seducción\n/cast [mod:shift,target=mouseover,exists] Bloqueo de hechizo; [mod:shift,target=focus,exists] Bloqueo de hechizo; [mod:shift] Bloqueo de hechizo" })
        
        local banish = self:GetSmartSpell(710, "Desterrar")
        if banish then table.insert(macros, { Name = "SeqBanish", Body = "#showtooltip " .. banish .. "\n/cast [target=mouseover,exists,harm] " .. banish .. "; [target=focus,exists,harm] " .. banish .. "; " .. banish }) end
        local fear = self:GetSmartSpell(5782, "Miedo")
        if fear then table.insert(macros, { Name = "SeqFear",   Body = "#showtooltip " .. fear .. "\n/cast [target=mouseover,exists,harm] " .. fear .. "; [target=focus,exists,harm] " .. fear .. "; " .. fear }) end
        table.insert(macros, { Name = "SeqDispel", Body = "#showtooltip Devorar magia\n/cast [mod:alt,target=player] Devorar magia; [target=mouseover,help,exists] Devorar magia; Devorar magia" })
        table.insert(macros, { Name = "SeqBurst",  Body = "#showtooltip\n/use 10\n/use 13\n/use 14\n/use Poción de velocidad\n/cast Metaformosis\n/cast [mod:shift] Eficacia interna" })

    -- DEATH KNIGHT
    elseif class == "DEATHKNIGHT" then
        local grip = self:GetSmartSpell(49576, "Atracción letal")
        table.insert(macros, { Name = "SeqGrip", Body = "#showtooltip " .. grip .. "\n/cast [target=focus,exists,harm] " .. grip .. "; [target=mouseover,exists,harm] " .. grip .. "; " .. grip })
        local freeze = self:GetSmartSpell(47528, "Helada mental")
        local strang = self:GetSmartSpell(47476, "Estrangular")
        table.insert(macros, { Name = "SeqInt",  Body = "#showtooltip " .. freeze .. "\n/cast [target=focus,exists,harm] " .. freeze .. "; [target=mouseover,exists,harm] " .. freeze .. "; " .. freeze .. "\n/cast [mod:shift] " .. strang })
        local tap = self:GetSmartSpell(48982, "Transfusión de runa")
        local pact = self:GetSmartSpell(48743, "Pacto de la muerte")
        table.insert(macros, { Name = "SeqHeal", Body = "#showtooltip " .. tap .. "\n/cast " .. tap .. "\n/cast [mod:shift] " .. pact .. "\n/use " .. potion })
        local dnd = self:GetSmartSpell(43265, "Muerte y descomposición")
        local pest = self:GetSmartSpell(50842, "Pestilencia")
        table.insert(macros, { Name = "SeqAoE",  Body = "#showtooltip " .. dnd .. "\n/cast [mod:shift] " .. pest .. "\n/cast " .. dnd })
        local strike = self:GetSmartSpell(45477, "Toque helado")
        table.insert(macros, { Name = "SeqStart", Body = "#showtooltip " .. strike .. "\n/startattack\n/petattack\n/cast " .. strike }) 
        
        local army = self:GetSmartSpell(42650, "Ejército de muertos")
        if army then table.insert(macros, { Name = "SeqArmy", Body = "#showtooltip " .. army .. "\n/cast " .. army .. "\n/s ¡Salid mis pequeños! ¡A comer!\n/in 2 /s Cenizas a las cenizas..." }) end

    -- PALADIN
    elseif class == "PALADIN" then
        local bub = self:GetSmartSpell(642, "Escudo divino") 
        table.insert(macros, { Name = "SeqBubble", Body = "#showtooltip " .. bub .. "\n/stopcasting\n/cast " .. bub .. "\n/s ¡Inmunidad Diplomática!\n/use " .. hearthstone })
        if spec == 1 then
             local shock = self:GetSmartSpell(48782, "Choque Sagrado")
             table.insert(macros, { Name = "SeqHeal", Body = "#showtooltip " .. shock .. "\n/cast [@mouseover,help][help][@player] " .. shock .. "\n/s ¡Luz salvadora sobre %t!" })
        end
        if spec == 2 then
             local shield = self:GetSmartSpell(31935, "Escudo de vengador")
             table.insert(macros, { Name = "SeqPull", Body = "#showtooltip " .. shield .. "\n/cast " .. shield .. "\n/s ¡Venid a mí, herejes! (Pull)" })
        end

    -- WARRIOR
    elseif class == "WARRIOR" then
        local wall = self:GetSmartSpell(871, "Muro de escudo")
        table.insert(macros, { Name = "SeqWall", Body = "#showtooltip " .. wall .. "\n/cast " .. wall .. "\n/s ¡Muro de Escudos activado! ¡No pasarán!" })
        
    -- HUNTER
    elseif class == "HUNTER" then
        local md = self:GetSmartSpell(34477, "Redirección")
        table.insert(macros, { Name = "SeqMD", Body = "#showtooltip " .. md .. "\n/cast [@focus,help][@pet,exists] " .. md .. "\n/s Redirigiendo amenaza hacia %t." })
        
    -- ROGUE
    elseif class == "ROGUE" then
         local tricks = self:GetSmartSpell(57934, "Secretos del oficio")
         table.insert(macros, { Name = "SeqTricks", Body = "#showtooltip " .. tricks .. "\n/cast [@focus,help][@target,help] " .. tricks .. "\n/s Secretos para %t..." })
         
    -- PRIEST
    elseif class == "PRIEST" then
         local hymn = self:GetSmartSpell(64843, "Himno divino")
         table.insert(macros, { Name = "SeqHymn", Body = "#showtooltip " .. hymn .. "\n/cast " .. hymn .. "\n/s ¡Escuchad la canción del olvido!\n/in 8 /s Himno finalizado." })
        
    -- SHAMAN
    elseif class == "SHAMAN" then
        local lust = self:GetSmartSpell(2825, "Ansia de sangre")
        if not lust then lust = self:GetSmartSpell(32182, "Heroísmo") end 
        if lust then
             table.insert(macros, { Name = "SeqLust", Body = "#showtooltip " .. lust .. "\n/cast " .. lust .. "\n/y ¡¡FURIA PARA EL SÉQUITO!! (BL/Hero)" })
        end
        if spec == 2 then
             local wolves = self:GetSmartSpell(51533, "Espíritu feral")
             table.insert(macros, { Name = "SeqWolves", Body = "#showtooltip " .. wolves .. "\n/cast " .. wolves .. "\n/cast Ira del chamán\n/s ¡Cazan en manada!" })
        end
        if spec == 3 then
             local tide = self:GetSmartSpell(16190, "Marea de maná")
             table.insert(macros, { Name = "SeqTide", Body = "#showtooltip " .. tide .. "\n/cast " .. tide .. "\n/s ¡Marea de Maná! ¡Bebed!" })
        end

    -- MAGE
    elseif class == "MAGE" then
         local tableSpell = self:GetSmartSpell(43987, "Ritual de refrigerio")
         table.insert(macros, { Name = "SeqTable", Body = "#showtooltip " .. tableSpell .. "\n/cast " .. tableSpell .. "\n/y ¡Mesita del Sequito! ¡Comed, malditos!\n/in 5 /s La mesa está puesta." })
         local remove = self:GetSmartSpell(475, "Eliminar maldición")
         table.insert(macros, { Name = "SeqDecurse", Body = "#showtooltip " .. remove .. "\n/cast [target=mouseover,help,exists] " .. remove .. "; [target=player] " .. remove })

    -- DRUID
    elseif class == "DRUID" then
         local rez = self:GetSmartSpell(20484, "Renacer")
         local rezText = "¡Levántate, %t! ¡Aún no he terminado contigo!"
         -- Random Speech Integration
         if S.GetRandomSpeech then
              local randomText = S:GetRandomSpeech("Resurrect")
              if randomText then rezText = randomText:gsub("<target>", "%%t") end
         end
         
         table.insert(macros, { Name = "SeqRez", Body = "#showtooltip " .. rez .. "\n/cast " .. rez .. "\n/s " .. rezText })
         local innervate = self:GetSmartSpell(29166, "Estimular")
         table.insert(macros, { Name = "SeqInnervate", Body = "#showtooltip " .. innervate .. "\n/cast [@mouseover,help][help][@player] " .. innervate })
    end

    -- INTELLIGENT ROTATION MACRO (Now Covers ALL Classes)
    local rotBody = self:GetNecrosisRotation(class, spec)
    if rotBody then
        table.insert(macros, { Name = "SeqRot", Body = "#showtooltip\n/startattack\n/petattack\n" .. rotBody })
    end
    
    -- MOUNT (Handled by Smart Utility above)
    -- Legacy code removed to prevent duplicates

    return macros
end

-- ===========================================================================
-- 4. GENERATIOR CORE
-- ===========================================================================

-- ===========================================================================
-- 4. GENERATOR CORE (SMART SYNC)
-- ===========================================================================

function S.MacroGen:GenerateClassMacros()
    local _, class = UnitClass("player")
    local spec = S.Universal and S.Universal:GetSpec() or 1
    
    print("|cFFFF00FFSequito:|r Sincronizando macros inteligentes para " .. class .. "...")

    -- 1. Generate Desired Macros List (Target State)
    local desired = self:GetClassMacros(class, spec)
    
    -- Add Racial
    local racial = self:GetRacialSpell()
    if racial then
        local rBody = "#showtooltip " .. racial .. "\n/cast " .. racial .. "\n/s ¡Por el Sequito del Terror! (" .. racial .. ")"
        table.insert(desired, { Name = "SeqRacial", Body = rBody })
    end
    
    -- Map desired names for quick lookup
    local desiredNames = {}
    for _, mac in ipairs(desired) do
        desiredNames[mac.Name] = true
    end
    
    -- 2. DELETE Obsolete "Seq" Macros FIRST (To free up space)
    local numAccount, numChar = GetNumMacros()
    local BASE_MACRO_INDEX = 36
    
    -- Scan backwards to avoid index shifting issues when deleting
    for i = 18, 1, -1 do
        local absIndex = BASE_MACRO_INDEX + i
        local name, icon, body, isLocal = GetMacroInfo(absIndex)
        if name and name:sub(1,3) == "Seq" then
            if not desiredNames[name] then
                print("|cFF999999Sequito:|r Eliminando macro obsoleta: " .. name)
                DeleteMacro(absIndex)
            end
        end
    end
    
    -- 3. CREATE / UPDATE Desired Macros
    for _, mac in ipairs(desired) do
        local macroID = GetMacroIndexByName(mac.Name)
        
        if macroID > 0 then
            -- Update existing
            EditMacro(macroID, mac.Name, 1, mac.Body)
        else
            -- Create new (finding space)
            local numAccount, numChar = GetNumMacros()
            if numChar < 18 then
                CreateMacro(mac.Name, 1, mac.Body, 1) -- 1 = per character
            else
                print("|cFFFF0000Sequito Error:|r Espacio lleno (18/18). No se pudo crear: " .. mac.Name)
            end
        end
    end
    
    print("|cFF00FF00Sequito:|r Macros sincronizadas y optimizadas.")
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_TALENT_UPDATE") 
f:RegisterEvent("LEARNED_SPELL_IN_TAB")
f:RegisterEvent("PLAYER_ENTERING_WORLD") -- Added for login generation
f:SetScript("OnEvent", function(self, event, ...)
    if S.db and S.db.profile and S.db.profile.AutoMacros then
       -- Little throttle/delay for login to ensure spells are loaded
       if event == "PLAYER_ENTERING_WORLD" then
           C_Timer.After(5, function() S.MacroGen:GenerateClassMacros() end)
       else
           S.MacroGen:GenerateClassMacros()
       end
    end
end)
