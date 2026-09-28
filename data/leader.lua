-- The organization leader — the Ace Detective-rank capstone target
-- (see SPEC.md §2.7). Not part of the regular 10-suspect deduction
-- roster; only appears once the detective's next case is the final one.
-- Trait combo deliberately uses values none of the 10 regular suspects
-- use (skydiving, racecar, scar), so she's always uniquely identifiable.
return {
    id        = "dominique_castellan",
    name      = "Dominique Castellan",
    is_leader = true,
    sex       = "female",
    hair      = "blonde",
    hobby     = "skydiving",
    vehicle   = "racecar",
    feature   = "scar",
    food      = "seafood",
}
