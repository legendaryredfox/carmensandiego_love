# Asset Credits

All assets used in this project are free for commercial use.

## Fonts

| Asset | Author | Source | License |
|---|---|---|---|
| Press Start 2P | CodeMan38 | https://fonts.google.com/specimen/Press+Start+2P | OFL |

## Music

| File | Pack | Author | Source | License |
|---|---|---|---|---|
| title.ogg | 15 Melodic RPG Chiptunes — rpgchip01_title_screen | aureolusomicron | https://opengameart.org/content/15-melodic-rpg-chiptunes | CC0 |
| briefing.ogg | 15 Melodic RPG Chiptunes — rpgchip07_the_shrine_of_mysteries | aureolusomicron | https://opengameart.org/content/15-melodic-rpg-chiptunes | CC0 |
| city.ogg | 15 Melodic RPG Chiptunes — rpgchip03_town | aureolusomicron | https://opengameart.org/content/15-melodic-rpg-chiptunes | CC0 |
| computer.ogg | 15 Melodic RPG Chiptunes — rpgchip06_dungeon | aureolusomicron | https://opengameart.org/content/15-melodic-rpg-chiptunes | CC0 |
| travel.ogg | Chiptune Adventures — "1. Stage 1" | Juhani Junkala | https://opengameart.org/content/4-chiptunes-adventure | CC0 |
| success.ogg | Chiptune Adventures — "4. Stage Select" | Juhani Junkala | https://opengameart.org/content/4-chiptunes-adventure | CC0 |
| failure.ogg | 15 Melodic RPG Chiptunes — rpgchip15_game_over | aureolusomicron | https://opengameart.org/content/15-melodic-rpg-chiptunes | CC0 |

## Sound Effects

| File | Source file | License |
|---|---|---|
| click.wav | Essential Retro SFX — General Sounds/Menu Sounds/sfx_menu_select1 | CC0 |
| clue.wav | Essential Retro SFX — General Sounds/Positive Sounds/sfx_sounds_powerup10 | CC0 |
| warrant.wav | Essential Retro SFX — General Sounds/Fanfares/sfx_sounds_fanfare1 | CC0 |
| arrest_ok.wav | Essential Retro SFX — General Sounds/Fanfares/sfx_sounds_fanfare3 | CC0 |
| arrest_fail.wav | Essential Retro SFX — General Sounds/Negative Sounds/sfx_sounds_error10 | CC0 |
| type.wav | Essential Retro SFX — General Sounds/Simple Bleeps/sfx_sounds_Blip1 | CC0 |

All SFX by Juhani Junkala — https://opengameart.org/content/512-sound-effects-8-bit-style

## UI Sprites

| File | Source | License |
|---|---|---|
| ui/panel.png (from 9-Slice/Colored/grey.png) | Kenney Pixel UI Pack — https://kenney.nl/assets/pixel-ui-pack | CC0 |
| ui/panel_pressed.png (from 9-Slice/Colored/grey_pressed.png) | Kenney Pixel UI Pack — https://kenney.nl/assets/pixel-ui-pack | CC0 |

Both are plain greyscale so `src/ui.lua` can tint them to any palette color at
draw time (`draw_nine_slice`). `ui.panel` and `ui.button` fall back to flat
rectangles when the files are absent, so the game runs without them too.

Board Game Icons and Roguelike Characters (Kenney, CC0) remain unused for now.

| File | Source | License |
|---|---|---|
| ui/icon.png | Original artwork for this project | N/A (project asset) |

Used as the window/taskbar icon via `conf.lua`'s `t.window.icon`.

## Briefing Screen Background

| File | Source | Author | License |
|---|---|---|---|
| ui/briefing_bg.png | [Detectivebureaus, SFA022824674.jpg](https://commons.wikimedia.org/wiki/File:Detectivebureaus,_SFA022824674.jpg) (Wikimedia Commons, via Spaarnestad Photo / Nationaal Archief) | Unknown (1929) | Public domain |

`src/screens/briefing.lua`'s dispatch screen backdrop. A real 1929 photo —
"the director with an employee of the Curo bureau, a private office for
information and investigation, in Amsterdam" — cropped (ImageMagick) to
the desk surface and its clutter of papers/books/inkwell, deliberately
excluding both people's faces, and composited onto a flat sepia fill
sampled from the photo's own wallpaper tone so the two blend as one
backdrop. Replaced an earlier version composed from CC-BY-licensed pixel
art (`wallpiece-clean.png` + furniture silhouettes from Croomfolk's
"Vintage Office Interiors") after that one didn't read well in practice —
see PLAN.md. Falls back to a flat `ui.C.bg` fill if the file is absent.

## World Map

| File | Source | License |
|---|---|---|
| map/world_map.png | TODO: source/license — confirm with whoever supplied it | TODO |

Pixel-art equirectangular world map (1774x887, exact 2:1) drawn on the
travel/flying screens' map inset (`src/map.lua`). Drawn stretched
independently on x/y to exactly fill the map rect, which keeps every
pixel's (lon, lat) fraction aligned with city markers regardless of the
rect's own aspect ratio.

`data/continents.lua` — simplified continent/major-island coastline
outlines, used as a fallback only when `map/world_map.png` is missing. Not
an image; this is coordinate data (Natural Earth's 1:110m land dataset,
public domain, no attribution required), fetched via the
[world-atlas](https://github.com/topojson/world-atlas) npm package (ISC
license) and simplified with Douglas-Peucker for legibility at ~300x200px.

## Clue Images

Per-clue images sourced from Wikimedia Commons under CC0 or CC-BY (never
CC-BY-SA, per this project's license policy), resized to 128x128 with
nearest-neighbor downscaling. Referenced from the `image` field in
`data/clues/<city_id>.lua`. Flags are NEVER used as clue images (see
CLAUDE.md). Not currently displayed anywhere in-game — the `image` field
is parsed by `src/mission.lua` but no screen reads it yet (the venue card
on `src/screens/city.lua` shows a generic category icon instead, see
"Venue Category Icons" below; `src/screens/venue.lua`'s investigate screen
is text + witness portrait only). Kept for a future rank-gated reveal
(SPEC.md: image-only clues at Ace Detective rank).

| File | Source file | Author | License |
|---|---|---|---|
| clues/athens/parthenon.png | [Restoration work Parthenon facade Acropolis Athens Greece.jpg](https://commons.wikimedia.org/wiki/File:Restoration_work_Parthenon_facade_Acropolis_Athens_Greece.jpg) | Jebulon | CC0 |
| clues/athens/euro_coin.png | [2020 Greek Commemorative 2 Euro Coin "2500th Anniversary of the Battle of Thermopylae" M.Hoffmann.png](https://commons.wikimedia.org/wiki/File:2020_Greek_Commemorative_2_Euro_Coin_%222500th_Anniversary_of_the_Battle_of_Thermopylae%22_M.Hoffmann.png) | Unknown author | CC BY 4.0 |
| clues/baghdad/dinar.png | [1IQDking1939front.jpg](https://commons.wikimedia.org/wiki/File:1IQDking1939front.jpg) | Iraqi Currency Board (scan by user:ImAhmedYousif) | Public domain |
| clues/bamako/hippo.png | [Hippopotamus @ Barcelona zoo.jpg](https://commons.wikimedia.org/wiki/File:Hippopotamus_@_Barcelona_zoo.jpg) | Pedroserafin | Public domain |
| clues/bamako/cfa_franc.png | [Billet de monnaie - Bénin.jpg](https://commons.wikimedia.org/wiki/File:Billet_de_monnaie_-_B%C3%A9nin.jpg) | Houss 2020 | CC0 |
| clues/bangkok/elephant.png | [Elephas maximus in Singapore Zoo, 20240206 0857 6202.jpg](https://commons.wikimedia.org/wiki/File:Elephas_maximus_in_Singapore_Zoo,_20240206_0857_6202.jpg) | Jakub Hałun | CC BY 4.0 |
| clues/bangkok/baht_coin.png | [Currently circulateing coins of the baht.jpg](https://commons.wikimedia.org/wiki/File:Currently_circulateing_coins_of_the_baht.jpg) | Isthisthing | CC0 |
| clues/beijing/forbidden_city.png | [Meridian Gate Forbidden City Beijing (1).jpg](https://commons.wikimedia.org/wiki/File:Meridian_Gate_Forbidden_City_Beijing_(1).jpg) | Radosław Botev | CC BY 3.0 pl |
| clues/beijing/panda.png | [Giant Panda 2004-03-2.jpg](https://commons.wikimedia.org/wiki/File:Giant_Panda_2004-03-2.jpg) | Jeff Kubina | Public domain |
| clues/budapest/forint.png | [Six Hungarian forint banknotes - DPLA - 50c1922bcaee8d769c07d36977907f49 (page 3).jpg](https://commons.wikimedia.org/wiki/File:Six_Hungarian_forint_banknotes_-_DPLA_-_50c1922bcaee8d769c07d36977907f49_(page_3).jpg) | Magyar Kereskedelmi Bank | Public domain |
| clues/buenos_aires/peso.png | [100 pesos eva peron 2022 a.jpg](https://commons.wikimedia.org/wiki/File:100_pesos_eva_peron_2022_a.jpg) | Argentina.gob.ar | CC BY 4.0 |
| clues/cairo/pyramids.png | [Great Pyramid (Pyramid of Cheops Khufu), Giza, GG, EGY (47850686472).jpg](https://commons.wikimedia.org/wiki/File:Great_Pyramid_(Pyramid_of_Cheops_Khufu),_Giza,_GG,_EGY_(47850686472).jpg) | Warren LeMay | CC0 |
| clues/cairo/pound.png | [جنيه مصري - 1967 (وجه أمامي).jpg](https://commons.wikimedia.org/wiki/File:%D8%AC%D9%86%D9%8A%D9%87_%D9%85%D8%B5%D8%B1%D9%8A_-_1967_(%D9%88%D8%AC%D9%87_%D8%A3%D9%85%D8%A7%D9%85%D9%8A).jpg) | Braindot4 | CC BY 4.0 |
| clues/colombo/tea.png | [Sri Lanka, Tea plantations, Nuwara Eliya.jpg](https://commons.wikimedia.org/wiki/File:Sri_Lanka,_Tea_plantations,_Nuwara_Eliya.jpg) | Vyacheslav Argenberg | CC BY 4.0 |
| clues/kathmandu/everest.png | [Everest, Himalayas.jpg](https://commons.wikimedia.org/wiki/File:Everest,_Himalayas.jpg) | Vyacheslav Argenberg | CC BY 4.0 |
| clues/kigali/gorilla.png | [Gorilla Portrait.jpg](https://commons.wikimedia.org/wiki/File:Gorilla_Portrait.jpg) | Bradley Gordon | CC BY 2.0 |
| clues/lima/condor.png | [Vultur gryphus head (Linnaeus, 1758).jpg](https://commons.wikimedia.org/wiki/File:Vultur_gryphus_head_(Linnaeus,_1758).jpg) | Michael Gäbler | CC BY 3.0 |
| clues/london/pound_coin.png | [England, Elizabeth I, 1558-1603 - Pound (obverse) - 1969.185.a - Cleveland Museum of Art.jpg](https://commons.wikimedia.org/wiki/File:England,_Elizabeth_I,_1558-1603_-_Pound_(obverse)_-_1969.185.a_-_Cleveland_Museum_of_Art.jpg) | Cleveland Museum of Art | CC0 |
| clues/montreal/beaver.png | [North American Beaver, Humber River near Kleinburg, Ontario (39637607974).jpg](https://commons.wikimedia.org/wiki/File:North_American_Beaver,_Humber_River_near_Kleinburg,_Ontario_(39637607974).jpg) | Vlad Podvorny | CC BY 2.0 |
| clues/moroni/coelacanth.png | [Latimeria Paris.jpg](https://commons.wikimedia.org/wiki/File:Latimeria_Paris.jpg) | sybarite48 | CC BY 2.0 |
| clues/moscow/basil.png | [Moscow - 2025 - Daytime view of St. Basil's Cathedral from Vasilyevsky Spusk.jpg](https://commons.wikimedia.org/wiki/File:Moscow_-_2025_-_Daytime_view_of_St._Basil%27s_Cathedral_from_Vasilyevsky_Spusk.jpg) | Юрий Д.К. | CC BY 4.0 |
| clues/new_delhi/tiger.png | [Tiger-ga7c0f1b70_1280.jpg](https://commons.wikimedia.org/wiki/File:Tiger-ga7c0f1b70_1280.jpg) | andibreit (Pixabay) | CC0 |
| clues/new_york/liberty.png | [Statue of Liberty close-up-NPS.jpg](https://commons.wikimedia.org/wiki/File:Statue_of_Liberty_close-up-NPS.jpg) | National Park Service | Public domain |
| clues/paris/eiffel.png | [Tour Eiffel Wikimedia Commons.jpg](https://commons.wikimedia.org/wiki/File:Tour_Eiffel_Wikimedia_Commons.jpg) | Benh LIEU SONG | Public domain |
| clues/port_moresby/bird_of_paradise.png | [John Collett - Red-Plumed Bird-of-Paradise (Paradisea Apoda Raggiana), Southeastern New Guinea - B1975.4.1810 - Yale Center for British Art.jpg](https://commons.wikimedia.org/wiki/File:John_Collett_-_Red-Plumed_Bird-of-Paradise_(Paradisea_Apoda_Raggiana),_Southeastern_New_Guinea_-_B1975.4.1810_-_Yale_Center_for_British_Art.jpg) | John Collett (Yale Center for British Art) | CC0 |
| clues/reykjavik/arctic_fox.png | [Vulpes lagopus in Iceland.jpg](https://commons.wikimedia.org/wiki/File:Vulpes_lagopus_in_Iceland.jpg) | Jonatan Pie (unsplash.com/@r3dmax) | CC0 |
| clues/rio_de_janeiro/christ.png | [Christ-the-redeemer.jpeg](https://commons.wikimedia.org/wiki/File:Christ-the-redeemer.jpeg) | Grandmaster Huon | CC0 |
| clues/rome/colosseum.png | [Colosseum of Rome, Italy.jpg](https://commons.wikimedia.org/wiki/File:Colosseum_of_Rome,_Italy.jpg) | Wilfredor | CC0 |
| clues/sydney/platypus.png | [Platypus (Ornithorhynchus anatinus). First Description 1799.jpg](https://commons.wikimedia.org/wiki/File:Platypus_(Ornithorhynchus_anatinus)._First_Description_1799.jpg) | Frederick Polydore Nodder | CC0 |
| clues/tokyo/macaque.png | [Macaca fuscata - Zoo Sauvage de Saint-Félicien - 2016-07-19 (2).jpg](https://commons.wikimedia.org/wiki/File:Macaca_fuscata_-_Zoo_Sauvage_de_Saint-F%C3%A9licien_-_2016-07-19_(2).jpg) | Letartean | CC BY 3.0 |
| clues/istanbul/hagia_sophia.png | [Hagia Sophia, Constantinople, Turkey, ca. 1897.jpg](https://commons.wikimedia.org/wiki/File:Hagia_Sophia,_Constantinople,_Turkey,_ca._1897.jpg) | Unknown author (Detroit Publishing Co. photochrom) | Public domain |
| clues/mexico_city/aztec_calendar_stone.png | [Aztec Calendar Stone (8263450477).jpg](https://commons.wikimedia.org/wiki/File:Aztec_Calendar_Stone_(8263450477).jpg) | Rob Young | CC BY 2.0 |
| clues/oslo/viking_ship.png | [Oseberg ship - IMG 9186.jpg](https://commons.wikimedia.org/wiki/File:Oseberg_ship_-_IMG_9186.jpg) | Daderot | Public domain |
| clues/san_marino/three_towers.png | [Towers San Marino.jpg](https://commons.wikimedia.org/wiki/File:Towers_San_Marino.jpg) | Nickel Chromo | Public domain |
| clues/singapore/dollar_coin.png | [10 Dollars of Singapore - Freighter beside Wharf 1976.png](https://commons.wikimedia.org/wiki/File:10_Dollars_of_Singapore_-_Freighter_beside_Wharf_1976.png) | Windrain | CC0 |

## Venue Category Icons

`src/screens/city.lua`'s three venue cards each show a generic icon for
the clue category behind that venue (landmark, currency, language,
geography, wildlife, culture, industry, trait, terminal, generic — see
`src/venue_name.lua`'s `category_for`), never the clue's own photo, so
the card can't spoil the clue before the player investigates. One PNG per
category, white silhouette on transparent background at 64x64, tinted at
draw time via `ui.C.border` (same tint pattern as the panel sprites
above). Source SVGs from [game-icons.net](https://game-icons.net),
CC BY 3.0, rasterized locally with ImageMagick.

| File | Source icon | Author | License |
|---|---|---|---|
| venues/landmark.png | [greek-temple](https://game-icons.net/1x1/delapouite/greek-temple.html) | Delapouite | CC BY 3.0 |
| venues/currency.png | [coins](https://game-icons.net/1x1/delapouite/coins.html) | Delapouite | CC BY 3.0 |
| venues/language.png | [open-book](https://game-icons.net/1x1/lorc/open-book.html) | Lorc | CC BY 3.0 |
| venues/geography.png | [compass](https://game-icons.net/1x1/lorc/compass.html) | Lorc | CC BY 3.0 |
| venues/wildlife.png | [paw-print](https://game-icons.net/1x1/lorc/paw-print.html) | Lorc | CC BY 3.0 |
| venues/culture.png | [drama-masks](https://game-icons.net/1x1/lorc/drama-masks.html) | Lorc | CC BY 3.0 |
| venues/industry.png | [factory](https://game-icons.net/1x1/delapouite/factory.html) | Delapouite | CC BY 3.0 |
| venues/trait.png | [magnifying-glass](https://game-icons.net/1x1/lorc/magnifying-glass.html) | Lorc | CC BY 3.0 |
| venues/terminal.png | [hood](https://game-icons.net/1x1/lorc/hood.html) | Lorc | CC BY 3.0 |
| venues/generic.png | [police-badge](https://game-icons.net/1x1/andymeneely/police-badge.html) | Andy Meneely | CC BY 3.0 |

Icons made by Lorc, Delapouite, and Andy Meneely. Available on
https://game-icons.net.

## Witness Portraits (planned)

`src/screens/venue.lua` shows a portrait next to witness dialogue, sourced
from `assets/images/witnesses/witness_<1-6>.png` (generic pixel-art
characters only — never a specific real person, see CLAUDE.md), picked
deterministically per city/venue. No art exists yet; the screen falls back
to a bordered "?" placeholder, same pattern as the other planned image
slots on this page. Attribution will be listed here once assets are added.

## City Arrival Photos

Shown on the city_info screen when the detective lands in a city, one photo
per city at `assets/images/cities/<city_id>.jpg`, sourced from Wikimedia
Commons under CC0, Public Domain, or CC-BY (never CC-BY-SA, per this
project's license policy). Resized to a max of 900px on the long edge.

| City | Source file | Author | License |
|---|---|---|---|
| athens | [Athens Acropolis at Daybreak.jpg](https://commons.wikimedia.org/wiki/File:Athens_Acropolis_at_Daybreak.jpg) | Andrew Parlette | CC BY 4.0 |
| baghdad | [5628442718 b10fc2c47f o.jpg](https://commons.wikimedia.org/wiki/File:5628442718_b10fc2c47f_o.jpg) | USACE HQ, Jim Gordan | Public domain |
| bamako | [Place de la liberté - Bamako.jpg](https://commons.wikimedia.org/wiki/File:Place_de_la_liberté_-_Bamako.jpg) | Rgaudin | Public domain |
| bangkok | [4Y1A1150 Bangkok (33536339665).jpg](https://commons.wikimedia.org/wiki/File:4Y1A1150_Bangkok_(33536339665).jpg) | Ninara | CC BY 2.0 |
| beijing | [Skyline of Beijing CBD with B-5906 approaching (20211016171955) (1).jpg](https://commons.wikimedia.org/wiki/File:Skyline_of_Beijing_CBD_with_B-5906_approaching_(20211016171955)_(1).jpg) | N509FZ | CC BY 4.0 |
| budapest | [View from Gellért Hill to the Danube, Hungary - Budapest (28493220635).jpg](https://commons.wikimedia.org/wiki/File:View_from_Gellért_Hill_to_the_Danube,_Hungary_-_Budapest_(28493220635).jpg) | Visions of Domino | CC BY 2.0 |
| buenos_aires | [Puerto Madero, Buenos Aires (40689219792) (cropped).jpg](https://commons.wikimedia.org/wiki/File:Puerto_Madero,_Buenos_Aires_(40689219792)_(cropped).jpg) | Deensel | CC BY 2.0 |
| cairo | [Cairo Opera House, Al Hurriyah Park and the Nile river (14797782354).jpg](https://commons.wikimedia.org/wiki/File:Cairo_Opera_House,_Al_Hurriyah_Park_and_the_Nile_river_(14797782354).jpg) | Jorge Láscar | CC BY 2.0 |
| colombo | [Colombo city skyline at night.png](https://commons.wikimedia.org/wiki/File:Colombo_city_skyline_at_night.png) | Gihanud2001 | CC0 |
| istanbul | [Historical peninsula and modern skyline of Istanbul.jpg](https://commons.wikimedia.org/wiki/File:Historical_peninsula_and_modern_skyline_of_Istanbul.jpg) | Hunanuk | CC0 |
| kathmandu | [Kathmandu, Basantapur, Holiday, Nepal.jpg](https://commons.wikimedia.org/wiki/File:Kathmandu,_Basantapur,_Holiday,_Nepal.jpg) | Vyacheslav Argenberg | CC BY 4.0 |
| kigali | [Bustling Nyabugogo - neighborhood of Kigali.jpg](https://commons.wikimedia.org/wiki/File:Bustling_Nyabugogo_-_neighborhood_of_Kigali.jpg) | Francisco Anzola | CC BY 3.0 |
| lima | [Plaza Mayor - Lima, Peru.jpg](https://commons.wikimedia.org/wiki/File:Plaza_Mayor_-_Lima,_Peru.jpg) | WMrapids | CC0 |
| london | [London Thames Sunset panorama - Feb 2008.jpg](https://commons.wikimedia.org/wiki/File:London_Thames_Sunset_panorama_-_Feb_2008.jpg) | Diliff | CC BY 3.0 |
| mexico_city | [Sobrevuelos CDMX HJ2A4913 (25514321687) (cropped).jpg](https://commons.wikimedia.org/wiki/File:Sobrevuelos_CDMX_HJ2A4913_(25514321687)_(cropped).jpg) | Gobierno CDMX | CC0 |
| montreal | [Montreal, Quebec skyline.jpg](https://commons.wikimedia.org/wiki/File:Montreal,_Quebec_skyline.jpg) | Quintin Soloviev | CC BY 4.0 |
| moroni | [Moroni, Comoros.jpg](https://commons.wikimedia.org/wiki/File:Moroni,_Comoros.jpg) | TheLizardQueen | CC BY 2.0 |
| moscow | [Saint Basil's Cathedral and the Red Square.jpg](https://commons.wikimedia.org/wiki/File:Saint_Basil's_Cathedral_and_the_Red_Square.jpg) | U.S. Department of State | Public domain |
| new_delhi | [Statue of Netaji Subhas Chandra Bose, in India Gate Canopy, New Delhi 01.jpg](https://commons.wikimedia.org/wiki/File:Statue_of_Netaji_Subhas_Chandra_Bose,_in_India_Gate_Canopy,_New_Delhi_01.jpg) | Pinakpani | CC BY 4.0 |
| new_york | [Lights of Rockefeller Center during sunset.jpg](https://commons.wikimedia.org/wiki/File:Lights_of_Rockefeller_Center_during_sunset.jpg) | Pedro Lastra | CC0 |
| oslo | [Oslo Opera House - 2025.jpg](https://commons.wikimedia.org/wiki/File:Oslo_Opera_House_-_2025.jpg) | Pierre Blaché | CC0 |
| paris | [Champ de Mars from the Eiffel Tower - July 2006 edit.jpg](https://commons.wikimedia.org/wiki/File:Champ_de_Mars_from_the_Eiffel_Tower_-_July_2006_edit.jpg) | Diliff, edited by Fir0002 | CC BY 2.5 |
| port_moresby | [Port Moresby Town2 Mschlauch.jpg](https://commons.wikimedia.org/wiki/File:Port_Moresby_Town2_Mschlauch.jpg) | MSchlauch | Public domain |
| reykjavik | [Reykjavik Hallgrimskirkja church (1413324848).jpg](https://commons.wikimedia.org/wiki/File:Reykjavik_Hallgrimskirkja_church_(1413324848).jpg) | michael clarke stuff | Public domain |
| rio_de_janeiro | [Christ-Redeemer-Rio-de-Janeiro.jpg](https://commons.wikimedia.org/wiki/File:Christ-Redeemer-Rio-de-Janeiro.jpg) | acediscovery | CC BY 4.0 |
| rome | [Trevi Fountain, Rome, Italy 2 - May 2007.jpg](https://commons.wikimedia.org/wiki/File:Trevi_Fountain,_Rome,_Italy_2_-_May_2007.jpg) | Diliff | CC BY 3.0 |
| san_marino | [Cesta in San Marino taken from Guaita.jpg](https://commons.wikimedia.org/wiki/File:Cesta_in_San_Marino_taken_from_Guaita.jpg) | San Marino S | CC0 |
| singapore | [Merlion (I).jpg](https://commons.wikimedia.org/wiki/File:Merlion_(I).jpg) | Supanut Arunoprayote | CC BY 4.0 |
| sydney | [MC Sydney Opera House.jpg](https://commons.wikimedia.org/wiki/File:MC_Sydney_Opera_House.jpg) | Christian Mehlführer | CC BY 2.5 |
| tokyo | [Minato City, Tokyo, Japan.jpg](https://commons.wikimedia.org/wiki/File:Minato_City,_Tokyo,_Japan.jpg) | David Kernan | CC BY 4.0 |
