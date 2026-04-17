extends Control

@onready var back_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/BackButton
@onready var start_game_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/StartGameButton
@onready var short_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/AISettings/RoleRow/RoleButtons/ShortButton
@onready var cut_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/AISettings/RoleRow/RoleButtons/CutButton
@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var ai_settings: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/AISettings
@onready var preset_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/GraphMode/ButtonContainer/PresetButton
@onready var dynamic_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/GraphMode/ButtonContainer/DynamicButton
@onready var custom_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/GraphMode/ButtonContainer/CustomButton
@onready var easy_ai_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/AISettings/DifficultyRow/RoleButtons/EasyAIButton
@onready var medium_ai_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/AISettings/DifficultyRow/RoleButtons/MediumAIButton
@onready var hard_ai_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/AISettings/DifficultyRow/RoleButtons/HardAIButton


func _ready() -> void:
	setup_screen_for_mode()
	
	preset_button.toggled.connect(_on_preset_button_toggled)
	dynamic_button.toggled.connect(_on_dynamic_button_toggled)
	custom_button.toggled.connect(_on_custom_button_toggled)

	back_button.pressed.connect(_on_back_pressed)
	start_game_button.pressed.connect(_on_start_game_pressed)

func setup_screen_for_mode() -> void:
	if GlobalVariables.selected_game_mode == GlobalVariables.GameMode.PVP:
		title_label.text = "Player vs Player Setup"
		ai_settings.visible = false
	else:
		title_label.text = "Player vs AI Setup"
		ai_settings.visible = true
		
		easy_ai_button.toggled.connect(_on_easy_ai_button_toggled)
		medium_ai_button.toggled.connect(_on_medium_ai_button_toggled)
		hard_ai_button.toggled.connect(_on_hard_ai_button_toggled)
		short_button.toggled.connect(_on_short_toggled)
		cut_button.toggled.connect(_on_cut_toggled)


func _on_easy_ai_button_toggled(pressed: bool) -> void:
	if pressed:
		medium_ai_button.button_pressed = false
		hard_ai_button.button_pressed = false
		
func _on_medium_ai_button_toggled(pressed: bool) -> void:
	if pressed:
		easy_ai_button.button_pressed = false
		hard_ai_button.button_pressed = false
		
func _on_hard_ai_button_toggled(pressed: bool) -> void:
	if pressed:
		medium_ai_button.button_pressed = false
		easy_ai_button.button_pressed = false

func _on_short_toggled(pressed: bool) -> void:
	if pressed:
		cut_button.button_pressed = false

func _on_cut_toggled(pressed: bool) -> void:
	if pressed:
		short_button.button_pressed = false

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
	get_tree().change_scene_to_file("res://scenes/Board.tscn")
	App.start_game(App.GameType.GALE)
	
