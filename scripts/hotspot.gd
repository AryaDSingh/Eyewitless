@tool
class_name Hotspot
extends PlaceholderArt
## Something the player can click in a location: a townie, a pigeon, a duck.
## When clicked it either plays a story knot, or a quick exchange: the
## Detective asks in the dialogue box, the hotspot answers in a bubble.

signal clicked(hotspot: Hotspot)

const BUBBLE_SECONDS := 1.4
const BUBBLE_MIN_WIDTH := 240.0
## Bubbles stay below the row of HUD icons (options, notebook, map) at the top.
const HUD_BOTTOM := 150.0
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
## Both can hold several lines split by "|": each click plays the next pair,
## and the last pair repeats. An empty part = no question that time.
@export var bubble := ""
## Only show this hotspot once this flag is set (empty = always shown).
@export var show_if_flag := ""
## Hide this hotspot once this flag is set.
@export var hide_if_flag := ""
## Sound played with the reply bubble, or on click for a knot (audio/<id>.ogg).
@export var sfx := ""

var _busy := false
var _exchanges := 0  # how many times this hotspot has answered
var _feel: Tween


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	# Hover: lift a little (from the feet). Click: a quick squash. Reads on line art
	# without outlines or tints.
	mouse_entered.connect(_bounce.bind(Vector2(1.05, 1.05), 0.15))
	mouse_exited.connect(_bounce.bind(Vector2.ONE, 0.15))


## Hover and clicks only count on the drawing, not its see-through corners, so
## overlapping pigeons each get their own clicks.
func _has_point(point: Vector2) -> bool:
	return is_drawn_at(point)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		if Audio.try_click(self):
			_squash()
			clicked.emit(self)


func _bounce(to: Vector2, seconds: float) -> void:
	if _feel:
		_feel.kill()
	pivot_offset = Vector2(size.x / 2, size.y)
	_feel = create_tween()
	_feel.tween_property(self, "scale", to, seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _squash() -> void:
	if _feel:
		_feel.kill()
	pivot_offset = Vector2(size.x / 2, size.y)
	_feel = create_tween()
	_feel.tween_property(self, "scale", Vector2(1.12, 0.92), 0.07)
	_feel.tween_property(self, "scale", Vector2(1.05, 1.05), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func refresh_visibility() -> void:
	var shown := show_if_flag == "" or GameState.has_flag(show_if_flag)
	if hide_if_flag != "" and GameState.has_flag(hide_if_flag):
		shown = false
	visible = shown


## Plays the ask / bubble exchange. detective_says(text) shows the question
## in the dialogue box and returns once the player clicks on.
func play_exchange(detective_says: Callable) -> void:
	if _busy:
		return
	_busy = true
	var asks := ask.split("|")
	var replies := bubble.split("|")
	var turn := mini(_exchanges, maxi(asks.size(), replies.size()) - 1)
	_exchanges += 1
	var question := asks[turn] if turn < asks.size() else ""
	var reply := replies[turn] if turn < replies.size() else ""
	if question != "":
		await detective_says.call(question)
	if reply != "":
		Audio.play_sfx(sfx)
		await say(reply)
	_busy = false


## Shows a speech bubble above this hotspot for a moment, its tail on the
## left. All-caps lines ("NO!") get the shout bubble.
func say(text: String) -> void:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shout := text == text.to_upper() and text.ends_with("!") and text.to_lower() != text
	panel.add_theme_stylebox_override("panel", _bubble_style(
			"shout" if shout else "left"))
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 36)
	panel.add_child(label)
	# The bubble art's ends (tail 150 + far side 40) don't shrink, so short replies
	# like "Coo." need a minimum width or the far end gets cut off.
	if not shout:
		panel.custom_minimum_size.x = BUBBLE_MIN_WIDTH
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(panel)
	var bubble_size := panel.get_combined_minimum_size()
	# Speech goes in front of everything (HUD icons, other people), and stays on screen.
	panel.z_index = 50
	var screen := get_viewport_rect().size
	# The tail lines up with the middle of the hotspot.
	var top_left := global_position + Vector2(size.x / 2 - TAIL_INSET, -bubble_size.y - 4)
	# On screen, and below the HUD icons along the top.
	top_left = top_left.clamp(Vector2(8, HUD_BOTTOM), screen - bubble_size - Vector2(8, 8))
	# Not scaled by the hotspot's hover/click bounce, which would push it off screen.
	panel.top_level = true
	panel.position = top_left
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
			style.texture_margin_top = 66.0  # the tape stays in the unstretched top strip
			style.texture_margin_bottom = 80.0
			style.content_margin_left = 52.0
			style.content_margin_right = 52.0
			style.content_margin_top = 66.0  # below the tape
			style.content_margin_bottom = 84.0
	return style
