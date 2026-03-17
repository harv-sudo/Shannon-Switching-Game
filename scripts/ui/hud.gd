extends Control

@onready var turn_label = $TurnLabel
@onready var status_label = $StatusLabel
@onready var restart_button = $RestartButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	restart_button.pressed.connect(_on_restart_button_pressed)
	update_turn_label()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_turn_label()

func update_turn_label():
	if TurnManager.currentPlayer == TurnManager.Player.P1:
		turn_label.text = "Current Turn: Player 1"
	else:
		turn_label.text = "Current Turn: Player 2"

func _on_restart_button_pressed():
	# reset player turns
	TurnManager.currentPlayer = TurnManager.Player.P1
	get_tree().reload_current_scene()
