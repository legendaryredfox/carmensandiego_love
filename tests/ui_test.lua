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
