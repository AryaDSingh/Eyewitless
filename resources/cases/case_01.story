# Case 1: The Scarf Incident (tutorial)
# How this file works: docs/STORY_FORMAT.md
# Follows the storyboard: letter -> Arya -> park (Debbie) -> bar (Felix)
# -> pond (ducks!) -> back to Felix -> plaza (find the pigeon) -> case solved.


# --- Opening: title, letters, the notebook ---------------------------------

=== start
~ log tutorial_start
~ card title_screen | EYEWITLESS | Start
~ card welcome_letter | Welcome to Muddleford, Detective!\nThe town is small, the people are strange, and nobody ever sees anything right. | Start game
~ card envelope | A letter on your desk.\n"To Detective" | Open it
~ card arya_letter | Dear Detective,\nI'm Arya. A pigeon pooped on my favourite scarf!\nPlease find it. Debbie took a photo. | Next
~ card notebook_intro | "I must keep it in my notebook.\nIt's my first case here." | Got it
~ case_open case_01
~ clue blurry_photo
~ notebook case_01 | Talk to Arya
~ goto flower_shop
-> arya_intro


# --- Flower shop: Arya -----------------------------------------------------

=== arya_intro
~ meet arya
Arya: AH!!! BLAH!!! My scarf! My beautiful scarf!
Arya: A pigeon did this. I want that pigeon FOUND.
* Who was with you? -> arya_who

=== arya_who
~ note arya | Says Debbie took the blurry photo.
Arya: My friend Debbie. She took the photo, but it's all blurry...
* Where's Debbie? -> arya_where

=== arya_where
~ note arya | Says Debbie is in the park, walking her dogs.
Arya: In the park, walking her dogs. She's ALWAYS walking her dogs.
* Find Debbie! -> arya_send_off

=== arya_send_off
~ set find_debbie
~ unlock park
~ hint Open the map and go to the park to find Debbie.

=== arya_talk
~ if debbie_done -> arya_felix
Arya: Did you find Debbie? She's at the park with her dogs.

=== arya_felix
Arya: Felix? He sells fish. Don't trust him before lunch.


# --- Park: Debbie and the dog walkers --------------------------------------

=== debbie_talk
~ if debbie_done -> debbie_after
~ if debbie_met -> debbie_check_photo
~ bubble Debbie | Hi! I'm Debbie!
~ meet debbie
~ set debbie_met
~ hint
Debbie: Hi! I'm Debbie! Don't mind the dogs. They're friendly. Mostly.
* About the pigeon and Arya's scarf... -> debbie_photo

=== debbie_photo
Debbie: Oh, the scarf! I took a photo, but I was holding six leashes at the time...
Debbie: Wait! Felix is in the photo! Look!
~ note debbie | Says Felix is in the blurry photo.
~ clue felix_in_photo
~ hint Check the photo in your notebook.

=== debbie_check_photo
~ if viewed_felix_in_photo -> debbie_where_felix
Debbie: Look at the photo in your notebook! Felix is right there!
~ blink notebook

=== debbie_where_felix
Detective: Where is Felix?
Debbie: It's 11am, so he must be at the bar. He's ALWAYS at the bar at 11.
~ note debbie | Says Felix is at the bar at 11am.
~ set debbie_done
~ unlock bar
~ hint Open the map and go to the bar to find Felix.

=== debbie_after
Debbie: Felix is at the bar! Biscuit, SIT. Sit. Good boy.


# --- Bar: Felix ------------------------------------------------------------

=== felix_talk
~ if got_pigeon_photo -> felix_after
~ if saw_ducks -> felix_ducks
~ if pond_lead -> felix_reminder
~ if felix_met -> felix_question
~ meet felix
~ set felix_met
~ hint
Felix: Hic! A detective! In MY bar!
Detective: I'm looking for a pigeon. It pooped on Arya's scarf.
-> felix_question

=== felix_question
Felix: Pigeons are spies, you know... Hic! How much do you weigh, detective?
* I'm here for pigeons! -> felix_pond
* ...60kg? -> felix_nonsense

=== felix_nonsense
~ log felix_nonsense_branch
Felix: You need to eat healthy. Lots of fish. I sell fish. Blah blah... hic...
-> felix_question

=== felix_pond
Felix: Pigeons! Right. In the park... in the POND! Hic!
~ note felix | Says the pigeon is at the pond in the park.
~ set pond_lead
~ unlock pond
~ hint Open the map and go to the pond.

=== felix_reminder
Felix: The pond! Go! Hic!

=== felix_ducks
Detective: THOSE ARE DUCKS!
~ note felix | Mixed up pigeons and ducks. Now says the plaza.
Felix: Oops. Sorry! I meant the plaza. Hic.
Felix: As a sorry, here's a photo of the pigeon.
* Accept the photo -> felix_photo

=== felix_photo
~ card clue_pigeon_photo | Felix's photo of the pigeon. | Got it
~ clue pigeon_photo
~ set got_pigeon_photo
~ unlock plaza
~ hint Go to the plaza and find the pigeon from the photo.

=== felix_after
Felix: The plaza! Pigeons LOVE the plaza. Hic.


# --- Pond: just ducks ------------------------------------------------------

=== pond_enter
~ if saw_ducks -> pond_again
~ hint
~ card pond_ducks | THESE ARE DUCKS! | Huh?!
~ set saw_ducks
~ note felix | The pond only had ducks. Felix was wrong.
~ hint Go back to the bar and talk to Felix.

=== pond_again
~ hint Go back to the bar and talk to Felix.


# --- Plaza: find the pigeon ------------------------------------------------

=== plaza_enter
~ if pigeon_caught -> plaza_done
~ hold_photo pigeon_photo
~ hint Which pigeon is in the photo? Click on it!

=== plaza_done
~ hold_photo off

=== pigeon_found
~ set pigeon_caught
~ hold_photo off
~ hint
~ card pigeon_omg | O.M.G!! | Gotcha!
~ card case_solved | CASE SOLVED! | Go see Arya
~ case_solve case_01
~ meet pigeon
~ goto flower_shop
Arya: THANK YOU! You found it!
Arya: This is a gift for you. A CAMERA!
* Take the camera -> ending

=== ending
~ card camera_intro | You can use it to take photos of clues! | Next
~ card pigeon_prison | "Let's send the pigeon to pigeon prison." | Next
~ card pigeon_cries | "NO! I'll help you with cases!" | Next
Arya: OK. You'll do 100 hours of community service. Help the detective solve cases!
Pigeon: ...OK.
Arya: AND wear a hat to cover your bald head.
~ note pigeon | Will help solve cases (100 hours of community service).
~ notebook case_01 | Close
~ card night_hint | It's getting dark...\nBe careful. Creepy things happen at night. | THE END
~ end_game
