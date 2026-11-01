class_name TitleScreen
extends Control
## The first screen: the game title, START, and Settings (opens the Options
## panel, which main.gd owns).

signal start_pressed
signal settings_pressed

@onready var _start_button: Button = %StartButton
@onready var _settings_button: Button = %SettingsButton


func _ready() -> void:
	hide()
	_start_button.pressed.connect(func():
		if Audio.try_click(self):
			start())
	_settings_button.pressed.connect(func():
		if Audio.try_click(self):
			settings_pressed.emit())


## Shows the title screen and waits for START.
func open() -> void:
	show()
	_start_button.grab_focus.call_deferred()
	EventLog.log_event("title_shown")
	await start_pressed


func start() -> void:
	hide()
	start_pressed.emit()
