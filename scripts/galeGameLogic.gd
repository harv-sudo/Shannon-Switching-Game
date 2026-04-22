extends Node2D
class_name GaleGame

var player_one_points: Array = []
var player_one_edges: Dictionary = {}
var player_one_captured_edges: Dictionary = {}
var player_one_start_points = [0, 1, 2, 3, 4]
var player_one_goal_points = [25, 26, 27, 28, 29]

var player_two_points: Array = []
var player_two_edges: Dictionary = {}
var player_two_captured_edges: Dictionary = {}
var player_two_start_points = [0, 6, 12, 18, 24]
var player_two_goal_points = [5, 11, 17, 23, 29]

var game_manager: GameManager

@onready var select_sound_effect = preload("res://audio/short_sound_effect.mp3")
@onready var winner_sound_effect = preload("res://audio/victory_sound_effect.mp3")

func _draw_graph():
	_generate_points("One")
	_generate_points("Two")
	_draw_edges(player_one_points, player_one_edges, "Blue", true)
	_draw_edges(player_two_points, player_two_edges, "Red", false)

func _generate_points(player: String):
	var start_x: int
	var start_y: int
	var rows: int
	var cols: int
	var points: Array
	var colour: Color
	
	if player == "One":
		start_x = 300
		start_y = 100
		rows = 6
		cols = 5
		points = player_one_points
		colour = Color.BLUE
		
	elif player == "Two":
		start_x = 250
		start_y = 150
		rows = 5
		cols = 6
		points = player_two_points
		colour = Color.RED
		
	else:
		print('ERROR!! - must be "One" or "Two"')
		
	for i in range(rows):
		for j in range(cols):
			var point = Vector2(start_x + (j * 100), start_y + (100 * i))
			points.append({"position" : point, "row" : str(i), "col" : str(j)})
			_draw_point(points.back(), colour, i, j)

func set_game_manager(gm: GameManager) -> void:
	game_manager = gm

func _draw_point(points: Dictionary, colour: Color, row: int, col: int):
	var point = Point.new(points["position"][0], points["position"][1], colour)
	var colour_name: String
	
	if colour == Color.BLUE:
		colour_name = "B"
	else:
		colour_name = "R"
	
	point.name = "{colour_name} | r: {row}, c: {col}".format({"colour_name" : colour_name, "row": row, "col": col})
	point.z_index = 5
	add_child(point)

func _make_edge(start_point: Vector2,
	end_point: Vector2,
	player_colour: String,
	visibility: bool,
	edgeReference: int):
		
		var edge = Edge.new(start_point, end_point, edgeReference)
		edge.name = str(player_colour) + "_" + str(edgeReference)
		edge.visible = visibility
		# Hides the grid from the player
		#edge.modulate.a = 0.0
		if player_colour == "Blue":
			edge.hovered_colour = Color.BLUE
		else:
			edge.hovered_colour = Color.RED
		
		# Adds a function to the edge_clicked signal in the Edge class
		edge.edge_clicked.connect(change_edge)
		add_child(edge)

# Draws the edges array for each player
func _draw_edges(points: Array,
	edges: Dictionary,
	player_colour: String,
	visibility: bool):
	
	var rows
	var cols
	var horizontal_first
	
	if points == player_one_points:
		rows = 6
		cols = 5
		horizontal_first = false
		
	if points == player_two_points:
		rows = 5
		cols = 6
		horizontal_first = true
	
	# Red: left/right
	# Blue: up/down
	if horizontal_first:
		_draw_horizontal_edges(points,
			edges,
			rows,
			cols,
			player_colour,
			visibility)
			
		_draw_vertical_edges(points,
			edges,
			rows,
			cols,
			player_colour,
			visibility)
	
	# Red up/down
	# Blue: left/right
	else:
		_draw_vertical_edges(points, edges, rows, cols, player_colour, visibility)	
		_draw_horizontal_edges(points, edges, rows, cols, player_colour, visibility)

func _draw_horizontal_edges(points: Array,
	edges: Dictionary,
	rows: int,
	cols: int,
	player_colour: String,
	visibility: bool):
	
	var offset: int = 0
	var first_row: int = cols - 1
	var last_row: int = (rows  - 1) * cols
	
	if player_colour == "Blue":
		offset = (rows * (cols - 1)) + 1 # Number of horizontal edges
	else:
		offset = 0
	
	for i in range(points.size() - 1):
		var start_position = points[i]["position"]
		var end_position = points[i + 1]["position"]
		
		if i % cols == cols - 1:
			continue
		
		# Connects all of Player One's starting points and goal points
		# VISUAL ONLY
		if player_colour == "Blue" and (i <= first_row or i >= last_row):
			_draw_visual_edge(start_position, end_position,Color.BLUE)
			continue # These edges are not added to the player's edge dictionary
		
		_make_edge(start_position,
			end_position,
			player_colour,
			visibility,
			offset)
		
		edges[offset] = {"start": i, "end": i+1}
		offset += 1

func _draw_vertical_edges(points: Array,
	edges: Dictionary,
	rows: int,
	cols: int,
	player_colour: String,
	visibility: bool):
	
	var offset: int
	
	if player_colour == "Blue":
		offset = 0
	else:
		offset = (rows * (cols - 1)) # Number of horizontal edges
	
	for j in range(points.size() - cols):
		var start_position = points[j]["position"]
		var end_position = points[j + cols]["position"]
		
		# Connects all of Player Two's starting points and goal points
		# VISUAL ONLY
		if player_colour == "Red" and ((j % cols == 0) or (j % cols == cols - 1)):
			_draw_visual_edge(start_position, end_position, Color.RED)
			continue # These edges are not added to the player's edge dictionary
		
		_make_edge(start_position,
			end_position,
			player_colour,
			visibility,
			offset)

		edges[offset] = {"start": j, "end": j+cols}
		offset += 1

func _draw_visual_edge(start_point: Vector2,
	end_point: Vector2,
	colour: Color):
	
	var line: Line2D = Line2D.new()
	line.width = 10
	line.default_color = colour
	line.points = [start_point, end_point]
	add_child(line)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_draw_graph()

func change_edge(edge):
	var edgeReference = edge.edgeReference
	var hide_child: String
	
	# Uses the AudioPlayer global to play sound effects
	#AudioPlayer.play_sound_effect(select_sound_effect)
	
	if game_manager.currentPlayer == game_manager.Player.P1:
		hide_child = "Red_" + str(edgeReference)
		edge.capture(Color.BLUE)
		player_one_captured_edges[edgeReference] = player_one_edges[edgeReference]
		
		var player_one_wins = WinConditions.is_game_over_Gale(player_one_start_points,
			player_one_goal_points,
			player_one_points,
			player_one_captured_edges)
		
		if player_one_wins:
			get_tree().change_scene_to_file("res://scenes/gameOverScreen.tscn")
			GlobalVariables.winner_label = "Player 1 wins!"
			AudioPlayer.play_sound_effect(winner_sound_effect)

	else:
		hide_child = "Blue_" + str(edgeReference)
		edge.capture(Color.RED)
		player_two_captured_edges[edgeReference] = player_two_edges[edgeReference]
		
		var player_two_wins = WinConditions.is_game_over_Gale(player_two_start_points,
			player_two_goal_points,
			player_two_points,
			player_two_captured_edges)
		
		if player_two_wins:
			get_tree().change_scene_to_file("res://scenes/gameOverScreen.tscn")
			GlobalVariables.winner_label = "Player 2 wins!"
			AudioPlayer.play_sound_effect(winner_sound_effect)
			
	# Edge name is changed to so that it become permanently visible
	# for the rest of the game
	edge.name = "CAPTURE: " + edge.name
	
	# Hides the node for the other player in the game scene, 
	# stopping them from selecting that edge on their game grid
	var hide_node = get_node(hide_child)
	hide_node.name = "hidden" + hide_child
	hide_node.visible = false
	
	# Toggles the visability of each player's grid
	for node_edge in get_children():
		if node_edge.name.begins_with("Blue_") or node_edge.name.begins_with("Red_"):
			if node_edge.visible == true:
				node_edge.visible = false
			else:
				node_edge.visible = true
	
	# Removes the selected edge from each players possible
	# moves, as edges that overlap share the same id
	player_one_edges.erase(edgeReference)
	player_two_edges.erase(edgeReference)
	
	game_manager.switchPlayer()
