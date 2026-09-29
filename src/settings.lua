local json = require("lib.json")

local M = {}

local _fs   = nil
local PATH  = "settings.json"

local DEFAULTS = {
    lang             = "en",
    music_volume     = 0.6,
    sfx_volume       = 0.8,
    typewriter_speed = 40,
    window_scale     = 2,
    fullscreen       = false,
}

M.MIN_WINDOW_SCALE = 1
M.MAX_WINDOW_SCALE = 3

local current = nil

function M.set_filesystem(fs)
    _fs = fs
end

local function get_fs()
    if _fs then return _fs end
    if love and love.filesystem then return love.filesystem end
    error("settings: no filesystem available — call settings.set_filesystem() first")
end

local function clamp01(v)
    return math.max(0, math.min(1, v))
end

-- Loads settings from disk, falling back to defaults for missing/corrupt data.
function M.load()
    local fs = get_fs()
    local data = nil
    if fs.getInfo(PATH) then
        local ok, contents = pcall(fs.read, PATH)
        if ok and contents then
            local ok2, decoded = pcall(json.decode, contents)
            if ok2 and type(decoded) == "table" then data = decoded end
        end
    end
    data = data or {}
    current = {
        lang             = data.lang             or DEFAULTS.lang,
        music_volume     = data.music_volume      or DEFAULTS.music_volume,
        sfx_volume       = data.sfx_volume        or DEFAULTS.sfx_volume,
        typewriter_speed = data.typewriter_speed  or DEFAULTS.typewriter_speed,
        window_scale     = data.window_scale     or DEFAULTS.window_scale,
        -- "or" would treat a saved `false` as missing and reset it to the
        -- default on every load — booleans need an explicit nil check.
        fullscreen       = data.fullscreen,
    }
    if current.fullscreen == nil then current.fullscreen = DEFAULTS.fullscreen end
    return current
end

function M.get()
    if not current then M.load() end
    return current
end

function M.save()
    local fs = get_fs()
    fs.write(PATH, json.encode(M.get()))
end

function M.set_lang(lang)
    M.get().lang = lang
    M.save()
end

function M.set_music_volume(v)
    M.get().music_volume = clamp01(v)
    M.save()
end

function M.set_sfx_volume(v)
    M.get().sfx_volume = clamp01(v)
    M.save()
end

function M.set_typewriter_speed(chars_per_sec)
    M.get().typewriter_speed = chars_per_sec
    M.save()
end

function M.set_window_scale(scale)
    M.get().window_scale =
        math.max(M.MIN_WINDOW_SCALE, math.min(M.MAX_WINDOW_SCALE, scale))
    M.save()
end

function M.set_fullscreen(enabled)
    M.get().fullscreen = enabled and true or false
    M.save()
end

return M
