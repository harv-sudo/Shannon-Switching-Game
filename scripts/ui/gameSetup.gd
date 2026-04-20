extends Control

@onready var back_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/BackButton
@onready var start_game_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/StartGameButton
@onready var short_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/RoleRow/RoleButtons/ShortButton
@onready var cut_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/RoleRow/RoleButtons/CutButton

@onready var preset_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/GraphMode/ButtonContainer/PresetButton
@onready var dynamic_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/GraphMode/ButtonContainer/DynamicButton
@onready var custom_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/GraphMode/ButtonContainer/CustomButton

@onready var pvp_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/GameModeRow/GameModeButtons/PVPButton
@onready var pvai_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/GameModeRow/GameModeButtons/PVAIButton
@onready var aivai_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/GameModeRow/GameModeButtons/AIVAIButton

@onready var role_row: HBoxContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/RoleRow


func _ready() -> void:
	role_row.visible = false
	short_button.button_pressed = true
	cut_button.button_pressed = false
	GlobalVariables.selected_role = "short"
	
	preset_button.toggled.connect(_on_preset_button_toggled)
	dynamic_button.toggled.connect(_on_dynamic_button_toggled)
	custom_button.toggled.connect(_on_custom_button_toggled)

	pvp_button.toggled.connect(_on_pvp_button_toggled)
	pvai_button.toggled.connect(_on_pvai_button_toggled)
	aivai_button.toggled.connect(_on_aivai_button_toggled)

	short_button.toggled.connect(_on_short_toggled)
	cut_button.toggled.connect(_on_cut_toggled)
	
	back_button.pressed.connect(_on_back_pressed)
	start_game_button.pressed.connect(_on_start_game_pressed)


func _on_pvp_button_toggled(pressed: bool) -> void:
	if pressed:
		pvai_button.button_pressed = false
		aivai_button.button_pressed = false
		role_row.visible = false
		GlobalVariables.game_mode = GlobalVariables.Mode.AI
		
func _on_pvai_button_toggled(pressed: bool) -> void:
	if pressed:
		pvp_button.button_pressed = false
		aivai_button.button_pressed = false
		role_row.visible = true
		GlobalVariables.game_mode = GlobalVariables.Mode.AI
		
func _on_aivai_button_toggled(pressed: bool) -> void:
	if pressed:
		pvp_button.button_pressed = false
		pvai_button.button_pressed = false
		role_row.visible = false
		GlobalVariables.game_mode = GlobalVariables.Mode.AIVSAI
		
		

func _on_short_toggled(pressed: bool) -> void:
	if pressed:
		cut_button.button_pressed = false
		GlobalVariables.selected_role = "Short"

func _on_cut_toggled(pressed: bool) -> void:
	if pressed:
		short_button.button_pressed = false
		GlobalVariables.selected_role = "Cut"
func _on_preset_button_toggled(pressed: bool) -> void:
	if pressed:
		dynamic_button.button_pressed = false
		custom_button.button_pressed = false

func _on_dynamic_button_toggled(pressed: bool) -> void:
	if pressed:
		preset_button.button_pressed = false
		custom_button.button_pressed = false

func _on_custom_button_toggled(pressed: bool) -> void:
	if pressed:
		preset_button.button_pressed = false
		dynamic_button.button_pressed = false

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")

func _on_start_game_pressed() -> void:
	if short_button.button_pressed:
		GlobalVariables.selected_role = "Short"
	elif cut_button.button_pressed:
		GlobalVariables.selected_role = "Cut"
	get_tree().change_scene_to_file("res://scenes/Board.tscn")
	
