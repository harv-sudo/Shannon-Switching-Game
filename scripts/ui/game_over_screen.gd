extends Control

@onready var winnerLabel = $Label
@onready var restartButton = $Button



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	winnerLabel.text = GlobalVariables.winner_label
	restartButton.pressed.connect(return_to_main_menu)

func return_to_main_menu():
	GlobalVariables.reset()	# Harsh: Reset global variables here
	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
