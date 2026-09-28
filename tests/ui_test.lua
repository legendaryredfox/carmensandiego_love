local ui = require("src.ui")

describe("ui.new_smooth / ui.update_smooth", function()
    it("starts at rest with value equal to target", function()
        local s = ui.new_smooth(10)
        assert_eq(s.value, 10)
        assert_eq(s.target, 10)
    end)

    it("moves value toward a new target over time", function()
        local s = ui.new_smooth(0)
        s.target = 100
        for _ = 1, 5 do ui.update_smooth(s, 1 / 60) end
        assert_true(s.value > 0, "value should have moved away from 0")
        assert_true(s.value < 100, "default damping should not overshoot")
    end)

    it("settles exactly on target and zeroes velocity", function()
        local s = ui.new_smooth(0)
        s.target = 50
        for _ = 1, 300 do ui.update_smooth(s, 1 / 60) end
        assert_eq(s.value, 50)
        assert_eq(s.vel, 0)
    end)

    it("does nothing once settled", function()
        local s = ui.new_smooth(20)
        ui.update_smooth(s, 1 / 60)
        assert_eq(s.value, 20)
        assert_eq(s.vel, 0)
    end)

    it("re-targets smoothly if target changes mid-flight", function()
        local s = ui.new_smooth(0)
        s.target = 100
        for _ = 1, 10 do ui.update_smooth(s, 1 / 60) end
        local mid_value = s.value
        s.target = 0
        for _ = 1, 300 do ui.update_smooth(s, 1 / 60) end
        assert_eq(s.value, 0)
        assert_true(mid_value > 0, "should have moved before re-targeting")
    end)
end)

describe("ui.utf8_len / ui.utf8_sub", function()
    it("counts multi-byte characters as one, unlike #str", function()
        local s = "café — ação"
        assert_true(ui.utf8_len(s) < #s, "expected fewer chars than bytes")
    end)

    it("returns the whole string when n exceeds its length", function()
        local s = "café"
        assert_eq(ui.utf8_sub(s, 100), s)
    end)

    it("returns empty string when n <= 0", function()
        assert_eq(ui.utf8_sub("café", 0), "")
    end)

    it("never splits a multi-byte character (valid UTF-8 at every cut)", function()
        local utf8 = require("utf8")
        local s    = "café — ação"
        for n = 0, ui.utf8_len(s) do
            local valid = utf8.len(ui.utf8_sub(s, n)) ~= nil
            assert_true(valid, "utf8_sub produced invalid UTF-8 for n=" .. n)
        end
    end)

    it("prefix of n chars matches the first n characters exactly", function()
        local s = "ação"
        assert_eq(ui.utf8_sub(s, 1), "a")
        assert_eq(ui.utf8_sub(s, 2), "aç")
        assert_eq(ui.utf8_sub(s, 3), "açã")
        assert_eq(ui.utf8_sub(s, 4), "ação")
    end)
end)
