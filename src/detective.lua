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

local DAY_EN = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }
local DAY_PT = { "Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab" }

local INVESTIGATION_HOURS = 2
M.INVESTIGATION_HOURS     = INVESTIGATION_HOURS

local function rank_for_cases(cases_solved)
    local current = RANKS[1]
    for _, r in ipairs(RANKS) do
        if cases_solved >= r.cases then current = r end
    end
    return current.id
end

function M.new(name)
    return {
        name             = name,
        rank             = "rookie",
        cases_solved     = 0,
        current_city_id  = nil,
        hours_elapsed    = 0,
        time_limit_hours = 7 * 24,
        start_timestamp  = os.time(),
        gathered_traits  = {},
        warrant_id       = nil,
        mission          = nil,
        career_complete  = false,
    }
end

-- Returns the in-game unix timestamp for the current moment.
function M.current_timestamp(det)
    return det.start_timestamp + math.floor(det.hours_elapsed * 3600)
end

-- Returns the deadline unix timestamp.
function M.deadline_timestamp(det)
    return det.start_timestamp + math.floor(det.time_limit_hours * 3600)
end

-- Formats a unix timestamp as "Mon 14:30" (or PT equivalent).
function M.format_datetime(ts, lang)
    local t    = os.date("*t", ts)
    local days = (lang == "pt") and DAY_PT or DAY_EN
    return string.format("%s %02d:%02d", days[t.wday], t.hour, t.min)
end

-- Returns formatted current game time string.
function M.current_time_str(det, lang)
    return M.format_datetime(M.current_timestamp(det), lang)
end

-- Returns formatted deadline string.
function M.deadline_str(det, lang)
    return M.format_datetime(M.deadline_timestamp(det), lang)
end

-- Moves detective to city_id, consuming flight hours.
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
-- Costs INVESTIGATION_HOURS in-game hours.
-- Returns the Clue table, or nil if city is not on the route (no leads).
function M.investigate(det, mission, venue_index)
    local city_id = det.current_city_id
    -- Advance clock regardless (time passes even on wrong city)
    det.hours_elapsed = math.min(det.time_limit_hours,
                                  det.hours_elapsed + INVESTIGATION_HOURS)
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

-- Attempts to arrest the suspect at the current city.
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

-- Called after a successful arrest.
function M.on_success(det)
    det.cases_solved = det.cases_solved + 1
    det.rank         = rank_for_cases(det.cases_solved)
end

function M.hours_remaining(det)
    return math.max(0, det.time_limit_hours - det.hours_elapsed)
end

function M.days_remaining(det)
    local h = M.hours_remaining(det)
    return math.floor(h / 24 * 2) / 2
end

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
    det.start_timestamp  = os.time()
    det.gathered_traits  = {}
    det.warrant_id       = nil
end

function M.serialize(det)
    return {
        name             = det.name,
        rank             = det.rank,
        cases_solved     = det.cases_solved,
        current_city_id  = det.current_city_id,
        hours_elapsed    = det.hours_elapsed,
        time_limit_hours = det.time_limit_hours,
        start_timestamp  = det.start_timestamp,
        gathered_traits  = det.gathered_traits,
        warrant_id       = det.warrant_id,
        career_complete  = det.career_complete,
    }
end

function M.deserialize(t)
    local det = M.new(t.name)
    det.rank             = t.rank             or "rookie"
    det.cases_solved     = t.cases_solved     or 0
    det.current_city_id  = t.current_city_id
    det.hours_elapsed    = t.hours_elapsed    or 0
    det.time_limit_hours = t.time_limit_hours or (7 * 24)
    det.start_timestamp  = t.start_timestamp  or os.time()
    det.gathered_traits  = t.gathered_traits  or {}
    det.warrant_id       = t.warrant_id
    det.career_complete  = t.career_complete  or false
    return det
end

M._rank_for_cases = rank_for_cases

return M
