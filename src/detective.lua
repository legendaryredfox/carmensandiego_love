local suspect_mod = require("src.suspect")

local M = {}

local RANKS = {
    { id = "rookie",           cases = 0  },
    { id = "junior_detective", cases = 1  },
    { id = "sleuth",           cases = 3  },
    { id = "private_eye",      cases = 6  },
    { id = "investigator",     cases = 10 },
    { id = "ace_detective",    cases = 15 },
}

local function rank_for_cases(cases_solved)
    local current = RANKS[1]
    for _, r in ipairs(RANKS) do
        if cases_solved >= r.cases then
            current = r
        end
    end
    return current.id
end

function M.new(name)
    return {
        name            = name,
        rank            = "rookie",
        cases_solved    = 0,
        current_city_id = nil,
        hours_elapsed   = 0,
        time_limit_hours = 7 * 24,
        gathered_traits = {},
        warrant_id      = nil,
        mission         = nil,
    }
end

-- Moves detective to city_id, consuming hours.
-- Returns "ok" or "time_expired".
function M.travel(det, city_id, hours)
    if det.hours_elapsed + hours >= det.time_limit_hours then
        det.hours_elapsed = det.time_limit_hours
        return "time_expired"
    end
    det.hours_elapsed   = det.hours_elapsed + hours
    det.current_city_id = city_id
    return "ok"
end

-- Investigates venue_index (1–3) in current city.
-- Returns the Clue table, or nil when city is not on the route (no leads).
function M.investigate(det, mission, venue_index)
    local city_id = det.current_city_id
    if not require("src.mission").on_route(mission, city_id) then
        return nil
    end
    return require("src.mission").clue_at(mission, city_id, venue_index)
end

-- Records a suspect trait clue gathered from a witness.
function M.add_trait(det, attr, value)
    det.gathered_traits[attr] = value
end

-- Tries to issue an arrest warrant from gathered traits.
-- suspects: full suspect list
-- Returns "issued", "multiple", or "none".
function M.issue_warrant(det, suspects)
    local matches = suspect_mod.filter(suspects, det.gathered_traits)
    if #matches == 1 then
        det.warrant_id = matches[1].id
        return "issued", matches[1]
    elseif #matches == 0 then
        return "none", nil
    else
        return "multiple", matches
    end
end

-- Attempts to arrest the thief at the current city.
-- Returns "success", "wrong_warrant", "no_warrant", or "wrong_city".
function M.attempt_arrest(det, mission)
    local thief_city = require("src.mission").thief_city(mission)
    if det.current_city_id ~= thief_city then
        return "wrong_city"
    end
    if not det.warrant_id then
        return "no_warrant"
    end
    if det.warrant_id == mission.thief.id then
        return "success"
    end
    return "wrong_warrant"
end

-- Called after a successful arrest. Updates cases_solved and rank.
function M.on_success(det)
    det.cases_solved = det.cases_solved + 1
    det.rank         = rank_for_cases(det.cases_solved)
end

-- Returns hours remaining before time limit.
function M.hours_remaining(det)
    return math.max(0, det.time_limit_hours - det.hours_elapsed)
end

-- Returns fractional days remaining (rounded down to nearest 0.5).
function M.days_remaining(det)
    local h   = M.hours_remaining(det)
    return math.floor(h / 24 * 2) / 2
end

-- Score = rank_index * cases_solved * 1000 / max(1, hours_elapsed)
function M.score(det)
    local rank_index = 1
    for i, r in ipairs(RANKS) do
        if r.id == det.rank then rank_index = i end
    end
    return math.floor(rank_index * det.cases_solved * 1000 /
        math.max(1, det.hours_elapsed))
end

-- Resets mission state for a new case.
function M.begin_mission(det, mission)
    det.mission          = mission
    det.current_city_id  = mission.route[1]
    det.hours_elapsed    = 0
    det.time_limit_hours = mission.time_limit_hours
    det.gathered_traits  = {}
    det.warrant_id       = nil
end

-- Serializes detective to a plain table (for JSON save).
function M.serialize(det)
    return {
        name             = det.name,
        rank             = det.rank,
        cases_solved     = det.cases_solved,
        current_city_id  = det.current_city_id,
        hours_elapsed    = det.hours_elapsed,
        time_limit_hours = det.time_limit_hours,
        gathered_traits  = det.gathered_traits,
        warrant_id       = det.warrant_id,
    }
end

-- Reconstructs a detective from a serialized table.
function M.deserialize(t)
    local det = M.new(t.name)
    det.rank             = t.rank             or "rookie"
    det.cases_solved     = t.cases_solved     or 0
    det.current_city_id  = t.current_city_id
    det.hours_elapsed    = t.hours_elapsed    or 0
    det.time_limit_hours = t.time_limit_hours or (7 * 24)
    det.gathered_traits  = t.gathered_traits  or {}
    det.warrant_id       = t.warrant_id
    return det
end

-- Exposed for tests.
M._rank_for_cases = rank_for_cases

return M
