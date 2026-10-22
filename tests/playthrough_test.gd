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
var choice_plan: Array[String] = ["...60kg?"]
var screenshot_dir := ""
var _shots_taken: Array[String] = []


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshots="):
			screenshot_dir = arg.trim_prefix("--screenshots=")
	Engine.time_scale = 1.0 if screenshot_dir != "" else 8.0
	for problem in Story.validate():
		_fail("story: " + problem)
	main = MAIN_SCENE.instantiate()
	add_child(main)
	await _play()
	if failures.is_empty():
		print("PASS: Case 1 played start to finish")
	else:
		for failure in failures:
			printerr("FAIL: ", failure)
	get_tree().quit(0 if failures.is_empty() else 1)


func _play() -> void:
	await _settle()
	_expect(GameState.current_location == "flower_shop", "starts at the flower shop after the notebook")
	_expect("blurry_photo" in GameState.found_clues, "blurry photo added automatically")
	_expect(GameState.is_location_unlocked("park"), "Arya unlocks the park")

	await _travel("park")
	await _shot("park")
	await _click("Walker1", true)
	await _click("Debbie")
	_expect("felix_in_photo" in GameState.found_clues, "Debbie adds the Felix clue")
	await _click("Debbie")
	_expect(not GameState.is_location_unlocked("bar"), "bar stays locked until the photo is checked")
	main.notebook.open("case_01")
	await _shot("notebook_case")
	main.notebook.view_clue("felix_in_photo")
	await _shot("notebook_clue_zoom")
	main.notebook.close()
	main.notebook.open("debbie")
	await _shot("notebook_characters")
	main.notebook.close()
	await _click("Debbie")
	_expect(GameState.is_location_unlocked("bar"), "Debbie unlocks the bar")

	await _travel("bar")
	await _click("Felix")
	_expect(EventLog.has_event("felix_nonsense_branch"), "the 60kg branch loops back")
	_expect(GameState.is_location_unlocked("pond"), "Felix unlocks the pond")

	await _travel("pond")
	_expect(GameState.has_flag("saw_ducks"), "the pond shows the ducks")
	await _travel("bar")
	await _click("Felix")
	_expect("pigeon_photo" in GameState.found_clues, "Felix gives the pigeon photo")
	_expect(GameState.is_location_unlocked("plaza"), "Felix unlocks the plaza")

	main.map_screen.open()
	await _shot("map")
	main.map_screen.close()
	await _travel("plaza")
	await _shot("plaza")
	await _click("Pigeon2", true)
	_expect("case_01" not in GameState.solved_cases, "a wrong pigeon doesn't solve the case")
	await _click("ScarfPigeon")
	_expect("case_01" in GameState.solved_cases, "the right pigeon solves the case")
	_expect(EventLog.has_event("game_end"), "the game reaches the end screen")


## Clicks through cards, dialogue and the notebook until the story is idle.
func _settle() -> void:
	for i in 3000:
		await get_tree().process_frame
		if EventLog.has_event("game_end"):
			return
		if main.card_screen.visible:
			await _shot("card_" + main.card_screen.get_node("%Art").art_id)
			main.card_screen.press()
		elif main.notebook.visible:
			main.notebook.close()
		elif main.dialogue_box.visible and main.dialogue_box.is_waiting_for_choice():
			await _shot("dialogue_" + main.dialogue_box.get_choice_texts()[0].left(12).validate_filename())
			main.dialogue_box.choose(_pick_choice(main.dialogue_box.get_choice_texts()))
		elif main.dialogue_box.visible:
			main.dialogue_box.advance()
		elif not Story.is_running:
			return
	_fail("the story got stuck")


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
	if pin == null or not pin.visible:
		_fail("no visible map pin for %s" % location_id)
		return
	pin.pressed.emit()
	await _settle()
	_expect(GameState.current_location == location_id, "travelled to %s" % location_id)


func _click(hotspot_name: String, screenshot_bubble := false) -> void:
	var hotspot: Hotspot = main.location.get_hotspot(hotspot_name)
	if hotspot == null or not hotspot.visible:
		_fail("can't click %s in %s" % [hotspot_name, GameState.current_location])
		return
	hotspot.clicked.emit(hotspot)
	if screenshot_bubble:
		var wait := Hotspot.BUBBLE_SECONDS * (1.5 if hotspot.ask != "" else 0.5)
		await get_tree().create_timer(wait).timeout
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
	failures.append(message)
