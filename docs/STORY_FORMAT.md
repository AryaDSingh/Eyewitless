# Writing story files

All dialogue and story steps live in `resources/cases/case_01.story`, a plain
text file. You can change what people say, add lines or add choices without
touching code. Run the game (or the test, below) to check your change.

## The basics

```
# Lines starting with # are notes for the team. The game ignores them.

=== felix_question
Felix: Pigeons are spies, you know... How much do you weigh, detective?
* I'm here for pigeons! -> felix_pond
* ...60kg? -> felix_nonsense
```

| You write | What happens |
|---|---|
| `=== name` | Starts a **knot**: a named chunk of story. Hotspots and choices point at knots by name. |
| `Name:`~ note alex | text` | A dialogue line. `Name` must be in `resources/characters.json` (or `Detective`). |
| `text` | A line with no speaker (narration). |
| `* text -> knot` | A choice button on the line above it. Picking it jumps to that knot. |
| `-> knot` | Jump straight to another knot. |
| `~ command` | Make something happen (see below). |

Write `\n` inside a card's text for a new line. Dialogue text can use
`[i]italics[/i]` (thoughts, whispers) and `[color=#c22]red[/color]` (nonsense).

**Tip:** put `~` commands *above* a dialogue line that has choices, not between
the line and its choices.

## Commands

| Command | What it does |
|---|---|
| `~ card art_name \| text \| button \| options` | Full-screen picture with text and a button. Use `none` for no picture. Options are optional, see below. |
| `~ goto park` | Moves the detective to a location. |
| `~ unlock park` | Adds a place to the map (the map button flashes). |
| `~ case_open case_01` / `~ case_solve case_01` | Shows a case in the notebook / strikes it through as solved. |
| `~ clue clue_id` | Adds a clue to its case in the notebook (clues are listed in `case_01.json`). |
| `~ meet alex` | Unlocks a character's page in the notebook. |
| `~ note alex | text`\| text` | Writes what someone said on their notebook page. |
| `~ notebook case_01 \| Button`~ note alex | text` | Opens the notebook on a page and waits for the player to close it. |
| `~ hint`~ note alex | text` | Sets the objective shown at the top of the screen. `~ hint` alone clears it. |
| `~ blink notebook` / `~ blink map` | Flashes a button until it's clicked. |
| `~ bubble Alex | Hi!`\| Hi!` | Speech bubble above a hotspot in the current scene. |
| `~ hold_photo clue_id` / `~ hold_photo off` | Shows a photo in the corner ("Find this!"). |
| `~ set flag` / `~ unset flag` | Remembers (or forgets) that something happened. |
| `~ if flag -> knot` | Jumps if the flag is set. `~ if !flag -> knot` jumps if it isn't. |
| `~ log event_name` | Writes an extra event to the playtest log. |
| `~ wait 1.5` | Pauses for that many seconds. |
| `~ end_game` | Shows the end screens and saves the playtest log. |
| `~ sfx sound_name` | Plays a sound from `audio/` (see docs/AUDIO_LIST.md). A new sound cuts off the last one. |
| `~ tool notebook` | Shows a HUD tool: `notebook`, `map`, `camera`, or `pigeon` (the companion). They start hidden. |

### Card options

Add words after the button text, separated by spaces:

| Option | What it does |
|---|---|
| `letter` | The text is written on the picture, like a letter. It shrinks to fit. |
| `photo=clue_blurry_photo` | Pins a small photo on a letter. |
| `click` | No button: the player clicks the picture (leave the button text empty). |
| `unroll` | The picture unrolls from the top. |
| `pop` | The picture pops in. |
| `stamp` | The picture slams down like a stamp. |
| `zoom` / `zoom=0.7,0.4` | Slowly zooms in, on the middle or on that spot (0,0 top left, 1,1 bottom right). |

Example: `~ card envelope | To Detective | | click pop`

## Clicks

Hotspots, buttons and dialogue ignore clicks that come less than 1 second
after the last one, so players can't spam them. Change `CLICK_COOLDOWN` in
`scripts/audio.gd`.

Opening a clue in the notebook sets the flag `viewed_<clue_id>`, so the story
can check whether the player has looked at it (`~ if viewed_felix_in_photo -> knot`).

## Checking your changes

The automated test plays the whole case and reports anything broken, such as a
choice that points at a knot that doesn't exist:

```
godot --headless --path . res://tests/playthrough_test.tscn
```
