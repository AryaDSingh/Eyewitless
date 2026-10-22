class_name CardScreen
extends Control
## A full-screen picture with text and one button: the title screen, letters,
## "THESE ARE DUCKS!", "CASE SOLVED!" and the ending panels.

signal closed

@onready var _art: PlaceholderArt = %Art
@onready var _text: Label = %Text
@onready var _button: Button = %Button


func _ready() -> void:
	hide()
	_button.pressed.connect(press)


## Shows a card and waits until its button is pressed.
## Use "none" as the art id for a card with text only.
func show_card(art_id: String, text: String, button_text: String) -> void:
	_art.visible = art_id != "" and art_id != "none"
	_art.art_id = art_id
	_text.text = text
	_text.visible = text != ""
	_button.text = button_text if button_text != "" else "Next"
	show()
	_button.grab_focus.call_deferred()
	var shown_at := EventLog.elapsed_seconds()
	EventLog.log_event("card_shown", {"art": art_id})
	await closed
	EventLog.log_event("card_closed", {"art": art_id, "seconds": snappedf(EventLog.elapsed_seconds() - shown_at, 0.1)})


func press() -> void:
	hide()
	closed.emit()
