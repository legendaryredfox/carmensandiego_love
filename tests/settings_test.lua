local settings = require("src.settings")

local function make_mock_fs()
    local store = {}
    return {
        write   = function(path, data) store[path] = data end,
        read    = function(path) return store[path] end,
        getInfo = function(path) return store[path] and {} or nil end,
        remove  = function(path) store[path] = nil end,
        _store  = store,
    }
end

local function setup()
    local fs = make_mock_fs()
    settings.set_filesystem(fs)
    settings.load()
    return fs
end

describe("settings.load", function()
    it("returns defaults when no file exists", function()
        setup()
        local s = settings.get()
        assert_eq(s.lang, "en")
        assert_eq(s.music_volume, 0.6)
        assert_eq(s.sfx_volume, 0.8)
        assert_eq(s.typewriter_speed, 40)
        assert_eq(s.window_scale, 2)
        assert_eq(s.fullscreen, false)
    end)

    it("falls back to defaults on corrupt JSON", function()
        local fs = make_mock_fs()
        fs.write("settings.json", "not valid json {{{{")
        settings.set_filesystem(fs)
        local s = settings.load()
        assert_eq(s.lang, "en")
    end)
end)

describe("settings.set_lang / set_music_volume / set_sfx_volume", function()
    it("persists lang across a reload", function()
        setup()
        settings.set_lang("pt")
        local s = settings.load()
        assert_eq(s.lang, "pt")
    end)

    it("clamps music volume to [0, 1]", function()
        setup()
        settings.set_music_volume(1.5)
        assert_eq(settings.get().music_volume, 1)
        settings.set_music_volume(-0.5)
        assert_eq(settings.get().music_volume, 0)
    end)

    it("clamps sfx volume to [0, 1]", function()
        setup()
        settings.set_sfx_volume(2)
        assert_eq(settings.get().sfx_volume, 1)
    end)
end)

describe("settings.set_typewriter_speed", function()
    it("persists the new speed across a reload", function()
        setup()
        settings.set_typewriter_speed(80)
        local s = settings.load()
        assert_eq(s.typewriter_speed, 80)
    end)
end)

describe("settings.set_window_scale / set_fullscreen", function()
    it("clamps window scale to [MIN_WINDOW_SCALE, MAX_WINDOW_SCALE]", function()
        setup()
        settings.set_window_scale(99)
        assert_eq(settings.get().window_scale, settings.MAX_WINDOW_SCALE)
        settings.set_window_scale(-5)
        assert_eq(settings.get().window_scale, settings.MIN_WINDOW_SCALE)
    end)

    it("persists window scale across a reload", function()
        setup()
        settings.set_window_scale(3)
        local s = settings.load()
        assert_eq(s.window_scale, 3)
    end)

    it("persists fullscreen=true across a reload", function()
        setup()
        settings.set_fullscreen(true)
        local s = settings.load()
        assert_eq(s.fullscreen, true)
    end)

    it("persists fullscreen=false across a reload, not just the default", function()
        -- Regression: `data.fullscreen or DEFAULTS.fullscreen` would treat a
        -- saved `false` as absent and silently reset it, since false is
        -- falsy in Lua — this only surfaces once the default isn't false.
        setup()
        settings.set_fullscreen(true)
        settings.set_fullscreen(false)
        local s = settings.load()
        assert_eq(s.fullscreen, false)
    end)
end)
