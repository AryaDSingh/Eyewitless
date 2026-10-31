class_name Polaroid
extends Control
## A photo in Ruby's white frame (art/ui/photo_frame.png), clipped so nothing
## pokes out, with an optional caption. Unknown = the dashed "?" frame.
## Used for clues, residents, photo cards, the held photo and map stickers.

const FRAME := preload("res://art/ui/photo_frame.png")
const FRAME_UNKNOWN := preload("res://art/ui/photo_frame_unknown.png")
const CAPTION_FONT := preload("res://ui/fonts/CaveatBrush-Regular.ttf")
## The grey photo square inside photo_frame.png, as fractions of the frame.
const PHOTO_AREA := Rect2(0.0995, 0.124, 0.80, 0.615)
## Frame width / height, to size polaroids without squashing them.
const ASPECT := 794.0 / 927.0

var _frame := TextureRect.new()
var _clip := Control.new()
var _photo := PlaceholderArt.new()
var _caption := Label.new()


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
	resized.connect(_layout)


## Sets what's in the photo. Returns itself so it can be chained.
## silhouette = heard of but not met: the photo shows a black shape and "???".
func setup(art_id: String, caption := "", known := true, silhouette := false) -> Polaroid:
	_frame.texture = FRAME if known else FRAME_UNKNOWN
	_clip.visible = known
	_photo.art_id = art_id
	_photo.modulate = Color.BLACK if silhouette else Color.WHITE
	# No drawing yet: a black box looks broken, and the grey box's label would give the name away.
	_photo.show_placeholder = not silhouette
	_caption.text = ("???" if silhouette else caption) if known else ""
	_layout()
	return self


func _layout() -> void:
	_frame.size = size
	_clip.position = PHOTO_AREA.position * size
	_clip.size = PHOTO_AREA.size * size
	_photo.size = _clip.size
	_caption.position = Vector2(0, PHOTO_AREA.end.y * size.y)
	_caption.size = Vector2(size.x, size.y * (0.93 - PHOTO_AREA.end.y))
	_caption.add_theme_font_size_override("font_size", maxi(12, int(size.y * 0.14)))
