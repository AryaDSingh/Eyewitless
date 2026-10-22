class_name Hud
extends Control
## Always-on screen elements: notebook and map buttons, the current objective,
## pop-up messages ("New clue!") and the photo the detective is holding up.

signal notebook_pressed
signal map_pressed

const TOAST_SECONDS := 2.5

var _blinks: Dictionary = {}  # "notebook" / "map" -> Tween
var _toast_count := 0

@onready var _notebook_button: Button = %NotebookButton
@onready var _map_button: Button = %MapButton
@onready var _objective: PanelContainer = %Objective
@onready var _objective_label: Label = %ObjectiveLabel
@onready var _toast: PanelContainer = %Toast
@onready var _toast_label: Label = %ToastLabel
@onready var _held_photo: PanelContainer = %HeldPhoto
@onready var _held_photo_art: PlaceholderArt = %HeldPhotoArt
@onready var _held_photo_label: Label = %HeldPhotoLabel


func _ready() -> void:
	_notebook_button.pressed.connect(func():
		stop_blink("notebook")
		notebook_pressed.emit())
	_map_button.pressed.connect(func():
		stop_blink("map")
		map_pressed.emit())
	_objective.hide()
	_toast.hide()
	_held_photo.hide()


func set_buttons_enabled(enabled: bool) -> void:
	_notebook_button.disabled = not enabled
	_map_button.disabled = not enabled


## Makes the notebook or map button flash until it's clicked.
func blink(target: String) -> void:
	var button := _button_for(target)
	if button == null:
		push_error("Can't blink '%s' (use notebook or map)" % target)
		return
	stop_blink(target)
	var tween := create_tween().set_loops()
	tween.tween_property(button, "modulate", Color(1.0, 0.75, 0.2), 0.4)
	tween.tween_property(button, "modulate", Color.WHITE, 0.4)
	_blinks[target] = tween


func stop_blink(target: String) -> void:
	if _blinks.has(target):
		_blinks[target].kill()
		_blinks.erase(target)
	var button := _button_for(target)
	if button:
		button.modulate = Color.WHITE


func is_blinking(target: String) -> bool:
	return _blinks.has(target)


func show_objective(text: String) -> void:
	_objective_label.text = text
	_objective.visible = text != ""


func show_toast(text: String) -> void:
	_toast_label.text = text
	_toast.show()
	_toast_count += 1
	var my_count := _toast_count
	await get_tree().create_timer(TOAST_SECONDS).timeout
	if my_count == _toast_count:
		_toast.hide()


## Shows a photo in the corner (e.g. the pigeon photo at the plaza).
## Pass an empty art id to put it away.
func hold_photo(art_id: String, caption: String) -> void:
	_held_photo.visible = art_id != ""
	_held_photo_art.art_id = art_id
	_held_photo_label.text = caption


func _button_for(target: String) -> Button:
	match target:
		"notebook":
			return _notebook_button
		"map":
			return _map_button
	return null
