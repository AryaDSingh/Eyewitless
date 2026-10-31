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
| `envelope` | Hand holding an envelope "To Detective" (the player clicks it) |
| `clue_blurry_photo_felix` | Also used as a card: the blurry photo zooming in on Felix |
| `clue_pigeon_photo` | Also used as a card: Felix's photo of the pigeon |
| `pigeon_omg` | The pigeon caught: "O.M.G.!!" |
| `pigeon_closeup` | Close-up of the pigeon, wide-eyed and sweating |
| `camera_intro` | Detective holding the camera from Arya |
| `pigeon_prison` | Pigeon in a cage; Arya and the Detective outside |
| `pigeon_cries` | Pigeon shouting, tears in its eyes |
| `pigeon_hat` | The pigeon in its hat, covering its bald head |
| `case_solved` | CASE SOLVED! stamp (red) |

## Letters — 1600×860
Draw **only the paper**: the game writes the letter text on top, so the
wording can change without redrawing.

| Name | What it shows |
|---|---|
| `welcome_letter` | Welcome letter paper (it unrolls) |
| `arya_letter` | Arya's letter paper. The blurry photo is pinned top right by the game (`clue_blurry_photo`), so leave room for it |

## Title screen — 1920×1080
`title_screen`: background behind the EYEWITLESS title and the START / Settings buttons.

## HUD
`companion_pigeon` (160×200, transparent): the pigeon in its hat, shown bottom left once it joins you.

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
| `townie_alex` | 260×560 | Park. Alex, the walker with **5** dogs |
| `prop_alex_dogs` | 460×160 | Alex's 5 dogs |
| `townie_dog_walker_1` | 220×520 | Walker with 1 dog ("NO!") |
| `townie_marwan` | 220×520 | Marwan with his 2 "capybaras" (Patagonian maras) |
| `townie_dog_walker_3` | 220×520 | Walker with a big pack of dogs (they bark) |
| `townie_felix` | 260×560 | Bar |
| `townie_bartender` | 240×560 | Bar |
| `townie_duck` | 200×180 | Pond (used 3 times) |
| `townie_plaza_1`, `townie_plaza_2` | 200×480 | Plaza people |
| `townie_pigeon_1` … `_6` | 150×190 | Plaza pigeons (wrong answers) |
| `townie_pigeon_7` | 150×190 | **The culprit.** Must match `clue_pigeon_photo`, but look close enough to the others that it's a puzzle |

## Portraits in the dialogue box and notebook — 300×300
`portrait_detective`, `portrait_arya`, `portrait_alex`, `portrait_marwan`, `portrait_felix`, `portrait_pigeon`

## Clue photos (notebook) — 4:3, e.g. 1100×825
| Name | What it shows |
|---|---|
| `clue_blurry_photo` | Arya's blurry photo of the scarf moment |
| `clue_blurry_photo_felix` | Same photo with Felix, small, behind Arya |
| `clue_pigeon_photo` | Felix's photo of the culprit pigeon |

## UI art (Ruby, Option 2) — in `art/ui/`
These are already in the game. To change one, save over the file with the same name.

| File(s) | Used for |
|---|---|
| `title_logo` | EYEWITLESS logo on the title screen |
| `btn_primary`, `_hover`, `_pressed`, `_disabled` | Dark buttons (START, choices, Next). They stretch to fit the text, so keep a plain middle |
| `btn_tag`, `_hover`, `_pressed` | Light buttons (Settings, Mute, notebook tabs) |
| `btn_close` | Close on the map and notebook ("Close ✕" is drawn in) |
| `dialogue_box`, `_thought`, `_no_portrait` | Dialogue panel. The game puts the portrait, the name (on the tape) and the text on fixed spots, so **keep new versions the same size and layout**. Spots are listed in `BOXES` in `scripts/dialogue_box.gd` |
| `bubble_speech_left`, `_right`, `bubble_shout` | Bubbles over people. Left = their reply, right = the Detective asking, shout = all-caps lines like "NO!" |
| `icon_notebook`, `icon_map`, `icon_camera` + `icon_bg`, `_new`, `_highlight` | HUD icons. `_new` until first clicked, `_highlight` when something new is inside |
| `pin_*` + `pin_box_*` (goto, unlocked, visited, locked) | Map pins. The game split each pin from its label box so the box can stretch to the place name |
| `photo_frame`, `photo_frame_unknown` | Residents and clue photos in the notebook; "?" for people not met yet |
| `stamp_solved` | SOLVED stamp on a solved case (also `art/case_solved.png`, the end card) |

Not used yet: `bubble_thought`, `icon_bg_locked`, `btn_primary_small_icon`, `btn_tag_small_icon`.

**Fonts** (`ui/fonts/`, free, OFL licence): Caveat Brush for buttons, pins and photo captions; Patrick Hand for everything else.

## Character art in the game (Samantha)
Cut out of the sheets in the team Drive, one figure per file:
`townie_arya`, `portrait_arya`, `townie_felix`, `portrait_felix`, `townie_marwan`, `portrait_marwan`,
`townie_dog_walker_1` (the cat walker), `townie_duck_1` … `_4`, `plaza_pigeons` (the whole crowd: each
pigeon is an invisible click spot on top, see `scenes/locations/plaza.tscn`), THE Pigeon as
`townie_pigeon_7`, `clue_pigeon_photo`, `portrait_pigeon`, `companion_pigeon`, `pigeon_omg`,
`pigeon_closeup`, `pigeon_cries`, plus `envelope`, `pigeon_prison`, `notebook_book` (notebook background,
pages filled in white) and `clue_blurry_photo` / `_felix` (the incident drawing, blurred, Felix circled).

Still grey boxes: Alex and her 5 dogs, the Detective's portrait, walker 3 (big pack), the bartender,
the plaza people, all backgrounds and the map, the letters' paper, and the cards `pigeon_hat`,
`camera_intro`.
