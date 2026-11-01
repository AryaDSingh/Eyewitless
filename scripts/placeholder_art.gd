@tool
class_name PlaceholderArt
extends Control
## Draws res://art/<art_id>.png (or .jpg / .webp). Until that file exists it
## draws a labelled grey box instead, so missing art is easy to spot.
## Artists: save a PNG with the same name into art/ and it replaces the box.

const ART_DIR := "res://art/"
const EXTENSIONS: Array[String] = ["png", "jpg", "jpeg", "webp"]
## Empty space above the picture with `cover_from_top` (fraction of the height).
const HEADROOM := 0.08

@export var art_id := "":
	set(value):
		art_id = value
		_texture = find_texture(value)
		queue_redraw()
@export var placeholder_color := Color(0.62, 0.62, 0.66):
	set(value):
		placeholder_color = value
		queue_redraw()
## Fill the whole box and crop the edges, instead of fitting inside it.
@export var cover := false:
	set(value):
		cover = value
		queue_redraw()
## With `cover`: crop only from the bottom, never the top, and leave a little
## empty space above (keeps heads in portraits). Off = crop evenly.
@export var cover_from_top := false:
	set(value):
		cover_from_top = value
		queue_redraw()
## Off = draw nothing when there's no picture (e.g. a clickable spot on top of
## a bigger picture, like one pigeon in the plaza crowd).
@export var show_placeholder := true:
	set(value):
		show_placeholder = value
		queue_redraw()

var _texture: Texture2D
## Pictures' pixels for is_drawn_at, shared by every hotspot using the same
## picture and loaded once (reading a texture back is slow, especially on web).
static var _images: Dictionary = {}  # Texture2D -> Image


static func find_texture(id: String) -> Texture2D:
	if id.is_empty():
		return null
	for extension in EXTENSIONS:
		var path := "%s%s.%s" % [ART_DIR, id, extension]
		if ResourceLoader.exists(path):
			return load(path)
	return null


## Where the picture is actually drawn inside this box (it's fitted, so it may
## not fill the whole box). The whole box if there's no picture or `cover` is on.
func get_drawn_rect() -> Rect2:
	if _texture == null or cover:
		return Rect2(Vector2.ZERO, size)
	var texture_size := _texture.get_size()
	var scale := minf(size.x / texture_size.x, size.y / texture_size.y)
	var drawn := texture_size * scale
	return Rect2((size - drawn) / 2, drawn)


## True if the picture has ink (or white fill) at this point, not a see-through
## part. Without a picture, the whole box counts.
func is_drawn_at(point: Vector2) -> bool:
	if _texture == null or cover:
		return Rect2(Vector2.ZERO, size).has_point(point)
	var drawn := get_drawn_rect()
	if not drawn.has_point(point):
		return false
	if not _images.has(_texture):
		var image := _texture.get_image()
		if image and image.is_compressed():
			image.decompress()
		_images[_texture] = image
	var pixels: Image = _images[_texture]
	if pixels == null:
		return true
	var pixel := Vector2i((point - drawn.position) / drawn.size * Vector2(pixels.get_size()))
	pixel = pixel.clamp(Vector2i.ZERO, pixels.get_size() - Vector2i.ONE)
	return pixels.get_pixelv(pixel).a > 0.1


func has_texture() -> bool:
	return _texture != null


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	if _texture:
		_draw_texture(rect)
		return
	if not show_placeholder:
		return
	draw_rect(rect, placeholder_color)
	draw_rect(rect, placeholder_color.darkened(0.45), false, 3.0)
	var label := art_id if art_id != "" else "(no art_id)"
	var font := get_theme_default_font()
	var font_size := clampi(int(minf(size.x / maxf(label.length(), 1) * 1.7, size.y * 0.3)), 10, 40)
	# Big boxes (backgrounds) get their label near the top, so townies don't cover it.
	var label_y := size.y * 0.15 if size.y > 700 else size.y / 2 + font_size / 3.0
	draw_string(font, Vector2(0, label_y), label,
		HORIZONTAL_ALIGNMENT_CENTER, size.x, font_size, Color(0, 0, 0, 0.7))


func _draw_texture(rect: Rect2) -> void:
	var texture_size := _texture.get_size()
	if cover:
		if cover_from_top and texture_size.x / texture_size.y < rect.size.x / rect.size.y:
			rect = Rect2(rect.position + Vector2(0, rect.size.y * HEADROOM), rect.size * Vector2(1, 1 - HEADROOM))
		var scale := maxf(rect.size.x / texture_size.x, rect.size.y / texture_size.y)
		var source_size := rect.size / scale
		var source := Rect2((texture_size - source_size) / 2, source_size)
		if cover_from_top:
			source.position.y = 0.0
		draw_texture_rect_region(_texture, rect, source)
	else:
		var scale := minf(rect.size.x / texture_size.x, rect.size.y / texture_size.y)
		var target_size := texture_size * scale
		draw_texture_rect(_texture, Rect2((rect.size - target_size) / 2, target_size), false)
