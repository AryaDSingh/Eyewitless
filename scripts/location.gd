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
## Music track here (audio/<id>). Empty keeps whatever is already playing.
@export var music := ""
## Background loop here, e.g. birds or a crowd. Empty means silence.
@export var ambience := ""
## Play the music as if through a wall.
@export var muffle_music := false

## Parallax: a child with metadata "parallax" drifts sideways against the mouse,
## up to that many pixels at the screen edges (0 or none = still). Far layers
## get small numbers, near ones big. Background layers need that much extra
## width past the screen edges.
const PARALLAX_EASE := 5.0

var _drift := 0.0  # -1..1, eased towards the mouse


func _ready() -> void:
	for hotspot in get_hotspots():
		hotspot.clicked.connect(func(clicked: Hotspot): hotspot_clicked.emit(clicked))
	GameState.changed.connect(refresh)
	refresh()


func _process(delta: float) -> void:
	var width := get_viewport_rect().size.x
	var target := clampf(1.0 - 2.0 * get_viewport().get_mouse_position().x / width, -1.0, 1.0)
	var eased := lerpf(_drift, target, minf(1.0, delta * PARALLAX_EASE))
	var step := eased - _drift
	_drift = eased
	if is_zero_approx(step):
		return
	# Moves by the change only, so layout or other code can still place things.
	for child in get_children():
		if child.has_meta("parallax"):
			child.position.x += step * float(child.get_meta("parallax"))


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
