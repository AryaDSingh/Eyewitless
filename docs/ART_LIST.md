# Art list for Case 1

Every grey box in the game has a name written on it. To replace a box with real
art, save a **PNG** with exactly that name into the `art/` folder (for example
`art/bg_park.png`). It shows up the next time you run the game, with no code changes.

**Rules**
- Lowercase names with underscores, exactly as listed below.
- PNG with a transparent background for characters, pigeons, ducks and props.
- The game screen is **1920×1080**. Backgrounds should be that size (or larger,
  same shape). Other sizes below are what the box is on screen; art is scaled to
  fit, so drawing bigger than that is fine, but keep the same proportions.
- To move or resize something in a scene, open the scene in Godot
  (`scenes/locations/…`) and drag it. Each clickable thing is a *Hotspot*.

## Cards (full-screen moments) — 1200×620
| Name | What it shows |
|---|---|
| `title_screen` | Game title art (EYEWITLESS) |
| `welcome_letter` | Welcome letter to Muddleford |
| `envelope` | Hand holding an envelope "To Detective" |
| `arya_letter` | Arya's letter, with the blurry photo |
| `notebook_intro` | Detective with the notebook ("I must keep it in my notebook") |
| `pond_ducks` | The pond — just ducks |
| `pigeon_omg` | The pigeon caught: "O.M.G!!" |
| `case_solved` | CASE SOLVED! stamp |
| `camera_intro` | The camera gift |
| `pigeon_prison` | Pigeon in a cage, detective and Arya |
| `pigeon_cries` | Crying pigeon: "NO! I'll help you with cases!" |
| `night_hint` | Town getting dark (teaser for night) |

## Backgrounds — 1920×1080
| Name | Location |
|---|---|
| `bg_office` | Detective office |
| `bg_flower_shop` | Arya's flower shop |
| `bg_park` | Park |
| `bg_bar` | Bar |
| `bg_pond` | Pond in the park |
| `bg_plaza` | Plaza |
| `map_bg` | Town map of Muddleford |

## Characters standing in scenes (transparent PNG)
| Name | Size on screen | Notes |
|---|---|---|
| `townie_arya` | 280×600 | Flower shop |
| `townie_debbie` | 260×560 | Park |
| `prop_debbie_dogs` | 460×160 | Debbie's dogs |
| `townie_dog_walker_1` … `_3` | 220×520 | The "NO!" dog walkers |
| `townie_felix` | 260×560 | Bar |
| `townie_bartender` | 240×560 | Bar |
| `townie_duck` | 200×180 | Pond (used 3 times) |
| `townie_plaza_1`, `townie_plaza_2` | 200×480 | Plaza people |
| `townie_pigeon_1` … `_6` | 150×190 | Plaza pigeons (wrong answers) |
| `townie_pigeon_7` | 150×190 | **The culprit.** Must match `clue_pigeon_photo`, but look close enough to the others that it's a puzzle |

## Portraits in the dialogue box and notebook — 300×300
`portrait_detective`, `portrait_arya`, `portrait_debbie`, `portrait_felix`, `portrait_pigeon`

## Clue photos (notebook) — 4:3, e.g. 1100×825
| Name | What it shows |
|---|---|
| `clue_blurry_photo` | Debbie's blurry photo of the scarf moment |
| `clue_blurry_photo_felix` | Same photo with Felix circled |
| `clue_pigeon_photo` | Felix's photo of the culprit pigeon |
