# Eyewitless

*Everyone saw something. Nobody saw it right.*

A comedic detective puzzle game set in the illustrated town of Muddleford. Match photo clues to locations, survive the night, and work out which unreliable witnesses to believe.

Team Solenodon — DMED503 Game Design, 2026.

## Getting started

1. Install **Godot 4.7.2** (standard build, not .NET) from [godotengine.org](https://godotengine.org/download/archive/4.7.2-stable/). Everyone uses this version.
2. Install [Git LFS](https://git-lfs.com) and run `git lfs install` once.
3. Clone this repo and open the folder in Godot (Import → select `project.godot`).
4. Press **F5** (or the ▶ button) to play Case 1.

## How the game is put together

- **Story and dialogue:** `resources/cases/case_01.story`, a plain text file anyone
  can edit. See [docs/STORY_FORMAT.md](docs/STORY_FORMAT.md).
- **Case, clue and character data:** `resources/cases/case_01.json` and
  `resources/characters.json`.
- **Locations:** one scene each in `scenes/locations/`. Clickable people and
  things are *Hotspots*; drag them around in the editor.
- **Art:** every grey box is named. Save a PNG with that name in `art/` and it
  replaces the box. Full list: [docs/ART_LIST.md](docs/ART_LIST.md).
- **UI screens:** `ui/` (dialogue box, notebook, map, cards, HUD). Colours and
  fonts are in `ui/theme.tres`.

## Playtesting

Every click, choice and screen is logged with a timestamp (one JSON object per line),
so we can measure the CDD's success metrics. On desktop the log is saved in Godot's
user data folder under `playtest_logs/`. In the web build, the last screen has a
**Download playtest log** button, and **F9** downloads it at any time.

To make a web build: **Project → Export → Web → Export Project** (Godot asks to
download export templates the first time). Upload `builds/web/` to itch.io.

## Automated test

Plays the whole of Case 1 and checks every step still works. Run it before
opening a pull request:

```
godot --headless --path . res://tests/playthrough_test.tscn
```

## Project layout

| Folder | Contents |
|---|---|
| `scenes/` | Scenes (`.tscn`) |
| `scripts/` | Shared GDScript (`.gd`) |
| `resources/cases/` | Case scripts (`.story`) and case data (`.json`) |
| `art/` | Sprites, backgrounds, UI art (stored via LFS) |
| `audio/` | Music and SFX (stored via LFS) |
| `ui/` | UI scenes and themes |

## Workflow

- `main` always runs. Work on a branch per feature, e.g. `feature/frame-lock`.
- One owner per scene — don't edit someone else's `.tscn` without asking.
- Open a pull request; one teammate reviews before merging.
- Code style: [official GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html).
- Done = runs in the web build and a teammate has played it.

Design docs (CDD, TDD) live in the team Google Drive and Notion.
