extends Control

@onready var winnerLabel = $Label
@onready var restartButton = $Button
@onready var victory_sound_effect = preload("res://audio/victory_sound_effect.mp3")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioPlayer.play_sound_effect(victory_sound_effect)
	winnerLabel.text = GlobalVariables.winner_label
	restartButton.pressed.connect(return_to_main_menu)

func return_to_main_menu():
	GlobalVariables.reset()
	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
