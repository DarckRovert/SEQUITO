--[[
    Sequito - WipeAnalyzer.lua
    Analizador de Wipes para Raids
    Version: 7.2.0
    
    Funcionalidades:
    - Registra muertes durante el combate
    - Detecta quién murió primero y por qué
    - Verifica uso de pociones/healthstones
    - Verifica interrupts fallidos
    - Muestra análisis post-wipe
]]

local addonName, S = ...
S.WipeAnalyzer = {}
local WA = S.WipeAnalyzer
local L = S.L or {}

-- Datos del combate actual
WA.CurrentFight = {
    inCombat = false,
    startTime = 0,
    deaths = {},
    interrupts = {
        successful = {},
        failed = {}
    },
    consumables = {},
    damage = {},
    healing = {}
}

-- Historial de peleas
WA.FightHistory = {}

-- Pociones y consumibles a trackear
local TrackedConsumables = {
    -- Pociones de vida
    [33447] = "Runic Healing Potion",
    [43569] = "Endless Healing Potion",
    -- Pociones de maná
    [33448] = "Runic Mana Potion",
    [43570] = "Endless Mana Potion",
    -- Healthstones
    [47875] = "Healthstone",
    [47876] = "Healthstone",
    [47877] = "Healthstone",
    -- Pociones de combate
    [53908] = "Potion of Speed",
    [53909] = "Potion of Wild Magic",
}

-- Spells de interrupt
local InterruptSpells = {
    [1766] = "Kick",
    [6552] = "Pummel",
    [47528] = "Mind Freeze",
    [57994] = "Wind Shear",
    [2139] = "Counterspell",
    [34490] = "Silencing Shot",
    [15487] = "Silence",
    [19647] = "Spell Lock",
}

WA.Frame = nil
WA.Rows = {}
WA.IsVisible = false

-- Helper para obtener configuración
function WA:GetOption(key)
    if S.ModuleConfig then
        return S.ModuleConfig:GetValue("WipeAnalyzer", key)
    end
    return true
end

function WA:Initialize()
    if not self:GetOption("enabled") then
        return
    end
    
    self:CreateFrame()
    self:RegisterEvents()
end

function WA:CreateFrame()
    if self.Frame then return end
    
    local f = CreateFrame("Frame", "SequitoWipeAnalyzer", UIParent)
    f:SetSize(500, 450) -- Un poco más ancho
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    
    -- Fondo elegante
    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture(0, 0, 0, 0.85)
    f.bg = bg
    
    -- Borde fino
    local border = CreateFrame("Frame", nil, f)
    border:SetAllPoints()
    border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    border:SetBackdropBorderColor(0.6, 0.2, 0.2, 1) -- Borde rojizo para wipe
    
    -- Header Strip
    local headerBg = f:CreateTexture(nil, "ARTWORK")
    headerBg:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    headerBg:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", 0, -24)
    headerBg:SetTexture(0.3, 0.1, 0.1, 1) -- Header rojo oscuro
    
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetClampedToScreen(true)
    f:Hide()
    
    -- Título
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", headerBg, "LEFT", 10, 0)
    title:SetText("|cffff0000" .. L["WIPE_ANALYZER_TITLE"] .. "|r")
    f.title = title
    
    -- Botón cerrar
    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function() WA:Toggle() end)
    
    -- Resumen
    local summary = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    summary:SetPoint("TOPLEFT", f, "TOPLEFT", 15, -35)
    summary:SetWidth(420)
    summary:SetJustifyH("LEFT")
    f.summary = summary
    
    -- Scroll frame para detalles
    local scrollFrame = CreateFrame("ScrollFrame", "SequitoWAScroll", f, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -80)
    scrollFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -30, 45)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(400, 800)
    scrollFrame:SetScrollChild(content)
    f.content = content
    
    -- Botones inferiores
    local announceBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    announceBtn:SetSize(120, 24)
    announceBtn:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 10, 10)
    announceBtn:SetText("Anunciar")
    announceBtn:SetScript("OnClick", function() WA:AnnounceAnalysis() end)
    
    local clearBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    clearBtn:SetSize(120, 24)
    clearBtn:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 10)
    clearBtn:SetText("Limpiar")
    clearBtn:SetScript("OnClick", function() WA:ClearCurrent() end)
    
    local historyBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    historyBtn:SetSize(120, 24)
    historyBtn:SetPoint("BOTTOM", f, "BOTTOM", 0, 10)
    historyBtn:SetText("Historial")
    historyBtn:SetScript("OnClick", function() WA:ShowHistory() end)
    
    self.Frame = f
end

function WA:RegisterEvents()
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    eventFrame:RegisterEvent("ENCOUNTER_START")
    eventFrame:RegisterEvent("ENCOUNTER_END")
    
    eventFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "COMBAT_LOG_EVENT_UNFILTERED" then
            WA:OnCombatLog()
        elseif event == "PLAYER_REGEN_DISABLED" then
            WA:OnCombatStart()
        elseif event == "PLAYER_REGEN_ENABLED" then
            WA:OnCombatEnd()
        elseif event == "ENCOUNTER_START" then
            WA:OnEncounterStart(...)
        elseif event == "ENCOUNTER_END" then
            WA:OnEncounterEnd(...)
        end
    end)
end

function WA:OnCombatStart()
    self.CurrentFight = {
        inCombat = true,
        startTime = GetTime(),
        deaths = {},
        interrupts = {
            successful = {},
            failed = {}
        },
        consumables = {},
        damage = {},
        healing = {}
    }
end

function WA:OnCombatEnd()
    if not self.CurrentFight.inCombat then return end
    
    self.CurrentFight.inCombat = false
    self.CurrentFight.endTime = GetTime()
    self.CurrentFight.duration = self.CurrentFight.endTime - self.CurrentFight.startTime
    
    -- Verificar si fue un wipe (más del 50% del raid murió)
    local raidSize = GetNumRaidMembers()
    if raidSize == 0 then raidSize = GetNumPartyMembers() + 1 end
    
    local deathCount = #self.CurrentFight.deaths
    local isWipe = deathCount >= (raidSize * 0.5)
    
    if isWipe and deathCount > 0 then
        self.CurrentFight.isWipe = true
        table.insert(self.FightHistory, self.CurrentFight)
        
        -- Analizar wipe
        self:AnalyzeWipe()
        
        -- Mostrar análisis automáticamente si está habilitado
        if self:GetOption("autoShow") then
            self:Show()
        end
        
        -- Anunciar resultados si está habilitado
        if self:GetOption("announceResults") then
            self:AnnounceAnalysis()
        end
        
        print("|cffff0000[Sequito]|r ¡Wipe detectado! Usa /sequito analyze para ver el análisis")
    end
end

function WA:OnEncounterStart(encounterID, encounterName, difficultyID, raidSize)
    self.CurrentFight.encounterName = encounterName
    self.CurrentFight.encounterID = encounterID
    self.CurrentFight.difficulty = difficultyID
end

function WA:OnEncounterEnd(encounterID, encounterName, difficultyID, raidSize, success)
    self.CurrentFight.success = success
end

function WA:OnCombatLog()
    if not self.CurrentFight.inCombat then return end
    
    local timestamp, event, _, sourceGUID, sourceName, sourceFlags, 
          sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags,
          spellId, spellName, spellSchool, extraArg1, extraArg2 = CombatLogGetCurrentEventInfo()
    
    -- Detectar muertes
    if event == "UNIT_DIED" then
        if destName and self:IsRaidMember(destGUID) then
            self:RecordDeath(destName, destGUID)
        end
    end
    
    -- Detectar uso de consumibles (si está habilitado)
    if event == "SPELL_CAST_SUCCESS" then
        if self:GetOption("trackConsumables") and TrackedConsumables[spellId] and self:IsRaidMember(sourceGUID) then
            self:RecordConsumable(sourceName, spellId, TrackedConsumables[spellId])
        end
    end
    
    -- Detectar interrupts exitosos (si está habilitado)
    if event == "SPELL_INTERRUPT" then
        if self:GetOption("trackInterrupts") and self:IsRaidMember(sourceGUID) then
            self:RecordInterrupt(sourceName, destName, spellId, extraArg1, true)
        end
    end
    
    -- Detectar casts enemigos que deberían haber sido interrumpidos
    if event == "SPELL_CAST_SUCCESS" then
        if bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then
            -- Aquí podríamos trackear spells importantes que no fueron interrumpidos
            -- Por ahora solo registramos para análisis
        end
    end
    
    -- Registrar daño recibido (para análisis de muerte)
    if event == "SPELL_DAMAGE" or event == "SWING_DAMAGE" then
        if self:IsRaidMember(destGUID) then
            self:RecordDamage(destName, sourceName, spellName or "Melee", extraArg1 or spellId)
        end
    end
end

function WA:IsRaidMember(guid)
    if UnitInRaid("player") then
        for i = 1, GetNumRaidMembers() do
            if UnitGUID("raid"..i) == guid then
                return true
            end
        end
    elseif UnitInParty("player") then
        if UnitGUID("player") == guid then return true end
        for i = 1, GetNumPartyMembers() do
            if UnitGUID("party"..i) == guid then
                return true
            end
        end
    else
        return UnitGUID("player") == guid
    end
    return false
end

function WA:RecordDeath(playerName, playerGUID)
    local deathTime = GetTime() - self.CurrentFight.startTime
    
    -- Obtener últimos daños recibidos
    local recentDamage = self.CurrentFight.damage[playerName] or {}
    local lastDamage = recentDamage[#recentDamage]
    
    -- Verificar si usó consumibles
    local usedConsumables = {}
    for _, cons in ipairs(self.CurrentFight.consumables) do
        if cons.player == playerName then
            table.insert(usedConsumables, cons.name)
        end
    end
    
    local deathInfo = {
        name = playerName,
        guid = playerGUID,
        time = deathTime,
        killedBy = lastDamage and lastDamage.source or "Desconocido",
        lastSpell = lastDamage and lastDamage.spell or "Desconocido",
        lastDamage = lastDamage and lastDamage.amount or 0,
        usedConsumables = usedConsumables,
        order = #self.CurrentFight.deaths + 1
    }
    
    -- Obtener clase
    local _, classFile = GetPlayerInfoByGUID(playerGUID)
    deathInfo.class = classFile
    
    table.insert(self.CurrentFight.deaths, deathInfo)
end

function WA:RecordConsumable(playerName, spellId, consumableName)
    table.insert(self.CurrentFight.consumables, {
        player = playerName,
        spellId = spellId,
        name = consumableName,
        time = GetTime() - self.CurrentFight.startTime
    })
end

function WA:RecordInterrupt(playerName, targetName, interruptSpellId, interruptedSpellId, success)
    local record = {
        player = playerName,
        target = targetName,
        interruptSpell = InterruptSpells[interruptSpellId] or "Interrupt",
        interruptedSpell = GetSpellInfo(interruptedSpellId) or "Unknown",
        time = GetTime() - self.CurrentFight.startTime,
        success = success
    }
    
    if success then
        table.insert(self.CurrentFight.interrupts.successful, record)
    else
        table.insert(self.CurrentFight.interrupts.failed, record)
    end
end

function WA:RecordDamage(destName, sourceName, spellName, amount)
    if not self.CurrentFight.damage[destName] then
        self.CurrentFight.damage[destName] = {}
    end
    
    -- Mantener solo los últimos 5 daños
    local damageList = self.CurrentFight.damage[destName]
    if #damageList >= 5 then
        table.remove(damageList, 1)
    end
    
    table.insert(damageList, {
        source = sourceName,
        spell = spellName,
        amount = amount,
        time = GetTime() - self.CurrentFight.startTime
    })
end

function WA:AnalyzeWipe()
    local fight = self.CurrentFight
    if #fight.deaths == 0 then return end
    
    -- Análisis
    local analysis = {
        firstDeath = fight.deaths[1],
        totalDeaths = #fight.deaths,
        duration = fight.duration,
        consumablesUsed = #fight.consumables,
        interruptsSuccessful = #fight.interrupts.successful,
        interruptsFailed = #fight.interrupts.failed,
        
        -- Jugadores que no usaron consumibles
        noConsumables = {},
        
        -- Orden de muertes
        deathOrder = fight.deaths
    }
    
    -- Encontrar quién no usó consumibles
    local usedConsumables = {}
    for _, cons in ipairs(fight.consumables) do
        usedConsumables[cons.player] = true
    end
    
    for _, death in ipairs(fight.deaths) do
        if not usedConsumables[death.name] then
            table.insert(analysis.noConsumables, death.name)
        end
    end
    
    self.LastAnalysis = analysis
    self:UpdateDisplay()
end

function WA:UpdateDisplay()
    if not self.Frame or not self.LastAnalysis then return end
    
    local analysis = self.LastAnalysis
    local fight = self.CurrentFight
    
    -- Resumen
    local summaryText = string.format(
        L["WIPE_SUMMARY_FMT"],
        fight.encounterName or "Desconocido",
        analysis.duration or 0,
        analysis.totalDeaths
    )
    
    self.Frame.summary:SetText(summaryText)
    
    -- Limpiar contenido anterior
    for _, child in ipairs({self.Frame.content:GetChildren()}) do
        child:Hide()
    end
    
    local yOffset = -10
    
    -- 1. PRIMERA MUERTE (SECTION CRÍTICA)
    if analysis.firstDeath then
        local firstDeathFrame = CreateFrame("Frame", nil, self.Frame.content)
        firstDeathFrame:SetSize(380, 60)
        firstDeathFrame:SetPoint("TOP", self.Frame.content, "TOP", 0, yOffset)
        
        -- Fondo rojo tenue
        firstDeathFrame.bg = firstDeathFrame:CreateTexture(nil, "BACKGROUND")
        firstDeathFrame.bg:SetAllPoints()
        firstDeathFrame.bg:SetTexture(0.3, 0.1, 0.1, 0.4)
        
        local classColor = analysis.firstDeath.class and RAID_CLASS_COLORS[analysis.firstDeath.class] or {r=1,g=1,b=1}
        
        local title = firstDeathFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOPLEFT", 10, -8)
        title:SetText("|cffff0000" .. L["SECTION_FIRST_DEATH"] .. "|r")
            
        local info = firstDeathFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        info:SetPoint("LEFT", 10, -5)
        info:SetText(string.format("|cff%02x%02x%02x%s|r", 
            classColor.r*255, classColor.g*255, classColor.b*255, 
            analysis.firstDeath.name))
            
        local detail = firstDeathFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        detail:SetPoint("TOPLEFT", info, "BOTTOMLEFT", 0, -4)
        detail:SetText(string.format(L["DEATH_REPORT_FMT"], 
            analysis.firstDeath.time, analysis.firstDeath.killedBy, analysis.firstDeath.lastSpell))
            
        yOffset = yOffset - 70
    end
    
    -- 2. CONSUMIBLES
    if #analysis.noConsumables > 0 then
        self:CreateHeader(self.Frame.content, yOffset, L["SECTION_NO_CONSUMABLES"])
        yOffset = yOffset - 25
        
        local consText = self:CreateTextLine(self.Frame.content, yOffset, table.concat(analysis.noConsumables, ", "))
        consText:SetTextColor(1, 0.6, 0) -- Naranja
        yOffset = yOffset - consText:GetStringHeight() - 20
    end
    
    -- 3. INTERRUPTS
    if analysis.interruptsSuccessful > 0 or analysis.interruptsFailed > 0 then
         self:CreateHeader(self.Frame.content, yOffset, L["SECTION_INTERRUPTS"])
         yOffset = yOffset - 25
         
         local intText = string.format("Exitosos: |cff00ff00%d|r | Fallidos/Pisados: |cffff0000%d|r",
            analysis.interruptsSuccessful, analysis.interruptsFailed)
         self:CreateTextLine(self.Frame.content, yOffset, intText)
         yOffset = yOffset - 30
    end

    -- 4. CRONOLOGÍA DE MUERTES
    self:CreateHeader(self.Frame.content, yOffset, L["SECTION_TIMELINE"])
    yOffset = yOffset - 25
    
    for i, death in ipairs(analysis.deathOrder) do
        local classColor = death.class and RAID_CLASS_COLORS[death.class] or {r=1,g=1,b=1}
        local colorCode = string.format("|cff%02x%02x%02x", classColor.r*255, classColor.g*255, classColor.b*255)
        
        local deathLine = string.format("%d. [%.1fs] %s%s|r - %s", 
            i, death.time, colorCode, death.name, death.killedBy)
            
        self:CreateTextLine(self.Frame.content, yOffset, deathLine)
        yOffset = yOffset - 18
        
        if i >= 15 then 
            self:CreateTextLine(self.Frame.content, yOffset, "... y " .. (#analysis.deathOrder - 15) .. " más")
            break 
        end
    end
    
    -- Ajustar altura del contenido
    self.Frame.content:SetHeight(math.abs(yOffset) + 50)
end

function WA:CreateHeader(parent, yOffset, text)
    local h = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    h:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    h:SetText("|cffaaaaaa" .. text .. "|r")
    return h
end

function WA:CreateTextLine(parent, yOffset, text)
    local line = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    line:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, yOffset)
    line:SetWidth(390)
    line:SetJustifyH("LEFT")
    line:SetText(text)
    return line
end

function WA:AnnounceAnalysis()
    if not self.LastAnalysis then
        print("|cffff0000[Sequito]|r No hay análisis disponible")
        return
    end
    
    local analysis = self.LastAnalysis
    local channel = IsInRaid() and "RAID" or (IsInGroup() and "PARTY" or nil)
    
    local function send(msg)
        if channel then
            SendChatMessage(msg, channel)
        else
            print(msg)
        end
    end
    
    send("[Sequito] === ANÁLISIS DE WIPE ===")
    
    if analysis.firstDeath then
        send(string.format("Primera muerte: %s (%.1fs) - %s de %s",
            analysis.firstDeath.name,
            analysis.firstDeath.time,
            analysis.firstDeath.lastSpell,
            analysis.firstDeath.killedBy))
    end
    
    if #analysis.noConsumables > 0 then
        send("Sin poción/healthstone: " .. table.concat(analysis.noConsumables, ", "))
    end
    
    send(string.format("Total muertes: %d | Interrupts: %d", 
        analysis.totalDeaths, analysis.interruptsSuccessful))
end

function WA:ClearCurrent()
    self.CurrentFight = {
        inCombat = false,
        startTime = 0,
        deaths = {},
        interrupts = {successful = {}, failed = {}},
        consumables = {},
        damage = {},
        healing = {}
    }
    self.LastAnalysis = nil
    print("|cff00ff00[Sequito]|r Análisis limpiado")
    self:Hide()
end

function WA:ShowHistory()
    if #self.FightHistory == 0 then
        print("|cffff0000[Sequito]|r No hay historial de wipes")
        return
    end
    
    print("|cff00ccff[Sequito]|r Historial de wipes:")
    for i, fight in ipairs(self.FightHistory) do
        local name = fight.encounterName or "Combate"
        print(string.format("  %d. %s - %d muertes (%.1fs)", 
            i, name, #fight.deaths, fight.duration or 0))
    end
end

function WA:Toggle()
    if not self.Frame then
        self:Initialize()
    end
    
    -- Check again after Initialize (module might be disabled)
    if not self.Frame then
        return
    end
    
    self.IsVisible = not self.IsVisible
    if self.IsVisible then
        self.Frame:Show()
        if self.LastAnalysis then
            self:UpdateDisplay()
        end
    else
        self.Frame:Hide()
    end
end

function WA:Show()
    if not self.Frame then
        self:Initialize()
    end
    self.IsVisible = true
    self.Frame:Show()
    if self.LastAnalysis then
        self:UpdateDisplay()
    end
end

function WA:Hide()
    if self.Frame then
        self.IsVisible = false
        self.Frame:Hide()
    end
end

-- Comando para análisis manual
function WA:Analyze()
    if self.CurrentFight and #self.CurrentFight.deaths > 0 then
        self:AnalyzeWipe()
        self:Show()
    elseif #self.FightHistory > 0 then
        -- Mostrar último wipe del historial
        self.CurrentFight = self.FightHistory[#self.FightHistory]
        self:AnalyzeWipe()
        self:Show()
    else
        print("|cffff0000[Sequito]|r No hay datos de wipe para analizar")
    end
end

-- Registrar configuración en ModuleConfig
if S.ModuleConfig then
    S.ModuleConfig:RegisterModule("WipeAnalyzer", {
        name = "Wipe Analyzer",
        icon = "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice",
        description = "Analiza wipes de raid y muestra estadísticas de muertes",
        category = "raid",
        options = {
            {key = "enabled", type = "checkbox", label = L["CFG_ENABLED"] or "Habilitar", default = true},
            {key = "announce", type = "checkbox", label = L["CFG_ANNOUNCE"] or "Anunciar Wipes", default = true},
            {key = "trackInterrupts", type = "checkbox", label = L["CFG_TRACK_INTERRUPTS"] or "Rastrear Interrupts", default = true, tooltip = "Registra interrupts exitosos y fallidos"},
            {key = "minFightDuration", type = "slider", label = L["CFG_MIN_DURATION"] or "Duración Mínima", min = 5, max = 60, step = 5, default = 10, tooltip = "Duración mínima del combate para analizar"},
        }
    })
end
-- Auto-inicializar
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function()
    local timer = CreateFrame("Frame")
    local elapsed = 0
    timer:SetScript("OnUpdate", function(self, delta)
        elapsed = elapsed + delta
        if elapsed >= 3 then
            self:SetScript("OnUpdate", nil)
            WA:Initialize()
        end
    end)
end)
