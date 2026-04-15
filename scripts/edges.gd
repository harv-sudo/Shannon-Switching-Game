extends Node2D
class_name Edge

var start_position: Vector2
var end_position: Vector2
var width: float = 12.0
var edgeReference: int

var area: Area2D
var collision: CollisionShape2D
var is_hovered: bool = false

func _init(start: Vector2, end: Vector2, index: int) -> void:
	start_position = start
	end_position = end
	edgeReference = index

func _ready() -> void:
	create_collision()

func create_collision() -> void:
	area = Area2D.new()
	add_child(area)
	area.input_pickable = true

	var rectangle = RectangleShape2D.new()
	var length = (start_position - end_position).length()
	rectangle.size = Vector2(length, width + 8.0)

	collision = CollisionShape2D.new()
	collision.shape = rectangle
	area.add_child(collision)

	area.position = (start_position + end_position) * 0.5
	area.rotation = (end_position - start_position).angle()

	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	area.input_event.connect(_select_edge)

func _on_mouse_entered() -> void:
	if GlobalVariables.can_select_edge(edgeReference):
		is_hovered = true
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		queue_redraw()

func _on_mouse_exited() -> void:
	is_hovered = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	queue_redraw()

func _draw() -> void:
	var state = GlobalVariables.edge_states.get(edgeReference, "free")
	var colour = Color(0.75, 0.75, 0.75) # default free edge
	var draw_width = width

	match state:
		"short":
			colour = Color(0.1, 0.85, 0.2) # green
		"cut":
			colour = Color(0.9, 0.2, 0.2) # red
			draw_width = 8.0
		_:
			if is_hovered:
				colour = Color.BLACK

	draw_line(start_position, end_position, colour, draw_width)

func _select_edge(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return

	if not GlobalVariables.can_select_edge(edgeReference):
		return

	match GlobalVariables.currentPlayer:
		GlobalVariables.Player.P1:
			GlobalVariables.edge_states[edgeReference] = "short"
		GlobalVariables.Player.P2:
			GlobalVariables.edge_states[edgeReference] = "cut"

	is_hovered = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	queue_redraw()

	GlobalVariables.check_win_conditions()

	if GlobalVariables.game_state != GlobalVariables.GameState.GAME_OVER:
		GlobalVariables.switch_turn()
