extends Node

enum GameType { SHANNON, GALE }
var game_type: GameType

func start_game(type: GameType) -> void:
	game_type = type
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/GameManager.tscn")

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_M:
		AudioPlayer.toggle_mute()
		get_viewport().set_input_as_handled()
