extends Node2D

class_name ShannonGame

var game_manager: GameManager

func set_game_manager(gm: GameManager) -> void:
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
		edge.name = "edge-" + str(i)
		add_child(edge)
		edge.edge_clicked.connect(update_edges)

func draw_nodes() -> void:
	var numberOfNodes = GlobalVariables.points.size()
	
	for i in numberOfNodes:
		var point = Point.new(
			GlobalVariables.points[i]["position"][0],
			GlobalVariables.points[i]["position"][1])
		
		point.name = "point-" + str(i)
		add_child(point)

# NEEDS BETTER NAME
# This function deals with short/cut edge interction
func update_edges(edge) -> void:
	var edgeReference = edge.edgeReference
	
	if game_manager.currentPlayer == game_manager.Player.P1:
		GlobalVariables.short_edges[edgeReference] = GlobalVariables.edges[edgeReference]
		edge.capture()
		
	else:
		# Tracks the shorts players current selected edges
		GlobalVariables.edges.erase(edgeReference)
		edge.remove()
	
	is_game_over()

func is_game_over() -> void:
	var gameIsOver = WinConditions.is_game_over(
	GlobalVariables.start_node,
	GlobalVariables.end_node,
	GlobalVariables.points,
	GlobalVariables.edges
	)
	
	if gameIsOver:
		game_manager.gameOver()
	else:
		game_manager.switchPlayer()

func apply_ai_move(edge_id: int) -> void:
	for child in get_children():
		if child is Edge and child.edgeReference == edge_id:
			child.remove() # or queue_free()
			if game_manager.currentPlayer == game_manager.Player.P1:
				GlobalVariables.short_edges[edge_id] = GlobalVariables.edges[edge_id]
			
			GlobalVariables.edges.erase(edge_id)
	
	is_game_over()

# When the node is added to the scene, the function is called
func _ready() -> void:
	drawGraph()
