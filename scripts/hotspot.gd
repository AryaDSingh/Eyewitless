@tool
class_name Hotspot
extends PlaceholderArt
## Something the player can click in a location: a townie, a pigeon, a duck.
## When clicked it either plays a story knot, or a quick bubble exchange
## (the detective asks, the hotspot answers with a short line).

signal clicked(hotspot: Hotspot)

const BUBBLE_SECONDS := 1.4

## Story knot to play when clicked (see resources/cases/*.story).
@export var knot := ""
## Without a knot: what the detective asks first (optional)...
@export var ask := ""
## ...and the short reply shown above this hotspot, e.g. "NO!".
@export var bubble := ""
## Only show this hotspot once this flag is set (empty = always shown).
@export var show_if_flag := ""
## Hide this hotspot once this flag is set.
@export var hide_if_flag := ""

var _busy := false


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(func(): modulate = Color(1.2, 1.2, 1.2))
	mouse_exited.connect(func(): modulate = Color.WHITE)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		clicked.emit(self)


func refresh_visibility() -> void:
	var shown := show_if_flag == "" or GameState.has_flag(show_if_flag)
	if hide_if_flag != "" and GameState.has_flag(hide_if_flag):
		shown = false
	visible = shown


## Plays the ask / bubble exchange.
func play_exchange() -> void:
	if _busy:
		return
	_busy = true
	if ask != "":
		await say(ask, true)
	if bubble != "":
		await say(bubble)
	_busy = false


## Shows a speech bubble above this hotspot for a moment.
func say(text: String, from_detective := false) -> void:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 0.95, 0.7) if from_detective else Color.WHITE
	style.border_color = Color(0.15, 0.13, 0.12)
	style.set_border_width_all(3)
	style.set_corner_radius_all(16)
	style.set_content_margin_all(14)
	panel.add_theme_stylebox_override("panel", style)
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 34)
	label.add_theme_color_override("font_color", Color(0.15, 0.13, 0.12) if from_detective else Color(0.8, 0.1, 0.1))
	panel.add_child(label)
	add_child(panel)
	var bubble_size := panel.get_combined_minimum_size()
	var x_offset := -bubble_size.x * 0.6 if from_detective else 0.0
	panel.position = Vector2((size.x - bubble_size.x) / 2 + x_offset, -bubble_size.y - 12)
	await get_tree().create_timer(BUBBLE_SECONDS).timeout
	panel.queue_free()
