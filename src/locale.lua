local M = {}

local current_lang = "en"
local strings = {}

local function load_lang(lang)
    local ok, data = pcall(require, "locales." .. lang)
    if not ok then
        error("locale: cannot load '" .. lang .. "': " .. tostring(data))
    end
    return data
end

function M.set(lang)
    strings = load_lang(lang)
    current_lang = lang
end

function M.get_lang()
    return current_lang
end

local function interpolate(str, vars)
    if not vars then return str end
    return (str:gsub("{(%w+)}", function(k)
        return tostring(vars[k] or "{" .. k .. "}")
    end))
end

-- Returns the localized string for key, with optional {var} interpolation.
-- Returns key verbatim if not found — UI never crashes on missing keys.
function M.t(key, vars)
    local str = strings[key]
    if str == nil then
        return interpolate(key, vars)
    end
    return interpolate(str, vars)
end

return M
