--[[
    SEQUITO - Context Menu
    Menú de configuración al hacer click derecho en la esfera.
    Version: 8.0.0
]]--

local addonName, S = ...
S.Menu = {}
local M = S.Menu

-- Helper para obtener configuración
function M:GetOption(key)
    if S.ModuleConfig then
        return S.ModuleConfig:GetValue("Menu", key)
    end
    return true
end

function M:Initialize()
    if not self:GetOption("enabled") then
        return
    end
    
    -- Dropdown frame creation
    self.frame = CreateFrame("Frame", "SequitoMenuFrame", UIParent, "UIDropDownMenuTemplate")
end

function M:SetScale(scale)
    S.db.profile.SphereScale = scale
    if S.Sphere then S.Sphere:SetScale(scale) end
    if S.RaidPanel then S.RaidPanel:Show() end -- Refresh panel if open
end

function M:Toggle()
    if not self.frame then
        self:Initialize()
    end
    -- If still nil (e.g. disabled in config), return
    if not self.frame then return end

    local menu = {
        { text = "|cff9966ffSequito v" .. (S.Version or "8.0.0") .. "|r", isTitle = true, notCheckable = true },
        
        -- Configuración Principal
        { 
            text = S.L["OPEN_OPTIONS"] or "Abrir Configuración",
            notCheckable = true,
            func = function() 
                SlashCmdList["SEQUITO"]("") 
            end 
        },

        -- Separador
        { text = "", notCheckable = true, disabled = true },
        
        -- Módulos Principales (v8.0.0)
        { 
            text = S.L["ASSIGNMENTS_PANEL"] or "Panel de Asignaciones",
            notCheckable = true,
            func = function() 
                if S.Assignments then S.Assignments:Toggle() end 
            end 
        },
        { 
            text = S.L["ANALYZE_WIPE"] or "Analizar Último Wipe",
            notCheckable = true,
            func = function() 
                if S.WipeAnalyzer then S.WipeAnalyzer:Analyze() end 
            end 
        },
        { 
            text = S.L["COOLDOWN_monitor"] or "Monitor de Cooldowns",
            notCheckable = true,
            func = function() 
                if S.CooldownMonitor then S.CooldownMonitor:Toggle() end 
            end 
        },

        -- Herramientas Raid
        {
            text = S.L["RAID_TOOLS"] or "Herramientas de Raid",
            hasArrow = true,
            notCheckable = true,
            menuList = {
                { 
                    text = S.L["READY_CHECK"] or "Ready Check", 
                    notCheckable = true,
                    func = function() if S.ReadyChecker then S.ReadyChecker:Toggle() end end 
                },
                { 
                    text = "Pull Timer (10s)", 
                    notCheckable = true,
                    func = function() if S.Assignments then S.Assignments:StartPullTimer(10) end end 
                },
                { 
                    text = "Raid Panel", 
                    notCheckable = true,
                    func = function() if S.RaidPanel then S.RaidPanel:Toggle() end end 
                },
                { 
                    text = "Loot Council", 
                    notCheckable = true,
                    func = function() if S.LootCouncil then S.LootCouncil:Toggle() end end 
                },
            }
        },

        -- Herramientas PvP (v8.0.0)
        {
            text = "Herramientas PvP",
            hasArrow = true,
            notCheckable = true,
            menuList = {
                { 
                    text = "Tracker de Trinkets", 
                    notCheckable = true,
                    func = function() if S.TrinketTracker then S.TrinketTracker:Toggle() end end 
                },
                { 
                    text = "Focus Fire", 
                    notCheckable = true,
                    func = function() if S.FocusFire then S.FocusFire:Toggle() end end 
                },
                { 
                    text = "Coordinador de CC", 
                    notCheckable = true,
                    func = function() if S.CCCoordinator then S.CCCoordinator:Toggle() end end 
                },
                { 
                    text = "Monitor de Healers", 
                    notCheckable = true,
                    func = function() if S.HealerTracker then S.HealerTracker:Toggle() end end 
                },
                { 
                    text = "Alertas Defensivas", 
                    notCheckable = true,
                    func = function() if S.DefensiveAlerts then S.DefensiveAlerts:Toggle() end end 
                },
            }
        },

        -- Herramientas Dungeon (v8.0.0)
        {
            text = "Herramientas Dungeon",
            hasArrow = true,
            notCheckable = true,
            menuList = {
                { 
                    text = "Guía de Pulls", 
                    notCheckable = true,
                    func = function() if S.PullGuide then S.PullGuide:Toggle() end end 
                },
                { 
                    text = "Timer de Dungeons", 
                    notCheckable = true,
                    func = function() if S.DungeonTimer then S.DungeonTimer:Toggle() end end 
                },
            }
        },
        
        -- Config Rapida
        {
            text = S.L["QUICK_SETTINGS"] or "Ajustes Rápidos",
            hasArrow = true,
            notCheckable = true,
            menuList = {
                { 
                    text = S.L["LOCK_SPHERE"] or "Bloquear Esfera",
                    checked = S.db.profile.Locked,
                    func = function() 
                        S.db.profile.Locked = not S.db.profile.Locked
                        print("|cff00ff00Sequito:|r Esfera " .. (S.db.profile.Locked and "Bloqueada" or "Desbloqueada"))
                    end
                },
                 {
                    text = "Activar Frases",
                    checked = S.db.profile.ShowSpeech,
                    func = function()
                        S.db.profile.ShowSpeech = not S.db.profile.ShowSpeech
                    end
                },
                {
                    text = "Escala",
                    hasArrow = true,
                    menuList = {
                        { text = "50%", func = function() M:SetScale(0.5) end },
                        { text = "75%", func = function() M:SetScale(0.75) end },
                        { text = "100%", func = function() M:SetScale(1.0) end },
                        { text = "125%", func = function() M:SetScale(1.25) end },
                        { text = "150%", func = function() M:SetScale(1.5) end },
                    }
                }
            }
        },
        
        { text = S.L["CLOSE"] or "Cerrar", notCheckable = true, func = function() end }
    }
    
    local frame = self.frame
    
    -- Inicializar menu para EasyMenu o UIDropDown estándar
    UIDropDownMenu_Initialize(frame, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        local list = level and menuList or menu
        -- Si level es 1 (nil o 1), usamos root menu.
        -- Si level > 1, usamos menuList pasado por el sistema de WoW
        if level == 1 or not level then
             list = menu
        end
        -- EasyMenu en 3.3.5 usa level 1 por defecto, pero UIDropDownMenu maneja submenus via calls recursivas
        -- En 3.3.5 la estructura `menuList` dentro de items hace que UIDropDownMenu lo maneje auto si pasamos `menuList` correcto.
        
        -- NOTA: UIDropDownMenu_Initialize pasa (frame, level, menuList). 
        -- menuList es la tabla anidada si level > 1.
        
        for _, item in ipairs(list) do
            if item.text then
                wipe(info)
                info.text = item.text
                info.isTitle = item.isTitle
                info.notCheckable = item.notCheckable
                info.func = item.func
                info.checked = item.checked
                info.disabled = item.disabled
                info.hasArrow = item.hasArrow
                info.menuList = item.menuList 
                info.keepShownOnClick = item.keepShownOnClick -- A veces util
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end, "MENU")
    
    ToggleDropDownMenu(1, nil, frame, "cursor", 0, 0)
end

-- Registrar en ModuleConfig
if S.ModuleConfig then
    S.ModuleConfig:RegisterModule("Menu", {
        name = "Context Menu",
        description = "Menu de opciones de click derecho",
        category = "general",
        icon = "Interface\\Icons\\INV_Misc_Gear_01",
        options = {
            {key = "enabled", type = "checkbox", label = "Habilitar Menú", default = true}
        }
    })
end
