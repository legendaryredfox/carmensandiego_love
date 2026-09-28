local json = require("lib.json")

local M = {}

local _fs   = nil
local PATH  = "settings.json"

local DEFAULTS = {
    lang             = "en",
    music_volume     = 0.6,
    sfx_volume       = 0.8,
    typewriter_speed = 40,
}

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
    }
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

return M
