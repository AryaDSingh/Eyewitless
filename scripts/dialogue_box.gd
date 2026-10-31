class_name DialogueBox
extends Control
## The conversation panel: portrait, name, text and choice buttons, drawn on
## the dialogue box art in art/ui/. A Detective line that is all
## [i]italics[/i] is a thought and uses the thought-cloud box.
## Click anywhere (or press Space/Enter) to finish the text or continue.

signal _advanced(choice: int)

const CHARACTERS_PER_SECOND := 60.0
const BOX_WIDTH := 1840.0
const BOTTOM_MARGIN := 20.0
const CHOICES_WIDTH := 560.0
const CHOICES_GAP := 24.0
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

@onready var _box: TextureRect = %Box
@onready var _portrait: PlaceholderArt = %Portrait
@onready var _name: Label = %Name
@onready var _text: RichTextLabel = %Text
@onready var _choices: VBoxContainer = %Choices


func _ready() -> void:
	hide()


## Shows one line. Returns the index of the choice picked, or -1 if there
## were no choices.
func show_line(speaker: String, text: String, choices: Array[String]) -> int:
	var character := GameState.get_character(speaker)
	var thought := speaker.to_lower() == "detective" and text.begins_with("[i]") and text.ends_with("[/i]")
	if thought:
		text = text.trim_prefix("[i]").trim_suffix("[/i]")
	_layout("thought" if thought else ("no_portrait" if speaker == "" else "default"), not choices.is_empty())
	_name.text = character.get("name", speaker)
	_name.visible = speaker != ""
	_portrait.art_id = character.get("portrait", "portrait_" + speaker.to_lower())
	_text.text = text
	_text.visible_ratio = 0.0
	_choice_texts = choices
	_ready_to_advance = false
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
		_advanced.emit(-1)


func choose(index: int) -> void:
	if is_waiting_for_choice():
		_ready_to_advance = false
		_advanced.emit(index)


func _on_typing_finished() -> void:
	if _ready_to_advance:
		return
	_ready_to_advance = true
	for i in _choice_texts.size():
		var button := Button.new()
		button.text = _choice_texts[i]
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.pressed.connect(_on_choice_pressed.bind(i))
		_choices.add_child(button)
	if not _choice_texts.is_empty():
		(_choices.get_child(0) as Button).grab_focus.call_deferred()


func _on_choice_pressed(index: int) -> void:
	if Audio.try_click():
		choose(index)


## Finishing the typing is always allowed; moving on waits for the click cooldown.
func _on_player_advance() -> void:
	if _typing and _typing.is_running():
		advance()
	elif _ready_to_advance and _choice_texts.is_empty() and Audio.try_click():
		advance()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		_on_player_advance()


func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_accept") and _choice_texts.is_empty():
		get_viewport().set_input_as_handled()
		_on_player_advance()
