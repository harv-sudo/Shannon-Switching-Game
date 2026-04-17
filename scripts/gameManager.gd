extends Node2D

class_name GameManager

enum Player { P1 , P2 }
var currentPlayer = Player.P1

var gameLogic: Node

@onready var ai_controller: AIController = AIController.new()
@onready var current_scene = get_tree().current_scene

func _ready() -> void:
	add_child(ai_controller)
	
	match App.game_type:
		App.GameType.SHANNON:
			gameLogic = ShannonGame.new()
		
		App.GameType.GALE:
			gameLogic = GaleGame.new()
	
	add_child(gameLogic)
	gameLogic.set_game_manager(self)

# Function is called in shannonGameLogic.updateEdges()

func switchPlayer() -> void:
	currentPlayer = Player.P1 if currentPlayer == Player.P2 else Player.P2
	
	#Below currently breaks the game when the AI is actively playing
	if currentPlayer == Player.P2:
		var best_edge = ai_controller.ai_take_turn(current_scene, GlobalVariables)
		(gameLogic as ShannonGame).apply_ai_move(best_edge)


# Used to transition the game to the gameOverScreen scene
func gameOver() -> void:
	get_tree().change_scene_to_file("res://scenes/gameOverScreen.tscn")
	GlobalVariables.reset()
