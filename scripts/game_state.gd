extends Node
## Everything the player has discovered so far: flags, map locations, cases,
## clues, characters met and what they said. Story commands change this.
## Case and character data is read from the JSON files in resources/.

signal changed
signal clue_added(clue_id: String)
signal note_added(character_id: String, text: String)
signal location_unlocked(location_id: String)

const CASE_FILES: Array[String] = ["res://resources/cases/case_01.json"]
const CHARACTERS_FILE := "res://resources/characters.json"

var cases: Dictionary = {}       # case_id -> case data
var characters: Dictionary = {}  # character_id -> character data
var clues: Dictionary = {}       # clue_id -> clue data (with "case_id" added)

var flags: Dictionary = {}       # flag -> true
var unlocked_locations: Array[String] = []
var visited_locations: Array[String] = []
var opened_cases: Array[String] = []
var solved_cases: Array[String] = []
var found_clues: Array[String] = []
var met_characters: Array[String] = []
var notes: Dictionary = {}       # character_id -> Array of statements
var current_location := ""


func _ready() -> void:
	characters = _load_json(CHARACTERS_FILE)
	for path in CASE_FILES:
		var case_data := _load_json(path)
		cases[case_data.id] = case_data
		for clue_id in case_data.get("clues", {}):
			var clue: Dictionary = case_data.clues[clue_id].duplicate()
			clue.case_id = case_data.id
			clues[clue_id] = clue


## Clears all progress (used by "Play again").
func reset() -> void:
	flags.clear()
	unlocked_locations.clear()
	visited_locations.clear()
	opened_cases.clear()
	solved_cases.clear()
	found_clues.clear()
	met_characters.clear()
	notes.clear()
	current_location = ""
	changed.emit()


func set_flag(flag: String) -> void:
	flags[flag] = true
	changed.emit()


func clear_flag(flag: String) -> void:
	flags.erase(flag)
	changed.emit()


func has_flag(flag: String) -> bool:
	return flags.has(flag)


func unlock_location(location_id: String) -> void:
	if location_id in unlocked_locations:
		return
	unlocked_locations.append(location_id)
	EventLog.log_event("location_unlocked", {"location": location_id})
	location_unlocked.emit(location_id)
	changed.emit()


func is_location_unlocked(location_id: String) -> bool:
	return location_id in unlocked_locations


func enter_location(location_id: String) -> void:
	current_location = location_id
	if location_id not in unlocked_locations:
		unlocked_locations.append(location_id)
	if location_id not in visited_locations:
		visited_locations.append(location_id)
	changed.emit()


func open_case(case_id: String) -> void:
	if not cases.has(case_id):
		push_error("Unknown case: %s" % case_id)
		return
	if case_id not in opened_cases:
		opened_cases.append(case_id)
		EventLog.log_event("case_opened", {"case": case_id})
		changed.emit()


func solve_case(case_id: String) -> void:
	if case_id not in solved_cases:
		solved_cases.append(case_id)
		EventLog.log_event("case_solved", {"case": case_id})
		changed.emit()


func add_clue(clue_id: String) -> void:
	if not clues.has(clue_id):
		push_error("Unknown clue: %s" % clue_id)
		return
	if clue_id in found_clues:
		return
	found_clues.append(clue_id)
	open_case(clues[clue_id].case_id)
	EventLog.log_event("clue_added", {"clue": clue_id})
	clue_added.emit(clue_id)
	changed.emit()


## Called when the player opens a clue in the notebook. Sets the flag
## "viewed_<clue_id>", which the story can check with `~ if`.
func view_clue(clue_id: String) -> void:
	EventLog.log_event("clue_viewed", {"clue": clue_id})
	set_flag("viewed_" + clue_id)


func get_clue(clue_id: String) -> Dictionary:
	return clues.get(clue_id, {})


func meet(character_id: String) -> void:
	if not characters.has(character_id):
		push_error("Unknown character: %s" % character_id)
		return
	if character_id not in met_characters:
		met_characters.append(character_id)
		EventLog.log_event("character_met", {"character": character_id})
		changed.emit()


func add_note(character_id: String, text: String) -> void:
	if not notes.has(character_id):
		notes[character_id] = []
	if text in notes[character_id]:
		return
	# Hearing about someone doesn't mean meeting them: the notebook shows a
	# silhouette until `~ meet`.
	notes[character_id].append(text)
	EventLog.log_event("note_added", {"character": character_id, "text": text})
	note_added.emit(character_id, text)
	changed.emit()


## Finds a character by id or display name ("Arya", "arya"). Returns {} if unknown.
func get_character(name_or_id: String) -> Dictionary:
	var key := name_or_id.to_lower()
	if characters.has(key):
		return characters[key]
	for id in characters:
		if characters[id].get("name", "").to_lower() == key:
			return characters[id]
	return {}


func _load_json(path: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	var data = JSON.parse_string(text)
	if data is Dictionary:
		return data
	push_error("Could not read %s (is the JSON valid?)" % path)
	return {}
