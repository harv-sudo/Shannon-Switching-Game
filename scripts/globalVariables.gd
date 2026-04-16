extends Node2D

# This script contains global variables that are loaded by the auto loader when the game runs.
# This allows us to access the variables declared within in other script files, allowing for 
# seperation of concerns.

# This makes it easier to keep track of what data structures we are using for testing purposes
# We need to implement this dynamically programatically creating different types of graphs


const AIControllerScript = preload("res://scripts/AIController.gd")

var ai_controller = AIControllerScript.new()

enum Player { P1 = 0, P2 = 1 }
var _currentPlayer: int = Player.P1

var currentPlayer: int:
	get:
		return _currentPlayer
	set(value):
		_currentPlayer = value
		if ai_controller.ai_enabled and _currentPlayer == ai_controller.ai_player:
			call_deferred("_run_ai_turn")


var points = [
	{"position": Vector2(120, 280)}, # 0 - S
	{"position": Vector2(240, 180)}, # 1
	{"position": Vector2(240, 380)}, # 2
	{"position": Vector2(420, 160)}, # 3
	{"position": Vector2(420, 420)}, # 4
	{"position": Vector2(600, 280)}, # 5
	{"position": Vector2(740, 280)}  # 6 - G
]

var edges = {
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
}

var start_node: int = 0
var end_node: int = 6

var short_edges = {}

var winner_label:String = ""

func _run_ai_turn() -> void:
	var board_root: Node = get_tree().current_scene
	if board_root == null:
		return
	ai_controller.ai_take_turn(board_root, self)

func ai_take_turn(board_root: Node) -> void:
	ai_controller.ai_take_turn(board_root, self)
