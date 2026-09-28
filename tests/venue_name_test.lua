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
end)
