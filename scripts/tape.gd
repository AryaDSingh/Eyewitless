class_name Tape
## A strip of grey tape stuck across the top edge of a paper label (map
## labels, the map title, the Close buttons), like the photos in the notebook.

const COLOR := Color(0.78, 0.78, 0.78, 0.85)


## Sticks tape on `control`, centred on its top edge; it follows resizes.
static func stick(control: Control, width := 56.0, height := 22.0) -> ColorRect:
	var tape := ColorRect.new()
	tape.color = COLOR
	tape.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tape.size = Vector2(width, height)
	control.add_child(tape)
	var place := func(): tape.position = Vector2((control.size.x - width) / 2, -height / 2)
	place.call()
	control.resized.connect(place)
	return tape
