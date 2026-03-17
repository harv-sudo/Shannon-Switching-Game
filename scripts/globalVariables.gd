extends Node2D

enum Player { P1 = 0, P2 = 1 }
var currentPlayer = Player.P1

var points = [
	{"position": Vector2(200, 200), },
	{"position": Vector2(450, 150), "edges": [0, 2, 3]},
	{"position": Vector2(650, 250), "edges": [1]},
	{"position": Vector2(350, 450), "edges": [0, 1, 2]},
]

var edges = {
	0: {"start": 0, "end": 1},
	1: {"start": 0, "end": 2},
	2: {"start": 0, "end": 3},
	3: {"start": 1, "end":  2}
}
