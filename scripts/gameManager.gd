extends Node2D
class_name GameManager

enum Player { P1 , P2 }
var currentPlayer = Player.P1

var gameLogic: Node

@onready var ai_controller: AIController = AIController.new()
@onready var current_scene = get_tree().current_scene
@onready var victory_sound_effect = preload("res://audio/victory_sound_effect.mp3")


func _ready() -> void:
	add_child(ai_controller)
	ai_controller.ai_enabled = (
	GlobalVariables.game_mode == GlobalVariables.Mode.AI
	or GlobalVariables.game_mode == GlobalVariables.Mode.AIVSAI)
	
	
	if GlobalVariables.selected_role == "Cut":

		set_cut_roles()
	else:
		set_short_roles()
	
	match App.game_type:
		App.GameType.SHANNON:
			gameLogic = ShannonGame.new()
			gameLogic.name = "ShannonGame"
		
		App.GameType.GALE:
			gameLogic = GaleGame.new()
			gameLogic.name = "GaleGame"
	
	gameLogic.set_game_manager(self)
	add_child(gameLogic)
	ai_controller.name = "AI"
	

# Function is called in shannonGameLogic.updateEdges()
func switchPlayer() -> void:
	currentPlayer = Player.P1 if currentPlayer == Player.P2 else Player.P2
	
	#if its ai vs ai mode: swaps the players but also has a time delay of 1 seconds
	if App.game_type != App.GameType.SHANNON:
		return
	
	if ai_controller.ai_enabled:
		if GlobalVariables.game_mode == GlobalVariables.Mode.AIVSAI:
			ai_controller.ai_player = currentPlayer
			await get_tree().create_timer(1).timeout
			var best_edge: int = ai_controller.ai_take_turn(GlobalVariables)
			if best_edge != -1:
				(gameLogic as ShannonGame).apply_ai_move(best_edge, currentPlayer)
		#PvAI swaps normally between players
		elif currentPlayer == ai_controller.ai_player:
			var best_edge: int = ai_controller.ai_take_turn(GlobalVariables)
			if best_edge != -1:
				(gameLogic as ShannonGame).apply_ai_move(best_edge, currentPlayer)
				

func set_short_roles() -> void:
	ai_controller.ai_player = GlobalVariables.Player.P2
	currentPlayer = Player.P1

func set_cut_roles() -> void:
	ai_controller.ai_player = GlobalVariables.Player.P1
	currentPlayer = Player.P1


# Used to transition the game to the gameOverScreen scene
func gameOver() -> void:
	get_tree().change_scene_to_file("res://scenes/gameOverScreen.tscn")
	AudioPlayer.play_sound_effect(victory_sound_effect)
	GlobalVariables.reset()
