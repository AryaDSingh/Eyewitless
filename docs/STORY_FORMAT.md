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
| `Name: text` | A dialogue line. `Name` must be in `resources/characters.json` (or `Detective`). |
| `text` | A line with no speaker (narration). |
| `* text -> knot` | A choice button on the line above it. Picking it jumps to that knot. |
| `-> knot` | Jump straight to another knot. |
| `~ command` | Make something happen (see below). |

Write `\n` inside a card's text for a new line.

**Tip:** put `~` commands *above* a dialogue line that has choices, not between
the line and its choices.

## Commands

| Command | What it does |
|---|---|
| `~ card art_name \| text \| button` | Full-screen picture with text and a button. Use `none` for no picture. |
| `~ goto park` | Moves the detective to a location. |
| `~ unlock park` | Adds a place to the map (the map button flashes). |
| `~ case_open case_01` / `~ case_solve case_01` | Shows a case in the notebook / strikes it through as solved. |
| `~ clue clue_id` | Adds a clue to its case in the notebook (clues are listed in `case_01.json`). |
| `~ meet debbie` | Unlocks a character's page in the notebook. |
| `~ note debbie \| text` | Writes what someone said on their notebook page. |
| `~ notebook case_01 \| Button text` | Opens the notebook on a page and waits for the player to close it. |
| `~ hint text` | Sets the objective shown at the top of the screen. `~ hint` alone clears it. |
| `~ blink notebook` / `~ blink map` | Flashes a button until it's clicked. |
| `~ bubble Debbie \| Hi!` | Speech bubble above a hotspot in the current scene. |
| `~ hold_photo clue_id` / `~ hold_photo off` | Shows a photo in the corner ("Find this!"). |
| `~ set flag` / `~ unset flag` | Remembers (or forgets) that something happened. |
| `~ if flag -> knot` | Jumps if the flag is set. `~ if !flag -> knot` jumps if it isn't. |
| `~ log event_name` | Writes an extra event to the playtest log. |
| `~ wait 1.5` | Pauses for that many seconds. |
| `~ end_game` | Shows the end screens and saves the playtest log. |

Opening a clue in the notebook sets the flag `viewed_<clue_id>`, so the story
can check whether the player has looked at it (Debbie does this).

## Checking your changes

The automated test plays the whole case and reports anything broken, such as a
choice that points at a knot that doesn't exist:

```
godot --headless --path . res://tests/playthrough_test.tscn
```
