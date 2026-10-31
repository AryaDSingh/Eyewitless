extends Node
## Records what playtesters do, so we can check the success metrics in the CDD
## (time to find Alex, wrong pigeons clicked, notebook opened, and so on).
##
## Every event is printed to the console and written as one JSON object per
## line to user://playtest_logs/. At the end of the game it's uploaded to the
## team's Google Drive (if upload_url is set). In the web build, press F9 (or
## use the button on the last screen if the upload failed) to download it.

const LOG_DIR := "user://playtest_logs"
const UPLOAD_TIMEOUT := 15.0

## Web app URL of tools/playtest_upload.gs (setup: docs/PLAYTEST_UPLOAD.md).
## Empty = don't upload; the end screen offers a download instead.
var upload_url := "https://script.google.com/macros/s/AKfycbwrnYhYXSDrrp4keVKL-MpFvBFAGNIrY92xtwbnCK1GF5nWEQwJRvc7NEGPtQPAN8Ba/exec"

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


func count_events(event: String) -> int:
	var needle := "\"event\":\"%s\"" % event
	var count := 0
	for line in _lines:
		if needle in line:
			count += 1
	return count


## True if an event has a field with this value, e.g. ("knot", "alex_after").
func has_event_with(key: String, value: String) -> bool:
	var needle := "\"%s\":\"%s\"" % [key, value]
	for line in _lines:
		if needle in line:
			return true
	return false


func get_log_path() -> String:
	return "%s/session_%s.jsonl" % [LOG_DIR, session_id]


## Sends the log to the team's Google Drive folder. Returns true if it arrived.
func upload() -> bool:
	if upload_url == "":
		return false
	var http := HTTPRequest.new()
	http.timeout = UPLOAD_TIMEOUT
	# Apps Script answers a POST with a redirect; the redirect itself means "saved".
	http.max_redirects = 0
	add_child(http)
	var url := "%s?platform=%s" % [upload_url, OS.get_name().uri_encode()]
	var text := "\n".join(_lines) + "\n"
	# text/plain keeps the browser from sending a CORS preflight Apps Script can't answer.
	var error := http.request(url, ["Content-Type: text/plain;charset=utf-8"], HTTPClient.METHOD_POST, text)
	if error != OK:
		http.queue_free()
		return false
	var response: Array = await http.request_completed
	http.queue_free()
	var code: int = response[1]
	return response[0] in [HTTPRequest.RESULT_SUCCESS, HTTPRequest.RESULT_REDIRECT_LIMIT_REACHED] \
		and code in [200, 302]


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
