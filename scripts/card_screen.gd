class_name CardScreen
extends Control
## A full-screen picture with text and one button: letters, the envelope,
## photos, "O.M.G.!!", "CASE SOLVED!" and the ending panels.
##
## Options (the 4th part of `~ card`, separated by spaces):
## - letter: the text is written on the picture, like a letter.
## - photo=<art_id>: pins a small photo on the letter.
## - framed: the picture is a photo, shown in a white photo frame.
## - unroll / pop / stamp / grow: how the picture appears. grow = a small photo
##   that grows to full size. (zoom / zoom=0.7,0.4 still work: zooms into a spot.)
## - click: no button; the player clicks the picture itself.
## - pull=<letter_art>,<front_art>: the picture is the back of an envelope; the
##   letter sits in it with the front flaps on top. Hovering the letter slides it
##   up out of the envelope; clicking it continues. All three pictures are the
##   same size (art/envelope_back, _letter, _front).

signal closed

const ART_SIZE := Vector2(1200, 620)
const LETTER_SIZE := Vector2(1600, 860)
const LETTER_FONT_MAX := 34
const LETTER_FONT_MIN := 18
const LETTER_MARGIN := 110.0
const PINNED_GAP := 40.0

var _click_art := false
var _intro: Tween
var _pull_letter := TextureRect.new()
var _pull_front := TextureRect.new()
var _pull_tween: Tween
var _letter_out := false
var _letter_image: Image  # to tell if the mouse is on the letter or a see-through part
const PULL_LIFT := 0.06  # how far the letter slides up on hover (fraction of its height)

@onready var _art_clip: Control = %ArtClip
@onready var _art: PlaceholderArt = %Art
@onready var _letter_text: RichTextLabel = %LetterText
@onready var _pinned: Polaroid = %Pinned
@onready var _photo_card: Polaroid = %PhotoCard
@onready var _text: Label = %Text
@onready var _button: Button = %Button


func _ready() -> void:
	hide()
	_button.pressed.connect(_on_button_pressed)
	for layer: TextureRect in [_pull_letter, _pull_front]:
		layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		layer.stretch_mode = TextureRect.STRETCH_SCALE
		layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_art.add_child(layer)
	_pull_letter.mouse_filter = Control.MOUSE_FILTER_STOP
	_pull_letter.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_pull_letter.gui_input.connect(_on_pull_input)
	_pull_letter.mouse_exited.connect(_set_letter_out.bind(false))
	_art.gui_input.connect(_on_art_input)
	# Clickable pictures lift and tilt a little under the mouse (no tint).
	_art.mouse_entered.connect(_lift_art.bind(true))
	_art.mouse_exited.connect(_lift_art.bind(false))


## Shows a card and waits until its button (or picture) is clicked.
## Use "none" as the art id for a card with text only.
func show_card(art_id: String, text: String, button_text: String, options := "") -> void:
	var words := options.split(" ", false)
	var letter := "letter" in words
	var framed := "framed" in words
	var photo := _option(words, "photo")
	var pull := _option(words, "pull").split(",")
	_click_art = "click" in words and pull.size() != 2
	_pull_letter.visible = pull.size() == 2
	_pull_front.visible = _pull_letter.visible
	if _pull_letter.visible:
		_pull_letter.texture = PlaceholderArt.find_texture(pull[0])
		_letter_image = _pull_letter.texture.get_image() if _pull_letter.texture else null
		_letter_out = false
		_pull_front.texture = PlaceholderArt.find_texture(pull[1])
		_pull_letter.size = Vector2.ZERO  # placed once the picture has its size (_animate_in)
		_pull_front.size = Vector2.ZERO
	_art_clip.visible = art_id != "" and art_id != "none"
	_art.art_id = art_id
	# The picture is clipped to this box, so zooming in never covers the text.
	_art_clip.custom_minimum_size = LETTER_SIZE if letter else ART_SIZE
	if framed:
		_art_clip.custom_minimum_size = Vector2(ART_SIZE.y * Polaroid.ASPECT, ART_SIZE.y)
	_art.visible = not framed
	_photo_card.visible = framed
	_photo_card.setup(art_id)
	_art.modulate = Color.WHITE
	_art.mouse_filter = Control.MOUSE_FILTER_STOP if _click_art else Control.MOUSE_FILTER_IGNORE
	_art.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if _click_art else Control.CURSOR_ARROW
	_letter_text.visible = letter
	_letter_text.text = text if letter else ""
	_letter_text.offset_right = -LETTER_MARGIN - (_pinned.size.x + PINNED_GAP if photo != "" else 0.0)
	_pinned.visible = photo != ""
	_pinned.setup(photo)
	_text.text = "" if letter else text
	_text.visible = _text.text != ""
	_button.visible = not _click_art and not _pull_letter.visible
	_button.text = button_text if button_text != "" else "Next"
	show()
	if _button.visible:
		_button.grab_focus.call_deferred()
	_animate_in(words, letter)
	var shown_at := EventLog.elapsed_seconds()
	EventLog.log_event("card_shown", {"art": art_id, "options": options})
	await closed
	EventLog.log_event("card_closed", {"art": art_id, "seconds": snappedf(EventLog.elapsed_seconds() - shown_at, 0.1)})


func press() -> void:
	if _intro:
		_intro.kill()
	if _pull_tween:
		_pull_tween.kill()
	_art.scale = Vector2.ONE
	_art.rotation = 0.0
	_art_clip.scale = Vector2.ONE
	_art_clip.rotation = 0.0
	hide()
	closed.emit()


func _on_button_pressed() -> void:
	if Audio.try_click():
		press()


func _lift_art(up: bool) -> void:
	if not _click_art:
		return
	if _pull_tween:
		_pull_tween.kill()
	# Lift the clip box, not the picture inside it, so the edges aren't cut off.
	_art_clip.pivot_offset = _art_clip.size / 2
	_pull_tween = create_tween().set_parallel()
	_pull_tween.tween_property(_art_clip, "scale", Vector2(1.04, 1.04) if up else Vector2.ONE, 0.2).set_trans(Tween.TRANS_SINE)
	_pull_tween.tween_property(_art_clip, "rotation_degrees", -1.5 if up else 0.0, 0.2).set_trans(Tween.TRANS_SINE)


func _set_letter_out(out: bool) -> void:
	if out == _letter_out:
		return
	_letter_out = out
	if _pull_tween:
		_pull_tween.kill()
	var drawn := _art.get_drawn_rect()
	_pull_tween = create_tween()
	_pull_tween.tween_property(_pull_letter, "position:y", drawn.position.y - (drawn.size.y * PULL_LIFT if out else 0.0), 0.25) 			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


## True if this point (in the letter's own coordinates) is on the letter itself.
func _on_letter(point: Vector2) -> bool:
	if _letter_image == null or _pull_letter.size.x <= 0:
		return true
	var pixel := Vector2i(point / _pull_letter.size * Vector2(_letter_image.get_size()))
	if not Rect2i(Vector2i.ZERO, _letter_image.get_size()).has_point(pixel):
		return false
	return _letter_image.get_pixelv(pixel).a > 0.5


func _on_pull_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var over := _on_letter(event.position)
		_set_letter_out(over)
		_pull_letter.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if over else Control.CURSOR_ARROW
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT 			and _on_letter(event.position) and Audio.try_click():
		accept_event()
		press()


func _on_art_input(event: InputEvent) -> void:
	if _click_art and event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT and Audio.try_click():
		accept_event()
		press()


## Not awaited by show_card, so a click during the animation still closes the card.
func _animate_in(words: PackedStringArray, letter: bool) -> void:
	if _intro:
		_intro.kill()
	_art.scale = Vector2.ONE
	_art_clip.scale = Vector2.ONE
	# Wait one frame so the picture has its final size.
	await get_tree().process_frame
	if not visible:
		return
	if letter:
		_fit_letter_text()
	if _pull_letter.visible:
		var drawn := _art.get_drawn_rect()
		for layer: TextureRect in [_pull_letter, _pull_front]:
			layer.position = drawn.position
			layer.size = drawn.size
	_intro = create_tween()
	var art_size := _art.size
	if "unroll" in words:
		_art.pivot_offset = Vector2(art_size.x / 2, 0)
		_art.scale = Vector2(1, 0)
		_intro.tween_property(_art, "scale", Vector2.ONE, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	elif "pop" in words:
		_art.pivot_offset = art_size / 2
		_art.scale = Vector2(0.6, 0.6)
		_intro.tween_property(_art, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	elif "grow" in words:
		_art_clip.pivot_offset = _art_clip.size / 2
		_art_clip.scale = Vector2(0.3, 0.3)
		_intro.tween_property(_art_clip, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	elif "stamp" in words:
		_art.pivot_offset = art_size / 2
		_art.scale = Vector2(2.2, 2.2)
		_intro.tween_property(_art, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	elif "zoom" in words or _option(words, "zoom") != "":
		var spot := _option(words, "zoom").split(",")
		var focus := Vector2(0.5, 0.5)
		if spot.size() == 2:
			focus = Vector2(spot[0].to_float(), spot[1].to_float())
		_art.pivot_offset = art_size * focus
		_intro.tween_property(_art, "scale", Vector2(1.35, 1.35), 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	else:
		_intro.kill()


## Shrinks the letter text until it fits on the paper.
func _fit_letter_text() -> void:
	for font_size in range(LETTER_FONT_MAX, LETTER_FONT_MIN - 1, -2):
		for kind in ["normal_font_size", "bold_font_size", "italics_font_size"]:
			_letter_text.add_theme_font_size_override(kind, font_size)
		if _letter_text.get_content_height() <= _letter_text.size.y:
			return


## "photo=clue_x" -> "clue_x"
func _option(words: PackedStringArray, key: String) -> String:
	for word in words:
		if word.begins_with(key + "="):
			return word.trim_prefix(key + "=")
	return ""
