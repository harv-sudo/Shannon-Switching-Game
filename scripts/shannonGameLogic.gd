extends Node2D

class_name ShannonGame

var game_manager: GameManager

func _init(gm: GameManager) -> void:
	game_manager = gm

func drawGraph() -> void:
	draw_edges()
	draw_nodes()

func draw_edges() -> void:
	for i in GlobalVariables.edges.size():
		var startPointIndex = GlobalVariables.edges[i]["start"]
		var endPointIndex = GlobalVariables.edges[i]["end"]
		
		var startPosition:Vector2 = GlobalVariables.points[startPointIndex]["position"]
		var endPosition:Vector2 = GlobalVariables.points[endPointIndex]["position"]
		var edge = Edge.new(startPosition, endPosition, i)
		add_child(edge)
		edge.edge_clicked.connect(update_edges)

func draw_nodes() -> void:
	var numberOfNodes = GlobalVariables.points.size()
	
	for i in numberOfNodes:
		add_child(Point.new(GlobalVariables.points[i]["position"][0], GlobalVariables.points[i]["position"][1]))

# NEEDS BETTER NAME
# This function deals with short/cut edge interction
func update_edges(edge) -> void:
	
	if game_manager.currentPlayer == game_manager.Player.P1:
			edge.capture()
	else:
			edge.remove()
	
	var edgeReference = edge.edgeReference
	
	if game_manager.currentPlayer == 1:
		GlobalVariables.edges.erase(edgeReference)
	else:
		# Tracks the shorts players current selected edges
		GlobalVariables.short_edges[edgeReference] = GlobalVariables.edges[edgeReference]
	
	
	var gameIsOver = WinConditions.is_game_over(
		GlobalVariables.start_node,
		GlobalVariables.end_node,
		GlobalVariables.points,
		GlobalVariables.edges
	)
	
	if gameIsOver:
		get_tree().change_scene_to_file("res://gameOverScreen.tscn")
		GlobalVariables.reset()
	
	game_manager.switchPlayer()

# When the node is added to the scene, the function is called
func _ready() -> void:
	drawGraph()
