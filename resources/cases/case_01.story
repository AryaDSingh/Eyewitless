# Case 1: The Scarf Incident (tutorial)
# How this file works: docs/STORY_FORMAT.md
# Follows "Script - Scenes 1-4: Arya's welcome" and Case 1 scenes 1-32:
# letters -> Arya -> park (Alex) -> bar (Felix) -> pond (ducks!) -> back to
# Felix -> plaza (find the pigeon) -> Arya's gift -> pigeon joins -> solved.
# The title screen (Part 1) is ui/title_screen.tscn; START plays this file.


# --- Parts 2-4: the letters --------------------------------------------------

=== start
~ log tutorial_start
# When Samantha's separate layers arrive: ~ card envelope_back | | | pull=envelope_letter,envelope_front pop
~ card envelope | | | click pop
~ sfx sfx_envelope_open
~ card welcome_letter | Dear Detective,\n\nWelcome to [b]Muddleford[/b], where everyone knows everyone… or thinks they do.\n\nWitnesses here have [b]questionable memories[/b]. Ask [b]questions[/b], collect [b]evidence[/b], and keep your [b]notebook[/b] handy.\n\nOne last thing: [b]keep an eye on the time[/b]. Muddleford gets strange [b]after dark[/b].\n\nGood luck. You'll need it.\n— The people of Muddleford | START GAME | letter unroll
~ card arya_letter | Dear Detective,\nI need your help. Immediately. A pigeon pooped on my favourite scarf. MY FAVOURITE SCARF! Do you have any idea how hard it is to find a scarf that looks this good? And what do I get in return? A pigeon attack. In broad daylight. In front of everyone!\nThere is a photo of the incident, but it's a little blurry. Still, look at it! That bird is out there somewhere, probably ruining someone else's day. Find that pigeon! I refuse to let this feathered criminal get away with it.\nP.S. I've heard pigeons are surprisingly difficult to tell apart. I hope you can find the right one.\n\n— Arya, the owner of one now deeply unfortunate scarf | NEXT | letter unroll photo=clue_blurry_photo
-> first_case


# --- Scenes 1-2: first case, notebook ----------------------------------------

=== first_case
Detective: [i]Really? Is this my first case? Anyway, I should keep the photo.[/i]
* ADD TO NOTEBOOK -> notebook_intro

=== notebook_intro
~ case_open case_01
~ clue blurry_photo
~ tool notebook
~ tool map
~ notebook case_01
~ goto flower_shop
-> arya_intro


# --- Scenes 3-5: Arya, residents, map ----------------------------------------
# Each line the player picks is a choice, and what Arya answers goes in the
# notebook (the note is at the top of the next knot, after she's said it).

=== arya_intro
~ meet arya
Arya: HEY YOU!
* You are the guy in the photo! -> arya_help

=== arya_help
Arya: Help me find that pigeon!
* How can I? I am new here, and your photo doesn't help at all. -> arya_alex

=== arya_alex
Arya: Find Alex; she took another photo. She was with Felix when everything happened. It was my favorite scarf. What am I gonna do now? Find that pigeon!
* I don't know either of them. How can I find them? -> arya_park

=== arya_park
~ note felix | Arya says he was there when it happened.
~ note arya | Says Alex took another photo, and was with Felix when it happened.
Arya: Talk with Alex; I think she is walking her dogs at the park
* FIND ALEX -> arya_send_off

=== arya_send_off
~ note arya | Says Alex is walking her dogs at the park.
~ note alex | Arya says she took another photo, and walks her dogs at the park.
~ notebook arya
~ unlock park
~ set find_alex

=== arya_talk
~ if alex_done -> arya_felix
Arya: Talk with Alex; I think she is walking her dogs at the park

=== arya_felix
Arya: Find that pigeon!


# --- Scenes 6-9: the park, finding Alex --------------------------------------
# Walker 1 ("NO!", the cat walker) is a bubble set on its
# hotspots in scenes/locations/park.tscn. Marwan and Alex play knots.

=== marwan_talk
~ meet marwan
Detective: Are you Alex?
Marwan: No! I'm Marwan; these are my capybaras!
Detective: Wait, aren't these Patagonian maras... never mind.
~ note marwan | Not Alex. Says his pets are capybaras (they're Patagonian maras).

=== alex_talk
~ if alex_done -> alex_after
~ meet alex
Detective: Are you Alex?
Alex: Hi! I'm Alex!
Alex: Who are you?
Detective: I am helping Arya find the pigeon that pooped on his scarf.
Alex: ok
Detective: He told me you took a photo of it.
Alex: Yeah, but I don't know anything about the pigeons. You can ask Felix; he was there too. I gave him the photo.
~ note alex | Doesn't know anything about the pigeons. Says Felix was there too, and she gave him the photo.
~ card clue_blurry_photo_felix | Alex: "Felix!" | Next | framed grow
~ clue felix_in_photo
~ note felix | He's in the blurry photo, right behind Arya.
Detective: Where is he?
Alex: If it's 11:00 am, probably getting drunk at the bar!
~ note alex | Says Felix is probably at the bar at 11:00 am.
~ set alex_done
~ unlock bar

=== alex_after
Alex: If it's 11:00 am, probably getting drunk at the bar!


# --- Scenes 10-14: the bar, Felix --------------------------------------------

=== felix_talk
~ if got_pigeon_photo -> felix_after
~ if saw_ducks -> felix_ducks
~ if pond_lead -> felix_reminder
~ if felix_met -> felix_question
~ set felix_met
~ meet felix
Detective: You were in the photo where Arya's scarf got pooped on…
-> felix_question

=== felix_question
Felix: [i]Pigeons are spies…[/i] *hic* hey, how much do you weigh?
* I need to find a pigeon -> felix_pond
* … 75 kg…? -> felix_nonsense

# The wrong answer is a detour, not a fail: it leads back to the pigeon.
=== felix_nonsense
~ log felix_nonsense_branch
Felix: [color=#c22]Hmmm, you need to eat healthy. Do you exercise? I exercise; pigeons fly[/color]
* There, back to pigeons -> felix_pond

=== felix_pond
Detective: You took a photo of it; where is it?
Felix: The photo? *hic* I don't remember; the pigeon spying in the park.. Mhh, no, it was in the pond!
~ note felix | Says the pigeon was at the pond.
~ set pond_lead
~ unlock pond

=== felix_reminder
Felix: The pond! It was in the pond!


# --- Scenes 15-19: the pond, back to Felix -----------------------------------

=== pond_enter
~ if saw_ducks -> pond_again
~ sfx sfx_duck_quack
Detective: [i]THESE ARE DUCKS![/i]
Detective: [i]Damn it, Felix!![/i]
~ set saw_ducks
~ note felix | The pond only had ducks. Felix was wrong.
~ blink map

=== pond_again

=== felix_ducks
Detective: Felix, those are ducks!
Felix: Hmmm, they're probably undercover. *hic* The real ones are in the plaza. I actually have a photo of the pigeon.
* ACCEPT THE PHOTO -> felix_photo

=== felix_photo
~ card clue_pigeon_photo | Felix's photo of the pigeon. | ADD TO NOTEBOOK | framed grow
~ clue pigeon_photo
~ note felix | Says the real pigeons are in the plaza. Gave you a photo of the pigeon.
~ set got_pigeon_photo
~ unlock plaza

=== felix_after
Felix: The real ones are in the plaza!


# --- Scenes 20-25: the plaza, comparing pigeons ------------------------------
# Wrong pigeons talk ("Who? Me!", "Marwan") or just coo: bubbles on their
# spots in scenes/locations/plaza.tscn. The right one is ScarfPigeon (the bald
# pigeon in the crowd). To compare, the player opens Felix's photo in the
# notebook and holds it up; nothing here tells them to.

=== plaza_enter
~ if pigeon_caught -> plaza_done
~ set been_plaza
~ sfx sfx_pigeon_wings

=== plaza_done
~ hold_photo off

=== pigeon_found
~ set pigeon_caught
~ hold_photo off
~ sfx sfx_pigeon_wings
~ card pigeon_omg | O.M.G.!! | Next | pop
~ meet pigeon
~ card pigeon_closeup | | Next | framed grow
~ voice voice_pigeon_wot_me
Pigeon: Wot?! Me, mate? I ain't done nuffin', guv!
* GO SEE ARYA -> arya_gift


# --- Scenes 26-32: Arya's gift, the pigeon joins, case solved ----------------

=== arya_gift
~ goto flower_shop
Arya: HA! That'll teach you to mess with my scarf, you feathered menace! Oh, Detective, you've made my day! I have a gift for you. CAMERA!
* TAKE THE CAMERA -> camera_tutorial

=== camera_tutorial
~ tool camera
~ card camera_intro | | Next | pop
Arya: You can explore the town and take photos of the clues with it. (And if a pigeon looks suspicious, get its good side, for the wanted poster!)
Arya: Thanks! Now what with the pigeon?
Arya: Let's send the pigeon to pigeon prison.
~ card pigeon_prison | | Next | pop
~ card pigeon_cries | | Next | pop
~ voice voice_pigeon_oi_no
Pigeon: OI! NO! Give us a chance, guv!
~ voice voice_pigeon_elp_ya
Pigeon: I'll 'elp ya out with yer cases, I will!
~ voice voice_pigeon_trust_me
Pigeon: An' trust me, you don't wanna be out on yer tod after dark, guv.
~ voice voice_pigeon_dodgy
Pigeon: Town gets proper dodgy. You'll be needin' a mate like me, innit!
Arya: OK. You do 1000 hours of social service; help the detective solve cases!
~ voice voice_pigeon_deal
Pigeon: Fair enough, guv. You got yerself a deal!
Arya: And wear a hat to cover your bald head…
~ card pigeon_hat | | Next | pop
~ voice voice_pigeon_mick
Pigeon: [i]Yeah, yeah, take the mick, why don't ya…[/i]
~ voice voice_pigeon_home
Pigeon: We oughta get home, guv. You don't want to be out here at night.
Detective: Btw, what's your name?
~ voice voice_pigeon_jason
Pigeon: My name is Jason. Jason Lee Elliott.
~ tool pigeon
~ note pigeon | Doing 1000 hours of social service: helping you solve cases.
~ case_solve case_01
# Opening the solved case plays the stamp and crossing-out (scripts/notebook.gd).
~ notebook case_01
~ end_game


# --- Nudges: the Detective thinks out loud when the player is stuck ---------
# main.gd plays `nudge` after NUDGE_AFTER seconds with nothing new happening.
# Each step gets a vague thought first, then a clearer one; then nothing more.

=== nudge
~ if pigeon_caught -> nudge_none
~ if been_plaza -> nudge_compare
~ if got_pigeon_photo -> nudge_plaza
~ if saw_ducks -> nudge_ducks
~ if pond_lead -> nudge_pond
~ if alex_done -> nudge_bar
~ if find_alex -> nudge_park

=== nudge_none

=== nudge_park
~ if nudged_park_2 -> nudge_none
~ if nudged_park -> nudge_park_2
~ set nudged_park
Detective: [i]Arya said something about a park…[/i]

=== nudge_park_2
~ set nudged_park_2
Detective: [i]Alex walks her dogs at the park. Where's that map…[/i]

=== nudge_bar
~ if felix_met -> nudge_none
~ if nudged_bar_2 -> nudge_none
~ if nudged_bar -> nudge_bar_2
~ set nudged_bar
Detective: [i]11 am… Alex said Felix would be somewhere by now.[/i]

=== nudge_bar_2
~ set nudged_bar_2
Detective: [i]Getting drunk at the bar, she said. Charming.[/i]

=== nudge_pond
~ if nudged_pond_2 -> nudge_none
~ if nudged_pond -> nudge_pond_2
~ set nudged_pond
Detective: [i]A pigeon. In a pond. Sure, Felix.[/i]

=== nudge_pond_2
~ set nudged_pond_2
Detective: [i]The pond's in the park somewhere. Worth a look.[/i]

=== nudge_ducks
~ if nudged_ducks_2 -> nudge_none
~ if nudged_ducks -> nudge_ducks_2
~ set nudged_ducks
Detective: [i]Ducks. Felix owes me an explanation.[/i]

=== nudge_ducks_2
~ set nudged_ducks_2
Detective: [i]Back to the bar. Felix has some explaining to do.[/i]

=== nudge_plaza
~ if nudged_plaza_2 -> nudge_none
~ if nudged_plaza -> nudge_plaza_2
~ set nudged_plaza
Detective: [i]"The real ones are in the plaza." Undercover ducks. Right.[/i]

=== nudge_plaza_2
~ set nudged_plaza_2
Detective: [i]The plaza. That's where the pigeons hang out.[/i]

=== nudge_compare
~ if nudged_compare_2 -> nudge_none
~ if nudged_compare -> nudge_compare_2
~ set nudged_compare
Detective: [i]So many pigeons. If only I had a picture of the guilty one…[/i]

=== nudge_compare_2
~ set nudged_compare_2
Detective: [i]Felix's photo is in my notebook. I could hold it up next to them.[/i]

