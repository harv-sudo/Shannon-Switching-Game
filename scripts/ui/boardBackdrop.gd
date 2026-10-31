extends Node2D
class_name BoardBackdrop

func _ready() -> void:
	z_index = -100
	get_viewport().size_changed.connect(queue_redraw)

func _draw() -> void:
	var extent = get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, extent), GameStyle.BACKGROUND)
	for x in range(24, int(extent.x), 32):
		for y in range(24, int(extent.y), 32):
			draw_circle(Vector2(x, y), 1.0, Color("#24343e"), true, -1, true)
