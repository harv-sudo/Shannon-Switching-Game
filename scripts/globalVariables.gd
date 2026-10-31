extends Node

# This script contains global variables that are loaded by the auto loader when the game runs.
# This allows us to access the variables declared within in other script files, allowing for 
# seperation of concerns.

# This makes it easier to keep track of what data structures we are using for testing purposes
# We need to implement this dynamically programatically creating different types of graphs

enum Player { P1, P2 }
enum Mode { PVP, AI, AIVSAI }

var game_mode: int = Mode.PVP
var selected_role: String = "Short"

# DYNAMIC GRAPHS VARIABLES
var use_dynamic_graph: bool = false
var dynamic_node_count: int = 7
var dynamic_edge_count: int = 12

var presetPoints = { 
	0:[
		{"position": Vector2(120, 280)}, # 0 - S
		{"position": Vector2(240, 180)}, # 1
		{"position": Vector2(240, 380)}, # 2
		{"position": Vector2(420, 160)}, # 3
		{"position": Vector2(420, 420)}, # 4
		{"position": Vector2(600, 280)}, # 5
		{"position": Vector2(740, 280)}  # 6 - G
	],
	1:[
		{"position": Vector2(100, 300)}, # 0 - S
		{"position": Vector2(200, 180)}, # 1
		{"position": Vector2(200, 420)}, # 2
		{"position": Vector2(350, 280)}, # 3
		{"position": Vector2(500, 180)}, # 4
		{"position": Vector2(500, 420)}, # 5
		{"position": Vector2(650, 280)}, # 6
		{"position": Vector2(780, 180)}, # 7
		{"position": Vector2(780, 420)}  # 8 - G

	],
	2:[
		{"position": Vector2(50, 100)},  # 0 - S
		{"position": Vector2(240, 180)}, # 1
		{"position": Vector2(240, 380)}, # 2
		{"position": Vector2(420, 160)}, # 3
		{"position": Vector2(420, 420)}, # 4
		{"position": Vector2(600, 280)}, # 5
		{"position": Vector2(740, 280)}, # 6
		{"position": Vector2(420, 500)}, # 7
		{"position": Vector2(600, 280)}, # 8
		{"position": Vector2(740, 280)}  # 9 - G
	]
}

var presetEdges= {
	0:{
		0:  {"start": 0, "end": 1},
		1:  {"start": 0, "end": 2},
		2:  {"start": 1, "end": 2},
		3:  {"start": 1, "end": 3},
		4:  {"start": 2, "end": 4},
		5:  {"start": 1, "end": 4},
		6:  {"start": 2, "end": 3},
		7:  {"start": 3, "end": 4},
		8:  {"start": 3, "end": 5},
		9:  {"start": 4, "end": 5},
		10: {"start": 3, "end": 6},
		11: {"start": 4, "end": 6},
		12: {"start": 5, "end": 6}
	},
	1:{
		0: {"start": 0, "end": 1},
		1: {"start": 1, "end": 2},
		2: {"start": 2, "end": 3},
		3: {"start": 3, "end": 0},
		4: {"start": 0, "end": 2},
		5: {"start": 3, "end": 4},
		6: {"start": 4, "end": 5},
		7: {"start": 5, "end": 6},
		8: {"start": 6, "end": 4},
		9: {"start": 6, "end": 7},
		10: {"start": 5, "end": 8},
		11: {"start": 8, "end": 7}
	}
}

var points = presetPoints[0].duplicate(true)
var edges = presetEdges[0].duplicate(true)

var start_node: int = 0
var end_node: int = points.size() -1

var short_edges = {}
var winner_label:String = ""

# Custom graph
var use_custom_graph: bool = false
var custom_points: Array = []
var custom_edges: Dictionary = {}
var initial_board: Dictionary = {}
var last_move_count: int = 0

# Keep a pristine board so replay preserves random layouts and custom terminals.
func remember_board() -> void:
	initial_board = {
		"points": points.duplicate(true),
		"edges": edges.duplicate(true),
		"start": start_node,
		"end": end_node,
	}

func restore_board() -> void:
	if initial_board.is_empty():
		reset()
		return
	points = initial_board["points"].duplicate(true)
	edges = initial_board["edges"].duplicate(true)
	start_node = initial_board["start"]
	end_node = initial_board["end"]
	short_edges = {}
	winner_label = ""

func setup_dynamic_graph(node_count: int, edge_count: int) -> void:
	var generator = DynamicGraph.new()
	var graph = generator.generate(node_count, edge_count)
	generator.free()

	points = graph["points"]
	edges = graph["edges"]
	start_node = graph["start"]
	end_node = graph["end"]

	dynamic_node_count = node_count
	dynamic_edge_count = edge_count

	short_edges = {}
	use_dynamic_graph = true

func reset():
	short_edges = {}
	winner_label = ""

	if use_custom_graph and custom_points.size() > 0:
		points = custom_points.duplicate(true)
		edges = custom_edges.duplicate(true)
		start_node = 0
		end_node = points.size() - 1
	elif use_dynamic_graph:
		setup_dynamic_graph(dynamic_node_count, dynamic_edge_count)
	else:
		points = presetPoints[0].duplicate(true)
		edges = presetEdges[0].duplicate(true)
		start_node = 0
		end_node = points.size() - 1
