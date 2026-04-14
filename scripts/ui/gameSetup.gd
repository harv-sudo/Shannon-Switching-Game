extends Control

@onready var mode_option_button: OptionButton = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ModeRow/ModeOptionButton
@onready var back_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/BackButton
@onready var start_game_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/StartGameButton

func _ready() -> void:
	mode_option_button.add_item("Player vs Player")
	mode_option_button.add_item("Player vs AI")

	back_button.pressed.connect(_on_back_pressed)
	start_game_button.pressed.connect(_on_start_game_pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://testingScene.tscn")
