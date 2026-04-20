extends Node2D
class_name GaleGame

var playerOnePoints: Array = []
var playerTwoPoints: Array = []

var playerOneEdges: Dictionary = {}
var playerTwoEdges: Dictionary = {}

var playerOneCapturedEdges: Dictionary
var playerTwoCapturedEdges: Dictionary

var game_manager: GameManager

var start = 300
var goal = 900

func set_game_manager(gm: GameManager) -> void:
	game_manager = gm

func drawGraph():
	generatePoints("One")
	generatePoints("Two")
	#print(playerOnePoints)
	drawEdges(playerOnePoints, playerOneEdges, "Blue", true)
	drawEdges(playerTwoPoints, playerTwoEdges, "Red", false)



func generatePoints(player: String):
	var startX: int
	var startY: int
	var rows: int
	var cols: int
	var points: Array
	var colour: Color
	var pointReference: int = 0
	
	if player == "One":
		startX = 300
		startY = 100
		rows = 6
		cols = 5
		points = playerOnePoints
		colour = Color.BLUE
		
	elif player == "Two":
		startX = 250
		startY = 150
		rows = 5
		cols = 6
		points = playerTwoPoints
		colour = Color.RED
		
	else:
		print('ERROR!! - must be "One" or "Two"')
		
	for i in range(rows):
		for j in range(cols):
			var point = Vector2(startX + (j * 100), startY + (100 * i))
			points.append({"position" : point, "row" : str(i), "col" : str(j)})
			drawPoint(points.back(), colour, i, j)

func drawPoint(points: Dictionary, colour: Color, row: int, col: int):
	var point = Point.new(points["position"][0], points["position"][1], colour)
	var colour_name: String
	
	if colour == Color.BLUE:
		colour_name = "B"
	else:
		colour_name = "R"
	
	#point.name = colour_name + "| r:" + str(row) + ", c: " + str(col)
	point.name = "{colour_name} | r: {row}, c: {col}".format({"colour_name" : colour_name, "row": row, "col": col})
	
	add_child(point)

func make_edge(points: Array, start_point: Vector2, end_point: Vector2, player_colour: String, visibility: bool, edgeReference: int):
		var edge = Edge.new(start_point, end_point, edgeReference)
		
		edge.name = str(player_colour) + "_" + str(edgeReference)
		edge.visible = visibility

		## Adds a function to the edge_clicked signal in the Edge class
		edge.edge_clicked.connect(change_edge)
		add_child(edge)

# Draws the edges array for each player
func drawEdges(points: Array, edges: Dictionary, player_colour: String, visibility: bool):
	var ROWS
	var COLS
	var horizontal_first
	
	if points == playerOnePoints:
		ROWS = 6
		COLS = 5
		horizontal_first = false
		
	if points == playerTwoPoints:
		ROWS = 5
		COLS = 6
		horizontal_first = true
	
	# Red: left/right
	# Blue: up/down
	if horizontal_first:
		draw_horizontal_edges(points, edges, ROWS, COLS, player_colour, visibility)
		draw_vertical_edges(points, edges, ROWS, COLS, player_colour, visibility)
	# Red up/down
	# Blue: left/right
	else:
		
		draw_vertical_edges(points, edges, ROWS, COLS, player_colour, visibility)	
		draw_horizontal_edges(points, edges, ROWS, COLS, player_colour, visibility)

func draw_horizontal_edges(points: Array, edges: Dictionary, ROWS: int, COLS: int, player_colour: String, visibility: bool):
	var index: int = 0
	var offset: int = 0
	var first_row: int = COLS - 1
	var last_row: int = (ROWS  - 1) * COLS
	
	if player_colour == "Blue":
		offset = (ROWS * (COLS - 1)) + 1 # Number of horizontal edges
	else:
		offset = 0
	
	for i in range(points.size() - 1):
		if i % COLS == COLS - 1:
			continue
		var start_position = points[i]["position"]
		var end_position = points[i + 1]["position"]
		if player_colour == "Blue" and (i <= first_row or i >= last_row):
			## Currently doesn't work due to needing to be called in _draw()
			draw_visual_edge(start_position, end_position,Color.BLUE)
			continue
		make_edge(points, start_position, end_position, player_colour, visibility, offset)
		edges[offset] = {"start": i, "end": i+1}
		offset += 1

func draw_vertical_edges(points: Array, edges: Dictionary, ROWS, COLS: int, player_colour: String, visibility: bool):
	var offset: int

	if player_colour == "Blue":
		offset = 0
	else:
		offset = (ROWS * (COLS - 1)) # Number of horizontal edges
		
	for j in range(points.size() - COLS):
		var start_position = points[j]["position"]
		var end_position = points[j + COLS]["position"]
		if player_colour == "Red" and ((j % COLS == 0) or (j % COLS == COLS - 1)):
			draw_visual_edge(start_position, end_position, Color.RED)
			continue
		make_edge(points, start_position, end_position, player_colour,visibility,offset)

		edges[offset] = {"start": j, "end": j+COLS}
		offset += 1

func draw_visual_edge(start_point: Vector2,end_point: Vector2, colour: Color):
	var line: Line2D = Line2D.new()
	line.width = 10
	line.default_color = colour
	line.points = [start_point, end_point]
	add_child(line)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	drawGraph()

func change_edge(edge):
	var edgeReference = edge.edgeReference
	var remove_child: String
	var winner = WinConditions.new()
	if game_manager.currentPlayer == game_manager.Player.P1:
		remove_child = "Red_" + str(edgeReference)
		edge.capture(Color.BLUE)
		playerOneCapturedEdges[edgeReference] = playerOneEdges[edgeReference]
		
		
		#winner.is_game_over(start,
			#goal,
			#playerOnePoints,
			#playerOneCapturedEdges)
	else:
		remove_child = "Blue_" + str(edgeReference)
		edge.capture(Color.RED)
		playerTwoCapturedEdges[edgeReference] = playerTwoEdges[edgeReference]
		#winner.is_game_over(start,
			#goal,
			#playerTwoPoints,
			#playerTwoCapturedEdges)
		
	# Edge name is changed to prevent its visibility changing, leaving the played move on the board
	edge.name = "CAPTURE: " + edge.name
	
	# Removes the node for the other player, stopping them from selecting that edge on their game grid
	var hide_node = get_node("/root/Board/GaleGame/" + remove_child)
	hide_node.name = "hidden" + remove_child
	hide_node.visible = false
	
	# Toggles the visability of each player's grid
	for node_edge in get_children():
		if node_edge.name.begins_with("Blue_") or node_edge.name.begins_with("Red_"):
			if node_edge.visible == true:
				node_edge.visible = false
			else:
				node_edge.visible = true
	
	playerOneEdges.erase(edgeReference)
	playerTwoEdges.erase(edgeReference)
	
	game_manager.switchPlayer()

#func _draw():
	#if game_manager.currentPlayer == game_manager.Player.P1:
		#drawEdges(playerOneEdges, "Blue", true)
	#else:
		#drawEdges(playerTwoEdges, "Red", true)
		#
