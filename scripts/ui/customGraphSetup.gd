extends Node2D

enum EditorMode { ADD_NODE, ADD_EDGE, SELECT_TERMINALS }

@onready var graph_root = $GraphRoot
@onready var status_label = $CanvasLayer/Control/StatusLabel
@onready var panel = $CanvasLayer/Control/Panel
@onready var toggle_menu_button = $CanvasLayer/Control/ToggleMenuButton

@onready var add_node_button = $CanvasLayer/Control/Panel/MarginContainer/VBoxContainer/AddNodeButton
@onready var add_edge_button = $CanvasLayer/Control/Panel/MarginContainer/VBoxContainer/AddEdgeButton
@onready var start_game_button = $CanvasLayer/Control/Panel/MarginContainer/VBoxContainer/StartGameButton
@onready var clear_graph_button = $CanvasLayer/Control/Panel/MarginContainer/VBoxContainer/ClearGraphButton

var editor_mode: int = EditorMode.ADD_NODE
var drag_start_index: int = -1
var preview_mouse_pos: Vector2 = Vector2.ZERO
var node_radius: float = 16.0
var status_message: String = "Click Add Node, then click anywhere to place nodes."

func _ready() -> void:
	add_node_button.pressed.connect(_on_add_node_button_pressed)
	add_edge_button.pressed.connect(_on_add_edge_button_pressed)
	start_game_button.pressed.connect(_on_start_game_button_pressed)
	clear_graph_button.pressed.connect(_on_clear_graph_button_pressed)
	toggle_menu_button.pressed.connect(_on_toggle_menu_button_pressed)

	# Restore custom graph if coming from restart
	if GlobalVariables.use_custom_graph and GlobalVariables.custom_points.size() > 0:
		GlobalVariables.points = GlobalVariables.custom_points.duplicate(true)
		GlobalVariables.edges = GlobalVariables.custom_edges.duplicate(true)

		editor_mode = EditorMode.SELECT_TERMINALS
		status_message = "Select START node, then END node."
	else:
		GlobalVariables.points = []
		GlobalVariables.edges = {}

		editor_mode = EditorMode.ADD_NODE
		status_message = "Click Add Node, then click anywhere to place nodes."

	# Always reset gameplay state
	GlobalVariables.short_edges = {}
	GlobalVariables.winner_label = ""
	GlobalVariables.start_node = -1
	GlobalVariables.end_node = -1

	_rebuild_graph_visuals()
	queue_redraw()

func _process(_delta: float) -> void:
	var mode_text := "Mode: Add Node"
	if editor_mode == EditorMode.ADD_EDGE:
		mode_text = "Mode: Add Edge"
	elif editor_mode == EditorMode.SELECT_TERMINALS:
		mode_text = "Mode: Select Terminals"

	status_label.text = mode_text + "\n" + status_message

func _input(event):
	if editor_mode == EditorMode.ADD_NODE:
		_handle_add_node_input(event)
	elif editor_mode == EditorMode.ADD_EDGE:
		_handle_add_edge_input(event)
	elif editor_mode == EditorMode.SELECT_TERMINALS:
		_handle_terminal_selection_input(event)

func _draw():
	if editor_mode == EditorMode.ADD_EDGE and drag_start_index != -1:
		var start_raw = GlobalVariables.points[drag_start_index]["position"]
		var start_pos = Vector2(start_raw[0], start_raw[1])
		draw_line(start_pos, preview_mouse_pos, Color.WHITE, 2.0)

func _handle_add_node_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _click_is_on_ui(event.position):
			return

		if _get_node_at_position(event.position) != -1:
			return

		add_node_at(event.position)

func _handle_add_edge_input(event):
	if event is InputEventMouseMotion:
		preview_mouse_pos = event.position
		queue_redraw()

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _click_is_on_ui(event.position):
				return

			var node_index = _get_node_at_position(event.position)
			if node_index != -1:
				begin_edge_drag(node_index)
		else:
			if drag_start_index == -1:
				return

			var node_index = _get_node_at_position(event.position)
			if node_index != -1 and node_index != drag_start_index:
				finish_edge_drag(node_index)
			else:
				cancel_edge_drag()

func _handle_terminal_selection_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _click_is_on_ui(event.position):
			return

		var node_index = _get_node_at_position(event.position)
		if node_index == -1:
			return

		if GlobalVariables.start_node == -1:
			GlobalVariables.start_node = node_index
			status_message = "Select END node."
			_rebuild_graph_visuals()
			queue_redraw()
			return

		if GlobalVariables.end_node == -1 and node_index != GlobalVariables.start_node:
			GlobalVariables.end_node = node_index

			GlobalVariables.custom_points = GlobalVariables.points.duplicate(true)
			GlobalVariables.custom_edges = GlobalVariables.edges.duplicate(true)
			GlobalVariables.use_custom_graph = true
			GlobalVariables.short_edges = {}
			GlobalVariables.winner_label = ""

			App.game_type = App.GameType.SHANNON
			get_tree().change_scene_to_file("res://scenes/GameManager.tscn")

func _on_add_node_button_pressed():
	editor_mode = EditorMode.ADD_NODE
	status_message = "Click anywhere outside the menu to place a node."
	queue_redraw()

func _on_add_edge_button_pressed():
	if GlobalVariables.points.size() < 2:
		status_message = "Place at least 2 nodes first."
		return

	editor_mode = EditorMode.ADD_EDGE
	status_message = "Drag from one node to another to create an edge."
	queue_redraw()

func _on_start_game_button_pressed():
	if GlobalVariables.points.size() < 2:
		status_message = "Place at least 2 nodes first."
		return

	if GlobalVariables.edges.is_empty():
		status_message = "Create at least one edge first."
		return

	editor_mode = EditorMode.SELECT_TERMINALS
	GlobalVariables.start_node = -1
	GlobalVariables.end_node = -1
	status_message = "Select START node, then END node."
	queue_redraw()

func _on_clear_graph_button_pressed():
	GlobalVariables.points = []
	GlobalVariables.edges = {}
	GlobalVariables.short_edges = {}
	GlobalVariables.start_node = -1
	GlobalVariables.end_node = -1
	drag_start_index = -1
	status_message = "Graph cleared."
	_rebuild_graph_visuals()
	queue_redraw()

func _on_toggle_menu_button_pressed():
	panel.visible = not panel.visible

	if panel.visible:
		toggle_menu_button.text = "Hide Menu"
	else:
		toggle_menu_button.text = "Settings"

func add_node_at(pos: Vector2):
	GlobalVariables.points.append({
		"position": [pos.x, pos.y]
	})

	status_message = "Node " + str(GlobalVariables.points.size() - 1) + " added."
	_rebuild_graph_visuals()

func begin_edge_drag(node_index: int):
	drag_start_index = node_index
	var point_raw = GlobalVariables.points[node_index]["position"]
	preview_mouse_pos = Vector2(point_raw[0], point_raw[1])
	status_message = "Release on another node to create an edge."
	queue_redraw()

func finish_edge_drag(node_index: int):
	var start_index = drag_start_index
	drag_start_index = -1

	if node_index == start_index:
		status_message = "Edge creation cancelled."
		queue_redraw()
		return

	add_edge_between(start_index, node_index)

func cancel_edge_drag():
	drag_start_index = -1
	status_message = "Edge creation cancelled."
	queue_redraw()

func add_edge_between(a: int, b: int):
	if a == b:
		status_message = "Cannot connect a node to itself."
		return

	for i in GlobalVariables.edges.keys():
		var edge = GlobalVariables.edges[i]
		if (edge["start"] == a and edge["end"] == b) or (edge["start"] == b and edge["end"] == a):
			status_message = "Edge already exists."
			return

	var new_edge_id = GlobalVariables.edges.size()
	GlobalVariables.edges[new_edge_id] = {
		"start": a,
		"end": b
	}

	status_message = "Edge created: " + str(a) + "-" + str(b)
	_rebuild_graph_visuals()

func _get_node_at_position(mouse_pos: Vector2) -> int:
	for i in range(GlobalVariables.points.size()):
		var point = GlobalVariables.points[i]["position"]
		var point_pos = Vector2(point[0], point[1])
		if mouse_pos.distance_to(point_pos) <= node_radius:
			return i
	return -1

func _click_is_on_ui(_mouse_pos: Vector2) -> bool:
	var hovered = get_viewport().gui_get_hovered_control()
	return hovered != null

func _rebuild_graph_visuals():
	for child in graph_root.get_children():
		child.queue_free()

	for i in GlobalVariables.edges.size():
		var edge = GlobalVariables.edges[i]
		var start_raw = GlobalVariables.points[edge["start"]]["position"]
		var end_raw = GlobalVariables.points[edge["end"]]["position"]
		var start_position = Vector2(start_raw[0], start_raw[1])
		var end_position = Vector2(end_raw[0], end_raw[1])
		graph_root.add_child(Edge.new(start_position, end_position, i))

	for i in range(GlobalVariables.points.size()):
		var point_raw = GlobalVariables.points[i]["position"]

		var point_colour = Color.BLACK
		if i == GlobalVariables.start_node:
			point_colour = Color.GREEN
		elif i == GlobalVariables.end_node:
			point_colour = Color.RED

		graph_root.add_child(Point.new(int(point_raw[0]), int(point_raw[1]), point_colour))
