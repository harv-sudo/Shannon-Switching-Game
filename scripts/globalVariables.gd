extends Node2D

# This script contains global variables that are loaded by the auto loader when the game runs..
# This allows us to access the variables declared within in other script files, allowing for 
# seperation of concerns.

# This makes it easier to keep track of what data structures we are using for testing purposes
# We need to implement this dynamically programatically creating different types of graphs




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

var edgesRemaining = 0

func is_game_over():
	if edgesRemaining == 0:
		get_tree().change_scene_to_file("res://gameOverScreen.tscn")
	pass
