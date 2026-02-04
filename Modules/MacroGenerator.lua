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
-- 2. ROTATION BRAIN (The "Intel" Core)
-- ============================================================================

function S.MacroGen:GetNecrosisRotation(class, spec)
    local spellList = {}
    
    local function GetIfKnown(id)
        return self:GetSmartSpell(id, nil)
    end
    
    -- -----------------------------------------------------------------------
    -- WARLOCK (Brain Logic)
    -- -----------------------------------------------------------------------
    if class == "WARLOCK" then
        if spec == 3 then -- Destruction
            if GetIfKnown(348) then table.insert(spellList, GetIfKnown(348)) end -- Immolate
            if GetIfKnown(17962) then table.insert(spellList, GetIfKnown(17962)) end -- Conflagrate
            if GetIfKnown(50796) then table.insert(spellList, GetIfKnown(50796)) end -- Chaos Bolt
            local incin = GetIfKnown(29722) or "Incinerar"
            table.insert(spellList, incin); table.insert(spellList, incin); table.insert(spellList, incin)
            return "/castsequence reset=combat/target " .. table.concat(spellList, ", ")
            
        elseif spec == 1 then -- Affliction
            if GetIfKnown(48181) then table.insert(spellList, GetIfKnown(48181)) end -- Haunt
            if GetIfKnown(30108) then table.insert(spellList, GetIfKnown(30108)) end -- UA
            if GetIfKnown(980) then table.insert(spellList, GetIfKnown(980)) end -- Agony
            if GetIfKnown(172) then table.insert(spellList, GetIfKnown(172)) end -- Corruption
            local sb = GetIfKnown(686) or "Descarga de las Sombras"
            table.insert(spellList, sb); table.insert(spellList, sb); table.insert(spellList, sb)
            
            -- Seed Logic (Ctrl Mod)
            local seed = GetIfKnown(27243)
            local prefix = ""
            if seed then prefix = "/cast [mod:ctrl] " .. seed .. "\n" end
            return prefix .. "/castsequence reset=combat/target " .. table.concat(spellList, ", ")
            
        elseif spec == 2 then -- Demonology
            local prefix = ""
            if GetIfKnown(47241) then 
                local aura = GetIfKnown(50589)
                local cleave = GetIfKnown(50581)
                if aura then prefix = prefix .. "/cast [form:1] " .. aura .. "\n" end
                if cleave then prefix = prefix .. "/cast [form:1] " .. cleave .. "\n" end
            end
            if GetIfKnown(348) then table.insert(spellList, GetIfKnown(348)) end 
            if GetIfKnown(172) then table.insert(spellList, GetIfKnown(172)) end 
            local sb = GetIfKnown(686) or "Descarga de las Sombras"
            table.insert(spellList, sb); table.insert(spellList, sb)
            return prefix .. "/castsequence [noform:1] reset=combat/target " .. table.concat(spellList, ", ")
        end
        
    -- -----------------------------------------------------------------------
    -- DEATH KNIGHT (Brain Logic)
    -- -----------------------------------------------------------------------
    elseif class == "DEATHKNIGHT" then
        if spec == 1 then -- Blood
            if GetIfKnown(45477) then table.insert(spellList, GetIfKnown(45477)) end -- Icy Touch
            if GetIfKnown(45462) then table.insert(spellList, GetIfKnown(45462)) end -- Plague Strike
            local heart = GetIfKnown(55050) or GetIfKnown(49930) 
            if heart then table.insert(spellList, heart); table.insert(spellList, heart) end
            if GetIfKnown(49998) then table.insert(spellList, GetIfKnown(49998)) end -- Death Strike
            local rs = GetIfKnown(56815) 
            local suffix = ""
            if rs then suffix = "\n/cast !" .. rs end
            return "/castsequence reset=combat/target " .. table.concat(spellList, ", ") .. suffix
            
        elseif spec == 2 then -- Frost
            if GetIfKnown(45477) then table.insert(spellList, GetIfKnown(45477)) end
            if GetIfKnown(45462) then table.insert(spellList, GetIfKnown(45462)) end
            if GetIfKnown(49020) then table.insert(spellList, GetIfKnown(49020)) end
            local fs = GetIfKnown(49143)
            if fs then table.insert(spellList, fs); table.insert(spellList, fs) end
            return "/castsequence reset=combat/target " .. table.concat(spellList, ", ")
            
        elseif spec == 3 then -- Unholy
           if GetIfKnown(45462) then table.insert(spellList, GetIfKnown(45462)) end
           if GetIfKnown(45477) then table.insert(spellList, GetIfKnown(45477)) end
           if GetIfKnown(55090) then table.insert(spellList, GetIfKnown(55090)) end
           if GetIfKnown(49930) then table.insert(spellList, GetIfKnown(49930)) end
           if GetIfKnown(47541) then table.insert(spellList, GetIfKnown(47541)) end
           return "/castsequence reset=combat/target " .. table.concat(spellList, ", ")
        end

    -- -----------------------------------------------------------------------
    -- PALADIN (Universal Style)
    -- -----------------------------------------------------------------------
    elseif class == "PALADIN" then
         -- Prot: 53595 (Hammer), 20271 (Judge), 35395 (Crusader/HotR)
         -- Ret: 20271 (Judge), 35395 (CS), 53385 (DS)
         -- Holy: 48782 (Shock)
         if spec == 2 then
             if GetIfKnown(53595) then table.insert(spellList, GetIfKnown(53595)) end
             if GetIfKnown(20271) then table.insert(spellList, GetIfKnown(20271)) end
             if GetIfKnown(35395) then table.insert(spellList, GetIfKnown(35395)) end
         elseif spec == 3 then
             if GetIfKnown(20271) then table.insert(spellList, GetIfKnown(20271)) end
             if GetIfKnown(35395) then table.insert(spellList, GetIfKnown(35395)) end
             if GetIfKnown(53385) then table.insert(spellList, GetIfKnown(53385)) end
         else -- Holy
             if GetIfKnown(48782) then table.insert(spellList, GetIfKnown(48782)) end
             if GetIfKnown(48782) then table.insert(spellList, GetIfKnown(48782)) end -- Double Shock (CD wait)
         end
         
         if #spellList == 0 then return "/cast " .. (GetIfKnown(35395) or "Golpe de cruzado") end
         return "/castsequence reset=combat/target " .. table.concat(spellList, ", ")

    -- -----------------------------------------------------------------------
    -- MAGE (Universal Style)
    -- -----------------------------------------------------------------------
    elseif class == "MAGE" then
         -- Arcane: 30451 (Blast) x3, 30455 (Ice Lance/Barrage logic too complex for simple seq, simple blast spam)
         -- Fire: 133 (Fireball)
         -- Frost: 116 (Frostbolt), 30455 (Ice Lance)
         if spec == 1 then
              return "/cast " .. (GetIfKnown(30451) or "Explosión Arcana")
         elseif spec == 3 then
              if GetIfKnown(116) then table.insert(spellList, GetIfKnown(116)) end
              if GetIfKnown(116) then table.insert(spellList, GetIfKnown(116)) end
              if GetIfKnown(30455) then table.insert(spellList, GetIfKnown(30455)) end
              return "/castsequence reset=target " .. table.concat(spellList, ", ")
         else 
              return "/cast " .. (GetIfKnown(133) or "Bola de Fuego")
         end

    -- -----------------------------------------------------------------------
    -- HUNTER (Universal Style)
    -- -----------------------------------------------------------------------
    elseif class == "HUNTER" then
         -- Mark, Serpent, Shot
         if GetIfKnown(1130) then table.insert(spellList, GetIfKnown(1130)) end -- Mark
         if GetIfKnown(1978) then table.insert(spellList, GetIfKnown(1978)) end -- Serpent
         local shot = GetIfKnown(53209) or GetIfKnown(3044) -- Chimera or Arcane
         if shot then table.insert(spellList, shot) end
         
         return "/castsequence reset=target " .. table.concat(spellList, ", ")

    -- -----------------------------------------------------------------------
    -- ROGUE (Universal Style)
    -- -----------------------------------------------------------------------
    elseif class == "ROGUE" then
         return "/cast " .. (GetIfKnown(1752) or "Golpe siniestro")

    -- -----------------------------------------------------------------------
    -- PRIEST (Universal Style)
    -- -----------------------------------------------------------------------
    elseif class == "PRIEST" then
         if spec == 3 then -- Shadow
             if GetIfKnown(34914) then table.insert(spellList, GetIfKnown(34914)) end -- VT
             if GetIfKnown(589) then table.insert(spellList, GetIfKnown(589)) end -- Pain
             if GetIfKnown(2944) then table.insert(spellList, GetIfKnown(2944)) end -- Plague
             local mf = GetIfKnown(15407)
             if mf then table.insert(spellList, mf) end
             return "/castsequence reset=combat/target " .. table.concat(spellList, ", ")
         else
             return "/cast " .. (GetIfKnown(585) or "Punición")
         end

    -- -----------------------------------------------------------------------
    -- WARRIOR (Universal Style)
    -- -----------------------------------------------------------------------
    elseif class == "WARRIOR" then
         -- MS/Bloodthirst/ShieldSlam
         local s = GetIfKnown(12294) or GetIfKnown(23881) or GetIfKnown(23922)
         return "/cast " .. (s or "Golpe heroico")

    -- -----------------------------------------------------------------------
    -- SHAMAN (Universal Style)
    -- -----------------------------------------------------------------------
    elseif class == "SHAMAN" then
         if GetIfKnown(8050) then table.insert(spellList, GetIfKnown(8050)) end -- Flame Shock
         local blast = GetIfKnown(51505) or GetIfKnown(403) -- Lava or Lightning
         if blast then table.insert(spellList, blast) table.insert(spellList, blast) end
         return "/castsequence reset=combat/target " .. table.concat(spellList, ", ")

    -- -----------------------------------------------------------------------
    -- DRUID (Universal Style)
    -- -----------------------------------------------------------------------
    elseif class == "DRUID" then
         -- Moonfire -> Starfire / Wrath
         if spec == 1 then
             if GetIfKnown(8921) then table.insert(spellList, GetIfKnown(8921)) end
             local filler = GetIfKnown(2912) or GetIfKnown(5176) -- Starfire / Wrath
             if filler then table.insert(spellList, filler) end
             return "/castsequence reset=combat/target " .. table.concat(spellList, ", ")
         elseif spec == 2 then -- Feral
             local s = GetIfKnown(33876) or GetIfKnown(6807) -- Mangle or Maul
             return "/cast " .. (s or "Arañazo")
         else
             return "/cast " .. (GetIfKnown(5176) or "Cólera")
         end
    end
    
    -- Absolute Fallback
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
    
    -- MOUNT
    local fly = self:GetSmartSpell(60025, "Montura voladora") 
    local ground = self:GetSmartSpell(48778, "Montura terrestre")
    if S.Mounts then
        local mBody = S.Mounts:GenerateMountMacro()
        table.insert(macros, { Name = "SeqMount", Body = mBody })
    else
        table.insert(macros, {
            Name = "SeqMount",
            Body = "#showtooltip\n/dismount [mounted]\n/leavevehicle [vehicleui]\n/castrandom [flyable] " .. (fly or "Grifo") .. "; " .. (ground or "Corcel")
        })
    end

    return macros
end

-- ===========================================================================
-- 4. GENERATIOR CORE
-- ===========================================================================

function S.MacroGen:CreateMacro(name, icon, body)
    if not name or not body or body == "" then return end
    
    local macroID = GetMacroIndexByName(name)
    if macroID == 0 then
        local numAccount, numChar = GetNumMacros()
        if numChar < 18 then
            CreateMacro(name, 1, body, 1) 
        end
    end
    
    macroID = GetMacroIndexByName(name)
    if macroID > 0 then
        EditMacro(macroID, name, icon, body)
    end
end

-- Cleanup outdated macros with Prefix "[SEQ]" or "Seq" not in current list
function S.MacroGen:WipeMacros()
    local numAccount, numChar = GetNumMacros()
    for i = 120 + numChar, 121, -1 do -- Iterate Character Macros backwards (121-138)
        local name, icon, body, isLocal = GetMacroInfo(i)
        if name and (name:sub(1,5) == "[SEQ]") then
             DeleteMacro(i)
        end
    end
end

function S.MacroGen:GenerateClassMacros()
    local _, class = UnitClass("player")
    local spec = S.Universal and S.Universal:GetSpec() or 1
    
    -- 0. Wipe Old Macros (Cleanup Phase)
    self:WipeMacros()

    print("|cFFFF00FFSequito:|r Regenerando macros (Necrosis Edition Final v6) para " .. class .. "...")

    -- 1. Class Spec Macros
    local macros = self:GetClassMacros(class, spec)
    for _, m in ipairs(macros) do
        self:CreateMacro(m.Name, 1, m.Body)
    end
    
    -- 2. Racial Macro
    local racial = self:GetRacialSpell()
    if racial then
        local rBody = "#showtooltip " .. racial .. "\n/cast " .. racial .. "\n/s ¡Por el Sequito del Terror! (" .. racial .. ")"
        self:CreateMacro("SeqRacial", 1, rBody)
        print("|cFF00FF00   + Maco Racial: " .. racial .. "|r")
    end
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
