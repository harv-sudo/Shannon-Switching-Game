extends Control

@onready var difficulty_option_button: OptionButton = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/DifficultyRow/DifficultyOptionButton
@onready var back_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/BackButton
@onready var start_game_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/StartGameButton

func _ready() -> void:
	difficulty_option_button.add_item("Easy")
	difficulty_option_button.add_item("Medium")
	difficulty_option_button.add_item("Hard")

	back_button.pressed.connect(_on_back_pressed)
	start_game_button.pressed.connect(_on_start_game_pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gameMode.tscn")

func _on_start_game_pressed() -> void:
	GlobalVariables.ai_controller.ai_player = GlobalVariables.Player.P1
	GlobalVariables.currentPlayer = GlobalVariables.Player.P2
	GlobalVariables.game_mode = GlobalVariables.Mode.AI
	GlobalVariables.update_ai_mode()
	get_tree().change_scene_to_file("res://shannonBoard.tscn")
