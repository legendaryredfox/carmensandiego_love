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
