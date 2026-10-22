class_name Notebook
extends Control
## The detective's notebook, with two tabs:
## - Cases: each case is a "???" silhouette until discovered, then shows its
##   clues (added automatically). Solved cases are struck through.
## - Characters: each townie is a "???" silhouette until met, then shows who
##   they are and everything they've said.

signal closed

enum Tab { CASES, CHARACTERS }

const CLUE_SIZE := Vector2(260, 190)

var _tab := Tab.CASES
var _selected := ""
var _opened_at := 0.0

@onready var _cases_tab: Button = %CasesTab
@onready var _characters_tab: Button = %CharactersTab
@onready var _list: VBoxContainer = %List
@onready var _detail: VBoxContainer = %Detail
@onready var _close_button: Button = %CloseButton
@onready var _zoom: Control = %Zoom
@onready var _zoom_art: PlaceholderArt = %ZoomArt
@onready var _zoom_text: Label = %ZoomText


func _ready() -> void:
	hide()
	_zoom.hide()
	_cases_tab.pressed.connect(_switch_tab.bind(Tab.CASES))
	_characters_tab.pressed.connect(_switch_tab.bind(Tab.CHARACTERS))
	_close_button.pressed.connect(close)
	_zoom.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			_zoom.hide())


## Opens the notebook, optionally on a case or character page, and waits
## until it's closed. `close_label` changes the close button's text.
func open(page := "", close_label := "") -> void:
	if GameState.cases.has(page):
		_tab = Tab.CASES
		_selected = page
	elif GameState.characters.has(page):
		_tab = Tab.CHARACTERS
		_selected = page
	_close_button.text = close_label if close_label != "" else "Close"
	_rebuild()
	show()
	_opened_at = EventLog.elapsed_seconds()
	EventLog.log_event("notebook_opened", {"page": _selected})
	await closed


func close() -> void:
	if not visible:
		return
	hide()
	_zoom.hide()
	EventLog.log_event("notebook_closed", {"seconds": snappedf(EventLog.elapsed_seconds() - _opened_at, 0.1)})
	closed.emit()


## Opens a clue in the big view (same as clicking it).
func view_clue(clue_id: String) -> void:
	var clue := GameState.get_clue(clue_id)
	_zoom_art.art_id = clue.get("image", "")
	_zoom_text.text = clue.get("text", "")
	_zoom.show()
	GameState.view_clue(clue_id)
	_rebuild()


func _switch_tab(tab: Tab) -> void:
	_tab = tab
	_selected = ""
	EventLog.log_event("notebook_tab", {"tab": Tab.keys()[tab].to_lower()})
	_rebuild()


func _rebuild() -> void:
	_cases_tab.button_pressed = _tab == Tab.CASES
	_characters_tab.button_pressed = _tab == Tab.CHARACTERS
	for child in _list.get_children() + _detail.get_children():
		child.queue_free()
	if _tab == Tab.CASES:
		_build_case_list()
	else:
		_build_character_list()


func _build_case_list() -> void:
	if _selected == "" and not GameState.opened_cases.is_empty():
		_selected = GameState.opened_cases[0]
	for case_id in GameState.cases:
		var case_data: Dictionary = GameState.cases[case_id]
		var opened: bool = case_id in GameState.opened_cases
		var title: String = case_data.get("title", case_id)
		if case_id in GameState.solved_cases:
			title = "[s]%s[/s]  [color=#c22]SOLVED[/color]" % title
		_add_list_entry(title if opened else "???", opened, case_id)
	if _selected in GameState.opened_cases:
		_build_case_page(_selected)
	else:
		_add_text("No cases yet.")


func _build_case_page(case_id: String) -> void:
	var case_data: Dictionary = GameState.cases[case_id]
	var title: String = case_data.get("title", case_id)
	if case_id in GameState.solved_cases:
		_add_rich("[font_size=52][s]%s[/s][/font_size]  [font_size=40][color=#c22]SOLVED![/color][/font_size]" % title)
	else:
		_add_rich("[font_size=52]%s[/font_size]" % title)
	var client := GameState.get_character(case_data.get("client", ""))
	if not client.is_empty():
		_add_text("Client: %s" % client.get("name", ""))
	_add_text(case_data.get("summary", ""))
	_add_rich("[font_size=40]Clues[/font_size]")
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 20)
	_detail.add_child(grid)
	var found_any := false
	for clue_id in case_data.get("clues", {}):
		if clue_id not in GameState.found_clues:
			continue
		found_any = true
		grid.add_child(_make_clue_card(clue_id))
	if not found_any:
		_add_text("No clues yet.")


func _make_clue_card(clue_id: String) -> Control:
	var clue := GameState.get_clue(clue_id)
	var card := VBoxContainer.new()
	var button := Button.new()
	button.custom_minimum_size = CLUE_SIZE
	button.pressed.connect(view_clue.bind(clue_id))
	var art := PlaceholderArt.new()
	art.art_id = clue.get("image", "")
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 6)
	button.add_child(art)
	card.add_child(button)
	var label := Label.new()
	label.text = clue.get("text", "")
	if not GameState.has_flag("viewed_" + clue_id):
		label.text = "NEW! " + label.text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x = CLUE_SIZE.x
	label.add_theme_font_size_override("font_size", 24)
	card.add_child(label)
	return card


func _build_character_list() -> void:
	for character_id in GameState.characters:
		var character: Dictionary = GameState.characters[character_id]
		if not character.get("in_notebook", true):
			continue
		var met: bool = character_id in GameState.met_characters
		if _selected == "" and met:
			_selected = character_id
		_add_list_entry(character.get("name", character_id) if met else "???", met, character_id)
	if _selected in GameState.met_characters:
		_build_character_page(_selected)
	else:
		_add_text("You haven't met anyone yet.")


func _build_character_page(character_id: String) -> void:
	var character: Dictionary = GameState.characters[character_id]
	var portrait := PlaceholderArt.new()
	portrait.art_id = character.get("portrait", "")
	portrait.custom_minimum_size = Vector2(280, 280)
	portrait.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_detail.add_child(portrait)
	_add_rich("[font_size=52]%s[/font_size]" % character.get("name", character_id))
	_add_text(character.get("role", ""))
	_add_text(character.get("description", ""))
	_add_rich("[font_size=40]What they told you[/font_size]")
	var said: Array = GameState.notes.get(character_id, [])
	if said.is_empty():
		_add_text("Nothing yet.")
	for statement in said:
		_add_text("• " + statement)


func _add_list_entry(bbcode: String, enabled: bool, id: String) -> void:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 72)
	button.disabled = not enabled
	button.toggle_mode = true
	button.button_pressed = id == _selected
	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	label.scroll_active = false
	label.text = bbcode
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 16)
	button.add_child(label)
	button.pressed.connect(func():
		_selected = id
		EventLog.log_event("notebook_page", {"page": id})
		_rebuild())
	_list.add_child(button)


func _add_text(text: String) -> void:
	if text == "":
		return
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail.add_child(label)


func _add_rich(bbcode: String) -> void:
	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.text = bbcode
	_detail.add_child(label)
