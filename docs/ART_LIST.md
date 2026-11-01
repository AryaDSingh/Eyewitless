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
| `clue_torn_right` | Also used as a card: Alex's half of the photo, Felix circled |
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
| `welcome_letter` | Welcome letter paper (it unrolls). Samantha's paper is portrait-shaped; the game writes the text inside whatever shape is drawn |
| `arya_letter` | Arya's letter paper. The game pins Arya's half of the photo (`clue_torn_left`) over the paper's right edge |

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
| `map_bg` | Town map of Muddleford. Each place's taped name label sits next to its building, and the building itself is clickable (`building` on each pin in `ui/map_screen.tscn`), so update those if the map changes |

## Characters standing in scenes (transparent PNG)
| Name | Size on screen | Notes |
|---|---|---|
| `townie_arya` | 280×600 | Flower shop |
| `townie_alex` | 800×575 | Park. Alex tangled in the leads of their **5** dogs (one picture; the dogs have their own invisible click spot) |
| `townie_dog_walker_1` | 490×390 | Regina, the cat walker ("NO!") |
| `townie_marwan` | 220×520 | Marwan with his 2 "capybaras" (Patagonian maras) |
| `townie_felix` | 260×560 | Bar (drunk) |
| `townie_felix_sober` | 260×560 | Bar, after the pond |
| `townie_arya_mad` | 290×600 | Flower shop, first talk: Arya holding the ruined scarf |
| `townie_bartender` | 240×560 | Bar |
| `townie_duck_1` … `_4` | 200×180 | Pond, four ducks |
| `townie_plaza_1`, `townie_plaza_2` | 200×480 | Plaza people |
| `plaza_pigeon_1` … `_12` (no 10) | as drawn | Plaza pigeons, each its own click spot, placed where they were in the crowd picture. `plaza_pigeon_9` wears a scarf (a wrong suspect) |
| `plaza_pigeon_11` | as drawn | **The culprit** (`ScarfPigeon` in `plaza.tscn`). Must match `clue_pigeon_photo` |

## Portraits in the dialogue box and notebook — 300×300
`portrait_arya`, `portrait_alex`, `portrait_marwan`, `portrait_felix`, `portrait_pigeon`

Plus `portrait_arya_mad` (first talk) and `portrait_regina`.

Full-body drawings on the notebook pages (`full_body` in `resources/characters.json`):
`townie_arya`, `alex_standing`, `marwan_standing`, `townie_felix`, `townie_dog_walker_1` (Regina), `companion_pigeon`.

Silhouettes (black shapes in the notebook before you meet someone) come from the portrait;
`marwan_silhouette` is filled in by hand because his portrait is outline-only.

## Clue photos (notebook) — 4:3, e.g. 1100×825
| Name | What it shows |
|---|---|
| `clue_torn_left` | Arya's half of the torn photo (Samantha's `photo-left`) |
| `clue_torn_right` | Alex's half (`photo-right`), Felix circled in red. `clue_torn_*` photos show without the white frame |
| `clue_pigeon_photo` | Felix's photo of the culprit pigeon |

## UI art (Ruby, Option 2) — in `art/ui/`
These are already in the game. To change one, save over the file with the same name.

| File(s) | Used for |
|---|---|
| `title_logo` | EYEWITLESS logo on the title screen |
| `btn_primary`, `_hover`, `_pressed`, `_disabled` | Dark buttons (START, choices, Next). They stretch to fit the text, so keep a plain middle |
| `btn_tag`, `_hover`, `_pressed` | Light buttons (Settings, Sound on/off, notebook tabs) |
| `icon_options` | The Options gear (top left), drawn for the game in the HUD icons' style, on `icon_bg` |
| `btn_close` | Not used any more: Close is now a taped paper label drawn by the game |
| `dialogue_box`, `_thought`, `_no_portrait` | Dialogue panel. The game puts the portrait, the name (on the tape) and the text on fixed spots, so **keep new versions the same size and layout**. Spots are listed in `BOXES` in `scripts/dialogue_box.gd` |
| `dialogue_arrow` | The "→" in the bottom right, cut out of the box art so it can nudge when a line is done. Leave it off new box pictures |
| `bubble_speech_left`, `bubble_shout` | Bubbles over people for their replies; shout = all-caps lines like "NO!". (The Detective's questions use the dialogue box, so `bubble_speech_right` is not used.) |
| `icon_notebook`, `icon_map`, `icon_camera` + `icon_bg`, `_new`, `_highlight` | HUD icons. `_new` until first clicked, `_highlight` when something new is inside |
| `camera_viewfinder` | Looking through the camera (1920×1080, transparent middle). Date changed to an impossible one |
| `pin_*` + `pin_box_*` (goto, unlocked, visited, locked) | Not used any more: the map now uses taped paper name labels drawn by the game |
| `photo_frame`, `photo_frame_unknown` | Residents and clue photos in the notebook; "?" for people not met yet |
| `stamp_solved` | SOLVED stamp on a solved case (also `art/case_solved.png`, the end card) |

Not used yet: `bubble_speech_right`, `bubble_thought`, `dialogue_box_thought`, `icon_bg_locked`, `btn_primary_small_icon`, `btn_tag_small_icon`.

**Fonts** (`ui/fonts/`, free, OFL licence): Caveat Brush for buttons, labels and photo captions; Patrick Hand for everything else.
Letters are handwritten: Kalam (the town's neat hand), Caveat (Arya's scribble), and cursive for the
"Dear Detective," and signatures: Mrs Saint Delafield (the town), Dancing Script (Arya). The red
"MUDDLEFORD · EST. ????" stamp on the welcome letter is drawn by the game.

## Character art in the game (Samantha)
Cut out of the sheets in the team Drive, one figure per file:
`townie_arya`, `portrait_arya`, `townie_felix`, `portrait_felix`, `townie_marwan`, `portrait_marwan`,
`townie_dog_walker_1` (Regina the cat walker), `townie_duck_1` … `_4`, `plaza_pigeon_*` (the crowd as
separate pigeons), `townie_arya_mad`, `townie_alex`, `alex_standing`, `marwan_standing`,
`townie_felix_sober`, `map_bg`, the letter paper, `portrait_alex`, `portrait_regina` and `portrait_arya_mad`
(cut from the figures), THE Pigeon as `townie_pigeon_7` (source of `pigeon_omg`), `clue_pigeon_photo`, `portrait_pigeon`, `companion_pigeon`, `pigeon_omg`,
`pigeon_closeup`, `pigeon_cries`, plus `envelope`, `pigeon_prison`, `notebook_book` (notebook background,
pages filled in white) and `clue_torn_left` / `_right` (the torn photo halves, Felix circled).

Not used any more: `plaza_pigeons` (the old one-picture crowd), `prop_alex_dogs`.
Not used (yet): `photo-left` / `photo-right` (torn photo halves, dropped for this prototype).

Still grey boxes: the bartender, the plaza people, all location backgrounds, the title screen,
and the cards `pigeon_hat`, `camera_intro`.
