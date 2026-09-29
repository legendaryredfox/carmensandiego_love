local venue_name = require("src.venue_name")
local locale     = require("src.locale")

locale.set("en")

describe("venue_name.category_for", function()
    it("returns generic when the city has no clues", function()
        local mission = { clues = {} }
        assert_eq(venue_name.category_for(mission, "atlantis", 1), "generic")
    end)

    it("returns terminal for terminal-type clues", function()
        local mission = { clues = { paris = {
            { type = "terminal" }, { type = "terminal" }, { type = "terminal" },
        } } }
        assert_eq(venue_name.category_for(mission, "paris", 1), "terminal")
    end)

    it("returns the clue's own category for destination clues", function()
        local mission = { clues = { paris = {
            { type = "destination", category = "landmark" },
        } } }
        assert_eq(venue_name.category_for(mission, "paris", 1), "landmark")
    end)

    it("falls back to generic when category is missing", function()
        local mission = { clues = { paris = {
            { type = "destination" },
        } } }
        assert_eq(venue_name.category_for(mission, "paris", 1), "generic")
    end)
end)

describe("venue_name.variant_for", function()
    it("gives each of the 3 off-route venues a distinct variant number", function()
        -- Regression: city.lua's venue-card icon is keyed off this variant
        -- for the "generic" category (see get_venue_icon's icon_path) — if
        -- two venues resolved the same variant, they'd render the same
        -- icon even though M.name_for already tells them apart by text.
        for i = 1, 30 do
            local city_id  = "offroute" .. i
            local no_clues = { clues = {} }
            local a = venue_name.variant_for(no_clues, city_id, 1)
            local b = venue_name.variant_for(no_clues, city_id, 2)
            local c = venue_name.variant_for(no_clues, city_id, 3)
            assert_true(a ~= b and b ~= c and a ~= c,
                "duplicate generic variant for " .. city_id)
        end
    end)

    it("is deterministic for the same city and venue", function()
        local mission = { clues = {} }
        local a = venue_name.variant_for(mission, "atlantis", 1)
        local b = venue_name.variant_for(mission, "atlantis", 1)
        assert_eq(a, b)
    end)
end)

describe("venue_name.name_for", function()
    local mission = { clues = { paris = {
        { type = "destination", category = "landmark" },
        { type = "destination", category = "currency" },
        { type = "trait" },
    } } }

    it("returns a non-empty localized name", function()
        local name = venue_name.name_for(mission, "paris", 1)
        assert_true(#name > 0)
    end)

    it("is deterministic for the same city and venue", function()
        local a = venue_name.name_for(mission, "paris", 1)
        local b = venue_name.name_for(mission, "paris", 1)
        assert_eq(a, b)
    end)

    it("resolves through locale rather than leaking the raw key", function()
        local name = venue_name.name_for(mission, "paris", 1)
        assert_true(name:sub(1, 11) ~= "venue_name.",
            "expected localized string, got raw key: " .. name)
    end)

    it("names venues 1 and 2 differently when categories differ", function()
        local a = venue_name.name_for(mission, "paris", 1)
        local b = venue_name.name_for(mission, "paris", 2)
        assert_true(a ~= b, "landmark and currency venues got the same name")
    end)

    it("avoids duplicate names across all 3 venues of an off-route city", function()
        -- An off-route city has no clues at all (see clue_at), so every
        -- venue falls back to "generic" — with only 1 variant available,
        -- all 3 venue cards used to render the identical name/icon.
        for i = 1, 30 do
            local city_id     = "offroute" .. i
            local no_clues    = { clues = {} }
            local a = venue_name.name_for(no_clues, city_id, 1)
            local b = venue_name.name_for(no_clues, city_id, 2)
            local c = venue_name.name_for(no_clues, city_id, 3)
            assert_true(a ~= b and b ~= c and a ~= c,
                "duplicate generic venue name for " .. city_id)
        end
    end)

    it("avoids duplicate names when two venues share a category", function()
        -- Same category on both venues used to be able to hash to the same
        -- variant (e.g. two "landmark" venues both drawing "MONUMENT PLAZA").
        for i = 1, 30 do
            local city_id   = "testcity" .. i
            local same_cat  = { clues = { [city_id] = {
                { type = "destination", category = "landmark" },
                { type = "destination", category = "landmark" },
                { type = "trait" },
            } } }
            local a = venue_name.name_for(same_cat, city_id, 1)
            local b = venue_name.name_for(same_cat, city_id, 2)
            assert_true(a ~= b, "duplicate venue name for " .. city_id)
        end
    end)
end)
