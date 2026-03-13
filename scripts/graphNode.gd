extends Node2D

class_name graphNode

var x_position: int;
var y_position: int;
var radius: int = 40;
var colour: Color = Color.ROYAL_BLUE;
var distance: int = 100;
	
func _init(x_position: int, y_position: int) -> void:
	self.x_position = x_position;
	self.y_position = y_position;
	
func _draw():
	draw_circle(Vector2(x_position, y_position),radius, colour);
