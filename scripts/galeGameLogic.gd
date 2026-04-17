extends Node2D

class_name GaleGame

var playerOnePoints: Array = []
var playerTwoPoints: Array = []

var playerOneEdges: Dictionary = {}
var playerTwoEdges: Dictionary = {}

var game_manager: GameManager

func set_game_manager(gm: GameManager) -> void:
	game_manager = gm

func drawGraph():
	generatePoints("One")
	generatePoints("Two")

func generatePoints(player: String):
	var startX: int
	var startY: int
	var rows: int
	var cols: int
	var points: Array = []
	var colour: Color
	
	if player == "One":
		startX = 300
		startY = 100
		rows = 5 
		cols = 6 # Columns
		points = playerOnePoints
		colour = Color.BLUE
		
	elif player == "Two":
		startX = 250
		startY = 150
		rows = 6 # rows
		cols = 5
		points = playerTwoPoints
		colour = Color.RED
	else:
		print('ERROR!! - must be "One" or "Two"')
		
	for i in range(rows):
		for j in range(cols):
			var point = Vector2(startX + (i * 100), startY + (100 * j))
			points.append({"position" : point})
			drawPoint(points.back(), colour)

func drawPoint(point: Dictionary, colour: Color):
	var drawPoint = Point.new(point["position"][0], point["position"][1], colour)
	add_child(drawPoint)

# Creates the edges for the game grid and stores them in relevant array
# Two grids for the two different players
func createEdges(player: String)-> Dictionary:
	var edge_index: int = 0
	var COLS: int
	var ROWS: int
	var points: Array
	var edges: Dictionary = {}
	
	if player == "One":
		COLS = 6
		ROWS = 5
		points = playerOnePoints
		
	elif player == "Two":
		COLS = 5
		ROWS = 6
		points = playerTwoPoints
		
	for i in range(ROWS):
		for j in range(COLS):
			var index = i * COLS + j
			var point = points[index]
			
			if i < ROWS - 1:
				var right = points[(i+1) * COLS + j]
				edges[edge_index] = {
					"start": point["position"],
					"end": right["position"] 
					}
				edge_index += 1
			
			if j < COLS - 1:
				var down = points[i * COLS + (j + 1)]
				edges[edge_index] = {
					"start": point["position"],
					"end": down["position"] }
				edge_index += 1
	
	return edges

# Draws the edges array for each player
func drawEdges(edges: Dictionary):
	for edgeIndex in edges:
		var edgeData = edges[edgeIndex]
		var edge = Edge.new(
			edgeData["start"],
			edgeData["end"],
			edgeIndex
		)
		
		# Adds a function to the edge_clicked signal in the Edge class
		edge.edge_clicked.connect(change_edge)
		add_child(edge)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("GaleGame instance:", get_instance_id())
	
	#print()
	drawGraph()
	playerOneEdges = createEdges("One")
	#playerTwoEdges = createEdges("Two")
	drawEdges(playerOneEdges)
	

func change_edge(edge):
	if game_manager.currentPlayer == game_manager.Player.P1:
		edge.capture()
	print("Connected!")

func _draw():
	pass
		
