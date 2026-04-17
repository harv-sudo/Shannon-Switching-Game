extends Node2D

class_name GameManager

enum Player { P1 , P2 }
var currentPlayer = Player.P1

func _ready() -> void:
	var gameLogic: Node
	
	
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

# Used to transition the game to the gameOverScreen scene
func gameOver() -> void:
	get_tree().change_scene_to_file("res://gameOverScreen.tscn")
	GlobalVariables.reset()
