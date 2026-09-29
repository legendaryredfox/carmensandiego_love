return {
    -- Title screen
    ["splash.tagline"]            = "MADE WITH LÖVE",

    ["title.game_name"]           = "DETECTIVE AGENCY",
    ["title.press_any_key"]       = "PRESS ANY KEY",
    ["title.subtitle"]            = "A GLOBE-TROTTING DETECTIVE GAME",
    ["title.copyright"]           = "(C) {year} - LEGENDARYREDFOX",

    -- Language select
    ["language.choose"]           = "CHOOSE YOUR LANGUAGE",
    ["language.en"]               = "ENGLISH",
    ["language.pt"]               = "PORTUGUES",
    ["language.nav_hint"]         = "UP/DOWN  ENTER",

    -- Main menu
    ["menu.new_game"]             = "NEW GAME",
    ["menu.continue"]             = "CONTINUE",
    ["menu.leaderboard"]          = "LEADERBOARD",
    ["menu.settings"]             = "SETTINGS",
    ["menu.quit"]                 = "QUIT",

    -- Settings
    ["settings.title"]            = "SETTINGS",
    ["settings.language"]         = "LANGUAGE",
    ["settings.music_volume"]     = "MUSIC VOLUME",
    ["settings.sfx_volume"]       = "SFX VOLUME",
    ["settings.typewriter_speed"] = "TEXT SPEED",
    ["settings.resolution"]       = "RESOLUTION",
    ["settings.fullscreen"]       = "FULLSCREEN",
    ["settings.on"]               = "ON",
    ["settings.off"]              = "OFF",
    ["settings.nav_hint"]         = "UP/DOWN  LEFT/RIGHT  ENTER  ESC=BACK",

    -- Name entry
    ["name.title"]                = "INTERPOL HEADQUARTERS",
    ["name.prompt"]               = "ENTER YOUR NAME, DETECTIVE:",
    ["name.confirm"]              = "PRESS ENTER TO CONFIRM",

    -- Briefing
    ["briefing.title"]            = "*** INTERPOL DISPATCH ***",
    -- {item} already carries its own article ("The Mona Lisa", "A relic")
    ["briefing.stolen"]           = "NEWS FLASH: {item} has been stolen from {city}.",
    ["briefing.suspect_seen_male"]   = "He was seen fleeing the scene, and Interpol believes he's already crossed the border.",
    ["briefing.suspect_seen_female"] = "She was seen fleeing the scene, and Interpol believes she's already crossed the border.",
    ["briefing.mission"]          = "Your mission: track down the thief\nand make the arrest.\nYou have {days} days.",
    ["briefing.good_luck"]        = "Good luck, {rank} {name}.",
    ["briefing.press_any_key"]    = "[ PRESS ANY KEY ]",

    -- City screen
    ["city.interpol"]             = "CRIME COMPUTER",
    ["city.airport"]              = "AIRPORT",
    ["city.status_city"]          = "CITY: {city}",
    ["city.status_days"]          = "DAYS LEFT: {days}",
    ["city.status_rank"]          = "RANK: {rank}",
    ["city.nav_hint"]             = "[ ARROWS  ENTER ]",

    -- Venue — clue_to_text (src/screens/venue.lua) wraps whichever of these
    -- gets picked in quotes, so this witness is always quoted directly
    -- speaking, never reported/summarized in the third person.
    ["venue.nobody_suspicious"]   = "Nobody suspicious around here, sorry.",
    ["venue.witness_says"]        = "A witness leans in and says:",
    ["venue.clue_destination"]    = "{hint}",
    ["venue.clue_trait"]          = "{trait}.",
    -- Pronoun matches thief.sex (see briefing.suspect_seen_male/female for
    -- the same convention) — only used for verb-phrase trait text (hobby,
    -- vehicle, feature, food); sex/hair stay on venue.clue_trait above since
    -- their trait strings are noun phrases ("Male", "Brown hair") that a
    -- leading pronoun would misgrammar.
    ["venue.clue_trait_male"]     = "He {trait}.",
    ["venue.clue_trait_female"]   = "She {trait}.",
    ["venue.back"]                = "BACK",

    -- Venue names (derived from the clue category at that venue)
    ["venue_name.landmark.1"]     = "MUSEUM",
    ["venue_name.landmark.2"]     = "OLD RUINS",
    ["venue_name.landmark.3"]     = "MONUMENT PLAZA",
    ["venue_name.currency.1"]     = "CURRENCY EXCHANGE",
    ["venue_name.currency.2"]     = "CENTRAL BANK",
    ["venue_name.currency.3"]     = "MARKET STALLS",
    ["venue_name.language.1"]     = "LANGUAGE INSTITUTE",
    ["venue_name.language.2"]     = "OLD BOOKSTORE",
    ["venue_name.language.3"]     = "TRANSLATOR'S OFFICE",
    ["venue_name.geography.1"]    = "OBSERVATORY",
    ["venue_name.geography.2"]    = "TOURIST OFFICE",
    ["venue_name.geography.3"]    = "SCENIC OVERLOOK",
    ["venue_name.wildlife.1"]     = "NATURE RESERVE",
    ["venue_name.wildlife.2"]     = "CITY ZOO",
    ["venue_name.wildlife.3"]     = "WILDLIFE SANCTUARY",
    ["venue_name.culture.1"]      = "CULTURAL CENTER",
    ["venue_name.culture.2"]      = "GRAND THEATER",
    ["venue_name.culture.3"]      = "ART GALLERY",
    ["venue_name.industry.1"]     = "TRADE OFFICE",
    ["venue_name.industry.2"]     = "HARBOR WAREHOUSE",
    ["venue_name.industry.3"]     = "FACTORY DISTRICT",
    ["venue_name.trait.1"]        = "INFORMANT'S TAVERN",
    ["venue_name.trait.2"]        = "BACK-ALLEY CONTACT",
    ["venue_name.trait.3"]        = "WITNESS CORNER",
    ["venue_name.terminal.1"]     = "SUSPICIOUS HIDEOUT",
    ["venue_name.terminal.2"]     = "QUIET BACK STREET",
    ["venue_name.generic.1"]      = "LOCAL PRECINCT",
    ["venue_name.generic.2"]      = "TRAIN STATION",
    ["venue_name.generic.3"]      = "PUBLIC LIBRARY",

    -- Investigation transition (walking from the city hub to a venue)
    ["investigating.heading_over"] = "HEADING OVER...",

    -- Crime computer
    ["crime.title"]               = "INTERPOL CRIME COMPUTER",
    ["crime.sex"]                 = "SEX",
    ["crime.hair"]                = "HAIR",
    ["crime.hobby"]               = "HOBBY",
    ["crime.vehicle"]             = "VEHICLE",
    ["crime.feature"]             = "FEATURE",
    ["crime.food"]                = "FOOD PREFERENCE",
    ["crime.search"]              = "SEARCH",
    ["crime.issue_warrant"]       = "ISSUE WARRANT",
    ["crime.no_match"]            = "NO SUSPECTS MATCH. REVIEW YOUR CLUES.",
    ["crime.multiple_match"]      = "MULTIPLE SUSPECTS MATCH. GATHER MORE CLUES.",
    ["crime.warrant_issued"]      = "ARREST WARRANT ISSUED FOR {name}.",
    ["crime.suspects_label"]      = "SUSPECTS: {count}",
    ["crime.warrant_label"]       = "WARRANT: {name}",
    ["crime.nav_hint"]            = "UP/DOWN  LEFT/RIGHT  S=SEARCH  W=WARRANT  ESC=BACK",

    -- Travel
    ["travel.title"]              = "DEPARTURE LOUNGE",
    ["travel.select"]             = "SELECT DESTINATION:",
    ["travel.distance"]           = "{km} KM",
    ["travel.duration"]           = "{hours}H FLIGHT",
    ["travel.departing"]          = "DEPARTING FOR {city}...",
    ["travel.low_on_time"]        = "WARNING: LOW ON TIME!",
    ["travel.nav_hint"]           = "UP/DOWN  ENTER=DEPART  ESC=BACK",

    -- Arrest
    ["arrest.success"]            = "You caught {name}!\nCase closed.",
    ["arrest.wrong_warrant"]      = "Wrong suspect!\n{name} escaped.",
    ["arrest.no_warrant"]         = "No warrant.\nThe suspect escaped.",
    ["arrest.wrong_city"]         = "The thief is not here.",
    ["arrest.title_success"]      = "CASE CLOSED!",
    ["arrest.title_failed"]       = "MISSION FAILED",
    ["arrest.next_mission"]       = "[ PRESS ENTER FOR NEXT MISSION ]",
    ["arrest.continue"]           = "[ PRESS ENTER TO CONTINUE ]",

    -- Rank up
    ["rankup.title"]              = "PROMOTION!",
    ["rankup.message"]            = "Congratulations, {name}.\nYou are now a {rank}.",
    ["rankup.press_enter"]        = "[ PRESS ENTER ]",

    -- Game over
    ["gameover.title"]            = "MISSION FAILED",
    ["gameover.time"]             = "You ran out of time.\nThe thief escaped.",
    ["gameover.retry"]            = "PRESS ENTER TO TRY AGAIN",

    -- Hall of Fame (career-capping arrest of the organization leader)
    ["hallfame.title"]            = "HALL OF FAME",
    ["hallfame.message"]          = "You caught {leader} and dismantled the\norganization for good, {rank} {name}.\n\nYour career as a detective is complete.",
    ["hallfame.continue"]         = "[ PRESS ENTER TO RETURN TO THE MENU ]",

    -- Leaderboard
    ["leaderboard.title"]         = "TOP DETECTIVES",
    ["leaderboard.empty"]         = "NO RECORDS YET.",
    ["leaderboard.back"]          = "PRESS ESCAPE TO GO BACK",
    ["leaderboard.col_num"]       = "#",
    ["leaderboard.col_name"]      = "NAME",
    ["leaderboard.col_rank"]      = "RANK",
    ["leaderboard.col_cases"]     = "CASES",
    ["leaderboard.col_score"]     = "SCORE",

    -- Ranks
    ["rank.rookie"]               = "Rookie",
    ["rank.sleuth"]               = "Sleuth",
    ["rank.private_eye"]          = "Private Eye",
    ["rank.investigator"]         = "Investigator",
    ["rank.ace_detective"]        = "Ace Detective",

    -- Suspect traits
    ["trait.sex.male"]            = "Male",
    ["trait.sex.female"]          = "Female",
    ["trait.hair.brown"]          = "Brown hair",
    ["trait.hair.blonde"]         = "Blonde hair",
    ["trait.hair.red"]            = "Red hair",
    ["trait.hair.black"]          = "Black hair",
    ["trait.hobby.tennis"]        = "Plays tennis",
    ["trait.hobby.mountain_climbing"] = "Climbs mountains",
    ["trait.hobby.croquet"]       = "Plays croquet",
    ["trait.hobby.skydiving"]     = "Skydives",
    ["trait.hobby.swimming"]      = "Swims",
    ["trait.vehicle.convertible"] = "Drives a convertible",
    ["trait.vehicle.limousine"]   = "Travels by limousine",
    ["trait.vehicle.motorcycle"]  = "Rides a motorcycle",
    ["trait.vehicle.racecar"]     = "Drives a racecar",
    ["trait.feature.tattoo"]      = "Has a tattoo",
    ["trait.feature.ring"]        = "Wears a distinctive ring",
    ["trait.feature.jewelry"]     = "Wears flashy jewelry",
    ["trait.feature.scar"]        = "Has a prominent scar",
    ["trait.food.mexican"]        = "Prefers Mexican food",
    ["trait.food.seafood"]        = "Prefers seafood",

    -- Short forms for the crime computer's dropdown (src/screens/crime_computer.lua)
    -- — the trait.* values above are full clue-sentence fragments and wrap
    -- inside the dropdown's fixed width, especially in PT.
    ["trait_short.hobby.tennis"]            = "Tennis",
    ["trait_short.hobby.mountain_climbing"] = "Climbing",
    ["trait_short.hobby.croquet"]           = "Croquet",
    ["trait_short.hobby.skydiving"]         = "Skydiving",
    ["trait_short.hobby.swimming"]          = "Swimming",
    ["trait_short.vehicle.convertible"]     = "Convertible",
    ["trait_short.vehicle.limousine"]       = "Limousine",
    ["trait_short.vehicle.motorcycle"]      = "Motorcycle",
    ["trait_short.vehicle.racecar"]         = "Racecar",
    ["trait_short.feature.tattoo"]          = "Tattoo",
    ["trait_short.feature.ring"]            = "Ring",
    ["trait_short.feature.jewelry"]         = "Jewelry",
    ["trait_short.feature.scar"]            = "Scar",
    ["trait_short.food.mexican"]            = "Mexican food",
    ["trait_short.food.seafood"]            = "Seafood",

    -- Time / status bar
    ["status.time"]               = "TIME: {time}",
    ["status.deadline"]           = "DUE: {time}",
    ["briefing.deadline"]         = "Catch the suspect by {deadline}.",

    -- Generic clue fallbacks
    ["clue.generic.destination"]  = "unusual activity in a distant land",
    ["clue.terminal"]             = "Nothing suspicious here.",

    -- Stolen items — landmark items tied to their real home city (see
    -- ITEM_BY_CITY in src/mission.lua); generic ones can be used anywhere
    ["item.mona_lisa"]            = "The Mona Lisa",
    ["item.crown_jewels"]         = "The Crown Jewel Collection",
    ["item.magna_carta"]          = "The Magna Carta",
    ["item.aztec_calendar"]       = "The Aztec Calendar Stone",
    ["item.parthenon_frieze"]     = "A Parthenon Frieze",
    ["item.eiffel_torch"]         = "The Eiffel Tower Torch",
    ["item.colosseum_stone"]      = "A Colosseum Cornerstone",
    ["item.big_ben_bell"]         = "Big Ben's Great Bell",
    ["item.generic_painting"]     = "A priceless painting",
    ["item.generic_gem"]          = "A rare gemstone",
    ["item.generic_relic"]        = "An ancient relic",
    ["item.generic_document"]     = "A historic document",
    ["item.generic_statue"]       = "A museum statue",

    -- City arrival info
    ["city_info.press_enter"]     = "PRESS ENTER TO CONTINUE",
    ["city_info.athens"]          = "CAPITAL OF GREECE, HOME TO THE ANCIENT ACROPOLIS AND THE PARTHENON.",
    ["city_info.baghdad"]         = "CAPITAL OF IRAQ, BUILT ON THE BANKS OF THE TIGRIS RIVER.",
    ["city_info.bamako"]          = "CAPITAL OF MALI, ON THE NIGER RIVER, KNOWN FOR ITS VIBRANT MUSIC SCENE.",
    ["city_info.bangkok"]         = "CAPITAL OF THAILAND, FAMOUS FOR ORNATE TEMPLES AND THE GRAND PALACE.",
    ["city_info.beijing"]         = "CAPITAL OF CHINA, HOME TO THE FORBIDDEN CITY AND CLOSE TO THE GREAT WALL.",
    ["city_info.budapest"]        = "CAPITAL OF HUNGARY, SPLIT BY THE DANUBE INTO BUDA AND PEST, FAMED FOR THERMAL BATHS.",
    ["city_info.buenos_aires"]    = "CAPITAL OF ARGENTINA, BIRTHPLACE OF THE TANGO.",
    ["city_info.cairo"]           = "CAPITAL OF EGYPT, ON THE NILE RIVER, NEAR THE PYRAMIDS OF GIZA.",
    ["city_info.colombo"]         = "SRI LANKA'S LARGEST CITY AND MAIN PORT, A HISTORIC HUB OF THE SPICE AND TEA TRADE.",
    ["city_info.istanbul"]        = "TURKEY'S LARGEST CITY, STRADDLING EUROPE AND ASIA ACROSS THE BOSPHORUS.",
    ["city_info.kathmandu"]       = "CAPITAL OF NEPAL, GATEWAY TO THE HIMALAYAS.",
    ["city_info.kigali"]          = "CAPITAL OF RWANDA, BUILT ACROSS ROLLING HILLS, KNOWN FOR ITS CLEANLINESS.",
    ["city_info.lima"]            = "CAPITAL OF PERU, A PACIFIC COAST CITY WITH A WELL-PRESERVED COLONIAL CENTER.",
    ["city_info.london"]          = "CAPITAL OF THE UNITED KINGDOM, ON THE THAMES, HOME TO BIG BEN.",
    ["city_info.mexico_city"]     = "CAPITAL OF MEXICO, BUILT ON THE SITE OF THE FORMER AZTEC CAPITAL TENOCHTITLAN.",
    ["city_info.montreal"]        = "CANADA'S SECOND-LARGEST CITY, A FRENCH-SPEAKING ISLAND HUB ON THE SAINT LAWRENCE RIVER.",
    ["city_info.moroni"]          = "CAPITAL OF COMOROS, A VOLCANIC ISLAND KNOWN FOR VANILLA AND YLANG-YLANG.",
    ["city_info.moscow"]          = "CAPITAL OF RUSSIA, HOME TO THE KREMLIN AND RED SQUARE.",
    ["city_info.new_delhi"]       = "CAPITAL OF INDIA, HOME TO THE INDIA GATE AND ADJACENT TO HISTORIC OLD DELHI.",
    ["city_info.new_york"]        = "THE UNITED STATES' LARGEST CITY, HOME TO THE STATUE OF LIBERTY AND WALL STREET.",
    ["city_info.oslo"]            = "CAPITAL OF NORWAY, SET AT THE HEAD OF A LONG FJORD.",
    ["city_info.paris"]           = "CAPITAL OF FRANCE, HOME TO THE EIFFEL TOWER ON THE SEINE RIVER.",
    ["city_info.port_moresby"]    = "CAPITAL OF PAPUA NEW GUINEA, ON THE COAST OF THE CORAL SEA.",
    ["city_info.reykjavik"]       = "CAPITAL OF ICELAND, THE WORLD'S NORTHERNMOST NATIONAL CAPITAL.",
    ["city_info.rio_de_janeiro"]  = "BRAZIL'S FAMED COASTAL CITY, HOME TO THE CHRIST THE REDEEMER STATUE.",
    ["city_info.rome"]            = "CAPITAL OF ITALY, HOME TO THE ANCIENT COLOSSEUM AND THE VATICAN ENCLAVE.",
    ["city_info.san_marino"]      = "ONE OF THE WORLD'S OLDEST REPUBLICS, A MOUNTAINTOP MICROSTATE SURROUNDED BY ITALY.",
    ["city_info.singapore"]       = "AN ISLAND CITY-STATE AND MAJOR SHIPPING HUB IN SOUTHEAST ASIA.",
    ["city_info.sydney"]          = "AUSTRALIA'S LARGEST CITY, KNOWN FOR ITS OPERA HOUSE AND HARBOUR BRIDGE.",
    ["city_info.tokyo"]           = "CAPITAL OF JAPAN, ONE OF THE WORLD'S MOST POPULOUS METROPOLITAN AREAS.",
}
