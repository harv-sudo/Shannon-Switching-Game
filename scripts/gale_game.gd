extends Node2D

var playerOnePoints: Array = []
var playerTwoPoints: Array = []

var playerOneEdges: Dictionary = {}
var playerTwoEdges: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generatePoints("One")
	generatePoints("Two")
	#drawEdges("One")
	pass # Replace with function body.

func _draw():
	generatePoints("One")
	generatePoints("Two")
	if GlobalVariables.currentPlayer == 0:
		drawEdges("One")
	elif GlobalVariables.currentPlayer == 1:
		drawEdges("Two")
		

func generatePoints(player: String):
	var start_x: int
	var start_y: int
	var rows: int
	var cols: int
	var points: Array = []
	var colour: Color
	
	if player == "One":
		start_x = 300
		start_y = 100
		rows = 5 
		cols = 6 # Columns
		points = playerOnePoints
		colour = Color.BLUE
		
	elif player == "Two":
		start_x = 250
		start_y = 150
		rows = 6 # rows
		cols = 5
		points = playerTwoPoints
		colour = Color.RED
	else:
		print('ERROR!! - must be "One" or "Two"')
		
	for i in range(rows):
		for j in range(cols):
			var point = Vector2(start_x + (i * 100), start_y + (100 * j))
			points.append({"position" : point})
			drawPoint(points.back(), colour)

func drawPoint(point: Dictionary, colour: Color):
	print(point)
	var drawPoint = Point.new(point["position"][0], point["position"][1], colour)
	add_child(drawPoint)


func drawEdges(player: String):
	var edge_index: int = 0
	var COLS: int
	var ROWS: int
	var addToDictionary: Dictionary = {}
	var points = []
	
	if player == "One":
		COLS = 6
		ROWS = 5
		addToDictionary = playerOneEdges
		points = playerOnePoints
		
	elif player == "Two":
		COLS = 5
		ROWS = 6
		addToDictionary = playerTwoEdges
		points = playerTwoPoints
		
	for i in range(ROWS):
		for j in range(COLS):
			var index = i * COLS + j
			var point = points[index]
			
			if i < ROWS - 1:
				var right = points[(i+1) * COLS + j]
				add_child(Edge.new(point["position"], right["position"], edge_index))
				addToDictionary[edge_index] = {"start": point["position"], "end": right["position"] }
				edge_index += 1
			
			if j < COLS - 1:
				var down = points[i * COLS + (j + 1)]
				add_child(Edge.new(point.position, down.position, edge_index))
				addToDictionary[edge_index] = {"start": point["position"], "end": down["position"] }
				edge_index += 1
				
				
