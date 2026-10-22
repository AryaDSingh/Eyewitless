class_name Location
extends Control
## A place in Muddleford (park, bar, plaza...). Holds a background and the
## Hotspots the player can click. Each location is its own scene in
## scenes/locations/, so artists can move things around in the editor.

signal hotspot_clicked(hotspot: Hotspot)

## Must match the id used by the map pins and `~ goto` / `~ unlock`.
@export var location_id := ""
@export var display_name := ""
## Story knot that plays every time the player arrives here (optional).
@export var on_enter_knot := ""


func _ready() -> void:
	for hotspot in get_hotspots():
		hotspot.clicked.connect(func(clicked: Hotspot): hotspot_clicked.emit(clicked))
	GameState.changed.connect(refresh)
	refresh()


func get_hotspots() -> Array[Hotspot]:
	var result: Array[Hotspot] = []
	for node in find_children("*", "", true, false):
		if node is Hotspot:
			result.append(node)
	return result


func get_hotspot(hotspot_name: String) -> Hotspot:
	return find_child(hotspot_name, true, false) as Hotspot


func refresh() -> void:
	for hotspot in get_hotspots():
		hotspot.refresh_visibility()
