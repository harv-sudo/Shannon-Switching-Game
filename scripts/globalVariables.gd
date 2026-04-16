extends Node2D

# This script contains global variables that are loaded by the auto loader when the game runs.
# This allows us to access the variables declared within in other script files, allowing for 
# seperation of concerns.

# This makes it easier to keep track of what data structures we are using for testing purposes
# We need to implement this dynamically programatically creating different types of graphs
enum Player { P1 = 0, P2 = 1 }
enum Mode { PVP = 0, AI = 1}
enum GameType { SHANNON = 0, GALE = 1}
var currentPlayer = Player.P2
var currentGameMode = GameType.GALE

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
		{"position": Vector2(420, 420)}, # 7
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

func reset():
	points = presetPoints[0].duplicate(true)
	edges = presetEdges[0].duplicate(true)
	start_node = 0
	currentPlayer = 0
	end_node = points.size() -1
	short_edges = {}
