# Eyewitless: everything that changed since the first prototype

**From:** the first playable prototype, commit `4b15516` (22 Oct 2026), before
Ruby's UI art and Samantha's character art.
**To:** the latest web build (`builds/eyewitless_web.zip`, 31 Oct 2026). This is
commit `6002ed0` plus the office start and the higher ducks, which are not
committed yet.

Use this to update the team documents (TDD, script, art list, audio list). All
dialogue below is copied from `resources/cases/case_01.story` and the scene
files, so it matches the game word for word.

Contents:
1. [Big-picture changes](#1-big-picture-changes)
2. [Story flow, old vs new](#2-story-flow-old-vs-new)
3. [Full dialogue, as in the game now](#3-full-dialogue-as-in-the-game-now)
4. [Click-to-talk lines (bubbles)](#4-click-to-talk-lines-bubbles)
5. [Detective hints when stuck (nudges)](#5-detective-hints-when-stuck-nudges)
6. [Voice acting](#6-voice-acting)
7. [Characters and notebook text](#7-characters-and-notebook-text)
8. [Audio files](#8-audio-files)
9. [Art files](#9-art-files)
10. [UI and how the game feels](#10-ui-and-how-the-game-feels)
11. [Scenes and layout](#11-scenes-and-layout)
12. [Code, tools and docs](#12-code-tools-and-docs)
13. [Removed or replaced](#13-removed-or-replaced)
14. [Still missing / known gaps](#14-still-missing--known-gaps)
15. [Added after that web build](#15-added-after-that-web-build)

---

## 1. Big-picture changes

- **New script.** The Case 1 dialogue follows the new script
  ("Script - Scenes 1-4: Arya's welcome" and Case 1 scenes 1-32).
- **Debbie is now Alex.** All lines, notes, the clue text, the art names and
  the story flags use Alex.
- **Arya is "he".** His character description and Alex's line use he/his.
- **A new resident: Marwan.** He is the walker in the park with his
  "capybaras" (Patagonian maras).
- **The pigeon has a name and a voice.** He is Jason Lee Elliott, a cockney
  pigeon. Arya voices him in 10 recorded lines.
- **No explicit hints.** The on-screen objective text, the hint commands and the
  "New clue!" pop-ups are gone. Players find their way, and the Detective only
  thinks out loud after 25 s of being stuck (see section 5).
- **Ruby's UI art (Option 2)** is in: buttons, dialogue boxes, bubbles, HUD
  icons, map pins, photo frames, SOLVED stamp, title logo.
- **Samantha's character art** is in: Arya, Felix, Marwan, the cat walker, 4
  ducks, the plaza pigeon crowd, Jason (several poses), the envelope, prison,
  notebook background and the clue photos.
- **Sound.** Background loops, sound effects, the pigeon's voice, a typing
  tick, and an Options panel (sound on/off, volumes). Music files exist but are turned off.
- **The game starts in the Detective's office.** The player finds the flower
  shop on the map themselves (new in the last build).
- **Playtest logs upload to Google Drive** at the end of a playthrough.
- **Web build for itch.io.** It starts with one click in the browser.

## 2. Story flow, old vs new

**Old (prototype):** title card → welcome letter → envelope → Arya's letter →
"keep it in my notebook" card → notebook → **auto-travel to the flower shop** →
Arya → park (Debbie) → bar (Felix) → pond (ducks card) → Felix → plaza → find
the pigeon → CASE SOLVED card → **auto-travel to Arya** → camera → prison and
pigeon cards → 100 hours of community service → notebook → "It's getting
dark…" THE END card.

**New (now):**
1. Title screen (START, Settings with volume sliders).
2. **Envelope.** The player clicks the envelope itself (no button) → envelope
   sound.
3. **Welcome letter** unrolls (NEXT).
4. **Arya's letter** unrolls, with the blurry photo pinned on it (NEXT).
5. The Detective's first thought → choice **ADD TO NOTEBOOK** → the notebook
   opens on Case 1.
6. **The player is in the office.** Only the flower shop is on the map, and the
   map icon glows.
7. **Flower shop.** Walking in the first time starts Arya's scene ("HEY YOU!").
   The park unlocks.
8. **Park.** Ask the cat walker ("NO!"), Marwan (not Alex), and Alex. Alex
   shows the blurry photo with Felix circled. The bar unlocks.
9. **Bar.** Felix. Picking "… 75 kg…?" is a detour that leads back. The pond
   unlocks.
10. **Pond.** The Detective sees only ducks ("Damn it, Felix!!"). The map icon
    glows.
11. **Bar again.** Felix says the ducks are undercover and gives his photo of the
    pigeon (ADD TO NOTEBOOK). The plaza unlocks.
12. **Plaza.** A crowd of pigeons. The player opens Felix's photo in the notebook
    and presses **HOLD IT UP** to compare. Clicking the right pigeon (the bald
    one in the crowd) → O.M.G.!! card → close-up → Jason speaks → GO SEE ARYA.
13. **Flower shop.** Arya's gift (TAKE THE CAMERA) → camera card → pigeon prison
    and crying cards → Jason begs (voiced) → 1000 hours of social service →
    hat card → "We oughta get home" → "what's your name?" → "Jason. Jason Lee
    Elliott."
14. The pigeon joins the HUD as a companion → **case solved**: the notebook opens,
    the SOLVED stamp slams down with a sound and the case is crossed out.
15. End of game (the playtest log uploads).

Changes in that flow worth noting for the docs:
- Jason's exchange now happens **before** the SOLVED animation, right after the
  pigeon says to go home. There is no black screen.
- "100 hours of community service" is now **"1000 hours of social service"**.
- The old "CASE SOLVED!" card, the "pond_ducks" card, the "notebook_intro" card
  and the "night_hint" THE END card are gone. The notebook stamp replaces the
  solved card.

## 3. Full dialogue, as in the game now

Format: **Speaker:** line. *Italics* = the Detective thinking.
`[CHOICE]` = a button the player picks. `(card: …)` = a full-screen picture.
`(voice: file)` = the recorded line that plays.

### Letters
(card: `envelope`, clicked to open)

**Welcome letter** (button NEXT; the town's neat handwriting, cursive greeting and signature, red town stamp):
> *Dear Detective,*
>
> Welcome to **Muddleford**, where everyone knows everyone… or thinks they do.
>
> Witnesses here have **questionable memories**. Ask **questions**, collect
> **evidence**, and keep your **notebook** handy.
>
> One last thing: **keep an eye on the time**. Muddleford gets strange **after
> dark**.
>
> Good luck. You'll need it.
> *The people of Muddleford* (signature) + stamp "MUDDLEFORD · EST. ????"

**Arya's letter** (button NEXT, blurry photo pinned; Arya's scribbly handwriting, cursive greeting and signature):
> *Dear Detective,*
> I need your help. Immediately. A pigeon pooped on my favourite scarf. MY
> FAVOURITE SCARF! Do you have any idea how hard it is to find a scarf that
> looks this good? And what do I get in return? A pigeon attack. In broad
> daylight. In front of everyone!
> There is a photo of the incident, but it's a little blurry. Still, look at it!
> That bird is out there somewhere, probably ruining someone else's day. Find
> that pigeon! I refuse to let this feathered criminal get away with it.
> P.S. I've heard pigeons are surprisingly difficult to tell apart. I hope you
> can find the right one.
>
> *Arya* (signature)
> the owner of one now deeply unfortunate scarf

### Office
- **Detective:** *Really? Is this my first case? Anyway, I should keep the photo.*
- [CHOICE] ADD TO NOTEBOOK → the notebook opens on Case 1.

### Flower shop: first visit (plays when you walk in)
Arya is angry and holding the ruined scarf for this whole talk.
- **Arya:** HEY YOU!
- [CHOICE] You are the guy in the photo!
- **Arya:** Help me find that pigeon!
- [CHOICE] How can I? I am new here, and your photo doesn't help at all.
- **Arya:** Find Alex; they took another photo. They were with Felix when everything
  happened. It was my favourite scarf. What am I gonna do now? Find that pigeon!
- [CHOICE] I don't know either of them. How can I find them?
- **Arya:** Talk with Alex; I think they are walking their dogs at the park.
- [CHOICE] FIND ALEX → the notebook opens on Arya's page; the park unlocks.

Clicking Arya later:
- Before Alex: **Arya:** Talk with Alex; I think they are walking their dogs at the park.
- After Alex: **Arya:** Find that pigeon!

### Park
**Sam (the cat walker):**
- **Detective:** Are you Alex?
- (shout bubble) NO!

**Marwan:**
- **Detective:** Are you Alex?
- **Marwan:** No! I'm Marwan; these are my capybaras!
- **Detective:** Wait, aren't these Patagonian maras... never mind.

**Alex:**
- **Detective:** Are you Alex?
- **Alex:** Hi! I'm Alex!
- **Alex:** Who are you?
- **Detective:** I am helping Arya find the pigeon that pooped on his scarf.
- **Alex:** OK.
- **Detective:** He told me you took a photo of it.
- **Alex:** Yeah, but I don't know anything about the pigeons. You can ask Felix;
  he was there too. I gave him the photo.
- (card: `clue_blurry_photo_felix`, text *Alex: "Felix!"*, grows in) → new clue.
- **Detective:** Where is he?
- **Alex:** If it's 11 am, probably getting drunk at the bar!
- The bar unlocks. Clicking Alex again repeats their last line.

### Bar: Felix
First time:
- **Detective:** You were in the photo where Arya's scarf got pooped on…
- **Felix:** *Pigeons are spies…* \*hic\* hey, how much do you weigh?
- [CHOICE] I need to find a pigeon / [CHOICE] … 75 kg…?

If "… 75 kg…?" (a detour, not a fail):
- **Felix:** Hmmm, you need to eat healthy. Do you exercise? I exercise; pigeons
  fly.
- [CHOICE] Anyway, back to pigeons

Then:
- **Detective:** Alex gave you a photo of it; where is it?
- **Felix:** The photo? \*hic\* I don't remember; the pigeon spying in the park..
  Mhh, no, it was in the pond!
- The pond unlocks. Clicking Felix again: **Felix:** The pond! It was in the pond!

### Pond (plays when you arrive the first time)
- **Detective:** *THESE ARE DUCKS!*
- **Detective:** *Damn it, Felix!!*

### Bar: Felix again (after the pond)
- **Detective:** Felix, those are ducks!
- **Felix:** Hmmm, they're probably undercover. \*hic\* The real ones are in the
  plaza. I actually have a photo of the pigeon.
- [CHOICE] ACCEPT THE PHOTO
- (card: `clue_pigeon_photo`, *Felix's photo of the pigeon.*, ADD TO NOTEBOOK)
- The plaza unlocks. Clicking Felix again: **Felix:** The real ones are in the plaza!

### Plaza: catching the pigeon
- (Click the right pigeon) (card: `pigeon_omg`, *O.M.G.!!*) (card: `pigeon_closeup`)
- **Pigeon:** Wot?! Me, mate? I ain't done nuffin', guv! (voice: `voice_pigeon_wot_me`)
- [CHOICE] GO SEE ARYA

### Flower shop: the ending
- **Arya:** HA! That'll teach you to mess with my scarf, you feathered menace!
  Oh, Detective, you've made my day! I have a gift for you. CAMERA!
- [CHOICE] TAKE THE CAMERA → the camera appears on the HUD.
- (card: `camera_intro`)
- **Arya:** You can explore the town and take photos of the clues with it. (And if
  a pigeon looks suspicious, get its good side, for the wanted poster!)
- **Detective:** Thanks! Now what do we do with the pigeon?
- **Arya:** Let's send the pigeon to pigeon prison.
- (card: `pigeon_prison`) (card: `pigeon_cries`)
- **Pigeon:** OI! NO! Give us a chance, guv! (voice: `voice_pigeon_oi_no`)
- **Pigeon:** I'll 'elp ya out with yer cases, I will! (voice: `voice_pigeon_elp_ya`)
- **Pigeon:** An' trust me, you don't wanna be out on yer tod after dark, guv.
  (voice: `voice_pigeon_trust_me`)
- **Pigeon:** Town gets proper dodgy. You'll be needin' a mate like me, innit!
  (voice: `voice_pigeon_dodgy`)
- **Arya:** OK. You do 1000 hours of social service; help the Detective solve cases!
- **Pigeon:** Fair enough, guv. You got yerself a deal! (voice: `voice_pigeon_deal`)
- **Arya:** And wear a hat to cover your bald head…
- (card: `pigeon_hat`)
- **Pigeon:** *Yeah, yeah, take the mick, why don't ya…* (voice: `voice_pigeon_mick`)
- **Pigeon:** We oughta get home, guv. You don't want to be out here at night.
  (voice: `voice_pigeon_home`)
- **Detective:** By the way, what's your name?
- **Pigeon:** My name is Jason. Jason Lee Elliott. (voice: `voice_pigeon_jason`)
- His name tag says "The Pigeon" until this line, then "Jason".
- The pigeon joins the HUD. Case solved: the notebook opens with the SOLVED stamp.

Clicking the pigeon in the flower shop afterwards: bubble *Coo, guv.*
(voice: `voice_pigeon_coo_guv`).

## 4. Click-to-talk lines (bubbles)

Clicking someone without a story scene gives a quick exchange. The **Detective's
question shows in the dialogue box** at the bottom (so it's clear who is
talking). The **reply is a bubble** over the person or animal. Lines separated
by `/` play one per click, and the last one repeats.

| Where | Who | Detective asks | Reply |
|---|---|---|---|
| Park | Alex's dogs | — / Who's a good witness? / Did you see a pigeon? / Sit! | Woof! / WOOF! / \*chases own tail\* / \*all five sit on Alex\* |
| Bar | Bartender | Seen any pigeons? / …In your soup? / What's good here? / Is Felix always like this? | Only in my soup. / Kidding. It's chicken. Probably. / The door. / Only when he's awake. |
| Pond | Duck 1 | — / Is there a pigeon in this pond? | Quack! / Quack. (No.) |
| Pond | Duck 2 | — / Are you sure? | QUACK! / QUACK. (Very sure.) |
| Pond | Duck 3 | — | Quack? / \*stares at you judgementally\* |
| Pond | Duck 4 | — | Quack. / \*paddles away from the question\* |
| Plaza | Townie 1 | Seen a pigeon? | Which one?! |
| Plaza | Townie 2 | Seen a pigeon? | Ugh, pigeons. |
| Plaza | Pigeons 1–8, 10, 11 | — | Who? Me! · Marwan · Not me! · Coo. · Brrr-roo? · Coo coo. · \*flap flap\* · It's MY scarf! (the one wearing a scarf) · Brrr. · \*pecks the ground\* |
| Flower shop | Jason (after the case) | — | Coo, guv. |

Sounds with the replies: dogs bark, ducks quack, plaza pigeons coo; Jason's
reply plays his recorded "Coo, guv".

## 5. Detective hints when stuck (nudges)

After **25 s** with nothing new happening (no dialogue, notebook, map or card
open), the Detective thinks out loud. Each step has a vague thought, then a
clearer one, then nothing more. These replace the old explicit hint text.

| Stage | First thought | Second thought |
|---|---|---|
| Office, before the flower shop | *Arya's letter. Where would someone that obsessed with a scarf be?* | *The map. I should find the flower shop.* |
| Find Alex | *Arya said something about a park…* | *Alex walks their dogs at the park. Where's that map…* |
| Find Felix | *11 am… Alex said Felix would be somewhere by now.* | *Getting drunk at the bar, they said. Charming.* |
| Go to the pond | *A pigeon. In a pond. Sure, Felix.* | *The pond. It should be on the map now.* |
| After the ducks | *Ducks. Felix owes me an explanation.* | *Back to the bar. Felix has some explaining to do.* |
| Go to the plaza | *"The real ones are in the plaza." Undercover ducks. Right.* | *The plaza. That's where the pigeons hang out.* |
| At the plaza | *So many pigeons. If only I had a picture of the guilty one…* | *Felix's photo is in my notebook. I could hold it up next to them.* |

## 6. Voice acting

Jason (the pigeon) is voiced by Arya. Recordings were made 31 Oct 2026 (OBS,
`C:\Users\arya_\Videos\eyewitless\`). Each was converted to `.ogg`, trimmed of
silence, and its volume evened out. A voice line stops when the player clicks
on, and the typing tick stays quiet while a voice plays.

| File (`audio/`) | Line | Recording used |
|---|---|---|
| `voice_pigeon_wot_me` | Wot?! Me, mate? I ain't done nuffin', guv! | 15-15-56 |
| `voice_pigeon_oi_no` | OI! NO! Give us a chance, guv! | 15-17-14 |
| `voice_pigeon_elp_ya` | I'll 'elp ya out with yer cases, I will! | 15-53-54 (replaced 15-17-58) |
| `voice_pigeon_trust_me` | An' trust me, you don't wanna be out on yer tod after dark, guv. | 15-58-06 (replaced 15-33-08 and 15-47-34) |
| `voice_pigeon_dodgy` | Town gets proper dodgy. You'll be needin' a mate like me, innit! | 15-34-39 (noise at the end cut) |
| `voice_pigeon_deal` | Fair enough, guv. You got yerself a deal! | 15-18-29 |
| `voice_pigeon_mick` | Yeah, yeah, take the mick, why don't ya… | 15-18-43 |
| `voice_pigeon_home` | We oughta get home, guv. You don't want to be out here at night. | 15-18-58 |
| `voice_pigeon_jason` | My name is Jason. Jason Lee Elliott. | 15-20-29 |
| `voice_pigeon_coo_guv` | Coo, guv. (clicking him in the flower shop) | 15-19-11 |

Script lines changed to match the recordings or the new cockney voice:
- "Wot?! Me?" → "Wot?! Me, **mate**?"
- "Jason." → "My name is Jason. Jason Lee Elliott."
- "I'll 'elp ya with yer cases" → "I'll 'elp ya **out** with yer cases"
- The long line "OI! NO! Give us a chance, guv! I'll 'elp ya with yer cases, I
  will! Although you don't want to be alone at night, the town gets creepy; you
  will definitely need some help!" is now **four** lines (one per recording).
  The last part was rewritten in cockney.

## 7. Characters and notebook text

From `resources/characters.json`:

| Character | Role | Description | Notebook | Where on map |
|---|---|---|---|---|
| Arya | Florist · Client | Runs the flower shop. Loves his scarf more than most people. | Yes | Flower shop |
| Alex (was Debbie) | Dog walker | Walks five dogs at the park. Took another photo of the scarf incident and gave it to Felix. | Silhouette until met (stand-in shape) | Park |
| Marwan (**new**) | Walker with "capybaras" | Walks his pets at the park. Insists they're capybaras. | Silhouette from the start | Park |
| Felix | Aquarium seller | Spends his mornings at the bar. Thinks pigeons are spies. Not reliable. | Silhouette until met (Arya mentions him) | Bar |
| Jason ("The Pigeon" until he says his name) | Culprit · Your new partner | Pooped on Arya's scarf. Very sorry about it. Mostly. | "?" until caught | Flower shop |
| Detective | You | — | Not shown (no portrait, so any player fits) | — |

Notes the game writes into the notebook as you play:
- **Arya:** Says Alex took another photo, and was with Felix when it happened. /
  Says Alex is walking their dogs at the park.
- **Alex:** Arya says they took another photo, and walk their dogs at the park. /
  Doesn't know anything about the pigeons. Says Felix was there too, and they
  gave him the photo. / Says Felix is probably at the bar at 11 am.
- **Marwan:** Not Alex. Says his pets are capybaras (they're Patagonian maras).
- **Felix:** Arya says he was there when it happened. / He's in the blurry photo,
  right behind Arya. / Says the pigeon was at the pond. / The pond only had
  ducks. Felix was wrong. / Says the real pigeons are in the plaza. Gave you a
  photo of the pigeon.
- **Pigeon:** Doing 1000 hours of social service: helping you solve cases.

Case 1, "The Scarf Incident" (`resources/cases/case_01.json`):
- The one-line summary was replaced by **"From Arya's letter:"** with three
  points: *A pigeon pooped on Arya's favourite scarf, in broad daylight, in front
  of everyone.* / *Arya's photo of it is blurry.* / *Pigeons are hard to tell
  apart.*
- Clues:
  - `blurry_photo`: "Arya's blurry photo of the incident." (was "Debbie's blurry
    photo…")
  - `felix_in_photo`: "Alex spotted Felix in the photo, right behind Arya."
  - `pigeon_photo`: "Felix's photo of the pigeon. Find this pigeon at the plaza!"
    (unchanged)

## 8. Audio files

All in `audio/`. Full sources and licences are in `docs/AUDIO_LIST.md`. Overall
volume is halved; the player sets Music and Sounds volume on the title screen.

**Background loops** (fade in and out per place):
| File | Where | On? | Source |
|---|---|---|---|
| `amb_bar.mp3` | Bar | Yes | "Busy bar and restaurant ambience…", jadeallencook, Pixabay #339222 (replaced BigSoundBank #0480) |
| `amb_plaza.mp3` | Plaza | Yes | "Ambiente Plaza 01", robertomikihiro, Pixabay #460479 (replaced BigSoundBank #0526) |
| `amb_park.ogg` | Park | Off | BigSoundBank #0544, CC0 |
| `amb_pond.ogg` | Pond | Off | BigSoundBank #0691, CC0 |

**Music** (all turned off for now): `music_title.ogg`, `music_town.ogg` (both
OpenGameArt "Cozy Puzzle", CC0), `music_bar.mp3` ("Drunken Saloon", CC0; it
plays muffled at the bar).

**Sound effects:**
| File | When | Source |
|---|---|---|
| `sfx_envelope_open.ogg` | Envelope clicked | BigSoundBank #1225 |
| `sfx_paper_unroll.ogg` | Map opens (cut to 1.67 s, a third shorter) | BigSoundBank #1251 |
| `sfx_page_turn.ogg` | Notebook opens or flips | BigSoundBank #0362 |
| `sfx_stamp.ogg` | SOLVED stamp | BigSoundBank #1410 |
| `sfx_pigeon_coo.ogg` | Plaza pigeons | BigSoundBank #0841 |
| `sfx_pigeon_wings.ogg` | Arriving at the plaza, catching Jason | BigSoundBank #0840 |
| `sfx_duck_quack.ogg` | Pond arrival, ducks | BigSoundBank #0276 |
| `sfx_dog_bark.ogg` | Alex's dogs | BigSoundBank #2954 |
| `sfx_text_tick.ogg` | Soft tick every 3 letters while dialogue types | Made in code (no licence needed) |

**Voices:** the 10 `voice_pigeon_*` files in section 6.

Rules: only one sound effect plays at a time, so they never pile up. Voices
and the typing tick have their own channels, so an effect doesn't cut them off.
The **Options** gear sits top left on every screen (sound on/off, music and sound volume).

## 9. Art files

All in `art/` (UI in `art/ui/`). The full list with sizes is in `docs/ART_LIST.md`.

**Samantha, characters and cards (in the game):**
`townie_arya`, `portrait_arya`, `townie_felix`, `portrait_felix`,
`townie_marwan`, `portrait_marwan`, `townie_dog_walker_1` (cat walker),
`townie_duck_1`–`_4`, `plaza_pigeon_*` (the crowd as separate pigeons, see section 15), `townie_pigeon_7` (Jason),
`portrait_pigeon`, `companion_pigeon`, `pigeon_omg` (transparent, from
`townie_pigeon_7`), `pigeon_closeup`, `pigeon_cries`, `pigeon_prison`,
`envelope`, `envelope_back` / `envelope_letter` / `envelope_front` (layers,
ready but not used yet), `notebook_book` (outside made see-through),
`clue_blurry_photo`, `clue_blurry_photo_felix` (Felix circled in red),
`clue_pigeon_photo` (the flapping pigeon), `case_solved`.

**Ruby, UI (Option 2):** `title_logo`, `btn_primary*`, `btn_tag*`, `btn_close`,
`dialogue_box`, `dialogue_box_no_portrait`, `dialogue_box_thought`,
`bubble_speech_left`, `bubble_speech_right`, `bubble_shout`, `bubble_thought`,
`icon_notebook`, `icon_map`, `icon_camera`, `icon_bg*`, `pin_*`, `pin_box_*`,
`photo_frame`, `photo_frame_unknown`, `stamp_solved`.
- **Edited:** the "→" was cut out of `dialogue_box` and
  `dialogue_box_no_portrait` into its own file, `dialogue_arrow`, so it can
  animate.

**Made by us as stand-ins:** `marwan_silhouette` (filled from his portrait),
`alex_silhouette` (plain head and shoulders).

**Fonts** (`ui/fonts/`, OFL): Caveat Brush (buttons, pins, captions), Patrick
Hand (everything else).

## 10. UI and how the game feels

**Title screen** (new): logo, START, Settings with Music and Sounds sliders.

**Cards** (full-screen pictures):
- Letters unroll, and their text is written on the paper by the game.
- The envelope is clicked directly, and lifts and tilts under the mouse. The
  layered "letter slides out" version is built, waiting for Samantha's layers.
- Photos sit in a white polaroid frame and grow in.
- O.M.G.!! and the ending cards pop in.

**Dialogue box:**
- Ruby's box art. The Detective has **no portrait**, so any player fits, and
  their thoughts are in italics.
- The text types out with a quiet tick sound.
- A "→" nudges in the corner when you can click on.
- Click, Space or Enter continues. A second click on the **same** thing within
  **1 s** is ignored, so spam-clicking does nothing; clicking something
  different only waits 0.25 s (so you can click a person right after talking).

**Clicking people and things:**
- They lift slightly on hover and squash on click.
- The Detective's questions show in the dialogue box; replies show as bubbles in
  front of everything (HUD too) and stay on screen.

**HUD** (top left):
- Options (gear), Notebook, Map; later Camera and the pigeon companion.
- New things show as a glow and a count badge on the icon, not as text pop-ups.
  Only the map glows when a place opens.
- The camera does nothing yet (it wiggles); its system comes in Case 2.

**Map:**
- Samantha's town map with taped paper name labels beside each building (see
  section 15), "you are here", and polaroid stickers of the residents you've met
  at each place.
- Locked places show as ???. The "Click a place to go there." text is gone.
- Opening the map plays a shorter paper sound.

**Travelling:** a short paper-coloured fade when you arrive somewhere.

**Notebook:**
- Samantha's book art (no white box behind it).
- Cases tab: the case page with "From Arya's letter" points and the clue polaroids.
- Residents tab: polaroids, 3 per row; silhouettes for people heard of but not
  met; "?" frames for strangers.
- Long pages split into pages with `<` `1 / 2` `>` and a page-turn sound.
  Headings never get left alone at the bottom of a page.
- Click a clue to zoom in. **HOLD IT UP** puts the photo on screen next to the
  scene (how you compare pigeons at the plaza). The page arrows no longer show
  over a zoomed clue.
- **Case solved:** the SOLVED stamp slams down (slowed to half speed) with a thud,
  and the case is crossed out.

## 11. Scenes and layout

- **Office:** where the game starts. It has nothing to click yet (background missing).
- **Flower shop:** Arya; Jason appears beside Arya after the case. Arya's scene
  plays on the first visit.
- **Park:** down to **3 people**: the cat walker ("NO!"), Marwan, and Alex with
  their 5 dogs. Walker2 and Walker3 were removed.
- **Bar:** bartender and Felix. The room-chatter loop plays.
- **Pond:** 4 ducks (was 3), moved **20% higher** so the dialogue box doesn't
  cover them.
- **Plaza:** 2 townies and 11 separate pigeons (see section 15); the culprit is
  the bald pigeon. The new
  ambience plays.

## 12. Code, tools and docs

New story commands (in `.story` files): `voice`, `tool` (show a HUD icon),
`sfx`, `wait`, `end_game`, plus card options (`letter`, `photo=`, `framed`,
`grow`, `pop`, `stamp`, `click`, `pull=`).

New scripts:
- `scripts/audio.gd`: sounds, volumes, mute and the click cooldown.
- `scripts/polaroid.gd`: framed photos.
- `scripts/title_screen.gd`.

Bigger changes:
- `scripts/main.gd`: nudges, the arrival fade, Detective questions in the dialogue box.
- `scripts/notebook.gd`: pages, residents, the stamp, letter points, silhouettes.
- `scripts/card_screen.gd`.
- `scripts/dialogue_box.gd`: box layouts, the arrow, the tick.
- `scripts/hotspot.gd`: lines that change with each click, hover and squash.
- `scripts/hud.gd`, `scripts/map_screen.gd`, `scripts/map_pin.gd`,
  `scripts/event_log.gd`: the Drive upload.

Characters can now set `"silhouette": true` (shown as a silhouette from the
start), `"silhouette_art"` (a stand-in shape) and `"location"` (for map stickers).
Hotspot `ask` / `bubble` take several lines split by `|`.

**Playtest logs:** `tools/playtest_upload.gs` (Google Apps Script) and
`docs/PLAYTEST_UPLOAD.md`. At the end of a run, the log goes to the team Drive
folder, numbered in the order it arrives.

**Automated playthrough test** (`tests/playthrough_test.gd`): plays Case 1 start
to finish and checks layout overlaps, spam clicks, notebook page fit, nudges,
the office start, the bartender's second joke and the continue arrow. It can
save screenshots.

**Web export:** single-threaded with sample audio, so it runs on itch.io without
special headers. The audio buses are in `default_bus_layout.tres`.

Docs:
- New: `docs/AUDIO_LIST.md`, `docs/PLAYTEST_UPLOAD.md`, this file.
- Updated: `docs/ART_LIST.md`, `docs/STORY_FORMAT.md`.

## 13. Removed or replaced

- Debbie (all of it) → Alex. Walker2 and Walker3 in the park.
- The on-screen objective text, hint pop-ups, "New clue in your notebook!" /
  "Notebook updated" / "New place on your map!" toasts, the map's "Click a place
  to go there." line.
- Cards: `title_screen` (now a real title screen), `notebook_intro`,
  `pond_ducks`, `night_hint` (THE END). `case_solved` is no longer shown as a
  card in the story (the notebook stamp replaces it).
- The old Arya, Debbie, Felix and ending dialogue (see the prototype file at commit
  `4b15516` if needed), including "AH!!! BLAH!!!", Felix's opening "Hic! A
  detective! In MY bar!", and the 100 hours of community service.
- Auto-travel to the flower shop at the start (now the player goes there).
- The old plaza crowd sound (`amb_plaza.ogg`, BigSoundBank #0526) and bar chatter (`amb_bar.ogg`, BigSoundBank #0480).
- The torn-photo-halves idea (dropped for this prototype).

## 14. Still missing / known gaps

- **Art still grey boxes:**
  - Backgrounds: all 6 places (`bg_*`).
  - `title_screen`.
  - `townie_bartender`, `townie_plaza_1` and `_2`.
  - Cards: `camera_intro`, `pigeon_hat`.
- **Envelope layers** are in `art/` but not switched on (the "letter slides out" version).
- **Italics** for thoughts don't show, because the font has no italic style.
- **Music** is off everywhere; the park and pond loops are off.
- **The camera** does nothing yet (Case 2).
- **Not committed yet:** the office start and the higher ducks are in the
  latest web build but not in a git commit.

## 15. Added after that web build

Not in `builds/eyewitless_web.zip` until the next build.

**Story and characters**
- **Alex uses they/them.** Every line and note about Alex was changed, e.g.
  "Find Alex; they took another photo. They were with Felix…", "I think they are
  walking their dogs at the park", "Getting drunk at the bar, they said." The
  Detective's office hint now says "**His** shop can't be far" (Arya is he).
- **Angry Arya.** The first talk in the flower shop (HEY YOU! until FIND ALEX)
  shows Arya holding the ruined scarf, angry, in the shop and in the dialogue
  box. After FIND ALEX he goes back to holding flowers.
- **Sam, a new resident:** the cat walker. Clicking Sam: the Detective asks "Are
  you Alex?", Sam shouts "NO!". Notebook: *Cat walker. Walks two cats on leads
  at the park. Is definitely not Alex.* Note: *Not Alex. Very sure about that.*
  Sam shows as a silhouette until met, and on the map at the park.
- **Sober Felix.** Back at the bar after the pond, Felix is drawn without the
  drunk bubbles (when he hands over the photo).
- **Plaza joke:** the pigeon wearing a scarf now says *"It's MY scarf!"* (it's a
  wrong suspect; the culprit is still the bald pigeon).

**Art now in the game** (from Samantha's Drive folder, 31 Oct)
- `townie_arya_mad`, `portrait_arya_mad`.
- `townie_alex` (Alex tangled in five dog leads, replaces the grey Alex and dogs
  boxes), `alex_standing` (notebook page), `portrait_alex`.
- `marwan_standing` (notebook page, without his pets), `townie_felix_sober`,
  `portrait_sam`.
- `plaza_pigeon_1` … `_12` (no 10): the plaza crowd as separate pigeons, each
  placed where it was in the crowd picture, so each one bounces on hover.
- `map_bg`: Samantha's town map. **The pins are gone:** each place has its name on a
  small taped paper label next to its building (so the drawing stays visible),
  and clicking the label or the building travels there. Locked places show a
  faded "???" label. "Muddleford" is on a strip of paper taped over the map's
  top edge.
- `welcome_letter`, `arya_letter`: the letter paper. The text sits inside the
  paper and the blurry photo is pinned over its right edge.
- Removed: the stand-in `alex_silhouette` (Alex's silhouette now comes from the
  real portrait).

**UI**
- **Notebook resident pages** show the whole figure, with the name and
  description beside it (team feedback: heads were cropped).
- **Clicks and hover only count on the drawing,** not the see-through corners
  of a picture, so overlapping pigeons each get their own clicks.
- **New places on the map** get a red pen circle drawn around them as the map
  opens, and its label hops twice; it stays still afterwards and disappears once
  visited.
- **Bar ambience** replaced (see section 8).
- **Handwritten letters.** The welcome letter is in the town's neat hand (Kalam),
  with a cursive "Dear Detective," and a cursive "The people of Muddleford"
  signature (Mrs Saint Delafield) plus a red town stamp, "MUDDLEFORD · EST. ????".
  Arya's letter is in his scribbly hand (Caveat), with a cursive "Dear Detective,"
  and a signed "Arya" (Dancing Script) above "the owner of one now deeply
  unfortunate scarf". New fonts in `ui/fonts/` (all OFL, licence files included).

**Review pass fixes** (after a three-part review: code, visuals, story/docs)
- Text: "favourite" everywhere; missing full stops; "OK."; "11 am"; "By the way";
  "Anyway, back to pigeons"; the Detective (not Arya) asks "Now what do we do with
  the pigeon?"; the Detective asks Felix about the photo *Alex gave him*; Felix's
  nutrition rant is no longer red; two stuck-hints corrected (office, pond).
- Buttons: single actions in capitals (NEXT, HOLD IT UP); the welcome letter's
  button is NEXT (another letter follows). The NEXT button stays at the same
  height on every card.
- Close buttons on the map and notebook are taped paper labels.
- Notebook: darker neutral dim behind it; the open tab is the raised one; the
  SOLVED stamp is red and stamped over the case title (it no longer pushes the
  page down); headings share one style; roles in grey; wide drawings (Sam) are
  shrunk so the text beside them fits.
- Letters: a gap between paragraphs and more room at the sides; the stamp's star
  is drawn (fonts have no ★, which would show as a box on web).
- Speech bubbles: the text starts below the tape, with more padding.
- The dialogue box is a little wider than the screen, so characters behind it
  don't peek out at the ends.
- Park: the dogs' click spots sit either side of Alex, so Alex's legs are
  clickable. Map: hovering a building highlights its label.
- Tests: real mouse clicks can't reach the game window during the automated
  test (the cause of two flaky checks); Sam's notebook page is checked too.
- Clicking someone right after a conversation no longer hits the 1 s spam
  cooldown: that only applies to repeat clicks on the same thing.
- **People and animals stand 20% higher** in the park, bar, plaza and flower
  shop (the pond's ducks already were), so the dialogue box doesn't hide them.
  (A version where the scene slid up during dialogue was tried and dropped: it
  was disorienting for one-line exchanges.) Backgrounds should put the ground
  at this new height. Speech bubbles stay below the HUD icons.
- **Options instead of Mute:** a drawn gear on a taped paper square (top left)
  opens a taped sheet with Sound on/off and the Music and Sounds volumes. The
  title screen's Settings opens the same sheet.
- **Notebook:** clicking a case quickly no longer flashes the clue photos from
  page 2.
