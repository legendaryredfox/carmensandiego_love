local SM       = require("src.state_machine")
local locale   = require("src.locale")
local ui       = require("src.ui")
local game     = require("src.game")
local det_mod  = require("src.detective")
local rank_mod = require("src.ranking")
local audio    = require("src.audio")

local S = {}
local result_key, msg, thief_name = "", "", ""
local timer = 0
local rank_before_success = nil

function S.enter()
    local result = det_mod.attempt_arrest(game.detective, game.mission)
    local thief  = game.mission.thief
    thief_name   = thief.name

    if result == "success" then
        result_key = "arrest.success"
        rank_before_success = game.detective.rank
        det_mod.on_success(game.detective)
        audio.play_sfx("arrest_ok")
        audio.crossfade("success")
        rank_mod.add(game.ranking, {
            name         = game.detective.name,
            rank         = game.detective.rank,
            cases_solved = game.detective.cases_solved,
            score        = det_mod.score(game.detective),
            date         = os.date("%Y-%m-%d"),
        })
        -- Not saving here: game.mission still points at the just-solved
        -- case. An abnormal exit before the player presses Enter below
        -- would otherwise lose this arrest entirely on next load (resuming
        -- from the last save made before the winning investigation, with
        -- cases_solved/rank not yet incremented) instead of just replaying
        -- the briefing for the next case. Save once state has actually
        -- moved past it, in keypressed below.
    elseif result == "wrong_warrant" then
        result_key = "arrest.wrong_warrant"
        audio.play_sfx("arrest_fail")
        audio.crossfade("failure")
    elseif result == "no_warrant" then
        result_key = "arrest.no_warrant"
    else
        result_key = "arrest.wrong_city"
    end

    msg   = locale.t(result_key, { name = thief_name })
    timer = 0
end

function S.update(dt) timer = timer + dt end

function S.draw()
    local success = (result_key == "arrest.success")

    ui.title(0, 30, locale.t(success and "arrest.title_success" or "arrest.title_failed"),
        success and ui.C.success or ui.C.danger)

    ui.panel(60, 80, ui.VIRTUAL_W - 120, 120)
    ui.text(70, 95, msg, success and ui.C.success or ui.C.danger)

    if timer > 1.5 then
        local hint_key = success and "arrest.next_mission" or "arrest.continue"
        ui.text(0, 220, locale.t(hint_key), ui.C.dim, "center", ui.VIRTUAL_W)
    end
end

function S.keypressed(key)
    if timer < 1.5 then return end
    if key ~= "return" and key ~= "space" then return end
    local success = (result_key == "arrest.success")
    if not success then
        SM.switch(require("src.screens.game_over"))
        return
    end

    if game.mission.is_final then
        game.detective.career_complete = true
        game.save()
        SM.switch(require("src.screens.hall_of_fame"))
        return
    end

    local ranked_up = game.detective.rank ~= rank_before_success
    game.next_mission()
    game.save()
    if ranked_up then
        SM.switch(require("src.screens.rank_up"))
    else
        SM.switch(require("src.screens.briefing"))
    end
end

return S
