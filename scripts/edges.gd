extends Node2D

class_name Edge

var start_position: Vector2
var end_position: Vector2
var width: float = 10.0
var colour: Color = Color.SKY_BLUE

var is_hovered = false
var hovered_colour = Color.BLACK

var area: Area2D 
var collision: CollisionShape2D

func _init(start: Vector2, end: Vector2):
	self.start_position = start
	self.end_position = end

func _ready() -> void:
	area = Area2D.new()
	add_child(area)
	
	area.input_pickable = true
	
	var rectangle = RectangleShape2D.new()
	var length = (start_position - end_position).length()
	rectangle.extents = Vector2(length * 0.5, width * 0.5)
	
	collision = CollisionShape2D.new()
	collision.shape = rectangle
	collision.disabled = false
	area.add_child(collision)
	
	area.position = (start_position + end_position) * 0.5
	area.rotation = (end_position - start_position).angle()
	
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	
	queue_redraw()

func _on_mouse_entered() -> void:
	is_hovered = true
	queue_redraw()
	
func _on_mouse_exited() -> void:
	is_hovered = false
	queue_redraw()
	
func _draw():
	var checkColour = hovered_colour if is_hovered else colour
	draw_line(start_position, end_position, checkColour, width)
