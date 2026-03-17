extends Node2D

var edgesArray: Array[Array] = [[0, 1, 0, 1], 
							  [1, 0, 1, 1],
							  [0, 1, 0, 1],
							  [1, 1, 1, 0]]

var points = [
	{"position": Vector2(200, 200)},
	{"position": Vector2(450, 150)},
	{"position": Vector2(650, 250)},
	{"position": Vector2(350, 450)},
]

func drawGraph():
	draw_edges()
	draw_nodes()

func draw_edges():
	var dimensions = edgesArray.size()
	
	for j in dimensions:
		for k in range (j + 1, dimensions):
			print("j = ",j, "| k = ", k)
			if edgesArray[j][k] == 1:
				add_child(Edge.new(points[k]["position"], points[j]["position"]))

func draw_nodes():
	var numberOfNodes = points.size()
	
	for i in numberOfNodes:
		add_child(Point.new(points[i]["position"][0], points[i]["position"][1]))

func _ready():
	drawGraph()
