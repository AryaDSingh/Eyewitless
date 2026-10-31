class_name MapPin
extends Button
## A place on the map: a pin with its name in a box underneath, from
## art/ui/pin_<look>.png and pin_box_<look>.png. Looks: "goto" (a place you
## haven't been yet), "unlocked" (any other open place), "locked" (shows ???,
## can't be clicked). Visited places look the same as any open place, so the
## map never suggests you're done with somewhere.
## Extras: "You are here" under the current place, and little polaroids of the
## residents you've met who are found there.
## In the editor, the middle of the button's rectangle is where the box's
## top-middle ends up.

const PIN_SCALE := 1.3
const NAME_FONT := preload("res://ui/fonts/CaveatBrush-Regular.ttf")
const STICKER_WIDTH := 58.0

## Must match the location's `location_id`.
@export var location_id := ""

var look := ""
var _place_name := ""
var _anchor := Vector2.ZERO
var _pin := TextureRect.new()
var _here := Label.new()
var _stickers := HBoxContainer.new()


func _ready() -> void:
	_place_name = text
	_anchor = position + size / 2
	_pin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	add_child(_pin)
	_here.text = "You are here"
	_here.add_theme_font_override("font", NAME_FONT)
	_here.add_theme_font_size_override("font_size", 26)
	_here.add_theme_color_override("font_color", Color(0.17, 0.17, 0.17))
	_here.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_here.hide()
	add_child(_here)
	_stickers.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stickers.add_theme_constant_override("separation", 4)
	add_child(_stickers)
	add_theme_font_override("font", NAME_FONT)
	add_theme_font_size_override("font_size", 32)
	set_look("goto")


func set_look(new_look: String, here := false) -> void:
	look = new_look
	disabled = look == "locked" or here
	text = "" if look == "locked" else _place_name
	var box: Texture2D = load("res://art/ui/pin_box_%s.png" % look)
	var style := StyleBoxTexture.new()
	style.texture = box
	style.set_texture_margin_all(10)
	style.content_margin_left = 20.0
	style.content_margin_right = 20.0
	style.content_margin_top = 4.0
	style.content_margin_bottom = 6.0
	custom_minimum_size = box.get_size() * PIN_SCALE if look == "locked" else Vector2.ZERO
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		add_theme_stylebox_override(state, style)
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	var text_color := Color.WHITE if look == "goto" else Color(0.17, 0.17, 0.17)
	for color in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_disabled_color"]:
		add_theme_color_override(color, text_color)
	size = Vector2.ZERO  # shrink to fit the new text
	position = Vector2(_anchor.x - size.x / 2, _anchor.y)
	var pin: Texture2D = load("res://art/ui/pin_%s.png" % look)
	_pin.texture = pin
	_pin.size = pin.get_size() * PIN_SCALE
	_pin.position = Vector2((size.x - _pin.size.x) / 2, -_pin.size.y - 4)
	_here.visible = here
	_here.size = _here.get_combined_minimum_size()
	_here.position = Vector2((size.x - _here.size.x) / 2, size.y + 2)


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
	_stickers.position = Vector2(_pin.position.x + _pin.size.x + 4, _pin.position.y - 10)
