extends Node
## Plays music, background ambience and sound effects from res://audio/<id>.ogg
## (or .wav / .mp3). A missing file is skipped, so the game runs before the
## sound is in. Only one sound effect plays at a time: a new one cuts the old
## one off, so sounds never pile up. The list of sounds is in docs/AUDIO_LIST.md.
##
## Also owns the click cooldown: hotspots, buttons and dialogue ignore clicks
## that come less than CLICK_COOLDOWN seconds after the last one, so players
## can't spam them.

const AUDIO_DIR := "res://audio/"
const EXTENSIONS: Array[String] = ["ogg", "wav", "mp3"]
const FADE_SECONDS := 1.0
const SILENT_DB := -40.0
const CLICK_COOLDOWN := 1.0
## Overall volume (1.0 = the files as they are).
const MASTER_VOLUME := 0.5

## Tests set this to 0 so they can click as fast as they like.
var click_cooldown := CLICK_COOLDOWN

var _last_click_msec := -100000
var _missing: Dictionary = {}
var _fades: Dictionary = {}  # player -> Tween
var _music: AudioStreamPlayer
var _ambience: AudioStreamPlayer
var _sfx: AudioStreamPlayer
var _voice: AudioStreamPlayer
var _tick: AudioStreamPlayer


func _ready() -> void:
	# The Music and Sounds buses are in default_bus_layout.tres: buses made in
	# code don't work in web builds.
	set_volume(MASTER_VOLUME, "Master")
	_music = _add_player("Music")
	_ambience = _add_player("Sounds")
	_sfx = _add_player("Sounds")
	_voice = _add_player("Sounds")
	_tick = _add_player("Sounds")
	_tick.volume_db = -14.0


## True if enough time has passed since the last click that counted.
func try_click() -> bool:
	var now := Time.get_ticks_msec()
	if now - _last_click_msec < click_cooldown * 1000.0:
		return false
	_last_click_msec = now
	return true


func play_sfx(id: String) -> void:
	var stream := find_stream(id)
	if stream == null:
		return
	# Swapping the stream stops the effect that was playing.
	_sfx.stream = stream
	_sfx.play()


## Plays a recorded line (`~ voice` in a story, before the line it goes with).
## Its own player, so a sound effect doesn't cut the voice off.
func play_voice(id: String) -> void:
	_voice.stream = find_stream(id)
	if _voice.stream:
		_voice.play()


func is_voice_playing() -> bool:
	return _voice.playing


## The quiet tick while dialogue types out. Its own player, so it never cuts
## off a sound effect; the pitch wobbles a little so it doesn't drone.
func play_tick() -> void:
	if _tick.stream == null:
		_tick.stream = find_stream("sfx_text_tick")
	_tick.pitch_scale = randf_range(0.9, 1.15)
	_tick.play()


## Called when the player moves on, so a line's voice never talks over the next.
func stop_voice() -> void:
	_voice.stop()


## Fades to a new music track. An empty id keeps the current music.
func play_music(id: String) -> void:
	if id != "":
		_crossfade(_music, id)


## Fades to a new background loop. An empty id fades the ambience out.
func play_ambience(id: String) -> void:
	_crossfade(_ambience, id)


## Makes the music sound like it's coming through a wall (the bar). The
## cutoff is on the Music bus's Muffle effect (Audio tab). Desktop only: web
## builds skip audio effects.
func set_muffled(muffled: bool) -> void:
	AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Music"), 0, muffled)


func set_muted(muted: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), muted)


func is_muted() -> bool:
	return AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))


## Volume from 0.0 to 1.0, for the "Music" or "Sounds" slider.
func get_volume(bus_name: String) -> float:
	return db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus_name)))


func set_volume(linear: float, bus_name: String) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), linear_to_db(linear))


func find_stream(id: String) -> AudioStream:
	if id.is_empty():
		return null
	for extension in EXTENSIONS:
		var path := "%s%s.%s" % [AUDIO_DIR, id, extension]
		if ResourceLoader.exists(path):
			return load(path)
	if not _missing.has(id):
		_missing[id] = true
		push_warning("No sound file for '%s' in %s (skipped)" % [id, AUDIO_DIR])
	return null


func _crossfade(player: AudioStreamPlayer, id: String) -> void:
	if player.get_meta("id", "") == id:
		return
	player.set_meta("id", id)
	if _fades.has(player):
		_fades[player].kill()
	var tween := create_tween()
	_fades[player] = tween
	if player.playing:
		tween.tween_property(player, "volume_db", SILENT_DB, FADE_SECONDS / 2)
	tween.tween_callback(_start_loop.bind(player, id))
	tween.tween_property(player, "volume_db", 0.0, FADE_SECONDS / 2).from(SILENT_DB)


func _start_loop(player: AudioStreamPlayer, id: String) -> void:
	var stream := find_stream(id)
	# shortcut: only .ogg and .mp3 loop; a .wav loop needs its loop points set in the import dock.
	if stream and "loop" in stream:
		stream.loop = true
	player.stream = stream
	if stream:
		player.play()
	else:
		player.stop()




func _add_player(bus_name: String) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = bus_name
	add_child(player)
	return player
