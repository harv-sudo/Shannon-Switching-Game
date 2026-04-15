extends Node2D
class_name GraphPoint

var x_position: float
var y_position: float
var radius: float = 12.0
var colour: Color = Color.BLACK
var label_text: String = ""
var label_colour: Color = Color.WHITE

func _init(
	x: float,
	y: float,
	radius_value: float = 12.0,
	point_colour: Color = Color.BLACK,
	text: String = "",
	text_colour: Color = Color.WHITE
) -> void:
	x_position = x
	y_position = y
	radius = radius_value
	colour = point_colour
	label_text = text
	label_colour = text_colour

func _ready() -> void:
	position = Vector2(x_position, y_position)
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, colour)

	if label_text != "":
		var font = ThemeDB.fallback_font
		var font_size = 18
		var text_size = font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		draw_string(
			font,
			Vector2(-text_size.x / 2.0, text_size.y / 2.5),
			label_text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size,
			label_colour
		)
