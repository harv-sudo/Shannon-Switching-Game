extends Node2D

class_name Edge

var start_position: Vector2
var end_position: Vector2
var width: float = 10.0
var colour: Color = Color.BLACK
var edgeReference: int

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
	queue_redraw()
	
# Used to remove hover effect for the edge
func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	is_hovered = false
	queue_redraw()

func _draw() ->void:
	var checkColour: Color
	
	# Changes colour of edge if selected by the short player (P1)
	if is_captured:
		checkColour = Color.GREEN
		area.mouse_entered.disconnect(_on_mouse_entered)
		area.mouse_exited.disconnect(_on_mouse_exited)

	elif is_hovered:
		checkColour = hovered_colour
		
	else:
		checkColour = colour

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
			# Edge selected by short player (P1) turns green
			0:
				print("\n\nPlayer 1s turn")
				# Enables the re-colouring of the edge
				is_captured = true
				# Tells the engine to redraw the canvas item
				queue_redraw()
				
			# Edge selected by player 2 is deleted from scene tree
			1:
				print("\n\nPlayer 2s turn")
				#Removes the edge from the edges global array
				# Removes the edge from the scene
				queue_free()
		
		# The section below is used to remove the clickable area for an edge
		# when selected
		
		if GlobalVariables.currentPlayer == 1:
			GlobalVariables.edges.erase(edgeReference)
		else:
			GlobalVariables.short_edges[edgeReference] = GlobalVariables.edges[edgeReference]
			print(GlobalVariables.short_edges[edgeReference])
		
		var gameState = WinConditions.new()
		var currentState = gameState.is_game_over(GlobalVariables.start_node, GlobalVariables.end_node, GlobalVariables.points, GlobalVariables.edges)
		
		GlobalVariables.currentPlayer ^= 1
		area.input_pickable = false
		is_hovered = false
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		
