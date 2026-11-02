class_name Viewfinder
extends Control
## Looking through the camera: Samantha's viewfinder drawn over the scene.
## Shown once when Arya gives the camera (`~ viewfinder` in the story).
## Click or Esc to put the camera down.
# shortcut: only looks for now; taking photos comes with Case 2.

signal closed

const FADE_SECONDS := 0.2
## Clicks this soon after opening are ignored (the click that finished
## Arya's line shouldn't also close the camera).
const CLOSE_DELAY := 0.5

var _opened_at := 0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	hide()
	var frame := TextureRect.new()
	frame.texture = preload("res://art/ui/camera_viewfinder.png")
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)


func open() -> void:
	modulate.a = 0.0
	_opened_at = Time.get_ticks_msec()
	show()
	create_tween().tween_property(self, "modulate:a", 1.0, FADE_SECONDS)
	EventLog.log_event("camera_opened")


func close() -> void:
	if visible:
		hide()
		EventLog.log_event("camera_closed")
		closed.emit()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		if Time.get_ticks_msec() - _opened_at >= CLOSE_DELAY * 1000:
			close()


func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()
