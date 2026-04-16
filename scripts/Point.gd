extends Node2D

class_name Point

var x_position: int;
var y_position: int;
var radius: int = 10;
var colour: Color = Color.BLACK;
var distance: int = 100;
	
func _init(x_pos: int, y_pos: int) -> void:
	self.x_position = x_pos;
	self.y_position = y_pos;
	
#func _add_image():
	#var texture: Texture2D = load("res://images/computer-icon.png")
	#
	#var sprite = Sprite2D.new()
	#sprite.texture = texture
	#sprite.size = Vector2(50, 50)
	#add_child(sprite)
	#
	#sprite.position = Vector2(x_position - 60, y_position - 60)
	
func _draw():
	draw_circle(Vector2(x_position, y_position),radius, colour);
	#_add_image()
