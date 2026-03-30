extends Node2D

const AIControllerScript = preload("res://scripts//AIController.gd")

var ai_controller: AIController = AIControllerScript.new()

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

func _run_ai_turn() -> void:
	var board_root := get_tree().current_scene
	if board_root == null:
		return
	ai_controller.ai_take_turn(self, board_root)


func ai_take_turn(board_root: Node) -> void:
	ai_controller.ai_take_turn(self, board_root)
