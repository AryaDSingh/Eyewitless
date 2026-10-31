class_name Hud
extends Control
## Always-on screen elements: the notebook, map and camera icons, the current
## objective and the photo the detective is holding up. New things are shown
## on the icons (glow and a count badge), never as text pop-ups. Icon backgrounds are in art/ui/: icon_bg (normal), _new (just
## unlocked, until first clicked), _highlight (something new inside).

signal notebook_pressed
signal map_pressed
signal camera_pressed

const BADGE_FONT := preload("res://ui/fonts/CaveatBrush-Regular.ttf")
const ICONS := {
	"notebook": preload("res://art/ui/icon_notebook.png"),
	"map": preload("res://art/ui/icon_map.png"),
	"camera": preload("res://art/ui/icon_camera.png"),
}
const ICON_BACKGROUNDS := {
	"default": preload("res://art/ui/icon_bg.png"),
	"new": preload("res://art/ui/icon_bg_new.png"),
	"highlight": preload("res://art/ui/icon_bg_highlight.png"),
}

var _blinks: Dictionary = {}  # "notebook" / "map" -> Tween
var _badges: Dictionary = {}  # "notebook" / "map" -> Label

@onready var _notebook_button: Button = %NotebookButton
@onready var _map_button: Button = %MapButton
@onready var _camera_button: Button = %CameraButton
@onready var _companion: PlaceholderArt = %Companion
@onready var _objective: PanelContainer = %Objective
@onready var _objective_label: Label = %ObjectiveLabel
@onready var _held_photo: Polaroid = %HeldPhoto


func _ready() -> void:
	for target in ICONS:
		var button := _button_for(target)
		button.icon = ICONS[target]
		_set_look(button, "default")
		_badges[target] = _make_badge(button)
	_notebook_button.pressed.connect(func():
		if Audio.try_click():
			stop_blink("notebook")
			notebook_pressed.emit())
	_map_button.pressed.connect(func():
		if Audio.try_click():
			stop_blink("map")
			map_pressed.emit())
	_camera_button.pressed.connect(func():
		if Audio.try_click():
			_set_look(_camera_button, "default")
			camera_pressed.emit())
	_objective.hide()
	_held_photo.hide()
	# Click the held photo to put it away.
	_held_photo.mouse_filter = Control.MOUSE_FILTER_STOP
	_held_photo.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_held_photo.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			EventLog.log_event("clue_put_away")
			hold_photo("", ""))


func set_buttons_enabled(enabled: bool) -> void:
	for button in [_notebook_button, _map_button, _camera_button]:
		button.disabled = not enabled
		button.self_modulate = Color.WHITE if enabled else Color(1, 1, 1, 0.55)


## Shows a tool once the story unlocks it: notebook, map, camera, or the
## pigeon companion.
func show_tool(tool_name: String) -> void:
	var node := _tool_node(tool_name)
	if node == null:
		push_error("Unknown tool '%s' (use notebook, map, camera or pigeon)" % tool_name)
		return
	if node is Button and not node.visible:
		_set_look(node, "new")
	node.show()


func is_tool_shown(tool_name: String) -> bool:
	var node := _tool_node(tool_name)
	return node != null and node.visible


func _tool_node(tool_name: String) -> Control:
	match tool_name:
		"notebook":
			return _notebook_button
		"map":
			return _map_button
		"camera":
			return _camera_button
		"pigeon":
			return _companion
	return null


## Circles the notebook or map icon and gently pulses it until it's clicked.
func blink(target: String) -> void:
	var button := _button_for(target)
	if button == null:
		push_error("Can't blink '%s' (use notebook, map or camera)" % target)
		return
	stop_blink(target)
	_set_look(button, "highlight")
	button.pivot_offset = button.size / 2
	var tween := create_tween().set_loops()
	tween.tween_property(button, "scale", Vector2(1.08, 1.08), 0.45).set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_SINE)
	_blinks[target] = tween


## Something new arrived (a clue, a note, a place): glow the icon and count it.
## Both clear when the player opens it.
## Only one icon glows at a time (the map, for new places); new notebook
## entries just add to the notebook's count, so players aren't torn between two.
func notify(target: String) -> void:
	var badge: Label = _badges[target]
	var count := int(badge.text) + 1 if badge.visible else 1
	if target == "map":
		blink(target)  # (this clears the badge, so set it after)
	badge.text = str(count)
	badge.show()


## A quick shake, e.g. when the camera is clicked but can't be used yet.
func wiggle(target: String) -> void:
	var button := _button_for(target)
	button.pivot_offset = button.size / 2
	var tween := create_tween()
	for angle in [-8.0, 8.0, -4.0, 0.0]:
		tween.tween_property(button, "rotation_degrees", angle, 0.06)


func stop_blink(target: String) -> void:
	if _badges.has(target):
		_badges[target].hide()
	if _blinks.has(target):
		_blinks[target].kill()
		_blinks.erase(target)
	var button := _button_for(target)
	if button:
		button.scale = Vector2.ONE
		_set_look(button, "default")


func _make_badge(button: Button) -> Label:
	var badge := Label.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.17, 0.17, 0.17)
	style.set_corner_radius_all(18)
	style.content_margin_left = 10
	style.content_margin_right = 10
	badge.add_theme_stylebox_override("normal", style)
	badge.add_theme_font_override("font", BADGE_FONT)
	badge.add_theme_font_size_override("font_size", 26)
	badge.add_theme_color_override("font_color", Color.WHITE)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.custom_minimum_size = Vector2(36, 36)
	badge.position = Vector2(92, 0)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.hide()
	button.add_child(badge)
	return badge


func _set_look(button: Button, look: String) -> void:
	var style := StyleBoxTexture.new()
	style.texture = ICON_BACKGROUNDS[look]
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		button.add_theme_stylebox_override(state, style)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func is_blinking(target: String) -> bool:
	return _blinks.has(target)


func show_objective(text: String) -> void:
	_objective_label.text = text
	_objective.visible = text != ""


## Shows a photo held up in the top-right corner, to compare with the scene.
## Pass an empty art id to put it away. (The caption is no longer shown.)
func hold_photo(art_id: String, _caption := "") -> void:
	_held_photo.visible = art_id != ""
	_held_photo.setup(art_id)


func is_holding_photo() -> bool:
	return _held_photo.visible


func _button_for(target: String) -> Button:
	match target:
		"notebook":
			return _notebook_button
		"map":
			return _map_button
		"camera":
			return _camera_button
	return null
