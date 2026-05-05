extends Node2D
class_name GameManager

enum Player { P1 , P2 }
var currentPlayer = Player.P1

var gameLogic: Node

@onready var ai_controller: AIController = AIController.new()
@onready var current_scene = get_tree().current_scene

func _ready() -> void:
	add_child(ai_controller)
	ai_controller.name = "AI"
	
	match App.game_type:
		App.GameType.SHANNON:
			gameLogic = ShannonGame.new()
			gameLogic.name = "ShannonGame"
		
		App.GameType.GALE:
			gameLogic = GaleGame.new()
			gameLogic.name = "GaleGame"
	
	add_child(gameLogic)
	gameLogic.set_game_manager(self)
	
	if App.game_type == App.GameType.SHANNON:
		if GlobalVariables.game_mode == GlobalVariables.Mode.AIVSAI:
			(gameLogic as ShannonGame)._start_first_ai_turn()
		elif GlobalVariables.game_mode == GlobalVariables.Mode.AI and GlobalVariables.selected_role == "Cut":
			currentPlayer = Player.P1
			(gameLogic as ShannonGame)._start_first_ai_turn()

func switchPlayer() -> void:
	currentPlayer = Player.P1 if currentPlayer == Player.P2 else Player.P2

func gameOver():
	get_tree().change_scene_to_file("res://gameOverScreen.tscn")
