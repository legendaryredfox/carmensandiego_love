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

function S.enter()
    local result = det_mod.attempt_arrest(game.detective, game.mission)
    local thief  = game.mission.thief
    thief_name   = thief.name

    if result == "success" then
        result_key = "arrest.success"
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
        game.save()
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

    ui.title(0, 30, success and "CASE CLOSED!" or "MISSION FAILED",
        success and ui.C.success or ui.C.danger)

    ui.panel(60, 80, ui.VIRTUAL_W - 120, 120)
    ui.text(70, 95, msg, success and ui.C.success or ui.C.danger)

    if timer > 1.5 then
        if success then
            ui.text(0, 220, "[ PRESS ENTER FOR NEXT MISSION ]",
                ui.C.dim, "center", ui.VIRTUAL_W)
        else
            ui.text(0, 220, "[ PRESS ENTER TO CONTINUE ]",
                ui.C.dim, "center", ui.VIRTUAL_W)
        end
    end
end

function S.keypressed(key)
    if timer < 1.5 then return end
    if key ~= "return" and key ~= "space" then return end
    local success = (result_key == "arrest.success")
    if success then
        -- Check rank up
        local old_rank = game.mission and game.mission.thief and "rookie" or "rookie"
        game.next_mission()
        SM.switch(require("src.screens.briefing"))
    else
        SM.switch(require("src.screens.game_over"))
    end
end

return S
