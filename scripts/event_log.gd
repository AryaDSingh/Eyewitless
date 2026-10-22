extends Node
## Records what playtesters do, so we can check the success metrics in the CDD
## (time to find Debbie, wrong pigeons clicked, notebook opened, and so on).
##
## Every event is printed to the console and written as one JSON object per
## line to user://playtest_logs/. In the web build, press F9 (or use the button
## on the last screen) to download the log.

const LOG_DIR := "user://playtest_logs"

var session_id := ""
var _start_msec := 0
var _lines: PackedStringArray = []
var _file: FileAccess


func _ready() -> void:
	start_session()


func start_session() -> void:
	_start_msec = Time.get_ticks_msec()
	session_id = Time.get_datetime_string_from_system().replace(":", "-")
	_lines.clear()
	DirAccess.make_dir_recursive_absolute(LOG_DIR)
	_file = FileAccess.open(get_log_path(), FileAccess.WRITE)
	log_event("session_start", {"platform": OS.get_name()})


func log_event(event: String, data: Dictionary = {}) -> void:
	var entry := {"t": snappedf(elapsed_seconds(), 0.01), "event": event}
	entry.merge(data)
	var line := JSON.stringify(entry)
	_lines.append(line)
	print("[log] ", line)
	if _file:
		_file.store_line(line)
		_file.flush()


func elapsed_seconds() -> float:
	return (Time.get_ticks_msec() - _start_msec) / 1000.0


func has_event(event: String) -> bool:
	var needle := "\"event\":\"%s\"" % event
	for line in _lines:
		if needle in line:
			return true
	return false


func get_log_path() -> String:
	return "%s/session_%s.jsonl" % [LOG_DIR, session_id]


## Saves the log as a file download (web build only).
func download() -> void:
	if not OS.has_feature("web"):
		print("Playtest log saved at: ", ProjectSettings.globalize_path(get_log_path()))
		return
	var text := "\n".join(_lines) + "\n"
	JavaScriptBridge.download_buffer(
		text.to_utf8_buffer(), "eyewitless_%s.jsonl" % session_id, "application/json")


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F9:
		download()
