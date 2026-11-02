class_name Tape
## A strip of grey tape stuck across the top edge of a paper label (map
## labels, the map title, Close buttons, the Options sheet), like the photos in
## the notebook. Drawn rather than added as a child, so containers (which
## stretch their children) can have tape too.

const COLOR := Color(0.78, 0.78, 0.78, 0.85)


## Sticks tape on `control`, centred on its top edge; it follows resizes.
static func stick(control: Control, width := 56.0, height := 22.0) -> void:
	control.draw.connect(func():
		control.draw_rect(Rect2((control.size.x - width) / 2, -height / 2, width, height), COLOR))
	control.queue_redraw()
