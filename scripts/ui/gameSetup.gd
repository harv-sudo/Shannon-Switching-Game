extends Control

@onready var back_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/BackButton
@onready var start_game_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/StartGameButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	start_game_button.pressed.connect(_on_start_game_pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gameMode.tscn")

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://shannonBoard.tscn")
