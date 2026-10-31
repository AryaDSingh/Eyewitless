class_name TitleScreen
extends Control
## The first screen: the game title, START, and Settings (music and sound volume).

signal start_pressed

@onready var _start_button: Button = %StartButton
@onready var _settings_button: Button = %SettingsButton
@onready var _settings: Control = %Settings
@onready var _menu: Control = $Center
@onready var _music_slider: HSlider = %MusicSlider
@onready var _sounds_slider: HSlider = %SoundsSlider
@onready var _back_button: Button = %BackButton


func _ready() -> void:
	hide()
	_settings.hide()
	_start_button.pressed.connect(func():
		if Audio.try_click():
			start())
	# The menu hides while Settings is open, so nothing shows around the panel.
	_settings_button.pressed.connect(func():
		_menu.hide()
		_settings.show()
		_back_button.grab_focus())
	_back_button.pressed.connect(func():
		_settings.hide()
		_menu.show()
		_settings_button.grab_focus())
	_music_slider.value_changed.connect(Audio.set_volume.bind("Music"))
	_sounds_slider.value_changed.connect(Audio.set_volume.bind("Sounds"))


## Shows the title screen and waits for START.
func open() -> void:
	_music_slider.set_value_no_signal(Audio.get_volume("Music"))
	_sounds_slider.set_value_no_signal(Audio.get_volume("Sounds"))
	show()
	_start_button.grab_focus.call_deferred()
	EventLog.log_event("title_shown")
	await start_pressed


func start() -> void:
	hide()
	_settings.hide()
	_menu.show()
	start_pressed.emit()
