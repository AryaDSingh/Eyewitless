extends Node
## Reads the .story files and plays them: dialogue lines, choices, cards and
## commands. The format is explained in docs/STORY_FORMAT.md.
##
## The story doesn't draw anything itself. It calls methods on `ui` (the Main
## scene): show_line, show_card, go_to, open_notebook, and so on.

signal started
signal finished

const STORY_FILES: Array[String] = ["res://resources/cases/case_01.story"]
const COMMANDS: Array[String] = [
	"card", "goto", "set", "unset", "if", "unlock", "map", "case_open", "case_solve",
	"clue", "meet", "note", "hint", "blink", "hold_photo", "bubble", "notebook",
	"log", "wait", "end_game", "sfx", "voice", "tool",
]
const SPEAKER_PATTERN := "^([A-Za-z][A-Za-z0-9_ ]{0,30}):\\s+(.+)$"

var knots: Dictionary = {}  # knot name -> Array of entries
var ui: Node
var is_running := false

var _queue: Array[String] = []
var _speaker_regex := RegEx.create_from_string(SPEAKER_PATTERN)


func _ready() -> void:
	for path in STORY_FILES:
		parse_file(path)
	for problem in validate():
		push_warning(problem)


## Plays a knot. If one is already playing, this one plays after it.
func run(knot: String) -> void:
	if is_running:
		_queue.append(knot)
		return
	is_running = true
	started.emit()
	var next := knot
	while next != "":
		next = await _run_knot(next)
		if next == "" and not _queue.is_empty():
			next = _queue.pop_front()
	is_running = false
	finished.emit()


func stop() -> void:
	_queue.clear()


func parse_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open story file %s" % path)
		return
	var current: Array = []
	var has_knot := false
	var last_line := {}
	var line_number := 0
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		line_number += 1
		if line.is_empty() or line.begins_with("#"):
			continue
		if line.begins_with("==="):
			current = []
			knots[line.trim_prefix("===").strip_edges()] = current
			has_knot = true
			last_line = {}
			continue
		if not has_knot:
			push_error("%s:%d: line is outside a knot (add `=== name` above it)" % [path, line_number])
			continue
		var where := "%s:%d" % [path.get_file(), line_number]
		if line.begins_with("*"):
			# A choice belongs to the dialogue line right before it.
			if last_line.is_empty():
				if not current.is_empty() and current[-1].type == "command":
					push_warning("%s: this choice comes right after a command, so it shows with no text. Move the command above the dialogue line." % where)
				last_line = {"type": "line", "speaker": "", "text": "", "choices": [], "where": where}
				current.append(last_line)
			var parts := line.trim_prefix("*").split("->", true, 1)
			var target := parts[1].strip_edges() if parts.size() > 1 else ""
			last_line.choices.append({"text": parts[0].strip_edges(), "target": target, "where": where})
		elif line.begins_with("->"):
			current.append({"type": "jump", "target": line.trim_prefix("->").strip_edges(), "where": where})
			last_line = {}
		elif line.begins_with("~"):
			var command := line.trim_prefix("~").strip_edges()
			var space := command.find(" ")
			var command_name := command if space == -1 else command.left(space)
			var args := "" if space == -1 else command.substr(space + 1).strip_edges()
			current.append({"type": "command", "name": command_name, "args": args, "where": where})
			last_line = {}
		else:
			var speaker := ""
			var text := line
			var found := _speaker_regex.search(line)
			if found:
				speaker = found.get_string(1)
				text = found.get_string(2)
			last_line = {"type": "line", "speaker": speaker, "text": _unescape(text), "choices": [], "where": where}
			current.append(last_line)


## Returns a list of problems: jumps to knots that don't exist, unknown
## commands, unknown speakers. Shown as warnings when the game starts.
func validate() -> Array[String]:
	var problems: Array[String] = []
	for knot in knots:
		for entry in knots[knot]:
			match entry.type:
				"jump":
					_check_target(entry.target, entry.where, problems)
				"line":
					for choice in entry.choices:
						_check_target(choice.target, choice.where, problems)
					if entry.speaker != "" and GameState.get_character(entry.speaker).is_empty():
						problems.append("%s: unknown speaker '%s' (add them to characters.json)" % [entry.where, entry.speaker])
				"command":
					if entry.name not in COMMANDS:
						problems.append("%s: unknown command '~ %s'" % [entry.where, entry.name])
					elif entry.name == "if":
						_check_target(_split_if(entry.args)[1], entry.where, problems)
	return problems


func _check_target(target: String, where: String, problems: Array[String]) -> void:
	if not knots.has(target):
		problems.append("%s: there is no knot called '%s'" % [where, target])


## Plays one knot. Returns the knot to jump to next, or "" when done.
func _run_knot(knot: String) -> String:
	if not knots.has(knot):
		push_error("Story knot not found: %s" % knot)
		return ""
	EventLog.log_event("knot", {"knot": knot})
	for entry in knots[knot]:
		match entry.type:
			"line":
				var choice_texts: Array[String] = []
				for choice in entry.choices:
					choice_texts.append(choice.text)
				var picked: int = await ui.show_line(entry.speaker, entry.text, choice_texts)
				if not entry.choices.is_empty():
					var choice: Dictionary = entry.choices[clampi(picked, 0, entry.choices.size() - 1)]
					EventLog.log_event("choice", {"knot": knot, "choice": choice.text})
					return choice.target
			"jump":
				return entry.target
			"command":
				var jump: String = await _run_command(entry.name, entry.args)
				if jump != "":
					return jump
	return ""


func _run_command(command: String, args: String) -> String:
	match command:
		"card":
			var parts := _split_args(args, 4)
			await ui.show_card(parts[0], _unescape(parts[1]), parts[2], parts[3])
		"goto":
			ui.go_to(args)
		"set":
			GameState.set_flag(args)
		"unset":
			GameState.clear_flag(args)
		"if":
			var condition := _split_if(args)
			var flag: String = condition[0]
			var wanted := not flag.begins_with("!")
			if GameState.has_flag(flag.trim_prefix("!")) == wanted:
				return condition[1]
		"unlock":
			GameState.unlock_location(args)
		"map":
			ui.open_map()
		"case_open":
			GameState.open_case(args)
		"case_solve":
			GameState.solve_case(args)
		"clue":
			GameState.add_clue(args)
		"meet":
			GameState.meet(args)
		"note":
			var parts := _split_args(args, 2)
			GameState.add_note(parts[0], parts[1])
		"hint":
			ui.show_hint(args)
		"blink":
			ui.blink(args)
		"hold_photo":
			ui.hold_photo(args)
		"bubble":
			var parts := _split_args(args, 2)
			await ui.show_bubble(parts[0], parts[1])
		"notebook":
			var parts := _split_args(args, 2)
			await ui.open_notebook(parts[0], parts[1])
		"log":
			EventLog.log_event(args)
		"sfx":
			Audio.play_sfx(args)
		"voice":
			Audio.play_voice(args)
		"tool":
			ui.show_tool(args)
		"wait":
			await get_tree().create_timer(args.to_float()).timeout
		"end_game":
			await ui.end_game()
		_:
			push_error("Unknown story command: ~ %s" % command)
	return ""


## "flag -> knot" -> ["flag", "knot"]
func _split_if(args: String) -> Array[String]:
	var parts := args.split("->", true, 1)
	var target := parts[1].strip_edges() if parts.size() > 1 else ""
	return [parts[0].strip_edges(), target]


## "a | b | c" -> ["a", "b", "c"], padded with "" up to `count`.
func _split_args(args: String, count: int) -> Array[String]:
	var result: Array[String] = []
	for part in args.split("|", true, count - 1):
		result.append(part.strip_edges())
	while result.size() < count:
		result.append("")
	return result


func _unescape(text: String) -> String:
	return text.replace("\\n", "\n")
