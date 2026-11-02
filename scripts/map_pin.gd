class_name MapPin
extends Button
## A place on the map: its name on a small taped paper label, placed next to
## the building on Samantha's map so the drawing stays visible. Clicking the
## label or the building (`building`) travels there. Looks: "goto" (a place
## you haven't been yet: a red pen circle is drawn around it), "unlocked" (any
## other open place), "locked" (a faded "???" label, can't be clicked).
## Extras: "you are here" under the current place, and little polaroids of the
## residents you've met who are found there.
## In the editor, the middle of the button's rectangle is where the label's
## middle ends up.

const NAME_FONT := preload("res://ui/fonts/CaveatBrush-Regular.ttf")
const STICKER_WIDTH := 58.0
const PAPER := Color(0.965, 0.957, 0.925)
const INK := Color(0.12, 0.11, 0.1)
const FADED := Color(0.55, 0.55, 0.55)
## New places get a red pen circle (the ink of the circle on Alex's photo),
## drawn on each time the map opens, while the label hops a few times. Then it
## all stays still until the place is visited.
const INK_RED := Color(0.83, 0.25, 0.24)
const CIRCLE_SECONDS := 0.5
const CIRCLE_WIDTH := 4.0

## Must match the location's `location_id`.
@export var location_id := ""
## The place's drawing on the map (in map pixels), clickable like the label.
@export var building := Rect2()

var look := ""
var _place_name := ""
var _anchor := Vector2.ZERO
var _here := Label.new()
var _stickers := HBoxContainer.new()
var _spot := Control.new()
var _circle := Control.new()
var _circle_drawn := 0.0  # 0..1, how much of the circle the pen has drawn
var _intro: Tween
var _style: StyleBoxFlat
var _hover: StyleBoxFlat


func _ready() -> void:
	_place_name = text
	_anchor = position + size / 2
	# A slight tilt, different per place, like labels stuck on by hand.
	rotation_degrees = [-3.0, 2.0, -1.5, 3.0, -2.0, 1.0][absi(hash(location_id)) % 6]
	Tape.stick(self)
	_here.text = "you are here"
	_here.add_theme_font_override("font", NAME_FONT)
	_here.add_theme_font_size_override("font_size", 36)
	_here.add_theme_color_override("font_color", INK_RED)
	_here.add_theme_color_override("font_outline_color", PAPER)
	_here.add_theme_constant_override("outline_size", 14)
	_here.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_here.hide()
	add_child(_here)
	_stickers.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stickers.add_theme_constant_override("separation", 4)
	add_child(_stickers)
	_circle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_circle.draw.connect(_draw_circle)
	add_child(_circle)
	add_theme_font_override("font", NAME_FONT)
	add_theme_font_size_override("font_size", 36)
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	# The building is clickable too: an invisible spot on top of it.
	_spot.position = building.position
	_spot.size = building.size
	_spot.gui_input.connect(_on_spot_input)
	# Hovering the building lights up its label, like hovering the label itself.
	_spot.mouse_entered.connect(func(): if not disabled: add_theme_stylebox_override("normal", _hover))
	_spot.mouse_exited.connect(func(): add_theme_stylebox_override("normal", _style))
	add_sibling.call_deferred(_spot)
	set_look("goto")


func set_look(new_look: String, here := false) -> void:
	look = new_look
	disabled = look == "locked" or here
	text = "???" if look == "locked" else _place_name
	var ink := FADED if look == "locked" else INK
	var style := StyleBoxFlat.new()
	style.bg_color = PAPER
	style.border_color = ink
	style.set_border_width_all(3)
	style.content_margin_left = 22.0
	style.content_margin_right = 22.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	style.shadow_color = Color(0, 0, 0, 0.12)
	style.shadow_offset = Vector2(3, 4)
	style.shadow_size = 2
	var hover := style.duplicate() as StyleBoxFlat
	hover.bg_color = Color.WHITE
	for state in ["normal", "pressed", "disabled"]:
		add_theme_stylebox_override(state, style)
	for state in ["hover", "hover_pressed"]:
		add_theme_stylebox_override(state, hover)
	_style = style
	_hover = hover
	for color in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_disabled_color"]:
		add_theme_color_override(color, ink)
	size = Vector2.ZERO  # shrink to fit the new text
	position = _anchor - size / 2
	pivot_offset = size / 2
	_spot.mouse_default_cursor_shape = Control.CURSOR_ARROW if disabled else Control.CURSOR_POINTING_HAND
	_here.visible = here
	_here.size = _here.get_combined_minimum_size()
	_here.position = Vector2((size.x - _here.size.x) / 2, size.y + 2)
	_circle_new_place(look == "goto" and not here)


## Little polaroids of who you'll find here (portrait art ids).
func set_residents(portraits: Array) -> void:
	for child in _stickers.get_children():
		child.queue_free()
	for i in portraits.size():
		var sticker := Polaroid.new().setup(portraits[i])
		sticker.custom_minimum_size = Vector2(STICKER_WIDTH, STICKER_WIDTH / Polaroid.ASPECT)
		sticker.rotation_degrees = -6.0 if i % 2 == 0 else 5.0
		_stickers.add_child(sticker)
	_stickers.size = _stickers.get_combined_minimum_size()
	_stickers.position = Vector2(size.x + 10, (size.y - _stickers.size.y) / 2)


func _on_spot_input(event: InputEvent) -> void:
	if not disabled and event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		_spot.accept_event()
		pressed.emit()


func _circle_new_place(on: bool) -> void:
	if _intro:
		_intro.kill()
	var label_y := _anchor.y - size.y / 2
	position.y = label_y
	_circle.visible = on
	if not on:
		return
	# Around the label and the building together (in the label's own space).
	var area := Rect2(Vector2.ZERO, size)
	if building.has_area():
		area = area.merge(Rect2(building.position - position, building.size))
	_circle.position = area.position
	_circle.size = area.size
	_intro = create_tween()
	_intro.tween_method(_set_circle_drawn, 0.0, 1.0, CIRCLE_SECONDS).set_ease(Tween.EASE_OUT)
	# Two hops, the second smaller, then still.
	for hop in [14.0, 6.0]:
		_intro.tween_property(self, "position:y", label_y - hop, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		_intro.tween_property(self, "position:y", label_y, 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


func _set_circle_drawn(amount: float) -> void:
	_circle_drawn = amount
	_circle.queue_redraw()


## A loose hand-drawn loop: a bit wobbly, and the end overshoots the start.
func _draw_circle() -> void:
	var center := _circle.size / 2
	var radius := _circle.size / 2 * 1.15 + Vector2(14, 14)
	var steps := int(72 * _circle_drawn)
	if steps < 2:
		return
	var points := PackedVector2Array()
	for i in steps + 1:
		var t := float(i) / 72.0
		var angle := deg_to_rad(-110.0) + t * TAU * 1.1
		var wobble := 1.0 + 0.035 * sin(angle * 3.0 + 1.3) + 0.02 * sin(angle * 7.0) + 0.05 * t
		points.append(center + Vector2(cos(angle), sin(angle)) * radius * wobble)
	_circle.draw_polyline(points, INK_RED, CIRCLE_WIDTH, true)
