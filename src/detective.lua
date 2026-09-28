local suspect_mod = require("src.suspect")
local mission_mod = require("src.mission")

local M = {}

-- Cumulative cases-solved thresholds to reach each rank — matches the
-- 1985 original exactly (reconstruction.md:59-61: promotion thresholds
-- 1, 5, 12, 20 solved cases for its first five ranks; the sixth rank,
-- Super Sleuth, isn't reached by a plain count — see mission.lua's
-- FINAL_CASE_CASES_SOLVED, which folds that into "solve the leader case
-- while at Ace Detective" instead of adding a 7th rank here).
local RANKS = {
    { id = "rookie",        cases = 0  },
    { id = "sleuth",        cases = 1  },
    { id = "private_eye",   cases = 5  },
    { id = "investigator",  cases = 12 },
    { id = "ace_detective", cases = 20 },
}

local DAY_EN = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }
local DAY_PT = { "Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab" }
local DAY_WORD_EN, DAY_WORD_PT = "Day", "Dia"

local INVESTIGATION_HOURS = 2
M.INVESTIGATION_HOURS     = INVESTIGATION_HOURS

-- Every case starts Monday 08:00 on the in-game clock — a deliberate
-- simplification, not a port of the 1985 original (which randomizes both
-- weekday and starting hour 08:00-17:00 per case; see PLAN.md's "Playtest
-- feedback" note). start_timestamp/current_timestamp/deadline_timestamp
-- below are plain "seconds since Monday 00:00" counters, not real unix
-- time or the host machine's clock — format_datetime derives weekday and
-- hour from that count directly instead of os.date, so the display can't
-- drift with the host's timezone/DST or whatever real day it is.
local SEC_PER_DAY          = 86400
local CASE_START_HOUR      = 8
M.CASE_START_TIMESTAMP     = CASE_START_HOUR * 3600

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
        start_timestamp  = M.CASE_START_TIMESTAMP,
        gathered_traits  = {},
        warrant_id       = nil,
        career_complete  = false,
        hideout_visited  = false,
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

-- Formats a virtual "seconds since Monday 00:00" timestamp (see
-- CASE_START_TIMESTAMP) as "Mon 14:30" (or PT equivalent). DAY_EN/DAY_PT
-- are Sunday-first (index 1); Monday is day_offset 0, hence the +2 below.
function M.format_datetime(ts, lang)
    local days       = (lang == "pt") and DAY_PT or DAY_EN
    local day_offset = math.floor(ts / SEC_PER_DAY) % 7
    local sec_of_day = ts % SEC_PER_DAY
    local wday       = (day_offset + 1) % 7 + 1
    local hour       = math.floor(sec_of_day / 3600)
    local min        = math.floor((sec_of_day % 3600) / 60)
    return string.format("%s %02d:%02d", days[wday], hour, min)
end

-- 1-indexed day-of-case number for a timestamp relative to the mission's
-- start — disambiguates e.g. "now" vs. a deadline exactly N*24h later,
-- which otherwise show the identical weekday and time (see
-- M.format_datetime) and read as if the deadline were already here.
local function day_number(det, ts)
    return math.floor((ts - det.start_timestamp) / 86400) + 1
end

-- Returns formatted current game time string, e.g. "Day 1, Mon 14:30".
function M.current_time_str(det, lang)
    local ts   = M.current_timestamp(det)
    local word = (lang == "pt") and DAY_WORD_PT or DAY_WORD_EN
    return word .. " " .. day_number(det, ts) .. ", " .. M.format_datetime(ts, lang)
end

-- Returns formatted deadline string, e.g. "Day 8, Mon 14:30".
function M.deadline_str(det, lang)
    local ts   = M.deadline_timestamp(det)
    local word = (lang == "pt") and DAY_WORD_PT or DAY_WORD_EN
    return word .. " " .. day_number(det, ts) .. ", " .. M.format_datetime(ts, lang)
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
--
-- The detective's very first investigation at the terminal (hideout) city
-- either finds the thief's marked venue or, if wrong, makes the thief
-- evade to the one remaining slot (see mission.evade_hideout) — mirrors
-- the 1985 original's "first place investigated can move the mark"
-- behavior (reconstruction.md:510-514) instead of the thief just sitting
-- in a fixed spot the moment the detective lands in the city.
function M.investigate(det, mission, venue_index)
    local city_id = det.current_city_id
    -- Advance clock regardless (time passes even on wrong city)
    det.hours_elapsed = math.min(det.time_limit_hours,
                                  det.hours_elapsed + INVESTIGATION_HOURS)
    if not mission_mod.on_route(mission, city_id) then
        return nil
    end
    if mission_mod.is_terminal(mission, city_id) and not det.hideout_visited then
        det.hideout_visited = true
        mission_mod.evade_hideout(mission, venue_index)
    end
    return mission_mod.clue_at(mission, city_id, venue_index)
end

-- Sets (or, with a nil value, clears) one gathered trait — what the crime
-- computer's dropdowns write as the player manually enters what a witness
-- told them (see src/screens/crime_computer.lua's cycle()).
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
    local thief_city = mission_mod.thief_city(mission)
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
    det.current_city_id  = mission.route[1]
    det.hours_elapsed    = 0
    det.time_limit_hours = mission.time_limit_hours
    det.start_timestamp  = M.CASE_START_TIMESTAMP
    det.gathered_traits  = {}
    det.warrant_id       = nil
    det.hideout_visited  = false
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
        hideout_visited  = det.hideout_visited,
    }
end

function M.deserialize(t)
    local det = M.new(t.name)
    det.rank             = t.rank             or "rookie"
    det.cases_solved     = t.cases_solved     or 0
    det.current_city_id  = t.current_city_id
    det.hours_elapsed    = t.hours_elapsed    or 0
    det.time_limit_hours = t.time_limit_hours or (7 * 24)
    det.start_timestamp  = t.start_timestamp  or M.CASE_START_TIMESTAMP
    det.gathered_traits  = t.gathered_traits  or {}
    det.warrant_id       = t.warrant_id
    det.career_complete  = t.career_complete  or false
    det.hideout_visited  = t.hideout_visited  or false
    return det
end

M._rank_for_cases = rank_for_cases

return M
