class_name Polaroid
extends Control
## A photo in Ruby's white frame (art/ui/photo_frame.png), clipped so nothing
## pokes out, with an optional caption. Unknown = the dashed "?" frame.
## Used for clues, residents, photo cards, the held photo and map stickers.
## Torn photos (art ids "clue_torn_*") already have their own ripped paper
## edge, so they're shown whole, without the frame, with a strip of tape on top.

const FRAME := preload("res://art/ui/photo_frame.png")
const FRAME_UNKNOWN := preload("res://art/ui/photo_frame_unknown.png")
const CAPTION_FONT := preload("res://ui/fonts/CaveatBrush-Regular.ttf")
## The grey photo square inside photo_frame.png, as fractions of the frame.
const PHOTO_AREA := Rect2(0.0995, 0.124, 0.80, 0.615)
## Frame width / height, to size polaroids without squashing them.
const ASPECT := 794.0 / 927.0
## Where a torn photo goes (no frame): everything above the caption.
const TORN_AREA := Rect2(0.0, 0.0, 1.0, PHOTO_AREA.end.y)

var _frame := TextureRect.new()
var _clip := Control.new()
var _photo := PlaceholderArt.new()
var _caption := Label.new()
var _torn := false
var _tape := Control.new()  # drawn over the photo, so it's its own node


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_frame.stretch_mode = TextureRect.STRETCH_SCALE
	_frame.texture = FRAME
	_clip.clip_contents = true
	_photo.cover = true
	_caption.add_theme_font_override("font", CAPTION_FONT)
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	for child: Control in [_frame, _clip, _photo, _caption]:
		child.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_frame)
	add_child(_clip)
	_clip.add_child(_photo)
	add_child(_caption)
	_tape.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tape.draw.connect(_draw_tape)
	add_child(_tape)
	resized.connect(_layout)


## Sets what's in the photo. Returns itself so it can be chained.
## silhouette = heard of but not met: the photo shows a black shape and "???".
func setup(art_id: String, caption := "", known := true, silhouette := false) -> Polaroid:
	_frame.texture = FRAME if known else FRAME_UNKNOWN
	_torn = known and art_id.begins_with("clue_torn_")
	_frame.visible = not _torn
	_tape.visible = _torn
	_photo.cover = not _torn
	_clip.visible = known
	_photo.art_id = art_id
	# People's photos keep their heads (and a little space above); clue photos fill the frame.
	_photo.cover_from_top = art_id.begins_with("portrait_") or art_id.ends_with("_silhouette")
	_photo.modulate = Color.BLACK if silhouette else Color.WHITE
	# No drawing yet: a black box looks broken, and the grey box's label would give the name away.
	_photo.show_placeholder = not silhouette
	_caption.text = ("???" if silhouette else caption) if known else ""
	_layout()
	return self


func _layout() -> void:
	_frame.size = size
	_tape.queue_redraw()
	var area := TORN_AREA if _torn else PHOTO_AREA
	_clip.position = area.position * size
	_clip.size = area.size * size
	_photo.size = _clip.size
	_caption.position = Vector2(0, PHOTO_AREA.end.y * size.y)
	_caption.size = Vector2(size.x, size.y * (0.93 - PHOTO_AREA.end.y))
	_caption.add_theme_font_size_override("font_size", maxi(12, int(size.y * 0.14)))


## Tape across the middle of the torn photo's top edge (only the part of the
## top that's still paper), no wider than that edge.
func _draw_tape() -> void:
	var texture: Texture2D = _photo._texture
	if texture == null:
		return
	var edge := _top_edge(texture)  # x: left, y: right, z: top (fractions of the picture)
	var drawn := _photo.get_drawn_rect()
	drawn.position += _clip.position
	var left := drawn.position.x + edge.x * drawn.size.x
	var width := (edge.y - edge.x) * drawn.size.x
	var tape_size := Vector2(minf(0.38 * size.x, 0.8 * width), 0.07 * size.y)
	var top := drawn.position.y + edge.z * drawn.size.y
	_tape.draw_rect(Rect2(left + (width - tape_size.x) / 2, top - tape_size.y / 2, tape_size.x, tape_size.y), Tape.COLOR)


static var _edges := {}

## Where the top edge of a see-through picture is: the columns that have paper
## in the top 6% (below the first row with any paper).
static func _top_edge(texture: Texture2D) -> Vector3:
	if not _edges.has(texture):
		var image := texture.get_image()
		if image.is_compressed():
			image.decompress()
		var w := image.get_width()
		var h := image.get_height()
		var top := 0
		while top < h - 1 and not _row_has_paper(image, top):
			top += 1
		var left := w
		var right := 0
		for y in range(top, mini(h, top + int(h * 0.06)), 4):
			for x in range(0, w, 2):
				if image.get_pixel(x, y).a > 0.5:
					left = mini(left, x)
					right = maxi(right, x)
		_edges[texture] = Vector3(float(left) / w, float(maxi(right, left)) / w, float(top) / h)
	return _edges[texture]


static func _row_has_paper(image: Image, y: int) -> bool:
	for x in range(0, image.get_width(), 2):
		if image.get_pixel(x, y).a > 0.5:
			return true
	return false
