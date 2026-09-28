-- Stolen items. ITEM_BY_CITY keys real landmarks to their actual home
-- city — a briefing must never claim, say, the Mona Lisa was stolen from
-- Kathmandu (see src/mission.lua). Cities without a specific landmark
-- here draw from GENERIC instead, which describes something vague
-- enough to be true of any city's museum.
return {
    BY_CITY = {
        paris       = { "item.mona_lisa", "item.eiffel_torch" },
        london      = { "item.crown_jewels", "item.magna_carta", "item.big_ben_bell" },
        mexico_city = { "item.aztec_calendar" },
        athens      = { "item.parthenon_frieze" },
        rome        = { "item.colosseum_stone" },
    },
    GENERIC = {
        "item.generic_painting", "item.generic_gem", "item.generic_relic",
        "item.generic_document", "item.generic_statue",
    },
}
