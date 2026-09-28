local clue_pool = require("src.clue_pool")

local function make_seed_rng(seed)
    local s = seed
    return function(n)
        s = (s * 1103515245 + 12345) % (2 ^ 31)
        return (s % n) + 1
    end
end

describe("clue_pool.pick_many", function()
    it("returns an empty table for a nil or empty pool", function()
        assert_eq(#clue_pool.pick_many(nil, 2, make_seed_rng(1)), 0)
        assert_eq(#clue_pool.pick_many({}, 2, make_seed_rng(1)), 0)
    end)

    it("never returns the same entry twice when the pool is large enough", function()
        local pool = { { id = "a" }, { id = "b" }, { id = "c" }, { id = "d" } }
        for seed = 1, 20 do
            local picks = clue_pool.pick_many(pool, 2, make_seed_rng(seed))
            assert_eq(#picks, 2)
            assert_true(picks[1].id ~= picks[2].id,
                "duplicate pick for seed " .. seed)
        end
    end)

    it("falls back to repeats once the pool is smaller than count", function()
        local pool  = { { id = "only" } }
        local picks = clue_pool.pick_many(pool, 2, make_seed_rng(5))
        assert_eq(#picks, 2)
        assert_eq(picks[1].id, "only")
        assert_eq(picks[2].id, "only")
    end)

    it("is deterministic given the same rng sequence", function()
        local pool = { { id = "a" }, { id = "b" }, { id = "c" } }
        local p1   = clue_pool.pick_many(pool, 2, make_seed_rng(42))
        local p2   = clue_pool.pick_many(pool, 2, make_seed_rng(42))
        assert_eq(p1[1].id, p2[1].id)
        assert_eq(p1[2].id, p2[2].id)
    end)

    it("with no rng, picks entries in order without repeating", function()
        local pool  = { { id = "a" }, { id = "b" } }
        local picks = clue_pool.pick_many(pool, 2, nil)
        assert_eq(picks[1].id, "a")
        assert_eq(picks[2].id, "b")
    end)
end)
