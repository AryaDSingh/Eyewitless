extends Node
## Plays through Case 1 automatically, the way a playtester would, and checks
## each step works. Run it from the project folder:
##   godot --headless --path . res://tests/playthrough_test.tscn
## Exits with code 0 if everything passed, 1 if something failed.
##
## To also save screenshots (needs a display, so not --headless):
##   godot --path . res://tests/playthrough_test.tscn -- --screenshots=/some/folder

const MAIN_SCENE := preload("res://scenes/main.tscn")

var main: Node
var failures: Array[String] = []
## Choices the bot should pick, in order, when it sees them. Anything else
## picks the first option.
var choice_plan: Array[String] = ["… 75 kg…?"]
var screenshot_dir := ""
var _shots_taken: Array[String] = []


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshots="):
			screenshot_dir = arg.trim_prefix("--screenshots=")
	Engine.time_scale = 1.0 if screenshot_dir != "" else 8.0
	# Real mouse clicks/hover on the window must not reach the game: the test
	# clicks for itself (push_input still works), and a stray click on someone
	# would change the story mid-test.
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_MOUSE_PASSTHROUGH, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_NO_FOCUS, true)
	Audio.click_cooldown = 0.0
	EventLog.upload_url = ""  # don't send test runs to the team's Drive folder
	for problem in Story.validate():
		_fail("story: " + problem)
	main = MAIN_SCENE.instantiate()
	main.nudge_after = 0.0  # nudges are tested separately below
	add_child(main)
	await _play()
	if failures.is_empty():
		print("PASS: Case 1 played start to finish")
	else:
		for failure in failures:
			printerr("FAIL: ", failure)
	# Sounds still playing at quit show up as leaks, so stop them first.
	for player in Audio.get_children():
		player.stop()
		player.stream = null
	await get_tree().create_timer(0.2, true, false, true).timeout
	get_tree().quit(0 if failures.is_empty() else 1)


func _play() -> void:
	await _settle()
	main.options_button.pressed.emit()
	_expect(main.options.visible, "the gear button opens Options")
	await _shot("options")
	main.options._sound.button_pressed = false
	_expect(Audio.is_muted(), "Sound: off mutes the game")
	main.options._sound.button_pressed = true
	_expect(not Audio.is_muted(), "Sound: on unmutes it")
	main.options.close()
	_expect(GameState.current_location == "office", "stays in the office after the letters")
	_expect("arya_half_photo" in GameState.found_clues, "Arya's half of the photo is added automatically")
	_expect(not GameState.is_location_unlocked("park"), "only the flower shop is open at first")
	main.nudge_after = 0.5
	await get_tree().create_timer(1.0).timeout
	await _settle()
	main.nudge_after = 0.0
	_expect(GameState.has_flag("nudged_shop"), "the Detective nudges towards the flower shop")
	await _travel("flower_shop")
	_expect("arya" in GameState.met_characters, "walking into the shop starts Arya's scene")
	_expect(GameState.is_location_unlocked("park"), "Arya unlocks the park")
	_expect(main.hud.is_tool_shown("notebook") and main.hud.is_tool_shown("map"), "notebook and map are unlocked")
	_expect(not main.hud.is_tool_shown("camera"), "camera stays hidden until Arya's gift")
	_expect(GameState.notes.get("arya", []).size() == 2, "Arya's answers go in the notebook")
	_expect("felix" not in GameState.met_characters and not GameState.notes.get("felix", []).is_empty(), "Felix is only heard of (a silhouette) until you meet him")

	await _travel("park")
	await _shot("park")
	await _check_spam_click("Walker1")
	await _check_click_switch()
	await _click("Walker1", true)
	_check_animals()
	await _click("Cat1")
	await _click("Mara2")
	await _click("Dog2", true)
	_expect(not GameState.has_flag("alex_done"), "the animals aren't Alex")
	await _click("Marwan")
	_expect(not GameState.has_flag("alex_done"), "Marwan isn't Alex")
	await _click("Alex")
	_expect("felix_in_photo" in GameState.found_clues, "Alex's photo adds the Felix clue")
	_expect(GameState.is_location_unlocked("bar"), "Alex unlocks the bar")
	var badge: Label = main.hud.get_node("%NotebookButton").get_child(0)
	_expect(badge.visible and int(badge.text) >= 2, "new notebook entries show a count on the icon")
	await _shot("hud_badge")
	main.notebook.open("case_01")
	await _shot("notebook_case")
	await _check_no_page_flash()
	main.notebook._show_page(main.notebook._page_count - 1)
	await _shot("notebook_case_clues")
	main.notebook.view_clue("felix_in_photo")
	await _shot("notebook_clue_zoom")
	main.notebook.close()
	main.notebook.open("alex")
	await _check_notebook_fits("Alex's page")
	await _shot("notebook_residents")
	main.notebook.close()
	main.notebook.open("regina")
	await _check_notebook_fits("Regina's page")
	main.notebook.close()

	await _travel("bar")
	await _click("Felix")
	_expect("felix" in GameState.met_characters, "meeting Felix reveals him")
	await _click("Bartender")
	await _click("Bartender", true)
	_expect(main.location.get_hotspot("Bartender")._exchanges == 2, "the bartender has a second joke")
	_expect(EventLog.has_event("felix_nonsense_branch"), "the 75 kg detour leads back to the pigeon")
	_expect(GameState.is_location_unlocked("pond"), "Felix unlocks the pond")

	await _travel("pond")
	_expect(GameState.has_flag("saw_ducks"), "the pond shows the ducks")
	main.nudge_after = 0.5
	await get_tree().create_timer(1.0).timeout
	await _settle()
	main.nudge_after = 0.0
	_expect(GameState.has_flag("nudged_ducks"), "standing still at the pond makes the Detective mutter about Felix")
	await _travel("bar")
	_expect(not main.location.get_hotspot("Felix").visible, "Felix has sobered up after the pond")
	await _click("FelixSober")
	_expect("pigeon_photo" in GameState.found_clues, "Felix gives the pigeon photo")
	_expect(GameState.is_location_unlocked("plaza"), "Felix unlocks the plaza")
	await _click("FelixSober")
	_expect(EventLog.has_event_with("knot", "felix_after"), "Felix has a line after giving the photo")
	await _travel("park")
	await _click("Alex")
	_expect(EventLog.has_event_with("knot", "alex_after"), "Alex has a line after their scene")
	await _travel("flower_shop")
	await _click("Arya")
	_expect(EventLog.has_event_with("knot", "arya_felix"), "Arya has a line mid-case")
	await _travel("pond")
	_expect(EventLog.has_event_with("knot", "pond_again"), "the pond doesn't replay the ducks")

	main.map_screen.open()
	await _shot("map")
	main.map_screen.close()
	await _travel("plaza")
	_expect(not main.hud.is_holding_photo(), "the plaza doesn't hold the photo up by itself")
	main.notebook.open("case_01")
	main.notebook.view_clue("pigeon_photo")
	await _shot("notebook_zoom_hold")
	main.notebook.hold_clue("pigeon_photo")
	_expect(main.hud.is_holding_photo() and not main.notebook.visible, "Hold it up puts the photo on screen")
	await _check_layout("plaza holding the photo")
	await _shot("plaza")
	await _click("Pigeon2", true)
	await _click("Pigeon4", true)  # a very short reply ("Coo.") still gets a whole bubble
	_expect("case_01" not in GameState.solved_cases, "a wrong pigeon doesn't solve the case")
	await _click("ScarfPigeon")
	_expect("case_01" in GameState.solved_cases, "the right pigeon solves the case")
	_expect(main.hud.is_tool_shown("camera"), "Arya's gift unlocks the camera")
	_expect(EventLog.has_event("camera_opened"), "Arya's gift shows the viewfinder")
	_expect(main.hud.is_tool_shown("pigeon"), "the pigeon joins as a companion")
	_expect(EventLog.has_event("game_end"), "the game reaches the end screen")


## Clicks through cards, dialogue and the notebook until the story is idle.
func _settle() -> void:
	for i in 3000:
		await get_tree().process_frame
		if EventLog.has_event("game_end"):
			return
		if main.title_screen.visible:
			await _check_layout("title screen")
			await _shot("title")
			main.title_screen.start()
		elif main.card_screen.visible:
			if screenshot_dir != "":
				await get_tree().create_timer(2.0).timeout  # let the card's animation finish
			await _check_layout("card " + main.card_screen.get_node("%Art").art_id)
			await _shot("card_" + main.card_screen.get_node("%Art").art_id)
			main.card_screen.press()
		elif main.viewfinder.visible:
			await _check_layout("viewfinder")
			if screenshot_dir != "":
				await get_tree().create_timer(1.0).timeout  # let it fade in
			await _shot("viewfinder")
			main.viewfinder.close()
		elif main.notebook.visible:
			await _check_layout("notebook")
			if screenshot_dir != "":
				await get_tree().create_timer(2.5).timeout  # let the stamp animation play
				await _shot("notebook_%s_%d" % [GameState.current_location, GameState.solved_cases.size()])
			main.notebook.close()
		elif main.dialogue_box.visible and main.dialogue_box.is_waiting_for_choice():
			await _check_layout("dialogue choice '%s'" % main.dialogue_box.get_choice_texts()[0])
			await _shot("dialogue_" + main.dialogue_box.get_choice_texts()[0].left(12).validate_filename())
			main.dialogue_box.choose(_pick_choice(main.dialogue_box.get_choice_texts()))
		elif main.dialogue_box.visible:
			if main.dialogue_box._ready_to_advance:
				_expect(main.dialogue_box._arrow.visible, "the continue arrow shows once a line is typed")
				await _shot("dialogue_arrow")
			main.dialogue_box.advance()
			await _check_layout("dialogue at " + GameState.current_location)
		elif not Story.is_running:
			return
	_fail("the story got stuck")


## Sends two real mouse clicks 0.15 s apart to a hotspot, the way a player
## spamming it would. Only the first may count (1 s click cooldown).
func _check_spam_click(hotspot_name: String) -> void:
	var hotspot: Hotspot = main.location.get_hotspot(hotspot_name)
	Audio.click_cooldown = Audio.CLICK_COOLDOWN
	# The cooldown counts from the last click (the map pin), so wait it out first. Real time.
	await get_tree().create_timer(Audio.CLICK_COOLDOWN + 0.1, true, false, true).timeout
	var before := EventLog.count_events("hotspot_clicked")
	var target := _drawn_point(hotspot)
	var motion := InputEventMouseMotion.new()
	motion.position = target
	motion.global_position = target
	get_viewport().push_input(motion, true)  # the GUI needs to know where the mouse is first
	for i in 2:
		for pressed in [true, false]:
			var click := InputEventMouseButton.new()
			click.button_index = MOUSE_BUTTON_LEFT
			click.pressed = pressed
			click.position = target
			click.global_position = target
			get_viewport().push_input(click, true)  # position is in game coordinates
		await get_tree().create_timer(0.15, true, false, true).timeout
	var counted := EventLog.count_events("hotspot_clicked") - before
	_expect(counted == 1, "spam clicks on %s count once (counted %d)" % [hotspot_name, counted])
	Audio.click_cooldown = 0.0
	await get_tree().create_timer(Hotspot.BUBBLE_SECONDS * 3).timeout


## Clicking the same thing again within 1 s is ignored, but clicking something
## else right away (the last dialogue line, then the person) isn't. Real time.
func _check_click_switch() -> void:
	Audio.click_cooldown = Audio.CLICK_COOLDOWN
	await get_tree().create_timer(Audio.CLICK_COOLDOWN + 0.1, true, false, true).timeout
	var first := Node.new()
	var other := Node.new()
	_expect(Audio.try_click(first), "a first click counts")
	_expect(not Audio.try_click(first), "the same thing clicked again right away doesn't")
	await get_tree().create_timer(Audio.SWITCH_COOLDOWN + 0.05, true, false, true).timeout
	_expect(Audio.try_click(other), "something else clicked straight after does count")
	first.free()
	other.free()
	Audio.click_cooldown = 0.0


## Clicking the case again and again rebuilds the page; nothing from page 2
## (the clue photos) may show while it's being split into pages.
func _check_no_page_flash() -> void:
	var nb: Notebook = main.notebook
	var area := nb._detail_scroll.get_global_rect()
	var seen: Array[Control] = []  # what was on screen in the page area while rebuilding
	for click in 3:
		nb._rebuild()
		for frame in 3:
			await get_tree().process_frame
			if nb._detail.modulate.a == 0.0:
				continue
			for child: Control in nb._detail.get_children():
				if child.is_visible_in_tree() and area.intersects(child.get_global_rect()):
					seen.append(child)
	for frame in 3:
		await get_tree().process_frame
	_expect(nb._detail.modulate.a == 1.0, "the notebook page shows again after rebuilding")
	for child in seen:
		if is_instance_valid(child) and child.get_meta("page", nb._page) != nb._page:
			_fail("rebuilding the notebook page flashes something from page %d" % (child.get_meta("page") + 1))
			return


## Each park animal is its own drawing: clicking it hits the animal, not its
## owner (the animals were cut out of the owners' pictures).
func _check_animals() -> void:
	var owners := {"Cat": "Walker1", "Mara": "Marwan", "Dog": "Alex"}
	for animal in ["Cat1", "Cat2", "Mara1", "Mara2", "Dog1", "Dog2", "Dog3", "Dog4", "Dog5"]:
		var hotspot: Hotspot = main.location.get_hotspot(animal)
		if hotspot == null:
			_fail("the park has no %s" % animal)
			continue
		var point := _drawn_point(hotspot)
		var owner: Hotspot = main.location.get_hotspot(owners[animal.left(-1)])
		_expect(hotspot.is_drawn_at(point - hotspot.global_position), "%s can be clicked" % animal)
		_expect(not owner.is_drawn_at(point - owner.global_position), "clicking %s doesn't hit %s" % [animal, owner.name])


## A point on the hotspot's drawing (clicks on see-through parts don't count),
## as close to its middle as possible.
func _drawn_point(hotspot: Hotspot) -> Vector2:
	var rect := hotspot.get_global_rect()
	var best := rect.get_center()
	var best_distance := INF
	for x in range(0, int(rect.size.x), 10):
		for y in range(0, int(rect.size.y), 10):
			var local := Vector2(x, y)
			var distance := local.distance_to(rect.size / 2)
			if distance < best_distance and hotspot.is_drawn_at(local):
				best = rect.position + local
				best_distance = distance
	return best


## Every page of the notebook's right side fits (nothing cut off), and you can
## flip forward and back.
func _check_notebook_fits(where: String) -> void:
	var nb: Notebook = main.notebook
	for i in 4:
		await get_tree().process_frame
	var bottom := nb._detail_scroll.get_global_rect().end.y
	for page in nb._page_count:
		nb._show_page(page)
		await get_tree().process_frame
		for child in nb._detail.get_children():
			if child.visible and child.get_global_rect().end.y > bottom + 1:
				_fail("%s page %d: '%s' is cut off" % [where, page + 1, child.get("text") if child.get("text") else child.name])
	if nb._page_count > 1:
		nb._show_page(nb._page_count - 1)
		nb._show_page(0)
		_expect(nb._page == 0 and nb._prev.disabled, "%s flips back to page 1" % where)
	await _shot("notebook_pages_%s" % nb._page_count)


## Fails if a visible button overlaps another button or a piece of text.
## Things under a full-screen screen (notebook, map, card, title) are skipped,
## since the player can't see or click them.
func _check_layout(where: String) -> void:
	await get_tree().process_frame
	var blocking := ["Notebook", "MapScreen", "CardScreen", "TitleScreen"]
	var top := -1
	for i in main.get_child_count():
		var layer: Control = main.get_child(i)
		if layer.visible and String(layer.name) in blocking:
			top = i
	var buttons: Array[Control] = []
	var texts: Array[Control] = []
	for node in main.find_children("*", "Control", true, false):
		var control := node as Control
		if not control.is_visible_in_tree() or _layer_index(control) < top:
			continue
		if control is BaseButton:
			buttons.append(control)
		elif (control is Label and control.text != "") or (control is RichTextLabel and control.text != ""):
			texts.append(control)
	for i in buttons.size():
		for other in buttons.slice(i + 1) + texts:
			if buttons[i].is_ancestor_of(other) or other.is_ancestor_of(buttons[i]):
				continue
			var overlap := buttons[i].get_global_rect().intersection(other.get_global_rect())
			if overlap.get_area() > 4.0:
				_fail("%s: '%s' overlaps '%s'" % [where, _describe(buttons[i]), _describe(other)])


func _layer_index(control: Control) -> int:
	var node: Node = control
	while node.get_parent() != main:
		node = node.get_parent()
	return node.get_index()


func _describe(control: Control) -> String:
	return "%s (%s)" % [control.name, control.get("text") if control.get("text") else control.get_class()]


func _pick_choice(options: Array[String]) -> int:
	for i in options.size():
		if options[i] in choice_plan:
			choice_plan.erase(options[i])
			return i
	return 0


func _travel(location_id: String) -> void:
	_expect(GameState.is_location_unlocked(location_id), "%s is on the map" % location_id)
	main.map_screen.open()
	var pin: MapPin = main.map_screen.get_pin(location_id)
	if pin == null or pin.disabled:
		_fail("no visible map pin for %s" % location_id)
		return
	await _check_layout("map")
	pin.pressed.emit()
	await _settle()
	await _check_layout(location_id)
	_expect(GameState.current_location == location_id, "travelled to %s" % location_id)


func _click(hotspot_name: String, screenshot_bubble := false) -> void:
	var hotspot: Hotspot = main.location.get_hotspot(hotspot_name)
	if hotspot == null or not hotspot.visible:
		_fail("can't click %s in %s" % [hotspot_name, GameState.current_location])
		return
	hotspot.clicked.emit(hotspot)
	if screenshot_bubble and main.dialogue_box.visible:
		await get_tree().create_timer(0.5).timeout
		await _shot("ask_" + hotspot_name)
	await _settle()  # clicks through the Detective's question, if there is one
	if screenshot_bubble:
		await get_tree().create_timer(Hotspot.BUBBLE_SECONDS * 0.5).timeout
		await _shot("bubble_" + hotspot_name)
	await get_tree().create_timer(Hotspot.BUBBLE_SECONDS * 2.5).timeout
	await _settle()


## Saves a screenshot the first time each name comes up (only with --screenshots).
func _shot(shot_name: String) -> void:
	if screenshot_dir == "" or shot_name in _shots_taken:
		return
	_shots_taken.append(shot_name)
	for i in 3:
		await RenderingServer.frame_post_draw
	var path := "%s/%02d_%s.png" % [screenshot_dir, _shots_taken.size(), shot_name]
	get_viewport().get_texture().get_image().save_png(path)


func _expect(condition: bool, description: String) -> void:
	if not condition:
		_fail(description)


func _fail(message: String) -> void:
	if message not in failures:
		failures.append(message)
