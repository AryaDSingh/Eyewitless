class_name OptionsPanel
extends Control
## Options, on a taped sheet of paper over a dimmed screen: sound on/off and
## the music and sound volumes. Opened by the gear button (top left) and by
## Settings on the title screen. Click outside the paper or Close to shut it.

const PAPER := Color(0.965, 0.957, 0.925)
const INK := Color(0.12, 0.11, 0.1)

var _sound := Button.new()
var _music := HSlider.new()
var _sounds := HSlider.new()
var _close := Button.new()


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	hide()
	var dim := ColorRect.new()
	dim.color = Color(0.07, 0.07, 0.07, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			close())
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var paper := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = PAPER
	style.border_color = INK
	style.set_border_width_all(4)
	style.set_content_margin_all(48)
	style.shadow_color = Color(0, 0, 0, 0.2)
	style.shadow_offset = Vector2(6, 8)
	style.shadow_size = 4
	paper.add_theme_stylebox_override("panel", style)
	paper.rotation_degrees = -1.0
	center.add_child(paper)
	paper.resized.connect(func(): paper.pivot_offset = paper.size / 2)
	Tape.stick(paper, 110, 40)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 22)
	paper.add_child(column)
	var heading := Label.new()
	heading.text = "Options"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_override("font", preload("res://ui/fonts/CaveatBrush-Regular.ttf"))
	heading.add_theme_font_size_override("font_size", 64)
	column.add_child(heading)
	_sound.theme_type_variation = &"TagButton"
	_sound.toggle_mode = true
	_sound.custom_minimum_size = Vector2(0, 64)
	_sound.toggled.connect(func(on: bool):
		Audio.set_muted(not on)
		_sound.text = "Sound: on" if on else "Sound: off")
	column.add_child(_sound)
	for row in [["Music", _music, "Music"], ["Sounds", _sounds, "Sounds"]]:
		var label := Label.new()
		label.text = row[0]
		column.add_child(label)
		var slider: HSlider = row[1]
		slider.max_value = 1.0
		slider.step = 0.05
		slider.custom_minimum_size = Vector2(620, 40)
		slider.value_changed.connect(Audio.set_volume.bind(row[2]))
		column.add_child(slider)
	_close.theme_type_variation = &"CloseButton"
	_close.text = "Close ×"
	_close.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_close.pressed.connect(close)
	column.add_child(_close)
	Tape.stick(_close)


func open() -> void:
	_sound.set_pressed_no_signal(not Audio.is_muted())
	_sound.text = "Sound: on" if _sound.button_pressed else "Sound: off"
	_music.set_value_no_signal(Audio.get_volume("Music"))
	_sounds.set_value_no_signal(Audio.get_volume("Sounds"))
	show()
	_close.grab_focus.call_deferred()
	EventLog.log_event("options_opened")


func close() -> void:
	if visible:
		hide()
		EventLog.log_event("options_closed")


func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()
