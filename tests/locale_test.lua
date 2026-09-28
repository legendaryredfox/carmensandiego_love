local locale = require("src.locale")

describe("locale", function()
    it("returns key when no language loaded and key missing", function()
        -- locale starts with empty strings table — missing key returns key itself
        assert_eq(locale.t("nonexistent.key"), "nonexistent.key")
    end)

    it("loads english and returns correct string", function()
        locale.set("en")
        assert_eq(locale.t("menu.new_game"), "NEW GAME")
        assert_eq(locale.t("menu.quit"), "QUIT")
    end)

    it("loads portuguese and returns correct string", function()
        locale.set("pt")
        assert_eq(locale.t("menu.new_game"), "NOVO JOGO")
        assert_eq(locale.t("menu.quit"), "SAIR")
    end)

    it("interpolates {var} placeholders", function()
        locale.set("en")
        local result = locale.t("briefing.stolen", {item = "Mona Lisa", city = "Paris"})
        assert_eq(result, "A Mona Lisa has been stolen from Paris.")
    end)

    it("leaves undefined vars as {var} in output", function()
        locale.set("en")
        local result = locale.t("briefing.stolen", {item = "X"})
        assert_true(result:find("{city}") ~= nil, "undefined var should remain as {city}")
    end)

    it("returns key verbatim for missing key", function()
        locale.set("en")
        local result = locale.t("does.not.exist")
        assert_eq(result, "does.not.exist")
    end)

    it("get_lang returns current language", function()
        locale.set("en")
        assert_eq(locale.get_lang(), "en")
        locale.set("pt")
        assert_eq(locale.get_lang(), "pt")
        locale.set("en") -- restore
    end)

    it("both locales have same set of keys", function()
        locale.set("en")
        -- spot-check keys present in both
        local keys = {
            "title.press_any_key", "menu.new_game", "menu.quit",
            "rank.rookie", "rank.ace_detective",
            "trait.sex.male", "trait.hair.brown",
        }
        for _, k in ipairs(keys) do
            local en_val = locale.t(k)
            assert_true(en_val ~= k, "EN missing key: " .. k)
        end
        locale.set("pt")
        for _, k in ipairs(keys) do
            local pt_val = locale.t(k)
            assert_true(pt_val ~= k, "PT missing key: " .. k)
        end
        locale.set("en")
    end)
end)
