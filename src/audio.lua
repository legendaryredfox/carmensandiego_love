local M = {}

-- All sources loaded lazily on first play. Missing files are silently skipped
-- so the game runs fully without any audio assets present.
local music_sources = {}
local sfx_sources   = {}
local current_music = nil

local MUSIC_VOL = 0.6
local SFX_VOL   = 0.8
local FADE_STEP = 0.02  -- volume change per update tick during crossfade

local fade_out_src  = nil
local fade_in_key   = nil

-- Track definitions: key → file path relative to game root.
local MUSIC_TRACKS = {
    title       = "assets/sounds/music/title.ogg",
    city        = "assets/sounds/music/city.ogg",
    briefing    = "assets/sounds/music/briefing.ogg",
    computer    = "assets/sounds/music/computer.ogg",
    travel      = "assets/sounds/music/travel.ogg",
    success     = "assets/sounds/music/success.ogg",
    failure     = "assets/sounds/music/failure.ogg",
}

local SFX_FILES = {
    click       = "assets/sounds/sfx/click.wav",
    clue        = "assets/sounds/sfx/clue.wav",
    warrant     = "assets/sounds/sfx/warrant.wav",
    arrest_ok   = "assets/sounds/sfx/arrest_ok.wav",
    arrest_fail = "assets/sounds/sfx/arrest_fail.wav",
    type        = "assets/sounds/sfx/type.wav",
}

local function try_load_music(path)
    if not love.filesystem.getInfo(path) then return nil end
    local ok, src = pcall(love.audio.newSource, path, "stream")
    if not ok then return nil end
    src:setLooping(true)
    src:setVolume(MUSIC_VOL)
    return src
end

local function try_load_sfx(path)
    if not love.filesystem.getInfo(path) then return nil end
    local ok, src = pcall(love.audio.newSource, path, "static")
    if not ok then return nil end
    src:setVolume(SFX_VOL)
    return src
end

local function get_music(key)
    if music_sources[key] == nil then
        local path = MUSIC_TRACKS[key]
        music_sources[key] = path and try_load_music(path) or false
    end
    return music_sources[key] or nil
end

local function get_sfx(key)
    if sfx_sources[key] == nil then
        local path = SFX_FILES[key]
        sfx_sources[key] = path and try_load_sfx(path) or false
    end
    return sfx_sources[key] or nil
end

-- Immediately switch to a music track (no crossfade).
function M.play_music(key)
    if current_music == key then return end
    local old = current_music and get_music(current_music)
    if old then old:stop() end
    current_music = key
    local src = get_music(key)
    if src then src:play() end
end

-- Start a crossfade to a new track.
function M.crossfade(key)
    if current_music == key then return end
    fade_out_src = current_music and get_music(current_music) or nil
    fade_in_key  = key
    current_music = key
    local new_src = get_music(key)
    if new_src then
        new_src:setVolume(0)
        new_src:play()
    end
end

-- Call once per frame to process crossfade.
function M.update()
    if fade_out_src then
        local v = fade_out_src:getVolume() - FADE_STEP
        if v <= 0 then
            fade_out_src:stop()
            fade_out_src = nil
        else
            fade_out_src:setVolume(v)
        end
    end
    if fade_in_key then
        local src = get_music(fade_in_key)
        if src then
            local v = src:getVolume() + FADE_STEP
            if v >= MUSIC_VOL then
                src:setVolume(MUSIC_VOL)
                fade_in_key = nil
            else
                src:setVolume(v)
            end
        else
            fade_in_key = nil
        end
    end
end

function M.stop_music()
    local src = current_music and get_music(current_music)
    if src then src:stop() end
    current_music = nil
    fade_out_src  = nil
    fade_in_key   = nil
end

function M.play_sfx(key)
    local src = get_sfx(key)
    if not src then return end
    -- Clone so overlapping SFX work.
    local clone = src:clone()
    clone:setVolume(SFX_VOL)
    clone:play()
end

function M.set_music_volume(v)
    MUSIC_VOL = math.max(0, math.min(1, v))
    local src  = current_music and get_music(current_music)
    if src then src:setVolume(MUSIC_VOL) end
end

function M.set_sfx_volume(v)
    SFX_VOL = math.max(0, math.min(1, v))
end

function M.get_music_volume() return MUSIC_VOL end
function M.get_sfx_volume()   return SFX_VOL end

return M
