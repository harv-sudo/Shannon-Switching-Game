extends Node2D

var playerOnePoints: Array = []
var playerTwoPoints: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#drawGrid()
	generatePoints("One")
	drawEdges("One")
	generatePoints("Two")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func generatePoints(player: String):
	var start_x: int
	var start_y: int
	var rows: int
	var cols: int
	var points: Array = []
	
	if player == "One":
		start_x = 300
		start_y = 100
		rows = 5 
		cols = 6 # Columns
		points = playerOnePoints
		
	elif player == "Two":
		start_x = 250
		start_y = 150
		rows = 6 # rows
		cols = 5
		points = playerTwoPoints
	else:
		print('ERROR!! - must be "One" or "Two"')
		
	for i in range(rows):
		for j in range(cols):
			var point = Vector2(start_x + (i * 100), start_y + (100 * j))
			points.append({"position" : point})
			drawPoint(points.back())

func drawPoint(point: Dictionary):
	print(point)
	var drawPoint = Point.new(point["position"][0], point["position"][1])
	add_child(drawPoint)


func drawEdges(player: String):
	var edge_index: int = 0
	var COLS: int
	if player == "One":
		COLS = 6
	elif player == "Two":
		COLS = 5
		
	for i in range(5):
		for j in range(6):
			var index = i * COLS + j
			var point = playerOnePoints[index]
			
			if i < 4:
				var right = playerOnePoints[(i+1) * COLS + j]
				add_child(Edge.new(point.position, right.position, edge_index))
				edge_index += 1
			
			if j < 5:
				var down = playerOnePoints[i * COLS + (j + 1)]
				add_child(Edge.new(point.position, down.position, edge_index))
				edge_index += 1
