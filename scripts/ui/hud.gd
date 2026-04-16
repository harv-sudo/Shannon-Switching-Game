extends Control

@onready var turn_label = $TurnLabel
@onready var status_label = $StatusLabel
@onready var restart_button = $RestartButton

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_button_pressed)
	update_turn_label()

func _process(_delta: float) -> void:
	update_turn_label()

func update_turn_label():
	if GlobalVariables.currentPlayer == GlobalVariables.Player.P1:
		turn_label.text = "Current Turn: Player 1"
	else:
		turn_label.text = "Current Turn: Player 2"

func _on_restart_button_pressed():
	GlobalVariables.currentPlayer = GlobalVariables.Player.P1
	get_tree().reload_current_scene()
