class_name Notebook
extends Control
## The detective's notebook, with two tabs:
## - Cases: each case and its clues (added automatically). Click a clue to see
##   it big; from there "HOLD IT UP" keeps it on screen to compare.
## - Residents: a polaroid for each townie, a "?" frame until met. Clicking
##   one shows who they are and everything they've said.
## The first time a solved case is opened, the SOLVED stamp slams down and the
## case is crossed out in the list.

signal closed
signal hold_requested(clue_id: String)

enum Tab { CASES, CHARACTERS }

const RESIDENT_WIDTH := 158.0
## Height of the full-body drawing on a resident's page.
const FIGURE_HEIGHT := 360.0
## Wide drawings (Sam and the cats) are shrunk to this width, so the text beside them has room.
const FIGURE_MAX_WIDTH := 240.0
const CLUE_WIDTH := 150.0
const STAMP_SOLVED := preload("res://art/ui/stamp_solved.png")
## The grey stamp art (100/255) multiplied up to the red ink used for circles (~211, 65, 61).
const STAMP_RED := Color(2.11, 0.65, 0.61)

var _tab := Tab.CASES
var _selected := ""
var _opened_at := 0.0
var _zoomed_clue := ""
var _celebrated: Array[String] = []  # solved cases whose stamp animation has played
var _stamp: TextureRect
var _case_entries: Dictionary = {}  # case_id -> RichTextLabel in the list
# The right page is split into pages that fit; < and > flip between them.
var _page := 0
var _page_count := 1
var _paged_for := ""  # which entry the page number belongs to
var _nav := HBoxContainer.new()
var _prev := Button.new()
var _next := Button.new()
var _page_label := Label.new()

@onready var _cases_tab: Button = %CasesTab
@onready var _characters_tab: Button = %CharactersTab
@onready var _list: VBoxContainer = %List
@onready var _detail: VBoxContainer = %Detail
@onready var _close_button: Button = %CloseButton
@onready var _zoom: Control = %Zoom
@onready var _zoom_photo: Polaroid = %ZoomPhoto
@onready var _zoom_text: Label = %ZoomText
@onready var _hold_button: Button = %HoldButton
@onready var _detail_scroll: ScrollContainer = $Book/Pages/DetailScroll


func _ready() -> void:
	hide()
	_zoom.hide()
	_cases_tab.pressed.connect(_switch_tab.bind(Tab.CASES))
	_characters_tab.pressed.connect(_switch_tab.bind(Tab.CHARACTERS))
	_close_button.pressed.connect(close)
	Tape.stick(_close_button)
	# The open tab is the raised one (Ruby's normal tag), the other lies flat and faded.
	for tab: Button in [_cases_tab, _characters_tab]:
		var raised := tab.get_theme_stylebox("normal", "TagButton")
		var flat := tab.get_theme_stylebox("pressed", "TagButton")
		for state in ["pressed", "hover_pressed"]:
			tab.add_theme_stylebox_override(state, raised)
		tab.add_theme_stylebox_override("normal", flat)
		tab.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))
	_hold_button.pressed.connect(func():
		if Audio.try_click(self):
			hold_clue(_zoomed_clue))
	for button: Button in [_prev, _next]:
		button.theme_type_variation = &"SmallTagButton"
		button.custom_minimum_size = Vector2(56, 44)
		button.add_theme_font_size_override("font_size", 30)
	_prev.text = "<"
	_next.text = ">"
	_prev.pressed.connect(func(): _flip(-1))
	_next.pressed.connect(func(): _flip(1))
	_page_label.add_theme_font_size_override("font_size", 26)
	_nav.alignment = BoxContainer.ALIGNMENT_CENTER
	_nav.add_theme_constant_override("separation", 16)
	for child in [_prev, _page_label, _next]:
		_nav.add_child(child)
	add_child(_nav)
	move_child(_nav, _zoom.get_index())  # under the zoomed clue, not over it
	_nav.hide()
	_zoom.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			_zoom.hide())


## Opens the notebook, optionally on a case or character page, and waits
## until it's closed with the X. (The second argument is ignored; it's kept
## so older story lines like `~ notebook case_01 | Talk to Arya` still work.)
func open(page := "", _close_label := "") -> void:
	if GameState.cases.has(page):
		_tab = Tab.CASES
		_selected = page
	elif GameState.characters.has(page):
		_tab = Tab.CHARACTERS
		_selected = page
	_rebuild()
	show()
	Audio.play_sfx("sfx_page_turn")
	_opened_at = EventLog.elapsed_seconds()
	EventLog.log_event("notebook_opened", {"page": _selected})
	if _tab == Tab.CASES and _selected in GameState.solved_cases and _selected not in _celebrated:
		_celebrate(_selected)
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
	_zoomed_clue = clue_id
	_zoom_photo.setup(clue.get("image", ""))
	_zoom_text.text = clue.get("text", "")
	_zoom.show()
	GameState.view_clue(clue_id)
	_rebuild()


## Puts the notebook away and keeps this clue's photo on screen.
func hold_clue(clue_id: String) -> void:
	EventLog.log_event("clue_held", {"clue": clue_id})
	hold_requested.emit(clue_id)
	close()


## The stamp slams down, a pen line crosses the case out, then SOLVED appears.
func _celebrate(case_id: String) -> void:
	_celebrated.append(case_id)
	var entry: RichTextLabel = _case_entries.get(case_id)
	var title: String = GameState.cases[case_id].get("title", case_id)
	if entry:
		entry.text = title
	_stamp.modulate.a = 0.0
	await get_tree().process_frame
	_stamp.pivot_offset = _stamp.size / 2
	_stamp.scale = Vector2(2.5, 2.5)
	var tween := create_tween()
	tween.tween_interval(0.8)
	tween.tween_property(_stamp, "modulate:a", 1.0, 0.1)
	tween.parallel().tween_property(_stamp, "scale", Vector2.ONE, 0.44).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(Audio.play_sfx.bind("sfx_stamp"))
	if entry:
		var line := ColorRect.new()
		line.color = Color(0.17, 0.17, 0.17)
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.position = Vector2(0, entry.size.y / 2)
		line.size = Vector2(0, 3)
		entry.add_child(line)
		tween.tween_interval(0.6)
		tween.tween_property(line, "size:x", entry.get_content_width(), 0.9).set_ease(Tween.EASE_OUT)
		tween.tween_callback(func():
			line.queue_free()
			entry.text = "[s]%s[/s]  [color=#c22]SOLVED[/color]" % title
			entry.pivot_offset = Vector2(0, entry.size.y / 2)
			entry.scale = Vector2(1.15, 1.15))
		tween.tween_property(entry, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK)
	EventLog.log_event("case_celebrated", {"case": case_id})


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
	_case_entries.clear()
	if _tab == Tab.CASES:
		_build_case_list()
	else:
		_build_character_list()
	if _paged_for != _selected:
		_page = 0
		_paged_for = _selected
	_paginate()


## Splits the right page's content into pages that fit, so nothing is cut off.
func _paginate() -> void:
	_nav.hide()
	await get_tree().process_frame
	await get_tree().process_frame  # wrapped text has its height now
	var limit := _detail_scroll.size.y - _nav.get_combined_minimum_size().y - 12
	var gap := _detail.get_theme_constant("separation")
	var used := 0.0
	var page := 0
	var children := _detail.get_children().filter(func(c): return not c.is_queued_for_deletion())
	for i in children.size():
		var child: Control = children[i]
		var height: float = child.size.y
		# Keep a heading together with what follows it.
		if child.has_meta("heading") and i + 1 < children.size():
			height += gap + children[i + 1].size.y
		if used > 0 and used + height > limit:
			page += 1
			used = 0
		child.set_meta("page", page)
		used += child.size.y + gap
	_page_count = page + 1
	_show_page(clampi(_page, 0, _page_count - 1))


func _flip(step: int) -> void:
	if not Audio.try_click(self):
		return
	Audio.play_sfx("sfx_page_turn")
	_show_page(clampi(_page + step, 0, _page_count - 1))
	EventLog.log_event("notebook_flip", {"page": _page})


func _show_page(page: int) -> void:
	_page = page
	for child in _detail.get_children():
		if child.has_meta("page"):
			child.visible = child.get_meta("page") == page
	_nav.visible = _page_count > 1
	_prev.disabled = page == 0
	_next.disabled = page == _page_count - 1
	_page_label.text = "%d / %d" % [page + 1, _page_count]
	var area := _detail_scroll.get_global_rect()
	_nav.size = _nav.get_combined_minimum_size()
	_nav.notification(Container.NOTIFICATION_SORT_CHILDREN)  # lay out < 1/2 > now, not next frame
	_nav.global_position = Vector2(area.get_center().x - _nav.size.x / 2, area.end.y - _nav.size.y)


func _build_case_list() -> void:
	if _selected == "" and not GameState.opened_cases.is_empty():
		_selected = GameState.opened_cases[0]
	for case_id in GameState.cases:
		var case_data: Dictionary = GameState.cases[case_id]
		var opened: bool = case_id in GameState.opened_cases
		var title: String = case_data.get("title", case_id)
		if case_id in GameState.solved_cases:
			title = "[s]%s[/s]  [color=#c22]SOLVED[/color]" % title
		_case_entries[case_id] = _add_list_entry(title if opened else "???", opened, case_id)
	if _selected in GameState.opened_cases:
		_build_case_page(_selected)
	else:
		_add_text("No cases yet.")


func _build_case_page(case_id: String) -> void:
	var case_data: Dictionary = GameState.cases[case_id]
	_add_rich("[font_size=52]%s[/font_size]" % case_data.get("title", case_id))
	if case_id in GameState.solved_cases:
		# Stamped over the end of the title in red ink, so it doesn't push the page down.
		var title: Control = _detail.get_child(-1)
		_stamp = TextureRect.new()
		_stamp.texture = STAMP_SOLVED
		_stamp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_stamp.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		_stamp.size = STAMP_SOLVED.get_size() * 0.45
		_stamp.modulate = STAMP_RED
		_stamp.rotation_degrees = -10.0
		_stamp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		title.clip_contents = false  # the stamp slams in at 2.5x; don't cut it off
		title.add_child(_stamp)
		var place := func(): _stamp.position = Vector2(title.size.x - _stamp.size.x, -_stamp.size.y * 0.1)
		title.resized.connect(place)
		place.call()
	var client := GameState.get_character(case_data.get("client", ""))
	if not client.is_empty():
		_add_text("Client: %s" % client.get("name", ""))
	# Key points from the client's letter, so players don't have to remember it.
	var points: Array = case_data.get("letter_points", [])
	if not points.is_empty():
		_add_rich("[font_size=40]From %s[/font_size]" % ("%s's letter" % client.name if not client.is_empty() else "the letter"), true)
		for point: String in points:
			_add_text("• " + point)
	_add_rich("[font_size=40]Clues[/font_size]", true)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 18)
	_detail.add_child(grid)
	var found_any := false
	for clue_id in case_data.get("clues", {}):
		if clue_id not in GameState.found_clues:
			continue
		found_any = true
		grid.add_child(_make_clue_card(clue_id))
	if not found_any:
		_add_text("No clues yet.")


## Just the photo; its description shows when it's opened (no text to get cut off).
func _make_clue_card(clue_id: String) -> Control:
	var clue := GameState.get_clue(clue_id)
	var button := _make_polaroid(clue.get("image", ""), "NEW!" if not GameState.has_flag("viewed_" + clue_id) else "", CLUE_WIDTH)
	button.tooltip_text = clue.get("text", "")
	button.pressed.connect(view_clue.bind(clue_id))
	return button


func _build_character_list() -> void:
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	_list.add_child(grid)
	for character_id in GameState.characters:
		var character: Dictionary = GameState.characters[character_id]
		if not character.get("in_notebook", true):
			continue
		var met: bool = character_id in GameState.met_characters
		# Heard about (someone mentioned them, or "silhouette": true in
		# characters.json) but not met yet: a silhouette.
		var heard: bool = not met and (character.get("silhouette", false) 				or not GameState.notes.get(character_id, []).is_empty())
		if _selected == "" and met:
			_selected = character_id
		# "silhouette_art": a stand-in shape while the real portrait isn't drawn yet.
		var art: String = character.get("silhouette_art", character.get("portrait", "")) if heard else character.get("portrait", "")
		var polaroid := _make_polaroid(art, character.get("name", character_id), RESIDENT_WIDTH, met or heard, heard)
		polaroid.disabled = not met
		polaroid.pressed.connect(func():
			_selected = character_id
			EventLog.log_event("notebook_page", {"page": character_id})
			_rebuild())
		grid.add_child(polaroid)
	if _selected in GameState.met_characters:
		_build_character_page(_selected)
	else:
		_add_text("You haven't met anyone yet.")


func _build_character_page(character_id: String) -> void:
	var character: Dictionary = GameState.characters[character_id]
	# The whole figure ("full_body" in characters.json), so nothing is cropped.
	# Until that drawing exists, the portrait polaroid.
	var body := PlaceholderArt.find_texture(character.get("full_body", ""))
	var column: VBoxContainer
	if body:
		# Figure on the left, name and description beside it, so it fits one page.
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 28)
		var figure := TextureRect.new()
		figure.texture = body
		figure.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		figure.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		var aspect := float(body.get_width()) / body.get_height()
		var width := minf(FIGURE_HEIGHT * aspect, FIGURE_MAX_WIDTH)
		figure.custom_minimum_size = Vector2(width, width / aspect)
		row.add_child(figure)
		column = VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_child(column)
		_detail.add_child(row)
	else:
		var portrait := Polaroid.new().setup(character.get("portrait", ""))
		portrait.custom_minimum_size = Vector2(220, 220 / Polaroid.ASPECT)
		portrait.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		_detail.add_child(portrait)
	var before := _detail.get_child_count()
	_add_rich("[font_size=52]%s[/font_size]" % character.get("name", character_id))
	if character.get("role", "") != "":
		_add_rich("[color=#6b6b6b]%s[/color]" % character.role)
	_add_text(character.get("description", ""))
	if column:
		for child in _detail.get_children().slice(before):
			child.reparent(column)
	_add_rich("[font_size=40]What they told you[/font_size]", true)
	var said: Array = GameState.notes.get(character_id, [])
	if said.is_empty():
		_add_text("Nothing yet.")
	for statement in said:
		_add_text("• " + statement)


## A clickable polaroid (or the "?" frame if it isn't known yet).
func _make_polaroid(art_id: String, caption: String, width: float, known := true, silhouette := false) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(width, width / Polaroid.ASPECT)
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	var polaroid := Polaroid.new().setup(art_id, caption, known, silhouette)
	polaroid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button.add_child(polaroid)
	if known and not silhouette:
		button.pivot_offset = button.custom_minimum_size / 2
		button.mouse_entered.connect(func(): button.rotation_degrees = -2.0)
		button.mouse_exited.connect(func(): button.rotation_degrees = 0.0)
	return button


func _add_list_entry(bbcode: String, enabled: bool, id: String) -> RichTextLabel:
	var button := Button.new()
	button.theme_type_variation = &"TagButton"
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
	return label


func _add_text(text: String) -> void:
	if text == "":
		return
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail.add_child(label)


func _add_rich(bbcode: String, heading := false) -> void:
	var label := RichTextLabel.new()
	if heading:
		label.set_meta("heading", true)
	label.bbcode_enabled = true
	label.fit_content = true
	label.text = bbcode
	_detail.add_child(label)
