extends Control
class_name NetworkArt

var gale: bool = false

func _ready() -> void:
	custom_minimum_size = Vector2(0, 160)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	var points: Array[Vector2] = []
	var links: Array = []
	if gale:
		for row in range(3):
			for col in range(5):
				points.append(Vector2(0.12 + col * 0.19, 0.16 + row * 0.34))
		for row in range(3):
			for col in range(4):
				links.append([row * 5 + col, row * 5 + col + 1])
		for col in range(5):
			for row in range(2):
				links.append([row * 5 + col, (row + 1) * 5 + col])
	else:
		points = [Vector2(0.08, 0.5), Vector2(0.29, 0.16), Vector2(0.29, 0.84),
			Vector2(0.63, 0.16), Vector2(0.63, 0.84), Vector2(0.9, 0.5)]
		links = [[0, 1], [0, 2], [1, 2], [1, 3], [2, 4], [1, 4], [3, 4], [3, 5], [4, 5]]
	for i in range(links.size()):
		var a: Vector2 = points[links[i][0]] * size
		var b: Vector2 = points[links[i][1]] * size
		var color = GameStyle.BORDER
		if (gale and i < 4) or (not gale and i in [0, 3, 7]):
			color = GameStyle.BLUE if gale else GameStyle.TEAL
		draw_line(a, b, color, 3.0, true)
	for i in range(points.size()):
		var at = points[i] * size
		var color = GameStyle.BLUE if gale else GameStyle.TEAL
		draw_circle(at, 10.0, GameStyle.BACKGROUND, true, -1, true)
		draw_circle(at, 7.0, color, false, 2.0, true)
