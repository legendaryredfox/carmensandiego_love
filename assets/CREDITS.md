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

## Clue Images (planned)

Country-specific images sourced from Wikimedia Commons under CC0 or CC-BY.
Full attribution per image will be listed here as assets are added.
Flags are NEVER used as clue images (see CLAUDE.md).

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
