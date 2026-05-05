extends Control

@onready var turn_label = $HBoxContainer/TurnLabel
@onready var restart_button = $RestartButton
@onready var menu_button = $MenuButton
@onready var gameManager: GameManager

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_button_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)
	gameManager = get_node("/root/Board")

func _process(_delta: float) -> void:
	update_turn_label()

func update_turn_label():
	if gameManager.gameLogic.name == "ShannonGame" and gameManager.currentPlayer == 0:
		turn_label.text = "Short"
	elif gameManager.gameLogic.name == "ShannonGame" and gameManager.currentPlayer == 1:
		turn_label.text = "Cut"
		
	elif gameManager.gameLogic.name == "GaleGame" and gameManager.currentPlayer == 0:
		turn_label.text = "Blue"
	elif gameManager.gameLogic.name == "GaleGame" and gameManager.currentPlayer == 1:
		turn_label.text = "Red"
		
func _on_restart_button_pressed():
	if GlobalVariables.use_custom_graph:
		GlobalVariables.points = GlobalVariables.custom_points.duplicate(true)
		GlobalVariables.edges = GlobalVariables.custom_edges.duplicate(true)
		GlobalVariables.short_edges = {}
		GlobalVariables.start_node = -1
		GlobalVariables.end_node = -1
		GlobalVariables.winner_label = ""

		get_tree().change_scene_to_file("res://scenes/customGraphSetup.tscn")
	else:
		GlobalVariables.reset()
		get_tree().reload_current_scene()


func _on_menu_button_pressed():
	GlobalVariables.reset()
	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
