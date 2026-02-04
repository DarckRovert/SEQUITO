--[[
    SEQUITO - Speech Database (Flavor Text)
]]--

local addonName, S = ...
S.Data = S.Data or {}
S.Data.Speech = {}

-- Basic Flavors
S.Data.Speech.Summon = {
    "¡Taxi Arcano! Por favor, dadle click al portal o no nos vamos nunca.",
    "Abriendo un agujero en el espacio-tiempo...",
    "¡Venid a mí, esbirros! (Click en el portal)",
    "Servicio de invocación 'Sequito Express' activo.",
    "Invocando a los perezosos. ¡Haced click en el armario!",
    "No tengo todo el día, tocad el portal.",
    "He traído el portal. Traed las galletas.",
    "¡Por el poder del vacío, os invoco!",
    "Ritual de pereza iniciado. Click, por favor.",
}

S.Data.Speech.Soulstone = {
    "He guardado el alma de <target>. Ya puedes morir tranquilo.",
    "<target> tiene una Piedra del Alma. ¡Aprovechadla!",
    "No te preocupes <target>, la muerte es solo el principio.",
    "¡Tu alma es mía, <target>! (Guardada por si acaso)",
    "Contrato firmado: <target> tiene permiso para morir una vez.",
    "¡<target> ha sido respaldado en la nube!",
    "Seguro de vida activado para <target>.",
    "Si mueres, <target>, recuerda que yo te salvé.",
}

S.Data.Speech.Mount = {
    "¡A cabalgar!",
    "¡Por la Horda! (O la Alianza, lo que sea...)",
    "Invocando montura de la muerte...",
    "Me voy, mi planeta me necesita.",
    "¡Corred, insensatos!",
    "Activando modo turbo...",
    "¡Yihaaa!",
}

S.Data.Speech.Resurrect = {
    "¡Levántate, <target>! ¡Aún no he terminado contigo!",
    "¡Vuelve a la vida, gusano!",
    "La muerte te rechaza, <target>.",
    "Arriba, <target>, que el suelo está frío.",
    "¡<target> vive! (Más o menos).",
    "¡No te hagas el muerto, <target>!",
    "Desfibrilador mágico... ¡YA!",
}

-- Helpers
function S:GetRandomSpeech(category)
    local tbl = S.Data.Speech[category]
    if tbl then
        return tbl[math.random(#tbl)]
    end
    return nil
end
