extends Node2D

class_name Edge

var start_position: Vector2
var end_position: Vector2
var width: float = 15.0
var colour: Color = Color.SKY_BLUE
var edgeReference: int

var is_hovered = false
var is_captured = false
var hovered_colour = Color.BLACK

var area: Area2D 
var collision: CollisionShape2D

func _init(start: Vector2, end: Vector2, index: int):
	self.start_position = start
	self.end_position = end
	self.edgeReference = index

func createCollision():
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
	
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	area.input_event.connect(_select_edge)

# Used to add hover effect for the edge
func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	is_hovered = true
	queue_redraw()
	
# Used to remove hover effect for the edge
func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	is_hovered = false
	queue_redraw()

func _draw():
	if is_captured:
		colour = Color.GREEN
		area.mouse_entered.disconnect(_on_mouse_entered)
		area.mouse_exited.disconnect(_on_mouse_exited)
		
	var checkColour = hovered_colour if is_hovered else colour
	draw_line(start_position, end_position, checkColour, width)

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
		
		match (GlobalVariables.currentPlayer):
			# Edge selected by player 1 turns green
			0:
				print("Player 1s turn")
				# Edge now belongs to the short player
				is_captured = true
				GlobalVariables.currentPlayer = GlobalVariables.Player.P2
				# Enables the re-colouring of the edge
				queue_redraw()
			# Edge selected by player 2 is deleted from scene
			1:
				print("Player 2s turn")
				#Removes the edge from the edges global array
				print(edgeReference)
				GlobalVariables.edges.erase(edgeReference)
				GlobalVariables.currentPlayer = GlobalVariables.Player.P1
				# Removes the edge from the scene
				queue_free()
		
		# The section below is used to remove the clickable area for an edge
		# when selected
		area.input_pickable = false
		is_hovered = false
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		
		print(GlobalVariables.edges)
