extends Control

@onready var quit_button: Button = $CenterContainer/VBoxContainer/VBoxButtonContainer/QuitButton
@onready var shannon_panel_container: PanelContainer = $CenterContainer/VBoxContainer/VBoxLabelContainer/GamesRow/ShannonPanelContainer
@onready var gale_panel_container: PanelContainer = $CenterContainer/VBoxContainer/VBoxLabelContainer/GamesRow/GalePanelContainer
@onready var shannon_button: TextureButton = $CenterContainer/VBoxContainer/VBoxLabelContainer/GamesRow/ShannonPanelContainer/ShannonMarginContainer/ShannonCard/ShannonButton
@onready var gale_button: TextureButton = $CenterContainer/VBoxContainer/VBoxLabelContainer/GamesRow/GalePanelContainer/GaleMarginContainer/GaleCard/GaleButton

var normal_style: StyleBoxFlat
var hover_style: StyleBoxFlat

func _ready() -> void:
	# AudioPlayer.play_music_level()
	quit_button.pressed.connect(_on_quit_pressed)
	shannon_button.pressed.connect(_on_shannon_pressed)
	gale_button.pressed.connect(_on_gale_pressed)

	shannon_button.mouse_entered.connect(func(): _set_card_hover(shannon_panel_container, true))
	shannon_button.mouse_exited.connect(func(): _set_card_hover(shannon_panel_container, false))
	gale_button.mouse_entered.connect(func(): _set_card_hover(gale_panel_container, true))
	gale_button.mouse_exited.connect(func(): _set_card_hover(gale_panel_container, false))

	_setup_styles()

func _setup_styles() -> void:
	normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color("6f7d3d")
	normal_style.border_color = Color("4d5630")
	normal_style.set_border_width_all(2)
	normal_style.corner_radius_top_left = 16
	normal_style.corner_radius_top_right = 16
	normal_style.corner_radius_bottom_left = 16
	normal_style.corner_radius_bottom_right = 16

	hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color("7c8c47")
	hover_style.border_color = Color("ffffff")
	hover_style.set_border_width_all(3)
	hover_style.corner_radius_top_left = 16
	hover_style.corner_radius_top_right = 16
	hover_style.corner_radius_bottom_left = 16
	hover_style.corner_radius_bottom_right = 16

	shannon_panel_container.add_theme_stylebox_override("panel", normal_style)
	gale_panel_container.add_theme_stylebox_override("panel", normal_style)

func _set_card_hover(panel: PanelContainer, hovered: bool) -> void:
	if hovered:
		panel.add_theme_stylebox_override("panel", hover_style)
		panel.scale = Vector2(1.03, 1.03)
	else:
		panel.add_theme_stylebox_override("panel", normal_style)
		panel.scale = Vector2(1, 1)

func _set_button_hover(button: TextureButton, hovered: bool) -> void:
	if hovered:
		# slightly darken
		button.modulate = Color(0.85, 0.85, 0.85, 1.0) 
		button.scale = Vector2(1.05, 1.05)
	else:
		button.modulate = Color(1, 1, 1, 1)
		button.scale = Vector2(1, 1)

#TODO: Wire up properly
func _on_shannon_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gameSetup.tscn")
	App.game_type = App.GameType.SHANNON
	
#TODO: Wire up properly
func _on_gale_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/GameManager.tscn")
	App.game_type = App.GameType.GALE
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()
