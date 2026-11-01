class_name DialogueBox
extends Control
## The conversation panel: portrait, name, text and choice buttons, drawn on
## the dialogue box art in art/ui/. The Detective's lines use the box without
## a portrait; their thoughts are written in [i]italics[/i].
## Click anywhere (or press Space/Enter) to finish the text or continue.

signal _advanced(choice: int)

const CHARACTERS_PER_SECOND := 60.0
const BOX_WIDTH := 2000.0  # wider than the screen (the art has see-through margins), so nothing peeks out at the ends
const BOTTOM_MARGIN := 20.0
const CHOICES_WIDTH := 560.0
const CHOICES_GAP := 24.0
## A tick plays every this many letters while the text types (not on voiced lines).
const TICK_EVERY := 3
## Ruby's "→", cut out of the box art so it can nudge. Where it sat on the box picture.
const ARROW := preload("res://art/ui/dialogue_arrow.png")
const ARROW_SPOT := Vector2(1524, 237)
## Where things sit on each box picture, in the picture's own pixels.
const BOXES := {
	"default": {
		"texture": preload("res://art/ui/dialogue_box.png"),
		"portrait": Rect2(55, 90, 170, 160), "name": Rect2(268, 30, 186, 56), "text": Rect2(290, 104, 1290, 176),
	},
	"thought": {
		"texture": preload("res://art/ui/dialogue_box_thought.png"),
		"portrait": Rect2(112, 90, 168, 160), "name": Rect2(325, 29, 242, 58), "text": Rect2(335, 104, 1290, 180),
	},
	"no_portrait": {
		"texture": preload("res://art/ui/dialogue_box_no_portrait.png"),
		"portrait": Rect2(), "name": Rect2(70, 29, 185, 56), "text": Rect2(165, 104, 1415, 176),
	},
}

var _choice_texts: Array[String] = []
var _typing: Tween
var _ready_to_advance := false
var _ticked_at := 0  # letters typed when the last tick played
## The "click to continue" arrow, bottom right, nudging.
var _arrow := TextureRect.new()

@onready var _box: TextureRect = %Box
@onready var _portrait: PlaceholderArt = %Portrait
@onready var _name: Label = %Name
@onready var _text: RichTextLabel = %Text
@onready var _choices: VBoxContainer = %Choices


func _ready() -> void:
	hide()
	_arrow.texture = ARROW
	_arrow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_arrow.hide()
	_box.add_child(_arrow)


func _process(_delta: float) -> void:
	if not (_typing and _typing.is_running()):
		return
	var typed := _text.visible_characters
	if typed - _ticked_at >= TICK_EVERY:
		_ticked_at = typed
		var letter := _text.get_parsed_text().substr(typed - 1, 1)
		if letter.strip_edges() != "" and not Audio.is_voice_playing():
			Audio.play_tick()


## Shows one line. Returns the index of the choice picked, or -1 if there
## were no choices.
func show_line(speaker: String, text: String, choices: Array[String]) -> int:
	var character := GameState.get_character(speaker)
	# The Detective has no portrait (for inclusivity; the player is the Detective),
	# so their lines (thoughts too, in italics) use the box without a photo.
	var no_portrait := speaker == "" or speaker.to_lower() == "detective"
	_layout("no_portrait" if no_portrait else "default", not choices.is_empty())
	_name.text = character.get("name", speaker)
	_name.visible = speaker != ""
	_portrait.art_id = character.get("portrait", "portrait_" + speaker.to_lower())
	_text.text = text
	_text.visible_ratio = 0.0
	_choice_texts = choices
	_ready_to_advance = false
	_ticked_at = 0
	_arrow.hide()
	for child in _choices.get_children():
		child.queue_free()
	show()
	_typing = create_tween()
	_typing.tween_property(_text, "visible_ratio", 1.0, maxf(text.length() / CHARACTERS_PER_SECOND, 0.05))
	_typing.finished.connect(_on_typing_finished)
	var picked: int = await _advanced
	return picked


## Puts the box picture at the bottom of the screen, scaled to BOX_WIDTH, and
## the portrait, name and text on their spots on it.
func _layout(kind: String, has_choices: bool) -> void:
	var box: Dictionary = BOXES[kind]
	var texture: Texture2D = box.texture
	var scale := BOX_WIDTH / texture.get_width()
	_box.texture = texture
	_box.size = texture.get_size() * scale
	_box.position = Vector2((size.x - _box.size.x) / 2, size.y - _box.size.y - BOTTOM_MARGIN)
	var portrait: Rect2 = box.portrait
	_portrait.visible = portrait.has_area()
	_place(_portrait, portrait, scale)
	_place(_name, box.name, scale)
	var text: Rect2 = box.text
	_place(_text, text, scale)
	_arrow.size = ARROW.get_size() * scale
	_arrow.position = ARROW_SPOT * scale
	# Nudge right and back, pointing on.
	if not _arrow.has_meta("nudge"):
		var nudge := create_tween().set_loops()
		nudge.tween_property(_arrow, "position:x", _arrow.position.x + 8, 0.45).set_trans(Tween.TRANS_SINE)
		nudge.tween_property(_arrow, "position:x", _arrow.position.x, 0.45).set_trans(Tween.TRANS_SINE)
		_arrow.set_meta("nudge", nudge)
	_choices.visible = has_choices
	if has_choices:
		_text.size.x -= CHOICES_WIDTH + CHOICES_GAP
		_choices.position = Vector2(text.end.x * scale - CHOICES_WIDTH, text.position.y * scale)
		_choices.size = Vector2(CHOICES_WIDTH, text.size.y * scale)


func _place(control: Control, rect: Rect2, scale: float) -> void:
	control.position = rect.position * scale
	control.size = rect.size * scale


func get_choice_texts() -> Array[String]:
	return _choice_texts


func is_waiting_for_choice() -> bool:
	return _ready_to_advance and not _choice_texts.is_empty()


## Same as clicking: finishes the text, or moves to the next line.
func advance() -> void:
	if _typing and _typing.is_running():
		_typing.kill()
		_text.visible_ratio = 1.0
		_on_typing_finished()
	elif _ready_to_advance and _choice_texts.is_empty():
		_ready_to_advance = false
		_arrow.hide()
		Audio.stop_voice()
		_advanced.emit(-1)


func choose(index: int) -> void:
	if is_waiting_for_choice():
		_ready_to_advance = false
		Audio.stop_voice()
		_advanced.emit(index)


func _on_typing_finished() -> void:
	if _ready_to_advance:
		return
	_ready_to_advance = true
	_arrow.visible = _choice_texts.is_empty()
	for i in _choice_texts.size():
		var button := Button.new()
		button.text = _choice_texts[i]
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.pressed.connect(_on_choice_pressed.bind(i))
		_choices.add_child(button)
	if not _choice_texts.is_empty():
		(_choices.get_child(0) as Button).grab_focus.call_deferred()


func _on_choice_pressed(index: int) -> void:
	if Audio.try_click(self):
		choose(index)


## Finishing the typing is always allowed; moving on waits for the click cooldown.
func _on_player_advance() -> void:
	if _typing and _typing.is_running():
		advance()
	elif _ready_to_advance and _choice_texts.is_empty() and Audio.try_click(self):
		advance()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		_on_player_advance()


func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_accept") and _choice_texts.is_empty():
		get_viewport().set_input_as_handled()
		_on_player_advance()
