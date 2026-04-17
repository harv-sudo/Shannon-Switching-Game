extends Control

@onready var pvp_button: Button = $CenterContainer/VBoxContainer/VBoxContainer/PVPButton
@onready var pvai_button: Button = $CenterContainer/VBoxContainer/VBoxContainer/PVAIButton
@onready var back_button: Button = $CenterContainer/VBoxContainer/VBoxContainer/BackButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	pvp_button.pressed.connect(_on_pvp_button_pressed)
	pvai_button.pressed.connect(_on_pvai_button_pressed)



func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")


func _on_pvp_button_pressed() -> void:
	GlobalVariables.selected_game_mode = GlobalVariables.GameMode.PVP
	print("Selected mode: ", GlobalVariables.selected_game_mode)
	get_tree().change_scene_to_file("res://scenes/gameSetup.tscn")

func _on_pvai_button_pressed() -> void:
	GlobalVariables.selected_game_mode = GlobalVariables.GameMode.PVAI
	print("Selected mode: ", GlobalVariables.selected_game_mode)
	get_tree().change_scene_to_file("res://scenes/gameSetup.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
