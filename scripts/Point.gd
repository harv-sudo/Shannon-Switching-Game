extends Node2D
class_name Point

var x_position: float
var y_position: float
var radius: float = 11.0
var colour: Color = Color.BLACK
var terminal_label: String = ""

func _init(x_pos: float, y_pos: float, pointColour: Color = Color.BLACK) -> void:
	x_position = x_pos
	y_position = y_pos
	colour = pointColour
	z_index = 2

func _draw() -> void:
	var at = Vector2(x_position, y_position)
	var ink = GameStyle.MUTED
	if colour == Color.BLUE:
		ink = GameStyle.BLUE
	elif colour == Color.RED:
		ink = GameStyle.CORAL
	elif colour == Color.GREEN:
		ink = GameStyle.TEAL
	elif colour == Color.GOLD:
		ink = GameStyle.GOLD
	var dot_radius = 17.0 if not terminal_label.is_empty() else radius
	draw_circle(at, dot_radius + 4, Color(ink, 0.12), true, -1, true)
	draw_circle(at, dot_radius, GameStyle.BACKGROUND, true, -1, true)
	draw_circle(at, dot_radius, ink, false, 2.5, true)
	if terminal_label.is_empty():
		draw_circle(at, 3.5, ink, true, -1, true)
	else:
		var font = ThemeDB.fallback_font
		var text_width = font.get_string_size(terminal_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 17).x
		draw_string(font, at + Vector2(-text_width / 2, 6), terminal_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, ink)
