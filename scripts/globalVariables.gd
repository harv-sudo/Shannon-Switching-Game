extends Node2D

enum Player { P1 = 0, P2 = 1 }
var currentPlayer = Player.P1

var points = [
	{"position": Vector2(200, 200)},
	{"position": Vector2(450, 150)},
	{"position": Vector2(650, 250)},
	{"position": Vector2(350, 450)},
]

var edges = {
	0: {"start": 0, "end": 1},
	1: {"start": 0, "end": 2},
	2: {"start": 0, "end": 3},
	3: {"start": 1, "end":  2}
}
