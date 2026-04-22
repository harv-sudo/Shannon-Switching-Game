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
	for i in GlobalVariables.edges.keys():
		var startPointIndex = GlobalVariables.edges[i]["start"]
		var endPointIndex = GlobalVariables.edges[i]["end"]
		
		var startPosition:Vector2 = GlobalVariables.points[startPointIndex]["position"]
		var endPosition:Vector2 = GlobalVariables.points[endPointIndex]["position"]
		var edge = Edge.new(startPosition, endPosition, i)
		edge.name = "edge-" + str(i)
		add_child(edge)
		edge.edge_clicked.connect(update_edges)

func draw_nodes() -> void:
	var numberOfNodes = GlobalVariables.points.size()
	
	for i in numberOfNodes:

		var point = Point.new(
			GlobalVariables.points[i]["position"][0],
			GlobalVariables.points[i]["position"][1])
		
		if (i == GlobalVariables.start_node 
			or i == GlobalVariables.end_node):
			point.colour = Color.GOLD
		
		point.name = "point-" + str(i)
		add_child(point)

# NEEDS BETTER NAME
# This function deals with short/cut edge interction
func update_edges(edge) -> void:
	var edgeReference = edge.edgeReference
	if game_manager.currentPlayer == game_manager.Player.P1:
		GlobalVariables.short_edges[edgeReference] = GlobalVariables.edges[edgeReference]
		edge.capture(Color.GREEN)
		AudioPlayer.play_sound_effect(short_sound_effect)
		
	else:
		AudioPlayer.play_sound_effect(cut_sound_effect)
		
		# Tracks the shorts players current selected edges
		GlobalVariables.edges.erase(edgeReference)
		await get_tree().create_timer(0.5).timeout
		edge.visible = false
		
	is_game_over()

func is_game_over() -> void:
	var gameIsOver = WinConditions.is_game_over(
	GlobalVariables.start_node,
	GlobalVariables.end_node,
	GlobalVariables.points,
	GlobalVariables.edges
	)
	
	if gameIsOver:
		await get_tree().create_timer(0.5).timeout
		game_manager.gameOver()
	else:
		game_manager.switchPlayer()

func apply_ai_move(edge_id: int, acting_player: int) -> void:
	for child in get_children():
		if child is Edge and child.edgeReference == edge_id:
			if acting_player == game_manager.Player.P1:
				GlobalVariables.short_edges[edge_id] = GlobalVariables.edges[edge_id]
				child.capture(Color.GREEN)
				AudioPlayer.play_sound_effect(short_sound_effect)
			else:
				GlobalVariables.edges.erase(edge_id)
				child.remove()
				AudioPlayer.play_sound_effect(cut_sound_effect)
			break

	is_game_over()

#starts AI vs AI and the AI when player plays cut in PvAI
func _start_first_ai_turn() -> void:
	await get_tree().create_timer(0.5).timeout
	
	if GlobalVariables.game_mode == GlobalVariables.Mode.AIVSAI:
		game_manager.ai_controller.ai_player = game_manager.currentPlayer
	var best_edge: int = game_manager.ai_controller.ai_take_turn(GlobalVariables)
	if best_edge != -1:
		apply_ai_move(best_edge, game_manager.currentPlayer)

# When the node is added to the scene, the function is called	
func _ready() -> void:
	drawGraph()
	if GlobalVariables.game_mode == GlobalVariables.Mode.AIVSAI:
		call_deferred("_start_first_ai_turn")
	elif game_manager.ai_controller.ai_enabled and game_manager.currentPlayer == game_manager.ai_controller.ai_player:
		call_deferred("_start_first_ai_turn")
