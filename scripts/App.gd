extends Node

enum GameType { SHANNON, GALE }
var game_type: GameType = GameType.SHANNON

func start_game(type: GameType):
	game_type = type
	get_tree().change_scene_to_file("res://scenes/Board.tscn")
