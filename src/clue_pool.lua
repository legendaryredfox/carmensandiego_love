local locale = require("src.locale")

local M = {}

local _cache = {}

-- Loads clue pool for a city. Returns array or empty table if file missing.
function M.load(city_id)
    if _cache[city_id] ~= nil then return _cache[city_id] end
    local ok, data = pcall(require, "data.clues." .. city_id)
    _cache[city_id] = ok and data or {}
    return _cache[city_id]
end

-- Picks a random clue from the pool. Returns nil if pool is empty.
-- rng: function(n) → integer in [1,n]; if nil uses first entry.
function M.pick(pool, rng)
    if not pool or #pool == 0 then return nil end
    local idx = rng and rng(#pool) or 1
    return pool[idx]
end

-- Returns display text for a clue in the current language.
function M.clue_text(clue)
    if not clue then return "" end
    -- Inline multilingual text (preferred for real clues)
    if clue.text then
        return clue.text[locale.get_lang()] or clue.text.en or ""
    end
    -- Legacy locale key (fallback for placeholders)
    if clue.text_key then
        return locale.t(clue.text_key)
    end
    return ""
end

-- Clears cache (for testing or language switch).
function M.clear_cache()
    _cache = {}
end

return M
