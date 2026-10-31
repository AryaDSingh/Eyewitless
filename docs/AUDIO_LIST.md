# Audio list

Every sound lives in `audio/` and is played by name, like art. To replace a
sound, save a new file with exactly the same name (`.ogg`, `.mp3` or `.wav`).
A missing file is skipped, so the game still runs.

- Music and background loops play per location. Set them on the location
  scene in Godot (`music`, `ambience`, `muffle_music` in the Inspector).
- Only one sound effect plays at a time; a new one cuts the old one off.
- There are no voices: dialogue is text only.
- Volumes are set by the player on the title screen (Settings). The Mute
  button sits top left on every screen. Overall volume is halved
  (`MASTER_VOLUME` in `scripts/audio.gd`).

## Music (loops)
**Turned off for now.** The files are still here. To turn one back on, set
`music` on a location scene (and `Audio.play_music("music_title")` in
`scripts/title_screen.gd` for the title).

| Name | Where | Source |
|---|---|---|
| `music_title` | Title screen and letters | "Cozy Puzzle Title", OpenGameArt, CC0 |
| `music_town` | Flower shop, park, pond, plaza | "Cozy Puzzle In-Game 2", OpenGameArt, CC0 |
| `music_bar` | Bar (muffled, as if through a wall) | "Drunken Saloon", OpenGameArt, CC0 |

## Background loops
**Only `amb_bar` is on for now.** Set `ambience` on a location scene to use the others.

| Name | Where | Source |
|---|---|---|
| `amb_park` | Park | BigSoundBank #0544 "Lecocq garden", CC0, first 60 s |
| `amb_pond` | Pond | BigSoundBank #0691 "Pond in a field", CC0, first 60 s, louder |
| `amb_plaza` | Plaza (crowd) | BigSoundBank #0526 "Pedestrian place", CC0, first 60 s |
| `amb_bar` | Bar (room chatter) | BigSoundBank #0480 "Atmosphere bar", CC0, 60 s |

## Sound effects
| Name | When | Source |
|---|---|---|
| `sfx_paper_unroll` | Welcome letter unrolls, map opens | BigSoundBank #1251 "Newspaper manipulations", CC0, trimmed |
| `sfx_envelope_open` | Envelope clicked | BigSoundBank #1225 "Torn and creased page", CC0, trimmed |
| `sfx_page_turn` | Notebook opens | BigSoundBank #0362 "Great page that turns", CC0 |
| `sfx_pigeon_coo` | Clicking a plaza pigeon | BigSoundBank #0841 "Pigeons fighting", CC0, 1.5 s cut |
| `sfx_pigeon_wings` | Arriving at the plaza, catching the pigeon | BigSoundBank #0840 "Flight of a pigeon", CC0 |
| `sfx_duck_quack` | Pond, clicking a duck | BigSoundBank #0276 "Ducks", CC0, trimmed |
| `sfx_stamp` | SOLVED stamp in the notebook | BigSoundBank #1410 "Closed book", CC0, trimmed to the thud |
| `sfx_dog_bark` | Big pack of dogs, Alex's dogs | BigSoundBank #2954 "Barking dog #2", CC0, trimmed |

CC0 means no credit is required, but it's listed here so the team knows where
each sound came from. Links: https://opengameart.org and https://bigsoundbank.com
