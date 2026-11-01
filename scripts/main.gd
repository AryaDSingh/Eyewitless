extends Control
## Root of the game. Holds the current location and the overlay screens, and
## is the `ui` that the Story runner calls (show_line, show_card, go_to...).

const LOCATIONS := {
	"office": "res://scenes/locations/office.tscn",
	"flower_shop": "res://scenes/locations/flower_shop.tscn",
	"park": "res://scenes/locations/park.tscn",
	"bar": "res://scenes/locations/bar.tscn",
	"pond": "res://scenes/locations/pond.tscn",
	"plaza": "res://scenes/locations/plaza.tscn",
}
const START_LOCATION := "office"
const START_KNOT := "start"

## Turn off to load the scene without starting the story (used by tests).
@export var autostart := true
## Seconds with nothing new happening (while the player is free to act) before
## the Detective mutters a nudge (the `nudge` knot). 0 = never.
@export var nudge_after := 25.0

var _idle := 0.0
var _arrive_fade := ColorRect.new()

var location: Location

@onready var location_layer: Control = %LocationLayer
@onready var hud: Hud = %Hud
@onready var dialogue_box: DialogueBox = %DialogueBox
@onready var notebook: Notebook = %Notebook
@onready var map_screen: MapScreen = %MapScreen
@onready var card_screen: CardScreen = %CardScreen
@onready var title_screen: TitleScreen = %TitleScreen
@onready var options_button: Button = %OptionsButton
var options := OptionsPanel.new()


func _ready() -> void:
	Story.ui = self
	Story.started.connect(_on_story_started)
	Story.finished.connect(_on_story_finished)
	GameState.clue_added.connect(_on_clue_added)
	GameState.note_added.connect(_on_note_added)
	GameState.location_unlocked.connect(_on_location_unlocked)
	hud.notebook_pressed.connect(_on_notebook_pressed)
	hud.map_pressed.connect(_on_map_pressed)
	hud.camera_pressed.connect(_on_camera_pressed)
	map_screen.travel_requested.connect(travel_to)
	GameState.changed.connect(func(): _idle = 0.0)
	# A quick fade from paper colour when arriving somewhere (under the HUD).
	_arrive_fade.color = Color(0.96, 0.94, 0.88, 0)
	_arrive_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_arrive_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	location_layer.add_sibling(_arrive_fade)
	notebook.hold_requested.connect(func(clue_id: String): hold_photo(clue_id))
	# Muting lasts until the game is closed, even through "Play again".
	# Options (sound, volumes): Ruby's taped paper square with a drawn gear, top left.
	var paper := StyleBoxTexture.new()
	paper.texture = preload("res://art/ui/icon_bg.png")
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		options_button.add_theme_stylebox_override(state, paper)
	options_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	options_button.icon = preload("res://art/ui/icon_options.png")
	options_button.pressed.connect(func():
		if Audio.try_click(options_button):
			options.open())
	add_child(options)  # last, so it's on top of everything
	title_screen.settings_pressed.connect(options.open)
	if autostart:
		await title_screen.open()
		go_to(START_LOCATION)
		Story.run(START_KNOT)


func _process(delta: float) -> void:
	var free := not Story.is_running and not notebook.visible and not map_screen.visible 			and not card_screen.visible and not title_screen.visible and not options.visible and location != null
	if nudge_after <= 0 or not free:
		return
	_idle += delta
	if _idle >= nudge_after:
		_idle = 0.0
		EventLog.log_event("nudge", {"location": GameState.current_location})
		Story.run("nudge")


func travel_to(location_id: String) -> void:
	EventLog.log_event("travel", {"from": GameState.current_location, "to": location_id})
	go_to(location_id)


func _on_hotspot_clicked(hotspot: Hotspot) -> void:
	if Story.is_running:
		return
	EventLog.log_event("hotspot_clicked", {"location": GameState.current_location, "hotspot": String(hotspot.name)})
	if hotspot.knot != "":
		Audio.play_sfx(hotspot.sfx)
		Story.run(hotspot.knot)
	else:
		hotspot.play_exchange(_detective_says)


## The Detective's side of a quick hotspot exchange: the dialogue box, like
## any other Detective line, so it's clear who's talking.
func _detective_says(text: String) -> void:
	await dialogue_box.show_line("Detective", text, [])
	dialogue_box.hide()


func _on_notebook_pressed() -> void:
	if not Story.is_running:
		notebook.open()


func _on_map_pressed() -> void:
	if not Story.is_running:
		map_screen.open()


func _on_camera_pressed() -> void:
	# shortcut: the camera does nothing yet; it gets its own system in Case 2.
	EventLog.log_event("camera_pressed")
	hud.wiggle("camera")


func _on_story_started() -> void:
	hud.set_buttons_enabled(false)


func _on_story_finished() -> void:
	dialogue_box.hide()
	hud.set_buttons_enabled(true)


# New things show on the HUD icon (glow and a count), not as text pop-ups.
func _on_clue_added(_clue_id: String) -> void:
	hud.notify("notebook")


func _on_note_added(_character_id: String, _text: String) -> void:
	hud.notify("notebook")


func _on_location_unlocked(location_id: String) -> void:
	if location_id in LOCATIONS:
		hud.notify("map")


func _unhandled_key_input(event: InputEvent) -> void:
	# Escape closes the notebook or map.
	if event.is_action_pressed("ui_cancel"):
		if map_screen.visible:
			map_screen.close()
		elif notebook.visible and not Story.is_running:
			notebook.close()


# --- Called by the Story runner -------------------------------------------

func show_line(speaker: String, text: String, choices: Array[String]) -> int:
	return await dialogue_box.show_line(speaker, text, choices)


func show_card(art_id: String, text: String, button_text: String, options := "") -> void:
	dialogue_box.hide()
	await card_screen.show_card(art_id, text, button_text, options)


func show_tool(tool_name: String) -> void:
	hud.show_tool(tool_name)


## Moves to a location. Its on-enter knot plays after the current one.
func go_to(location_id: String) -> void:
	var path: String = LOCATIONS.get(location_id, "")
	if path == "":
		push_error("Unknown location: %s (add it to LOCATIONS in main.gd)" % location_id)
		return
	if location:
		location.queue_free()
	location = load(path).instantiate()
	location_layer.add_child(location)
	_arrive_fade.color.a = 1.0
	create_tween().tween_property(_arrive_fade, "color:a", 0.0, 0.35).set_trans(Tween.TRANS_SINE)
	location.hotspot_clicked.connect(_on_hotspot_clicked)
	Audio.play_music(location.music)
	Audio.play_ambience(location.ambience)
	Audio.set_muffled(location.muffle_music)
	GameState.enter_location(location_id)
	if location.on_enter_knot != "":
		Story.run(location.on_enter_knot)


func open_map() -> void:
	hud.stop_blink("map")
	map_screen.open()


func blink(target: String) -> void:
	hud.blink(target)


func show_hint(text: String) -> void:
	hud.show_objective(text)


func hold_photo(clue_id: String) -> void:
	if clue_id == "" or clue_id == "off":
		hud.hold_photo("", "")
		return
	var clue := GameState.get_clue(clue_id)
	hud.hold_photo(clue.get("image", clue_id), "Find this!")


func show_bubble(hotspot_name: String, text: String) -> void:
	var hotspot := location.get_hotspot(hotspot_name) if location else null
	if hotspot == null:
		push_error("No hotspot called '%s' here" % hotspot_name)
		return
	await hotspot.say(text)


func open_notebook(page: String, close_label: String) -> void:
	dialogue_box.hide()
	hud.stop_blink("notebook")
	await notebook.open(page, close_label)


func end_game() -> void:
	EventLog.log_event("game_end", {"seconds": snappedf(EventLog.elapsed_seconds(), 0.1)})
	if await EventLog.upload():
		await card_screen.show_card("none", "Thanks for playing!\nYour playtest log was sent to the team.", "NEXT")
	else:
		var on_web := OS.has_feature("web")
		await card_screen.show_card("none", "Thanks for playing!\nPlease tell the team what you thought.",
			"Download playtest log" if on_web else "Save playtest log")
		EventLog.download()
	await card_screen.show_card("none", "THE END", "Play again")
	Story.stop()
	GameState.reset()
	EventLog.start_session()
	get_tree().reload_current_scene()
