--[[
    SEQUITO - Raid Synchronization (HiveMind)
    Sincronización de raid y comunicación addon-to-addon.
    Inspirado en NecrosisHiveMind.lua
]]--

local addonName, S = ...
S.RaidSync = {}
S.RaidSync.Prefix = "SEQUITO_SYNC"
S.RaidSync.RaidData = {} -- [PlayerName] = { class, spec, role, ready }

-- Helper para obtener configuración
function S.RaidSync:GetOption(key)
    if S.ModuleConfig then
        return S.ModuleConfig:GetValue("RaidSync", key)
    end
    return true
end

-- ===========================================================================
-- INICIALIZACIÓN
-- ===========================================================================
function S.RaidSync:Initialize()
    if not self:GetOption("enabled") then
        return
    end
    
    -- Registrar prefijo de addon
    if RegisterAddonMessagePrefix then
        RegisterAddonMessagePrefix(self.Prefix)
    end
    
    -- Frame de eventos
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("CHAT_MSG_ADDON")
    frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    frame:RegisterEvent("RAID_ROSTER_UPDATE")
    frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    frame:SetScript("OnEvent", function(self, event, ...)
        S.RaidSync:OnEvent(event, ...)
    end)
    
    print("|cFFFF00FFSequito|r: [RaidSync] Sistema de sincronización iniciado.")
end

function S.RaidSync:OnEvent(event, ...)
    if event == "CHAT_MSG_ADDON" then
        local prefix, msg, channel, sender = ...
        if prefix == self.Prefix then
            -- Ignorar mensajes propios
            if sender == UnitName("player") then return end
            self:ParseMessage(msg, sender)
        end
    elseif event == "GROUP_ROSTER_UPDATE" or event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" then
        self:ScanRaid()
        self:BroadcastMyInfo()
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Delay para asegurar que todo esté cargado
        C_Timer.After(2, function()
            S.RaidSync:ScanRaid()
            S.RaidSync:BroadcastMyInfo()
        end)
    end
end

-- ===========================================================================
-- COMUNICACIÓN
-- ===========================================================================
function S.RaidSync:Broadcast(msg)
    -- Verificar si sync está habilitado
    if not self:GetOption("syncEnabled") then
        return
    end
    
    if GetNumRaidMembers() > 0 then
        SendAddonMessage(self.Prefix, msg, "RAID")
    elseif GetNumPartyMembers() > 0 then
        SendAddonMessage(self.Prefix, msg, "PARTY")
    end
end

function S.RaidSync:BroadcastMyInfo()
    if not S.Universal then return end
    
    local info = S.Universal:GetPlayerInfo()
    -- Formato: INFO:class:spec:role
    local msg = string.format("INFO:%s:%d:%s", info.class, info.spec, info.role)
    self:Broadcast(msg)
end

function S.RaidSync:ParseMessage(msg, sender)
    local cmd, payload = strsplit(":", msg, 2)
    
    if cmd == "INFO" then
        -- Payload: class:spec:role
        local class, spec, role = strsplit(":", payload)
        self:UpdateMemberInfo(sender, class, tonumber(spec), role)
    elseif cmd == "FOCUS" then
        self:OnFocusCommand(payload, sender)
    elseif cmd == "ALPHA" then
        self:OnAlphaStrike(sender)
    elseif cmd == "READY" then
        self:OnReadyCheck(payload, sender)
    end
end

-- ===========================================================================
-- ESCANEO DE RAID
-- ===========================================================================
function S.RaidSync:ScanRaid()
    self.RaidData = {}
    
    local numRaid = GetNumRaidMembers()
    local numParty = GetNumPartyMembers()
    
    if numRaid > 0 then
        for i = 1, numRaid do
            local name, _, _, _, _, class = GetRaidRosterInfo(i)
            if name then
                self.RaidData[name] = {
                    class = class,
                    spec = 0,
                    role = "UNKNOWN",
                    hasSequito = false
                }
            end
        end
    elseif numParty > 0 then
        for i = 1, numParty do
            local unit = "party" .. i
            if UnitExists(unit) then
                local name = UnitName(unit)
                local _, class = UnitClass(unit)
                self.RaidData[name] = {
                    class = class,
                    spec = 0,
                    role = "UNKNOWN",
                    hasSequito = false
                }
            end
        end
        -- Añadir al jugador
        local myName = UnitName("player")
        local _, myClass = UnitClass("player")
        self.RaidData[myName] = {
            class = myClass,
            spec = S.Universal and S.Universal:GetSpec() or 1,
            role = S.PlayerRole or "DPS",
            hasSequito = true
        }
    end
end

function S.RaidSync:UpdateMemberInfo(name, class, spec, role)
    if not self.RaidData[name] then
        self.RaidData[name] = {}
    end
    
    self.RaidData[name].class = class
    self.RaidData[name].spec = spec
    self.RaidData[name].role = role
    self.RaidData[name].hasSequito = true
    
    -- Actualizar UI si existe
    if S.RaidSync.UpdateUI then
        S.RaidSync:UpdateUI()
    end
end

-- ===========================================================================
-- COMPOSICIÓN DE RAID
-- ===========================================================================
function S.RaidSync:GetRaidComposition()
    local comp = {
        tanks = {},
        healers = {},
        dps = {},
        unknown = {},
        total = 0,
        byClass = {}
    }
    
    for name, data in pairs(self.RaidData) do
        comp.total = comp.total + 1
        
        -- Por rol
        if data.role == "TANK" then
            table.insert(comp.tanks, name)
        elseif data.role == "HEALER" then
            table.insert(comp.healers, name)
        elseif data.role == "DPS" then
            table.insert(comp.dps, name)
        else
            table.insert(comp.unknown, name)
        end
        
        -- Por clase
        if data.class then
            if not comp.byClass[data.class] then
                comp.byClass[data.class] = {}
            end
            table.insert(comp.byClass[data.class], name)
        end
    end
    
    return comp
end

function S.RaidSync:PrintRaidComposition()
    local comp = self:GetRaidComposition()
    
    print("|cFFFF00FF=== Sequito: Composición de Raid ===")
    print(string.format("|cFFFFFFFFTotal: %d jugadores|r", comp.total))
    print(string.format("|cFF00FF00Tanks: %d|r - %s", #comp.tanks, table.concat(comp.tanks, ", ")))
    print(string.format("|cFF00FFFFHealers: %d|r - %s", #comp.healers, table.concat(comp.healers, ", ")))
    print(string.format("|cFFFF0000DPS: %d|r - %s", #comp.dps, table.concat(comp.dps, ", ")))
    
    if #comp.unknown > 0 then
        print(string.format("|cFF888888Sin Sequito: %d|r - %s", #comp.unknown, table.concat(comp.unknown, ", ")))
    end
    
    print("|cFFFF00FF--- Por Clase ---|r")
    for class, players in pairs(comp.byClass) do
        local r, g, b = S.Universal:GetClassColor(class)
        print(string.format("|cFF%02x%02x%02x%s (%d)|r: %s", 
            r*255, g*255, b*255, class, #players, table.concat(players, ", ")))
    end
end

-- ===========================================================================
-- COMANDOS TÁCTICOS
-- ===========================================================================
function S.RaidSync:SendFocus(targetName)
    if not targetName then
        targetName = UnitName("target")
    end
    if not targetName then
        print("|cFFFF0000Sequito|r: No hay objetivo seleccionado.")
        return
    end
    
    self:Broadcast("FOCUS:" .. targetName)
    print("|cFFFF00FFSequito|r: Orden de FOCUS enviada: " .. targetName)
end

function S.RaidSync:OnFocusCommand(targetName, sender)
    -- Mostrar alerta visual
    if S.RaidSync.ShowFocusAlert then
        S.RaidSync:ShowFocusAlert(targetName, sender)
    else
        -- Fallback: mensaje en chat
        print(string.format("|cFFFF0000[SEQUITO] FOCUS: %s|r (ordenado por %s)", targetName, sender))
        PlaySound("RaidWarning")
    end
end

function S.RaidSync:SendAlphaStrike()
    self:Broadcast("ALPHA:NOW")
    print("|cFFFF00FFSequito|r: ¡ALPHA STRIKE enviado!")
end

function S.RaidSync:OnAlphaStrike(sender)
    print(string.format("|cFFFFD700[SEQUITO] ¡¡ALPHA STRIKE!! ordenado por %s|r", sender))
    PlaySound("RaidWarning")
    
    -- Efecto visual si existe
    if S.FX and S.FX.PlayAlphaStrike then
        S.FX:PlayAlphaStrike()
    end
end

-- ===========================================================================
-- FRAME DE ALERTA VISUAL
-- ===========================================================================
-- ===========================================================================
-- FRAME DE ALERTA VISUAL (TACTICAL DISPLAY)
-- ===========================================================================
function S.RaidSync:CreateAlertFrame()
    local f = CreateFrame("Frame", "SequitoTacticalFrame", UIParent)
    f:SetSize(400, 100)
    f:SetPoint("TOP", UIParent, "TOP", 0, -180) -- Un poco mas abajo que los errores
    f:Hide()
    
    -- Fondo semi-transparente para darle peso
    f.bg = f:CreateTexture(nil, "BACKGROUND")
    f.bg:SetAllPoints()
    f.bg:SetTexture(0, 0, 0, 0.6)
    f.bg:SetBlendMode("MOD") -- Efecto oscurecedor
    
    -- Texto Gigante
    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    f.text:SetPoint("CENTER", f, "CENTER", 20, 0)
    f.text:SetTextColor(1, 0.1, 0.1) -- Rojo Intenso
    f.text:SetShadowColor(0, 0, 0)
    f.text:SetShadowOffset(2, -2)
    
    -- Icono de Calavera (Skull)
    f.icon = f:CreateTexture(nil, "OVERLAY")
    f.icon:SetSize(50, 50)
    f.icon:SetPoint("RIGHT", f.text, "LEFT", -10, 0)
    f.icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_8")
    
    -- Animacion de Flash
    f.ag = f:CreateAnimationGroup()
    local a1 = f.ag:CreateAnimation("Alpha")
    a1:SetChange(-1)
    a1:SetDuration(0.5)
    a1:SetOrder(1)
    a1:SetSmoothing("IN_OUT") 
    local a2 = f.ag:CreateAnimation("Alpha")
    a2:SetChange(1)
    a2:SetDuration(0.5)
    a2:SetOrder(2)
    a2:SetSmoothing("IN_OUT")
    f.ag:SetLooping("BOUNCE")
    
    self.AlertFrame = f
end

function S.RaidSync:ShowFocusAlert(targetName, sender)
    if not self.AlertFrame then
        self:CreateAlertFrame()
    end
    
    local f = self.AlertFrame
    f.text:SetText("MATAR: " .. (targetName or "TARGET"))
    f:Show()
    f.ag:Play() -- Iniciar parpadeo
    
    -- Sonido de Alerta de Raid
    PlaySound("RaidWarning")
    
    -- Auto-ocultar tras 6 segundos
    if self.hideTimer then C_Timer.After(0.1, function() end) end -- Cancel dummy
    -- Tip: C_Timer.After no devuelve handle en nuestro polyfill simple.
    -- Simplemente lanzamos otro timer que oculte. Si se solapan, se oculta antes. No es critico.
    C_Timer.After(6, function() 
        f:Hide() 
        f.ag:Stop()
    end)
end

-- Registrar módulo en ModuleConfig
if S.ModuleConfig then
    S.ModuleConfig:RegisterModule("RaidSync", {
        name = "Raid Sync",
        description = "Sincronización de raid y comunicación addon-to-addon",
        category = "raid",
        icon = "Interface\\\\Icons\\\\Spell_Holy_PrayerOfHealing",
        options = {
            {key = "enabled", type = "checkbox", label = "Habilitar Raid Sync", default = true},
            {key = "broadcastInfo", type = "checkbox", label = "Transmitir información de spec/rol", default = true},
            {key = "showAlerts", type = "checkbox", label = "Mostrar alertas tácticas", default = true},
            {key = "syncCooldowns", type = "checkbox", label = "Sincronizar cooldowns", default = true},
        }
    })
end

