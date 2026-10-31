@tool
class_name Hotspot
extends PlaceholderArt
## Something the player can click in a location: a townie, a pigeon, a duck.
## When clicked it either plays a story knot, or a quick bubble exchange
## (the detective asks, the hotspot answers with a short line).

signal clicked(hotspot: Hotspot)

const BUBBLE_SECONDS := 1.4
const BUBBLE_LEFT := preload("res://art/ui/bubble_speech_left.png")
const BUBBLE_RIGHT := preload("res://art/ui/bubble_speech_right.png")
const BUBBLE_SHOUT := preload("res://art/ui/bubble_shout.png")
## How far the bubble's tail is from its side, in pixels.
const TAIL_INSET := 100.0

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
## Sound played with the reply bubble, or on click for a knot (audio/<id>.ogg).
@export var sfx := ""

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
		if Audio.try_click():
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
		Audio.play_sfx(sfx)
		await say(bubble)
	_busy = false


## Shows a speech bubble above this hotspot for a moment. The Detective's
## bubble sits to the left with its tail on the right; the hotspot's own
## reply has its tail on the left. All-caps lines ("NO!") get the shout bubble.
func say(text: String, from_detective := false) -> void:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shout := text == text.to_upper() and text.ends_with("!") and text.to_lower() != text
	panel.add_theme_stylebox_override("panel", _bubble_style(
			"shout" if shout else ("right" if from_detective else "left")))
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 36)
	panel.add_child(label)
	add_child(panel)
	var bubble_size := panel.get_combined_minimum_size()
	# Line the tail up with the middle of the hotspot.
	var x := size.x / 2 - (bubble_size.x - TAIL_INSET if from_detective else TAIL_INSET)
	panel.position = Vector2(x, -bubble_size.y - 4)
	# Speech goes in front of everything (HUD icons, other people), and stays on screen.
	panel.z_index = 50
	var screen := get_viewport_rect().size
	var top_left := global_position + panel.position
	top_left = top_left.clamp(Vector2(8, 8), screen - bubble_size - Vector2(8, 8))
	panel.position = top_left - global_position
	await get_tree().create_timer(BUBBLE_SECONDS).timeout
	panel.queue_free()


static func _bubble_style(kind: String) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	match kind:
		"shout":
			# Spiky outline: stretch the whole picture rather than slicing it.
			style.texture = BUBBLE_SHOUT
			style.set_content_margin_all(64)
		"left", "right":
			style.texture = BUBBLE_LEFT if kind == "left" else BUBBLE_RIGHT
			# Keep the tail corner unstretched.
			style.texture_margin_left = 150.0 if kind == "left" else 40.0
			style.texture_margin_right = 40.0 if kind == "left" else 150.0
			style.texture_margin_top = 50.0
			style.texture_margin_bottom = 80.0
			style.content_margin_left = 44.0
			style.content_margin_right = 44.0
			style.content_margin_top = 40.0
			style.content_margin_bottom = 84.0
	return style
