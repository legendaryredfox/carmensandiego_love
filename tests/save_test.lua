local save    = require("src.save")
local ranking = require("src.ranking")
local detective = require("src.detective")

-- In-memory filesystem mock for testing without love.filesystem
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
    save.set_filesystem(fs)
    return fs
end

describe("save.write / save.read", function()
    it("round-trips detective and ranking", function()
        setup()
        local d = detective.new("Tester")
        d.rank = "sleuth"
        d.cases_solved = 3

        local r = ranking.new()
        ranking.add(r, { name="Tester", rank="sleuth", cases_solved=3, score=999, date="2025-01-01" })

        save.write(1, detective.serialize(d), ranking.to_table(r))
        local loaded = save.read(1)

        assert_not_nil(loaded)
        assert_eq(loaded.detective.name, "Tester")
        assert_eq(loaded.detective.rank, "sleuth")
        assert_eq(loaded.detective.cases_solved, 3)
        assert_eq(#loaded.ranking.entries, 1)
        assert_eq(loaded.ranking.entries[1].score, 999)
    end)

    it("round-trips an in-progress mission alongside the detective", function()
        -- Regression: Continue used to restore only detective + ranking,
        -- leaving game.mission nil and crashing the next screen that read it.
        setup()
        local d = detective.new("Tester")
        local mission = {
            thief             = { id = "scarlet_vega", name = "Scarlet Vega", sex = "female" },
            is_final          = false,
            stolen_item       = "item.generic_gem",
            graph_index       = 2,
            route             = { "paris", "london", "rome" },
            time_limit_hours  = 120,
            clues             = {
                paris = {
                    { type = "destination", next_city_id = "london",
                      category = "landmark", text = { en = "hi", pt = "oi" } },
                },
            },
        }

        save.write(1, detective.serialize(d), ranking.to_table(ranking.new()), mission)
        local loaded = save.read(1)

        assert_not_nil(loaded.mission)
        assert_eq(loaded.mission.thief.id, "scarlet_vega")
        assert_eq(loaded.mission.route[2], "london")
        assert_eq(loaded.mission.clues.paris[1].text.en, "hi")
        assert_false(loaded.mission.is_final)
    end)

    it("read returns nil for missing slot", function()
        setup()
        local result = save.read(2)
        assert_nil(result)
    end)

    it("slot isolation — slot 1 does not affect slot 2", function()
        setup()
        local d1 = detective.new("Alice")
        local d2 = detective.new("Bob")
        save.write(1, detective.serialize(d1), {})
        save.write(2, detective.serialize(d2), {})

        local s1 = save.read(1)
        local s2 = save.read(2)
        assert_eq(s1.detective.name, "Alice")
        assert_eq(s2.detective.name, "Bob")
    end)
end)

describe("save.exists", function()
    it("returns false before writing", function()
        setup()
        assert_false(save.exists(3))
    end)

    it("returns true after writing", function()
        setup()
        save.write(3, detective.serialize(detective.new("X")), {})
        assert_true(save.exists(3))
    end)
end)

describe("save.delete", function()
    it("deletes existing slot", function()
        setup()
        save.write(1, detective.serialize(detective.new("Del")), {})
        assert_true(save.exists(1))
        save.delete(1)
        assert_false(save.exists(1))
        assert_nil(save.read(1))
    end)

    it("delete on nonexistent slot does not crash", function()
        setup()
        save.delete(9)  -- should not error
        assert_true(true)
    end)
end)

describe("save.read corrupt data", function()
    it("returns nil on corrupt JSON", function()
        local fs = make_mock_fs()
        save.set_filesystem(fs)
        fs.write("save_1.json", "not valid json {{{{")
        local result = save.read(1)
        assert_nil(result)
    end)
end)
