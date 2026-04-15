extends Node2D

func drawGraph():
	draw_edges()
	draw_nodes()

func draw_edges() -> void:
	for i in GlobalVariables.edges.size():
		var startPointIndex = GlobalVariables.edges[i]["start"]
		var endPointIndex = GlobalVariables.edges[i]["end"]
		
		var startPosition:Vector2 = GlobalVariables.points[startPointIndex]["position"]
		var endPosition:Vector2 = GlobalVariables.points[endPointIndex]["position"]
		add_child(Edge.new(startPosition, endPosition, i))
	
func draw_nodes():
	var numberOfNodes = GlobalVariables.points.size()
	
	for i in numberOfNodes:
		add_child(Point.new(GlobalVariables.points[i]["position"][0], GlobalVariables.points[i]["position"][1]))

func totalEdges():
	var count: int
	for i in GlobalVariables.edges:
		count = count + 1
	return count

func _ready():
	drawGraph()
	#GlobalVariables.edgesRemaining = totalEdges()
