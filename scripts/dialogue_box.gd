class_name DialogueBox
extends Control
## The conversation panel: portrait, name, text and choice buttons.
## Click anywhere (or press Space/Enter) to finish the text or continue.

signal _advanced(choice: int)

const CHARACTERS_PER_SECOND := 60.0

var _choice_texts: Array[String] = []
var _typing: Tween
var _ready_to_advance := false

@onready var _portrait: PlaceholderArt = %Portrait
@onready var _name: Label = %Name
@onready var _text: RichTextLabel = %Text
@onready var _choices: VBoxContainer = %Choices
@onready var _continue_hint: Label = %ContinueHint


func _ready() -> void:
	hide()


## Shows one line. Returns the index of the choice picked, or -1 if there
## were no choices.
func show_line(speaker: String, text: String, choices: Array[String]) -> int:
	var character := GameState.get_character(speaker)
	_name.text = character.get("name", speaker)
	_name.visible = speaker != ""
	_portrait.visible = speaker != ""
	_portrait.art_id = character.get("portrait", "portrait_" + speaker.to_lower())
	_text.text = text
	_text.visible_ratio = 0.0
	_choice_texts = choices
	_ready_to_advance = false
	for child in _choices.get_children():
		child.queue_free()
	_continue_hint.hide()
	show()
	_typing = create_tween()
	_typing.tween_property(_text, "visible_ratio", 1.0, maxf(text.length() / CHARACTERS_PER_SECOND, 0.05))
	_typing.finished.connect(_on_typing_finished)
	var picked: int = await _advanced
	return picked


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
	_continue_hint.visible = _choice_texts.is_empty()
	for i in _choice_texts.size():
		var button := Button.new()
		button.text = _choice_texts[i]
		button.pressed.connect(choose.bind(i))
		_choices.add_child(button)
	if not _choice_texts.is_empty():
		(_choices.get_child(0) as Button).grab_focus.call_deferred()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		advance()


func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_accept") and _choice_texts.is_empty():
		get_viewport().set_input_as_handled()
		advance()
