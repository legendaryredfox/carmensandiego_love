local suspect = require("src.suspect")

local suspects = suspect.load()

describe("suspect.load", function()
    it("loads exactly 10 suspects", function()
        assert_eq(#suspects, 10)
    end)

    it("each suspect has all required fields", function()
        local required = {"id","name","sex","hair","hobby","vehicle","feature","food"}
        for _, s in ipairs(suspects) do
            for _, field in ipairs(required) do
                assert_not_nil(s[field], s.id .. " missing field: " .. field)
            end
        end
    end)

    it("sex values are only male or female", function()
        for _, s in ipairs(suspects) do
            assert_true(s.sex == "male" or s.sex == "female",
                s.id .. " invalid sex: " .. tostring(s.sex))
        end
    end)

    it("has 5 male and 5 female suspects", function()
        local male, female = 0, 0
        for _, s in ipairs(suspects) do
            if s.sex == "male" then male = male + 1
            else female = female + 1 end
        end
        assert_eq(male, 5)
        assert_eq(female, 5)
    end)

    it("all ids are unique", function()
        local seen = {}
        for _, s in ipairs(suspects) do
            assert_nil(seen[s.id], "duplicate id: " .. s.id)
            seen[s.id] = true
        end
    end)

    it("full trait combinations are unique (deduction is possible)", function()
        local seen = {}
        for _, s in ipairs(suspects) do
            local key = table.concat({s.sex,s.hair,s.hobby,s.vehicle,s.feature}, "|")
            assert_nil(seen[key], "duplicate trait combo for " .. s.id .. " and " .. (seen[key] or "?"))
            seen[key] = s.id
        end
    end)
end)

describe("suspect.filter", function()
    it("empty filter returns all suspects", function()
        local result = suspect.filter(suspects, {})
        assert_eq(#result, 10)
    end)

    it("nil filter returns all suspects", function()
        local result = suspect.filter(suspects, nil)
        assert_eq(#result, 10)
    end)

    it("filter by sex=female returns 5", function()
        local result = suspect.filter(suspects, {sex="female"})
        assert_eq(#result, 5)
    end)

    it("filter by sex=male returns 5", function()
        local result = suspect.filter(suspects, {sex="male"})
        assert_eq(#result, 5)
    end)

    it("treats an empty-string trait value as unset, not a real filter", function()
        -- Regression: the crime computer stores "" for a dropdown left on
        -- "----" (see cycle() in src/screens/crime_computer.lua). Before
        -- the fix, that made filter() require the trait literally equal
        -- "" — which no suspect has — silently rejecting an otherwise
        -- correct, uniquely-identified warrant.
        local result = suspect.filter(suspects, {
            sex = "female", hair = "brown", hobby = "tennis",
            vehicle = "convertible", feature = "jewelry", food = "",
        })
        assert_eq(#result, 1)
        assert_eq(result[1].id, "scarlet_vega")
    end)

    it("unique trait combo returns exactly 1 suspect", function()
        -- scarlet_vega: female, brown, tennis, convertible, jewelry
        local result = suspect.filter(suspects, {
            sex="female", hair="brown", hobby="tennis",
            vehicle="convertible", feature="jewelry"
        })
        assert_eq(#result, 1)
        assert_eq(result[1].id, "scarlet_vega")
    end)

    it("contradictory filter returns 0 suspects", function()
        -- no suspect can be both male and female
        local result = suspect.filter(suspects, {sex="male", hair="blonde", hobby="tennis"})
        -- no male tennis/blonde in our roster
        assert_eq(#result, 0)
    end)

    it("filter by hobby=croquet returns 3", function()
        local result = suspect.filter(suspects, {hobby="croquet"})
        assert_eq(#result, 3)
    end)

    it("filter by vehicle=motorcycle returns 2", function()
        local result = suspect.filter(suspects, {vehicle="motorcycle"})
        assert_eq(#result, 2)
    end)

    it("all matched suspects actually have the filtered traits", function()
        local filter = {hair="red", sex="male"}
        local result = suspect.filter(suspects, filter)
        for _, s in ipairs(result) do
            assert_eq(s.hair, "red")
            assert_eq(s.sex, "male")
        end
    end)
end)

describe("suspect.by_id", function()
    it("finds suspect by id", function()
        local s = suspect.by_id(suspects, "igor_volkov")
        assert_not_nil(s)
        assert_eq(s.name, "Igor Volkov")
    end)

    it("returns nil for unknown id", function()
        local s = suspect.by_id(suspects, "does_not_exist")
        assert_nil(s)
    end)
end)

describe("suspect.random", function()
    it("returns a suspect from the list", function()
        local rng = function(n) return 1 end
        local s = suspect.random(suspects, rng)
        assert_not_nil(s)
        assert_not_nil(s.id)
    end)

    it("rng is called with correct max", function()
        local called_with
        local rng = function(n) called_with = n; return 1 end
        suspect.random(suspects, rng)
        assert_eq(called_with, 10)
    end)

    it("returns nil for empty list", function()
        local s = suspect.random({}, function(n) return 1 end)
        assert_nil(s)
    end)
end)
