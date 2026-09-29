local ranking = require("src.ranking")

local function entry(name, score, cases_solved)
    return { name = name, rank = "rookie", cases_solved = cases_solved,
             score = score, date = "2025-01-01" }
end

describe("ranking.new", function()
    it("starts with an empty entry list", function()
        local r = ranking.new()
        assert_eq(#r.entries, 0)
    end)
end)

describe("ranking.add", function()
    it("sorts entries descending by score", function()
        local r = ranking.new()
        ranking.add(r, entry("Low", 10, 1))
        ranking.add(r, entry("High", 30, 1))
        ranking.add(r, entry("Mid", 20, 1))
        assert_eq(r.entries[1].name, "High")
        assert_eq(r.entries[2].name, "Mid")
        assert_eq(r.entries[3].name, "Low")
    end)

    it("breaks score ties by cases_solved descending", function()
        local r = ranking.new()
        ranking.add(r, entry("FewerCases", 50, 2))
        ranking.add(r, entry("MoreCases", 50, 5))
        assert_eq(r.entries[1].name, "MoreCases")
        assert_eq(r.entries[2].name, "FewerCases")
    end)

    it("caps the list at 10 entries", function()
        local r = ranking.new()
        for i = 1, 12 do
            ranking.add(r, entry("Player" .. i, i, 1))
        end
        assert_eq(#r.entries, 10)
    end)

    it("drops the lowest score once past the cap", function()
        local r = ranking.new()
        for i = 1, 10 do
            ranking.add(r, entry("Player" .. i, i, 1))
        end
        -- Lowest so far is score 1 ("Player1") — a new higher entry should
        -- bump it out instead of the cap just truncating the newest add.
        ranking.add(r, entry("Newcomer", 5, 1))
        local names = {}
        for _, e in ipairs(r.entries) do names[e.name] = true end
        assert_true(names["Newcomer"])
        assert_true(names["Player1"] == nil)
    end)
end)

describe("ranking.from_table / ranking.to_table", function()
    it("round-trips a plain entry array", function()
        local t = { entry("A", 100, 1), entry("B", 50, 1) }
        local r = ranking.from_table(t)
        assert_eq(#r.entries, 2)
        assert_eq(r.entries[1].name, "A")
        assert_eq(ranking.to_table(r), r.entries)
    end)

    it("defaults to an empty list when given nil", function()
        local r = ranking.from_table(nil)
        assert_eq(#ranking.to_table(r), 0)
    end)
end)
