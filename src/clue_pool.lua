local locale = require("src.locale")

local M = {}

local _cache = {}

-- Loads clue pool for a city. Returns array or empty table if the file is
-- genuinely missing. A file that exists but fails to load (syntax error,
-- runtime error) is NOT treated the same way — that's a real content bug
-- and gets re-raised instead of silently caching an empty pool, which
-- would otherwise mask it as "no leads for this city" forever.
function M.load(city_id)
    if _cache[city_id] ~= nil then return _cache[city_id] end
    local mod_name  = "data.clues." .. city_id
    local ok, data  = pcall(require, mod_name)
    if ok then
        _cache[city_id] = data
        return data
    end
    if not tostring(data):find("module '" .. mod_name .. "' not found", 1, true) then
        error("clue_pool: " .. mod_name .. " exists but failed to load: " ..
            tostring(data), 0)
    end
    _cache[city_id] = {}
    return {}
end

-- Picks a random clue from the pool. Returns nil if pool is empty.
-- rng: function(n) → integer in [1,n]; if nil uses first entry.
function M.pick(pool, rng)
    if not pool or #pool == 0 then return nil end
    local idx = rng and rng(#pool) or 1
    return pool[idx]
end

-- Picks up to `count` distinct clues (never the same entry twice, unlike
-- calling M.pick repeatedly). Falls back to repeats only once the pool
-- itself is smaller than `count`. Returns an array shorter than `count`
-- only when the pool is empty.
function M.pick_many(pool, count, rng)
    if not pool or #pool == 0 then return {} end
    local available = {}
    for i = 1, #pool do available[i] = i end
    local result = {}
    for _ = 1, count do
        if #available == 0 then
            table.insert(result, M.pick(pool, rng))
        else
            local pick_at = rng and rng(#available) or 1
            table.insert(result, pool[available[pick_at]])
            table.remove(available, pick_at)
        end
    end
    return result
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
