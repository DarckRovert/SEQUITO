--[[
    SEQUITO - El Sequito del Terror
    Universal Sphere UI for WotLK 3.3.5a
    
    Addon universal para TODAS las clases.
    - Reconocimiento de clase/raza
    - Generacion de macros personalizadas
    - Sincronizacion de raid (hasta 40 jugadores)
    - Datos estrategicos en tiempo real
    
    Copyright (c) 2026 DarckRovert (Ingame: Eljesuita)
]]--

-- Namespace
local addonName, S = ...
_G.Sequito = S -- Global Access

-- Version
S.Version = "8.0.0"
S.Build = "Sistema Automático Edition"

-- Database Defaults
local defaults = {
    profile = {
        Enabled = true, -- Master switch
        Scale = 1.0,
        Alpha = 1.0,
        Position = {point = "CENTER", relativeTo = "UIParent", relativePoint = "CENTER", x = 0, y = 0},
        Locked = false,
        Language = "esMX",
        ShowWelcome = true,
        Debug = false,
        ShowMinimap = true,
        ShowTooltips = true,
        
        -- Sphere
        ShowSphere = true,
        SphereScale = 1.0,
        SphereText = true,
        SpherePercent = true,
        
        -- Raid Panel
        ShowRaidPanel = true,
        RaidPanelScale = 1.0,
        RaidPanelHP = true,
        RaidPanelRoles = true,
        RaidPanelAuto = false,
        RaidPanelSort = "class",

        -- Features
        ShowSpeech = true,
        RaidSync = true,
        SyncAnnounce = true,
        ShowAlerts = true,
        AlertSound = true,
        AlertFlash = true,
        AlertCombatOnly = true,
        AlertLowHP = true,
        AlertBuffs = true,
        AlertCDs = true,
        AlertRaid = true,
        
        -- Logistics
        AutoRepair = true,
        AutoSell = true,
        AutoTrade = true,
        ShardLimit = 28,
        -- Menu Toggles
        ShowRunes = true,
        ShowMounts = true,
        AutoMacros = true,
        MacroConfirm = true, -- Default to TRUE for the new system
    }
}

-- Core Event Frame
S.Core = CreateFrame("Frame")
S.Core:RegisterEvent("ADDON_LOADED")
S.Core:RegisterEvent("PLAYER_LOGIN")
S.Core:RegisterEvent("PLAYER_ENTERING_WORLD")

S.Core:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        S:OnInitialize()
    elseif event == "PLAYER_LOGIN" then
        S:OnEnable()
    elseif event == "PLAYER_ENTERING_WORLD" then
        S:OnEnterWorld()
    end
end)

function S:OnInitialize()
    -- Initialize Database safely
    if not SequitoDB then SequitoDB = {} end
    
    -- Merge defaults (Deep copy/Merge simulo)
    if not SequitoDB.profile then SequitoDB.profile = {} end
    
    for k, v in pairs(defaults.profile) do
        if SequitoDB.profile[k] == nil then
            SequitoDB.profile[k] = v
        end
    end
    
    self.db = SequitoDB
    
    -- Mensaje de carga
    print(string.format("|cFFFF00FFSequito|r v%s |cFF888888%s|r cargando...", self.Version, self.Build))
end

function S:OnEnable()
    -- 0. Inicializar ModuleConfig PRIMERO (Configuración crítica)
    if S.ModuleConfig and S.ModuleConfig.Initialize then S.ModuleConfig:Initialize() end

    -- 1. Inicializar Universal (Datos de Jugador)
    if S.Universal and S.Universal.Initialize then
        S.Universal:Initialize()
    end
    
    -- 2. Inicializar GUI (Esfera) - Ahora seguro porque ModuleConfig está listo
    if S.GUI and S.GUI.Initialize then
        print("|cFF00FFFFSequito|r: Creando Interfaz...")
        S.GUI:Initialize()
    else
        print("|cFFFF0000Sequito Error|r: Modulo GUI no encontrado.")
    end
    
    -- 3. Generar Macros (Forzado)
    if S.MacroGen then
        print("|cFF00FFFFSequito|r: Verificando macros...")
        S.MacroGen:GenerateClassMacros()
    end
    
    -- Inicializar otros modulos
    if S.RaidSync and S.RaidSync.Initialize then S.RaidSync:Initialize() end
    if S.RaidIntel and S.RaidIntel.Initialize then S.RaidIntel:Initialize() end
    if S.RaidPanel and S.RaidPanel.Initialize then S.RaidPanel:Initialize() end
    
    if S.Options and S.Options.Initialize then S.Options:Initialize() end
    if S.CombatTracker and S.CombatTracker.Initialize then S.CombatTracker:Initialize() end
    if S.Logistics and S.Logistics.Initialize then S.Logistics:Initialize() end
    if S.PetManager and S.PetManager.Initialize then S.PetManager:Initialize() end
    if S.CCTracker and S.CCTracker.Initialize then S.CCTracker:Initialize() end
    if S.Visuals and S.Visuals.Initialize then S.Visuals:Initialize() end
    if S.Runes and S.Runes.Initialize then S.Runes:Initialize() end
    if S.Mounts and S.Mounts.Initialize then S.Mounts:Initialize() end
    if S.Menu and S.Menu.Initialize then S.Menu:Initialize() end
    
    -- RaidAssist (Nuevo)
    if S.RaidAssist and S.RaidAssist.Initialize then S.RaidAssist:Initialize() end
    if S.RaidAssistUI and S.RaidAssistUI.Initialize then S.RaidAssistUI:Initialize() end
    
    -- MacroSync (Sistema de macros compartidos)
    if S.MacroSync and S.MacroSync.Initialize then S.MacroSync:Initialize() end
    
    -- SpecWatcher (Monitor)
    if S.SpecWatcher and S.SpecWatcher.Initialize then 
        S.SpecWatcher:Initialize() 
    end

    -- v8.0.0 Sistema Automático
    if S.Alerts and S.Alerts.Initialize then S.Alerts:Initialize() end
    
    if S.AutoSync and S.AutoSync.Initialize then
        S.AutoSync:Initialize()
    end
    if S.SmartDefaults and S.SmartDefaults.Initialize then
        S.SmartDefaults:Initialize()
    end
    if S.ContextEngine and S.ContextEngine.Initialize then
        S.ContextEngine:Initialize()
    end

    -- v8.0.0 Modules Initialization
    local modules = {
        "Universal", "CooldownMonitor", "Assignments", "ReadyChecker", "TrinketTracker", 
        "WipeAnalyzer", "FocusFire", "CCCoordinator", "HealerTracker", 
        "DefensiveAlerts", "PullGuide", "DungeonTimer", "LootCouncil", 
        "PlayerNotes", "BuildManager", "EventCalendar", "PerformanceStats", 
        "VotingSystem", "VersionSync", "QuickWhisper"
    }

    for _, moduleName in ipairs(modules) do
        if S[moduleName] and S[moduleName].Initialize then
            S[moduleName]:Initialize()
        end
    end
    
    -- Reporte Final
    if S.Sphere and S.Sphere:IsVisible() then
        -- Sphere OK
    else
        -- Auto-fix position silently
        if S.Sphere then
            S.Sphere:ClearAllPoints()
            S.Sphere:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            S.Sphere:Show()
            print("|cFF00FF00Sequito|r: Posicion de esfera restaurada.")
        end
    end
    
    print("|cFFFF00FFSequito|r: Sistema listo. (/sequito help)")
    PlaySound("ReadyCheck") -- Audio Feedback
end

function S:OnEnterWorld()
    -- Re-check UI
    if S.GUI and not S.Sphere then
        S.GUI:Initialize()
    end
end

-- ===========================================================================
-- SLASH COMMANDS
-- ===========================================================================
SLASH_SEQUITO1 = "/sequito"
SLASH_SEQUITO2 = "/seq"

SlashCmdList["SEQUITO"] = function(msg)
    local cmd, arg = strsplit(" ", msg, 2)
    cmd = cmd:lower()
    
    if cmd == "" then
        if S.Options then
            S.Options:Toggle()
        else
            S:PrintHelp()
        end
    elseif cmd == "help" then
        S:PrintHelp()
    elseif cmd == "macros" then
        if S.MacroGen then
            S.MacroGen:GenerateClassMacros()
        end
    elseif cmd == "raid" or cmd == "comp" then
        if S.RaidSync then
            S.RaidSync:PrintRaidComposition()
        end
    elseif cmd == "buffs" or cmd == "scan" then
        if S.RaidIntel then
            S.RaidIntel:PrintBuffReport()
        end
    elseif cmd == "focus" then
        if S.RaidSync then
            S.RaidSync:SendFocus(arg)
        end
    elseif cmd == "alpha" then
        if S.RaidSync then
            S.RaidSync:SendAlphaStrike()
        end
    elseif cmd == "class" or cmd == "classes" then
        if S.RaidIntel then
            S.RaidIntel:PrintClassCount()
        end
    elseif cmd == "info" then
        S:PrintPlayerInfo()
    elseif cmd == "panel" or cmd == "raidpanel" then
        if S.RaidPanel then
            S.RaidPanel:Toggle()
        end
    elseif cmd == "options" or cmd == "config" or cmd == "opciones" then
        if S.Options then
            S.Options:Toggle()
        end
    elseif cmd == "combat" or cmd == "dps" then
        if S.CombatTracker then
            S.CombatTracker:PrintSummary()
        end
    elseif cmd == "combatclear" or cmd == "clearhistory" then
        if S.CombatTracker then
            S.CombatTracker:ClearHistory()
        end
    elseif cmd == "spec" then
        if S.SpecWatcher then
            local info = S.SpecWatcher:GetInfo()
            print("|cFFFF00FF=== Sequito: Especializacion ===")
            print(string.format("Clase: |cFFFFFFFF%s|r", info.class))
            print(string.format("Spec: |cFFFFFFFF%s|r (Arbol %d)", info.specName, info.spec))
            print(string.format("Grupo de Talentos: |cFFFFFFFF%d|r", info.talentGroup))
            print(string.format("Auto-update macros: |cFFFFFFFF%s|r", info.autoUpdate and "Si" or "No"))
        end
    elseif cmd == "specauto" then
        if S.SpecWatcher then
            local current = S.SpecWatcher:GetInfo().autoUpdate
            S.SpecWatcher:SetAutoUpdate(not current)
        end
    elseif cmd == "lock" then
        S.db.profile.Locked = not S.db.profile.Locked
        print("|cFFFF00FFSequito|r: Posicion " .. (S.db.profile.Locked and "bloqueada" or "desbloqueada"))
    elseif cmd == "reset" then
        S.db.profile.Position = defaults.profile.Position
        if S.Sphere then
            S.Sphere:ClearAllPoints()
            S.Sphere:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        end
        print("|cFFFF00FFSequito|r: Posicion reiniciada.")
    elseif cmd == "mounts" or cmd == "monturas" then
        if S.Mounts then
            S.Mounts:ListMounts()
        end
    elseif cmd == "setflying" then
        if S.Mounts and arg then
            S.Mounts:SetFavorite("flying", arg)
        end
    elseif cmd == "setground" then
        if S.Mounts and arg then
            S.Mounts:SetFavorite("ground", arg)
        end
    elseif cmd == "setaquatic" then
        if S.Mounts and arg then
            S.Mounts:SetFavorite("aquatic", arg)
        end
    elseif cmd == "ra" or cmd == "raidassist" then
        if S.RaidAssistUI then
            S.RaidAssistUI:Toggle()
        end
    elseif cmd == "raleader" then
        if S.RaidAssistUI then
            S.RaidAssistUI:ToggleLeaderPanel()
        end
    elseif cmd == "pull" then
        local seconds = tonumber(arg) or 10
        if S.RaidAssist then
            S.RaidAssist:StartPullTimer(seconds)
        end
    elseif cmd == "phase" then
        if S.RaidAssist and arg then
            S.RaidAssist:AnnouncePhase(arg)
        end
    elseif cmd == "checkbuffs" or cmd == "checkcons" then
        if S.RaidAssist then
            S.RaidAssist:CheckConsumables()
            local report = S.RaidAssist:GetConsumableReport()
            S:Print("=== Reporte de Consumibles ===")
            S:Print(report)
        end
    elseif cmd == "wipes" then
        if S.RaidAssist then
            S:Print("Wipes en esta sesión: " .. S.RaidAssist.wipeCount)
        end
    elseif cmd == "resetwipes" then
        if S.RaidAssist then
            S.RaidAssist:ResetWipeCounter()
            S:Print("Contador de wipes reiniciado")
        end
    elseif cmd == "mode" then
        if S.RaidAssist then
            local newMode = arg and arg:upper() or (S.RaidAssist.mode == "FARM" and "PROGRESSION" or "FARM")
            S.RaidAssist:SetMode(newMode)
        end
    elseif cmd == "wipehistory" or cmd == "wipestats" then
        if S.RaidAssist then
            S.RaidAssist:PrintWipeHistory()
        end
    elseif cmd == "clearwipes" then
        if S.RaidAssist then
            S.RaidAssist:ClearWipeHistory()
        end
    elseif cmd == "alert" then
        if S.RaidAssist and arg then
            S.RaidAssist:ShowAlert(arg, "INFO", 5)
        end
    elseif cmd == "alertpos" then
        if S.RaidAssist and arg then
            local pos = arg:upper()
            if pos == "TOP" or pos == "CENTER" or pos == "BOTTOM" then
                S.RaidAssist:SetAlertPosition(pos)
                S:Print("Posici\195\179n de alertas: " .. pos)
            end
        end
    -- TrinketTracker Commands (PvP)
    elseif cmd == "trinkets" or cmd == "tt" then
        if S.TrinketTracker then
            local subcmd = arg and arg:lower() or ""
            if subcmd == "clear" then
                S.TrinketTracker:ClearAll()
            elseif subcmd == "announce" then
                S.TrinketTracker:AnnounceAll()
            else
                S.TrinketTracker:Toggle()
            end
        end
    -- WipeAnalyzer Commands (PvE)
    elseif cmd == "analyze" or cmd == "wa" then
        if S.WipeAnalyzer then
            local subcmd = arg and arg:lower() or ""
            if subcmd == "announce" then
                S.WipeAnalyzer:AnnounceAnalysis()
            elseif subcmd == "clear" then
                S.WipeAnalyzer:ClearCurrent()
            elseif subcmd == "history" then
                S.WipeAnalyzer:ShowHistory()
            else
                S.WipeAnalyzer:Analyze()
            end
        end
    -- CooldownMonitor Commands
    elseif cmd == "cooldowns" or cmd == "cd" then
        if S.CooldownMonitor then
            local subcmd = arg and arg:lower() or ""
            if subcmd == "bres" then
                S.CooldownMonitor:AnnounceAvailable("bres")
            elseif subcmd == "lust" then
                S.CooldownMonitor:AnnounceAvailable("lust")
            elseif subcmd == "raid" then
                S.CooldownMonitor:AnnounceAvailable("raid_cd")
            elseif subcmd == "external" then
                S.CooldownMonitor:AnnounceAvailable("external")
            else
                S.CooldownMonitor:Toggle()
            end
        end
    -- Assignments Commands
    elseif cmd == "assign" or cmd == "as" then
        if S.Assignments then
            local subcmd = arg and arg:lower() or ""
            if subcmd == "interrupts" then
                S.Assignments:AutoAssignInterrupts()
            elseif subcmd == "announce" then
                S.Assignments:AnnounceAll()
            elseif subcmd == "clear" then
                S.Assignments:ClearAll()
            elseif subcmd == "sync" then
                S.Assignments:SyncToRaid()
            else
                S.Assignments:Toggle()
            end
        end
    -- Pull Timer Command
    elseif cmd == "pull" then
        if S.Assignments then
            S.Assignments:StartPullTimer(tonumber(arg) or 10)
        end
    -- ReadyChecker Commands
    elseif cmd == "readycheck" or cmd == "rc" then
        if S.ReadyChecker then
            local subcmd = arg and arg:lower() or ""
            if subcmd == "full" then
                S.ReadyChecker:ScanRaid()
                S.ReadyChecker:AnnounceProblems()
            elseif subcmd == "scan" then
                S.ReadyChecker:ScanRaid()
            else
                S.ReadyChecker:Toggle()
            end
        end
    -- FocusFire Commands (PvP)
    elseif cmd == "focusfire" or cmd == "ff" then
        if S.FocusFire then
            local subcmd = arg and arg:lower() or ""
            if subcmd == "call" then
                S.FocusFire:CallTarget()
            else
                S.FocusFire:Toggle()
            end
        end
    -- CCCoordinator Commands (PvP)
    elseif cmd == "cc" or cmd == "cccoord" then
        if S.CCCoordinator then
            local subcmd = arg and arg:lower() or ""
            if subcmd == "assign" then
                S.CCCoordinator:AssignCC()
            elseif subcmd == "clear" then
                S.CCCoordinator:ClearAssignments()
            else
                S.CCCoordinator:Toggle()
            end
        end
    -- HealerTracker Commands (PvP)
    elseif cmd == "healers" or cmd == "ht" then
        if S.HealerTracker then
            S.HealerTracker:Toggle()
        end
    -- DefensiveAlerts Commands (PvP)
    elseif cmd == "defensive" or cmd == "def" then
        if S.DefensiveAlerts then
            local subcmd = arg and arg:lower() or ""
            if subcmd == "peel" then
                S.DefensiveAlerts:RequestPeel()
            elseif subcmd == "heal" then
                S.DefensiveAlerts:RequestHeal()
            elseif subcmd == "dispel" then
                S.DefensiveAlerts:RequestDispel()
            else
                S.DefensiveAlerts:Toggle()
            end
        end
    -- PullGuide Commands (Dungeons)
    elseif cmd == "pullguide" or cmd == "pg" then
        if S.PullGuide then
            local subcmd = arg and arg:lower() or ""
            if subcmd == "mark" then
                S.PullGuide:MarkPack()
            else
                S.PullGuide:Toggle()
            end
        end
    -- DungeonTimer Commands (Dungeons)
    elseif cmd == "dungeon" or cmd == "dt" then
        if S.DungeonTimer then
            S.DungeonTimer:Toggle()
        end
    -- LootCouncil Commands (Dungeons)
    elseif cmd == "loot" or cmd == "lc" then
        if S.LootCouncil then
            local subcmd = arg and arg:lower() or ""
            if subcmd == "start" then
                S.LootCouncil:StartSession()
            elseif subcmd == "end" then
                S.LootCouncil:EndSession()
            else
                S.LootCouncil:Toggle()
            end
        end
    -- PlayerNotes Commands (General)
    elseif cmd == "notes" or cmd == "pn" then
        if S.PlayerNotes then
            local subcmd, subarg = strsplit(" ", arg or "", 2)
            subcmd = subcmd and subcmd:lower() or ""
            if subcmd == "add" and subarg then
                local player, note = strsplit(" ", subarg, 2)
                if player and note then
                    S.PlayerNotes:AddNote(player, note)
                end
            elseif subcmd == "show" and subarg then
                S.PlayerNotes:ShowNote(subarg)
            elseif subcmd == "delete" and subarg then
                S.PlayerNotes:DeleteNote(subarg)
            else
                S.PlayerNotes:Toggle()
            end
        end
    -- BuildManager Commands (General)
    elseif cmd == "build" or cmd == "bm" then
        if S.BuildManager then
            local subcmd, subarg = strsplit(" ", arg or "", 2)
            subcmd = subcmd and subcmd:lower() or ""
            if subcmd == "save" and subarg then
                S.BuildManager:SaveBuild(subarg)
            elseif subcmd == "load" and subarg then
                S.BuildManager:LoadBuild(subarg)
            elseif subcmd == "list" then
                S.BuildManager:ListBuilds()
            elseif subcmd == "delete" and subarg then
                S.BuildManager:DeleteBuild(subarg)
            else
                S.BuildManager:Toggle()
            end
        end
    -- EventCalendar Commands (General)
    elseif cmd == "calendar" or cmd == "cal" then
        if S.EventCalendar then
            S.EventCalendar:Toggle()
        end
    -- PerformanceStats Commands (General)
    elseif cmd == "stats" or cmd == "ps" then
        if S.PerformanceStats then
            local subcmd = arg and arg:lower() or ""
            if subcmd == "clear" then
                S.PerformanceStats:ClearStats()
            elseif subcmd == "compare" then
                S.PerformanceStats:CompareRaids()
            else
                S.PerformanceStats:Toggle()
            end
        end
    -- VotingSystem Commands (General)
    elseif cmd == "poll" or cmd == "vote" then
        if S.VotingSystem then
            local subcmd = arg and arg:lower() or ""
            if subcmd == "yes" then
                S.VotingSystem:Vote("yes")
            elseif subcmd == "no" then
                S.VotingSystem:Vote("no")
            elseif subcmd:find("create") then
                local question = arg:gsub("create%s*", "")
                S.VotingSystem:CreatePoll(question)
            elseif subcmd == "end" then
                S.VotingSystem:EndPoll()
            else
                S.VotingSystem:Toggle()
            end
        end
    -- VersionSync Commands (General)
    elseif cmd == "version" or cmd == "vs" then
        if S.VersionSync then
            local subcmd = arg and arg:lower() or ""
            if subcmd == "check" then
                S.VersionSync:CheckVersions()
            else
                S.VersionSync:Toggle()
            end
        end
    -- QuickWhisper Commands (General)
    elseif cmd == "whisper" or cmd == "qw" then
        if S.QuickWhisper then
            local subcmd = arg and arg:lower() or ""
            if subcmd == "1" then
                S.QuickWhisper:SendTemplate(1)
            elseif subcmd == "2" then
                S.QuickWhisper:SendTemplate(2)
            elseif subcmd == "3" then
                S.QuickWhisper:SendTemplate(3)
            else
                S.QuickWhisper:Toggle()
            end
        end
    -- MacroSync Commands
    elseif cmd == "macro" then
        if S.MacroSync then
            local subcmd, subarg = strsplit(" ", arg or "", 2)
            subcmd = subcmd and subcmd:lower() or ""
            
            if subcmd == "share" and subarg then
                S.MacroSync:ShareMacro(subarg)
            elseif subcmd == "list" then
                S.MacroSync:ListSharedMacros()
            elseif subcmd == "import" and subarg then
                S.MacroSync:ImportMacro(subarg)
            elseif subcmd == "library" or subcmd == "lib" then
                local spec = S.Universal and S.Universal:GetSpec() or 0
                S.MacroSync:ListLibraryMacros(nil, spec)
            elseif subcmd == "libraryall" then
                S.MacroSync:ListLibraryMacros(nil, 0)
            elseif subcmd == "getlib" and subarg then
                S.MacroSync:ImportFromLibrary(subarg)
            elseif subcmd == "getall" then
                local spec = S.Universal and S.Universal:GetSpec() or 0
                S.MacroSync:ImportAllFromLibrary(spec)
            elseif subcmd == "request" then
                S.MacroSync:RequestMacroList()
            elseif subcmd == "get" and subarg then
                local macroName, target = strsplit(" ", subarg, 2)
                if macroName and target then
                    S.MacroSync:RequestMacro(macroName, target)
                else
                    S:Print("Uso: /sequito macro get <nombre> <jugador>")
                end
            else
                S:Print("Subcomandos de macro:")
                S:Print("  share <nombre> - Comparte un macro con el grupo")
                S:Print("  list - Lista macros compartidos recibidos")
                S:Print("  import <nombre> - Importa un macro compartido")
                S:Print("  library - Muestra biblioteca de tu clase/spec")
                S:Print("  libraryall - Muestra toda la biblioteca de tu clase")
                S:Print("  getlib <nombre> - Importa macro de biblioteca")
                S:Print("  getall - Importa todos los macros de biblioteca")
                S:Print("  request - Solicita lista de macros del grupo")
                S:Print("  get <nombre> <jugador> - Solicita macro específico")
            end
        end
    else
        print("|cFFFF00FFSequito|r: Comando desconocido. Usa /sequito help")
    end
end

function S:PrintHelp()
    print("|cFFFF00FF=== Sequito v" .. self.Version .. " - Comandos ===")
    print("|cFFFFFFFF/sequito macros|r - Genera macros para tu clase")
    print("|cFFFFFFFF/sequito raid|r - Muestra composicion de raid")
    print("|cFFFFFFFF/sequito buffs|r - Escanea buffs faltantes")
    print("|cFFFFFFFF/sequito class|r - Cuenta clases en raid")
    print("|cFFFFFFFF/sequito focus [nombre]|r - Envia orden de focus")
    print("|cFFFFFFFF/sequito alpha|r - Envia Alpha Strike")
    print("|cFFFFFFFF/sequito info|r - Muestra tu info de clase")
    print("|cFFFFFFFF/sequito panel|r - Abre/cierra panel de raid")
    print("|cFFFFFFFF/sequito options|r - Abre panel de opciones")
    print("|cFFFFFFFF/sequito combat|r - Muestra resumen de combate")
    print("|cFFFFFFFF/sequito spec|r - Muestra info de especializacion")
    print("|cFFFFFFFF/sequito specauto|r - Toggle auto-update de macros")
    print("|cFFFFFFFF/sequito lock|r - Bloquea/desbloquea posicion")
    print("|cFFFFFFFF/sequito reset|r - Reinicia posicion")
    print("|cFFFFFFFF/sequito mounts|r - Lista monturas disponibles")
    print("|cFF00FFFF=== RaidAssist ===")
    print("|cFFFFFFFF/sequito ra|r - Abre panel de RaidAssist")
    print("|cFFFFFFFF/sequito raleader|r - Panel de Raid Leader")
    print("|cFFFFFFFF/sequito pull [seg]|r - Inicia pull timer")
    print("|cFFFFFFFF/sequito phase [num]|r - Anuncia fase de boss")
    print("|cFFFFFFFF/sequito checkcons|r - Revisa consumibles")
    print("|cFFFFFFFF/sequito wipes|r - Muestra contador de wipes")
    print("|cFFFFFFFF/sequito resetwipes|r - Reinicia contador")
    print("|cFFFFFFFF/sequito mode [farm/progression]|r - Cambia modo")
    print("|cFFFFFFFF/sequito wipehistory|r - Muestra historial de wipes")
    print("|cFFFFFFFF/sequito clearwipes|r - Borra historial de wipes")
    print("|cFFFFFFFF/sequito alert [mensaje]|r - Muestra alerta de prueba")
    print("|cFFFFFFFF/sequito alertpos [top/center/bottom]|r - Posici\195\179n de alertas")
    print("|cFF00FFFF=== Monturas ===|r")
    print("|cFFFFFFFF/sequito setflying [nombre]|r - Establece montura voladora favorita")
    print("|cFFFFFFFF/sequito setground [nombre]|r - Establece montura terrestre favorita")
    print("|cFFFFFFFF/sequito setaquatic [nombre]|r - Establece montura acuatica favorita")
    print("|cFF00FFFF=== Macros Compartidos ===|r")
    print("|cFFFFFFFF/sequito macro share <nombre>|r - Comparte macro con grupo")
    print("|cFFFFFFFF/sequito macro list|r - Lista macros recibidos")
    print("|cFFFFFFFF/sequito macro import <nombre>|r - Importa macro compartido")
    print("|cFFFFFFFF/sequito macro library|r - Biblioteca de tu clase")
    print("|cFFFFFFFF/sequito macro getlib <nombre>|r - Importa de biblioteca")
    print("|cFFFFFFFF/sequito macro getall|r - Importa todos de biblioteca")
    print("|cFF00FFFF=== PvP - TrinketTracker ===|r")
    print("|cFFFFFFFF/sequito trinkets|r - Panel de trinkets enemigos")
    print("|cFFFFFFFF/sequito trinkets clear|r - Limpiar tracker")
    print("|cFFFFFFFF/sequito trinkets announce|r - Anunciar trinkets")
    print("|cFF00FFFF=== PvE - Raid Tools ===|r")
    print("|cFFFFFFFF/sequito analyze|r - An\195\161lisis del \195\186ltimo wipe")
    print("|cFFFFFFFF/sequito cooldowns|r - Monitor de CDs del raid")
    print("|cFFFFFFFF/sequito cd bres|r - Anuncia Battle Res disponibles")
    print("|cFFFFFFFF/sequito assign|r - Panel de asignaciones")
    print("|cFFFFFFFF/sequito assign interrupts|r - Auto-asignar interrupts")
    print("|cFFFFFFFF/sequito readycheck|r - Chequeo pre-pull mejorado")
    print("|cFF00FFFF=== PvP - Herramientas ===")
    print("|cFFFFFFFF/sequito focusfire|r - Panel de Focus Fire")
    print("|cFFFFFFFF/sequito ff call|r - Llamar target actual")
    print("|cFFFFFFFF/sequito cc|r - Coordinador de CC")
    print("|cFFFFFFFF/sequito healers|r - Monitor de healers enemigos")
    print("|cFFFFFFFF/sequito defensive|r - Panel de alertas defensivas")
    print("|cFFFFFFFF/sequito def peel/heal/dispel|r - Pedir ayuda")
    print("|cFF00FFFF=== Dungeons ===")
    print("|cFFFFFFFF/sequito pullguide|r - Gu\195\173a de pulls")
    print("|cFFFFFFFF/sequito pg mark|r - Marcar pack actual")
    print("|cFFFFFFFF/sequito dungeon|r - Timer de heroicas")
    print("|cFFFFFFFF/sequito loot|r - Panel de Loot Council")
    print("|cFF00FFFF=== General ===")
    print("|cFFFFFFFF/sequito notes|r - Notas de jugadores")
    print("|cFFFFFFFF/sequito notes add <jugador> <nota>|r - Agregar nota")
    print("|cFFFFFFFF/sequito build|r - Gestor de builds")
    print("|cFFFFFFFF/sequito build save/load <nombre>|r - Guardar/cargar")
    print("|cFFFFFFFF/sequito calendar|r - Calendario de eventos")
    print("|cFFFFFFFF/sequito stats|r - Estad\195\173sticas de rendimiento")
    print("|cFFFFFFFF/sequito poll|r - Sistema de votaciones")
    print("|cFFFFFFFF/sequito poll create <pregunta>|r - Crear votaci\195\179n")
    print("|cFFFFFFFF/sequito version|r - Sincronizaci\195\179n de versiones")
    print("|cFFFFFFFF/sequito whisper|r - Mensajes r\195\161pidos")
end

function S:PrintPlayerInfo()
    if not S.Universal then return end
    
    local info = S.Universal:GetPlayerInfo()
    local r, g, b = S.Universal:GetClassColor(info.class)
    local count, resType = S.Universal:GetResourceCount()
    
    print("|cFFFF00FF=== Sequito: Tu Informacion ===")
    print(string.format("Nombre: |cFFFFFFFF%s|r", info.name))
    print(string.format("Clase: |cFF%02x%02x%02x%s|r", r*255, g*255, b*255, info.class))
    print(string.format("Raza: |cFFFFFFFF%s|r", info.race))
    print(string.format("Spec: |cFFFFFFFF%d|r | Rol: |cFFFFFFFF%s|r", info.spec, info.role))
    print(string.format("Recursos (%s): |cFFFFFFFF%d|r", resType, count))
end

-- ===========================================================================
-- UTILIDADES
-- ===========================================================================
function S:Msg(text, msgType)
    if S.Alerts and S.Alerts.Show then
        if msgType == "ERROR" then
            S.Alerts:Show(text, "ERROR")
        elseif msgType == "WARNING" then
            S.Alerts:Show(text, "WARNING")
        else
            S.Alerts:Show(text, "INFO")
        end
    else
        -- Fallback si AlertManager no cargó
        if msgType == "ERROR" then
            print("|cFFFF0000Sequito Error:|r " .. text)
        elseif msgType == "WARNING" then
            print("|cFFFFFF00Sequito:|r " .. text)
        else
            print("|cFFFF00FFSequito:|r " .. text)
        end
    end
end

function S:Print(msg)
    self:Msg(msg)
end

-- Wrapper function for Bindings.xml keybinds
function S:TargetOrAttack()
    if UnitExists("target") and UnitCanAttack("player", "target") then
        -- Already have attackable target, start attack
        if not IsCurrentSpell(6603) then -- Auto Attack spell ID
            AttackTarget()
        end
    else
        -- Target nearest enemy
        TargetNearestEnemy()
    end
end

