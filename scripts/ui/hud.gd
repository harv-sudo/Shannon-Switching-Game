extends Control

var game_manager: GameManager

@onready var turn_label = $HBoxContainer/TurnLabel
@onready var restart_button = $RestartButton
@onready var menu_button = $MenuButton


func _ready() -> void:
	restart_button.pressed.connect(_on_restart_button_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)

func set_game_manager(gm: GameManager) -> void:
	game_manager = gm

func _process(_delta: float) -> void:
	update_turn_label()

func update_turn_label():
	if game_manager.currentPlayer == game_manager.Player.P1:
		turn_label.text = "Player 1"
	else:
		turn_label.text = "Player 2"

func _on_restart_button_pressed():
	GlobalVariables.reset()
	get_tree().reload_current_scene()

func _on_menu_button_pressed():
	GlobalVariables.reset()
	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
	
