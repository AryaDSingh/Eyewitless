# Eyewitless

*Everyone saw something. Nobody saw it right.*

A comedic detective puzzle game set in the illustrated town of Muddleford. Match photo clues to locations, survive the night, and work out which unreliable witnesses to believe.

Team Solenodon — DMED503 Game Design, 2026.

## Getting started

1. Install **Godot 4.x** (standard build, not .NET). Everyone uses the same version: `[pin version here]`.
2. Install [Git LFS](https://git-lfs.com) and run `git lfs install` once.
3. Clone this repo and open the folder in Godot (Import → select `project.godot`).

## Project layout

| Folder | Contents |
|---|---|
| `scenes/` | Scenes (`.tscn`) |
| `scripts/` | Shared GDScript (`.gd`) |
| `resources/cases/` | Case data resources (`.tres`) |
| `art/` | Sprites, backgrounds, UI art (stored via LFS) |
| `audio/` | Music and SFX (stored via LFS) |
| `ui/` | UI scenes and themes |

## Workflow

- `main` always runs. Work on a branch per feature, e.g. `feature/frame-lock`.
- One owner per scene — don't edit someone else's `.tscn` without asking.
- Open a pull request; one teammate reviews before merging.
- Code style: [official GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html).
- Done = runs in the web build and a teammate has played it.

Design docs (CDD, TDD) live in the team Notion.
