local detective  = require("src.detective")
local mission    = require("src.mission")
local suspect_mod = require("src.suspect")
local city_mod   = require("src.city")
local routes     = require("data.routes")

local suspects     = suspect_mod.load()
local cities_by_id = city_mod.load("data/cities.csv")

local function make_seed_rng(seed)
    local s = seed
    return function(n)
        s = (s * 1103515245 + 12345) % (2^31)
        return (s % n) + 1
    end
end

local function fresh_det()
    return detective.new("Agent Zero")
end

local function fresh_mission(seed)
    return mission.new(suspects, cities_by_id, routes, "rookie", make_seed_rng(seed or 42))
end

describe("detective.new", function()
    it("creates detective with correct defaults", function()
        local d = fresh_det()
        assert_eq(d.name, "Agent Zero")
        assert_eq(d.rank, "rookie")
        assert_eq(d.cases_solved, 0)
        assert_eq(d.hours_elapsed, 0)
        assert_nil(d.warrant_id)
        assert_nil(d.current_city_id)
    end)
end)

describe("detective.travel", function()
    it("updates city and hours on normal travel", function()
        local d = fresh_det()
        d.time_limit_hours = 168
        local result = detective.travel(d, "london", 10)
        assert_eq(result, "ok")
        assert_eq(d.current_city_id, "london")
        assert_eq(d.hours_elapsed, 10)
    end)

    it("returns time_expired when hours exceed limit", function()
        local d = fresh_det()
        d.time_limit_hours = 5
        d.hours_elapsed    = 3
        local result = detective.travel(d, "paris", 5)
        assert_eq(result, "time_expired")
        assert_eq(d.hours_elapsed, 5)
    end)

    it("returns time_expired exactly at the boundary", function()
        local d = fresh_det()
        d.time_limit_hours = 10
        d.hours_elapsed    = 0
        local result = detective.travel(d, "rome", 10)
        assert_eq(result, "time_expired")
    end)
end)

describe("detective.add_trait / issue_warrant", function()
    it("warrant issued when exactly one suspect matches", function()
        local d = fresh_det()
        -- scarlet_vega: female, brown, tennis, convertible, jewelry, mexican
        detective.add_trait(d, "sex",     "female")
        detective.add_trait(d, "hair",    "brown")
        detective.add_trait(d, "hobby",   "tennis")
        detective.add_trait(d, "vehicle", "convertible")
        detective.add_trait(d, "feature", "jewelry")
        local result, match = detective.issue_warrant(d, suspects)
        assert_eq(result, "issued")
        assert_not_nil(match)
        assert_eq(match.id, "scarlet_vega")
        assert_eq(d.warrant_id, "scarlet_vega")
    end)

    it("returns multiple when traits match more than one suspect", function()
        local d = fresh_det()
        detective.add_trait(d, "sex", "female")  -- 5 female suspects
        local result, matches = detective.issue_warrant(d, suspects)
        assert_eq(result, "multiple")
        assert_true(#matches > 1)
        assert_nil(d.warrant_id)
    end)

    it("returns none when no suspects match", function()
        local d = fresh_det()
        -- impossible combo: male + tennis + brown (no such suspect)
        detective.add_trait(d, "sex",  "male")
        detective.add_trait(d, "hair", "brown")
        detective.add_trait(d, "hobby","tennis")
        local result = detective.issue_warrant(d, suspects)
        assert_eq(result, "none")
        assert_nil(d.warrant_id)
    end)
end)

describe("detective.attempt_arrest", function()
    local m = fresh_mission(42)

    it("returns wrong_city when not at thief city", function()
        local d = fresh_det()
        d.current_city_id = m.route[1]  -- start, not terminal
        local result = detective.attempt_arrest(d, m)
        assert_eq(result, "wrong_city")
    end)

    it("returns no_warrant when at thief city without warrant", function()
        local d = fresh_det()
        d.current_city_id = mission.thief_city(m)
        local result = detective.attempt_arrest(d, m)
        assert_eq(result, "no_warrant")
    end)

    it("returns success with correct warrant at thief city", function()
        local d = fresh_det()
        d.current_city_id = mission.thief_city(m)
        d.warrant_id      = m.thief.id
        local result = detective.attempt_arrest(d, m)
        assert_eq(result, "success")
    end)

    it("returns wrong_warrant with wrong suspect warrant at thief city", function()
        local d = fresh_det()
        d.current_city_id = mission.thief_city(m)
        -- pick a different suspect id
        local wrong_id = (m.thief.id == suspects[1].id) and suspects[2].id or suspects[1].id
        d.warrant_id = wrong_id
        local result = detective.attempt_arrest(d, m)
        assert_eq(result, "wrong_warrant")
    end)
end)

describe("detective.on_success / rank progression", function()
    it("cases_solved increments on success", function()
        local d = fresh_det()
        detective.on_success(d)
        assert_eq(d.cases_solved, 1)
    end)

    it("rank advances at correct thresholds", function()
        local thresholds = {
            {0,  "rookie"},
            {1,  "junior_detective"},
            {3,  "sleuth"},
            {6,  "private_eye"},
            {10, "investigator"},
            {15, "ace_detective"},
        }
        for _, pair in ipairs(thresholds) do
            assert_eq(detective._rank_for_cases(pair[1]), pair[2],
                "cases=" .. pair[1] .. " expected " .. pair[2])
        end
    end)

    it("rank stays ace_detective beyond 15 cases", function()
        local d = fresh_det()
        for _ = 1, 20 do detective.on_success(d) end
        assert_eq(d.rank, "ace_detective")
    end)
end)

describe("detective time helpers", function()
    it("hours_remaining returns correct value", function()
        local d = fresh_det()
        d.time_limit_hours = 168
        d.hours_elapsed    = 48
        assert_eq(detective.hours_remaining(d), 120)
    end)

    it("hours_remaining never goes below 0", function()
        local d = fresh_det()
        d.time_limit_hours = 10
        d.hours_elapsed    = 20
        assert_eq(detective.hours_remaining(d), 0)
    end)

    it("days_remaining rounds to 0.5 day increments", function()
        local d = fresh_det()
        d.time_limit_hours = 168
        d.hours_elapsed    = 156  -- 12h remaining = 0.5 days
        assert_eq(detective.days_remaining(d), 0.5)
    end)
end)

describe("detective serialize/deserialize", function()
    it("round-trips all fields", function()
        local d = fresh_det()
        d.rank             = "sleuth"
        d.cases_solved     = 5
        d.current_city_id  = "tokyo"
        d.hours_elapsed    = 36
        d.time_limit_hours = 144
        d.gathered_traits  = { sex = "female", hair = "red" }
        d.warrant_id       = "some_suspect"

        local t  = detective.serialize(d)
        local d2 = detective.deserialize(t)

        assert_eq(d2.name,             d.name)
        assert_eq(d2.rank,             d.rank)
        assert_eq(d2.cases_solved,     d.cases_solved)
        assert_eq(d2.current_city_id,  d.current_city_id)
        assert_eq(d2.hours_elapsed,    d.hours_elapsed)
        assert_eq(d2.time_limit_hours, d.time_limit_hours)
        assert_eq(d2.warrant_id,       d.warrant_id)
        assert_eq(d2.gathered_traits.sex,  "female")
        assert_eq(d2.gathered_traits.hair, "red")
    end)

    it("deserialize handles nil optional fields gracefully", function()
        local d2 = detective.deserialize({ name = "X" })
        assert_eq(d2.rank, "rookie")
        assert_eq(d2.cases_solved, 0)
        assert_eq(d2.hours_elapsed, 0)
    end)
end)
