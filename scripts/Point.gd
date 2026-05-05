extends Node2D
class_name Point

var x_position: int;
var y_position: int;
var radius: int = 10;
var colour: Color = Color.BLACK;
var distance: int = 100;

func _init(x_pos: int, y_pos: int, pointColour:Color = Color.BLACK) -> void:
	self.x_position = x_pos
	self.y_position = y_pos
	self.colour = pointColour

func _draw():
	draw_circle(Vector2(x_position, y_position),radius, colour);
	#_add_image()
