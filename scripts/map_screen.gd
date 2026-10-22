class_name MapScreen
extends Control
## The town map. Click an unlocked place to travel there. New places pulse
## until the player has been there.

signal travel_requested(location_id: String)

var _opened_at := 0.0
var _pulses: Array[Tween] = []

@onready var _pins: Control = %Pins
@onready var _close_button: Button = %CloseButton


func _ready() -> void:
	hide()
	_close_button.pressed.connect(close)
	for pin in get_pins():
		pin.set_meta("base_text", pin.text)
		pin.pressed.connect(_on_pin_pressed.bind(pin))


func open() -> void:
	refresh()
	show()
	_opened_at = EventLog.elapsed_seconds()
	EventLog.log_event("map_opened", {"location": GameState.current_location})


func close() -> void:
	if not visible:
		return
	hide()
	for tween in _pulses:
		tween.kill()
	_pulses.clear()
	EventLog.log_event("map_closed", {"seconds": snappedf(EventLog.elapsed_seconds() - _opened_at, 0.1)})


func get_pins() -> Array[MapPin]:
	var result: Array[MapPin] = []
	for child in _pins.get_children():
		if child is MapPin:
			result.append(child)
	return result


func get_pin(location_id: String) -> MapPin:
	for pin in get_pins():
		if pin.location_id == location_id:
			return pin
	return null


func refresh() -> void:
	for pin in get_pins():
		var here := pin.location_id == GameState.current_location
		pin.visible = GameState.is_location_unlocked(pin.location_id)
		pin.disabled = here
		pin.text = pin.get_meta("base_text") + ("\n(you are here)" if here else "")
		pin.modulate = Color.WHITE
		if pin.visible and not here and pin.location_id not in GameState.visited_locations:
			var tween := create_tween().set_loops()
			tween.tween_property(pin, "modulate", Color(1.0, 0.8, 0.3), 0.45)
			tween.tween_property(pin, "modulate", Color.WHITE, 0.45)
			_pulses.append(tween)


func _on_pin_pressed(pin: MapPin) -> void:
	close()
	travel_requested.emit(pin.location_id)
