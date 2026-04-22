extends Node2D

class_name Edge
signal edge_clicked(edge)

var start_position: Vector2
var end_position: Vector2
var width: float = 10.0
var colour: Color = Color.BLACK
var edgeReference: int
var audio: AudioStreamPlayer

var is_hovered: bool = false
var is_captured: bool = false
var hovered_colour: Color = Color.GRAY

var area: Area2D 
var collision: CollisionShape2D

func _init(start: Vector2, end: Vector2, index: int) -> void:
	self.start_position = start
	self.end_position = end
	self.edgeReference = index

func createCollision() -> void:
	area = Area2D.new()
	add_child(area)
	
	area.input_pickable = true
	
	var rectangle = RectangleShape2D.new()
	var length = (start_position - end_position).length()
	rectangle.size = Vector2(length, width)
	
	collision = CollisionShape2D.new()
	collision.shape = rectangle
	collision.disabled = false
	
	area.add_child(collision)
	area.position = (start_position + end_position) * 0.5
	area.rotation = (end_position - start_position).angle()
	
	# Adds event listeners to each area created
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	area.input_event.connect(_select_edge)

# Used to add hover effect for the edge
func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	is_hovered = true
	#if App.game_type == App.GameType.GALE:
		#self.modulate.a = 1.0

	queue_redraw()
	
# Used to remove hover effect for the edge
func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	is_hovered = false
	#if App.game_type == App.GameType.GALE:
		#self.modulate.a = 0.0
	queue_redraw()	

func capture(change_color: Color):
	colour = change_color
	is_captured = true
	is_hovered = false
	area.input_pickable = false
	area.mouse_entered.disconnect(_on_mouse_entered)
	area.mouse_exited.disconnect(_on_mouse_exited)
	queue_redraw()

func remove():
	queue_free()

# function needs to be fixed so that it works with SHANNON GAME
# Will just be a case of changing how Edge.capture() is called.
func _draw() ->void:
	var current_colour: Color
	if is_hovered:
		current_colour = hovered_colour
	else:
		current_colour = colour
	draw_line(start_position, end_position, current_colour, width)

func _ready() -> void:
	# Adds the collison to the edge, allowing for hover events to trigger
	createCollision()

# _ is required infront of variables that are not used, 
# but they are still need to not flag and error in the debugger
# as input_event that it is connected to requires these 3 args
func _select_edge(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (event is InputEventMouseButton 
	and event.button_index == MOUSE_BUTTON_LEFT
	and event.pressed):
		edge_clicked.emit(self)
