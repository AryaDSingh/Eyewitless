class_name MapScreen
extends Control
## The town map. Every place has a pin; locked ones show ???. Click an
## unlocked place to travel there. New places use the highlighted "goto" pin
## until the player has been there.

signal travel_requested(location_id: String)

var _opened_at := 0.0

@onready var _pins: Control = %Pins
@onready var _close_button: Button = %CloseButton


func _ready() -> void:
	hide()
	_close_button.pressed.connect(close)
	for pin in get_pins():
		pin.pressed.connect(_on_pin_pressed.bind(pin))


func open() -> void:
	refresh()
	show()
	Audio.play_sfx("sfx_paper_unroll")
	_opened_at = EventLog.elapsed_seconds()
	EventLog.log_event("map_opened", {"location": GameState.current_location})


func close() -> void:
	if not visible:
		return
	hide()
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
		var id := pin.location_id
		if not GameState.is_location_unlocked(id):
			pin.set_look("locked")
			pin.set_residents([])
			continue
		var new_place := id not in GameState.visited_locations
		pin.set_look("goto" if new_place else "unlocked", id == GameState.current_location)
		pin.set_residents(_residents_at(id))


## Portraits of met characters who are found at this place (the "location"
## field in characters.json).
func _residents_at(location_id: String) -> Array:
	var portraits := []
	for id in GameState.met_characters:
		var character := GameState.get_character(id)
		if character.get("location", "") == location_id:
			portraits.append(character.get("portrait", ""))
	return portraits


func _on_pin_pressed(pin: MapPin) -> void:
	if not Audio.try_click():
		return
	close()
	travel_requested.emit(pin.location_id)
