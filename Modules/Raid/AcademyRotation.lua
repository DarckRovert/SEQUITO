--[[
    Sequito - Academy Rotation Advisor
    Sugiere la rotación óptima basada en clase/spec.
    Parte del sistema "Academy Mode" (v9.0)
]]

local addonName, S = ...
S.AcademyRotation = {}
local AR = S.AcademyRotation

-- Rotaciones simplificadas por clase/spec
local ROTATIONS = {
    ["WARLOCK"] = {
        [1] = "Affliction: CoA > Corruption > UA > Haunt > SB filler",
        [2] = "Demonology: Corruption > Immolate > Incinerate > SB (Molten Core)",
        [3] = "Destruction: Immolate > Conflagrate > CB > Incinerate",
    },
    ["MAGE"] = {
        [1] = "Arcane: AB x4 > AM proc > ABarr reset",
        [2] = "Fire: LB > Scorch > FB > Hot Streak! > Pyroblast",
        [3] = "Frost: FB > FFB (proc) > IL (proc) > FB filler",
    },
    ["DEATHKNIGHT"] = {
        [1] = "Blood: IT > PS > HS > HS > DS > DC",
        [2] = "Frost: IT > PS > OB > BS > FS > DC/HB",
        [3] = "Unholy: IT > PS > BS > SS > DC > Gargoyle",
    },
    ["PRIEST"] = {
        [1] = "Discipline: PW:S > Penance > Flash Heal > PoM",
        [2] = "Holy: CoH > PoM > Renew > Flash Heal > GHeal",
        [3] = "Shadow: VT > SWP > DP > MB > MF filler",
    },
}

function AR:Initialize()
    if not S.db.profile.AcademyRotation then return end

    print("|cFF00FFFFSequito|r: [Academy] Rotation Advisor activo.")

    -- Register Config
    if S.ModuleConfig then
        S.ModuleConfig:RegisterModule("AcademyRotation", {
            name = "Rotation Advisor",
            description = "Muestra la rotación óptima para tu clase y especialización.",
            category = "general",
            icon = "Interface\\Icons\\Spell_Holy_SealOfRighteousness",
            options = {
                {key = "enabled", type = "checkbox", label = "Habilitar Rotation Advisor", default = true},
            }
        })
    end
end

function AR:ShowRotation()
    local _, class = UnitClass("player")
    local spec = S.Universal and S.Universal:GetSpec() or 1

    local classData = ROTATIONS[class]
    if not classData then
        print("|cFFFF9900[Sequito] No hay rotación definida para tu clase.|r")
        return
    end

    local rotation = classData[spec] or classData[1] or "Sin datos."
    print("|cFFFF00FF=== Sequito: Rotación Sugerida ===|r")
    print("|cFFFFFFFF" .. rotation .. "|r")
end
