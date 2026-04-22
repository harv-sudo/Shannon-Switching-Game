extends Node2D

class_name ShannonGame

var game_manager: GameManager

@onready var cut_sound_effect = preload("res://audio/cut_sound_effect.mp3")
@onready var short_sound_effect = preload("res://audio/short_sound_effect.mp3")

func set_game_manager(gm: GameManager) -> void:
	game_manager = gm

func drawGraph() -> void:
	draw_edges()
	draw_nodes()

func draw_edges() -> void:
	for i in GlobalVariables.edges.size():
		var startPointIndex = GlobalVariables.edges[i]["start"]
		var endPointIndex = GlobalVariables.edges[i]["end"]

		var start_raw = GlobalVariables.points[startPointIndex]["position"]
		var end_raw = GlobalVariables.points[endPointIndex]["position"]

		var startPosition = Vector2(start_raw[0], start_raw[1])
		var endPosition = Vector2(end_raw[0], end_raw[1])

		var edge = Edge.new(startPosition, endPosition, i)
		edge.name = "edge-" + str(i)
		add_child(edge)
		edge.edge_clicked.connect(update_edges)

# Harsh: Added colour code for terminal nodes
func draw_nodes() -> void:
	var numberOfNodes = GlobalVariables.points.size()
	
	for i in numberOfNodes:
		var point_raw = GlobalVariables.points[i]["position"]
		var point_colour = Color.BLACK

		if i == GlobalVariables.start_node:
			point_colour = Color.GREEN
		elif i == GlobalVariables.end_node:
			point_colour = Color.RED

		var point = Point.new(
			point_raw[0],
			point_raw[1],
			point_colour
		)
		
		if (i == GlobalVariables.start_node 
			or i == GlobalVariables.end_node):
			point.colour = Color.GOLD
		
		point.name = "point-" + str(i)
		add_child(point)

# NEEDS BETTER NAME
# This function deals with short/cut edge interaction
func update_edges(edge) -> void:
	var edgeReference = edge.edgeReference

	if game_manager.currentPlayer == game_manager.Player.P1:
		GlobalVariables.short_edges[edgeReference] = GlobalVariables.edges[edgeReference]
		edge.capture(Color.GREEN)
		AudioPlayer.play_sound_effect(short_sound_effect)
	else:
		AudioPlayer.play_sound_effect(cut_sound_effect)

		# Remove the edge from the available graph for Cut
		GlobalVariables.edges.erase(edgeReference)
		#await get_tree().create_timer(0.5).timeout
		edge.visible = false

	is_game_over()

# Harsh: Displays winner label when the game finishes
func is_game_over() -> void:
	var gameIsOver = WinConditions.is_game_over(
		GlobalVariables.start_node,
		GlobalVariables.end_node,
		GlobalVariables.points,
		GlobalVariables.edges
	)
	
	if gameIsOver:
		if game_manager.currentPlayer == game_manager.Player.P1:
			GlobalVariables.winner_label = "Short wins!"
		else:
			GlobalVariables.winner_label = "Cut wins!"

		await get_tree().create_timer(0.5).timeout
		game_manager.gameOver()
	else:
		game_manager.switchPlayer()

func apply_ai_move(edge_id: int) -> void:
	for child in get_children():
		if child is Edge and child.edgeReference == edge_id:
			if game_manager.currentPlayer == game_manager.Player.P1:
				GlobalVariables.short_edges[edge_id] = GlobalVariables.edges[edge_id]

			GlobalVariables.edges.erase(edge_id)
			child.remove()
			break

	is_game_over()

# When the node is added to the scene, the function is called
func _ready() -> void:
	drawGraph()
