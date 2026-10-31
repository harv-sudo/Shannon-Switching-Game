extends Control

var manager: GameManager
var turn_label: Label
var turn_hint: Label
var stats: Label
var confirmation: ConfirmationDialog
var pending_action: Callable

func _ready() -> void:
	theme = GameStyle.make_theme()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	size = get_viewport_rect().size
	get_viewport().size_changed.connect(func(): size = get_viewport_rect().size)
	manager = get_parent() as GameManager
	var header = PanelContainer.new()
	add_child(header)
	header.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	header.offset_left = 28
	header.offset_top = 20
	header.offset_right = -28
	header.offset_bottom = 90
	var row = HBoxContainer.new()
	header.add_child(row)
	var title = GameStyle.label("Gale’s Game" if App.game_type == App.GameType.GALE else "Shannon Switching", 25)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)
	row.add_child(GameStyle.label("THE CONNECTION COLLECTION", 13, GameStyle.MUTED))
	var panel = PanelContainer.new()
	add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	panel.offset_left = -310
	panel.offset_right = -28
	panel.offset_top = 112
	panel.offset_bottom = -28
	var column = VBoxContainer.new()
	panel.add_child(column)
	column.add_child(GameStyle.label("ON THE BOARD", 13, GameStyle.MUTED))
	turn_label = GameStyle.label("", 30, GameStyle.TEAL)
	column.add_child(turn_label)
	turn_hint = GameStyle.paragraph("")
	column.add_child(turn_hint)
	column.add_child(HSeparator.new())
	stats = GameStyle.paragraph("", 16)
	column.add_child(stats)
	column.add_child(GameStyle.paragraph(
		"Blue: top to bottom.\nRed: left to right."
		if App.game_type == App.GameType.GALE else "S  Start    G  Goal\nHighlighted links belong to Short.", 15))
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)
	column.add_child(GameStyle.button("How to play", _show_rules))
	column.add_child(GameStyle.sound_button())
	column.add_child(GameStyle.button("Restart board", _request_restart))
	column.add_child(GameStyle.button("Main menu", _request_menu))
	column.add_child(GameStyle.label("R Restart · M Sound · Esc Menu", 12, GameStyle.MUTED))
	confirmation = ConfirmationDialog.new()
	confirmation.title = "Leave this position?"
	add_child(confirmation)
	confirmation.confirmed.connect(_resume_game)
	confirmation.confirmed.connect(func(): pending_action.call())
	confirmation.canceled.connect(_resume_game)
	confirmation.process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_refresh")

func _process(_delta: float) -> void:
	_refresh()

func _refresh() -> void:
	if not is_instance_valid(manager.gameLogic):
		return
	var first = manager.currentPlayer == GameManager.Player.P1
	var gale = App.game_type == App.GameType.GALE
	var ai_turn = not gale and manager.gameLogic._is_ai_turn()
	var finished = not gale and manager.gameLogic.game_over
	turn_label.text = ("Blue" if first else "Red") if gale else ("Short" if first else "Cut")
	turn_label.add_theme_color_override("font_color", (GameStyle.BLUE if first else GameStyle.CORAL) if gale else (GameStyle.TEAL if first else GameStyle.CORAL))
	if finished:
		turn_hint.text = GlobalVariables.winner_label
	elif ai_turn:
		turn_hint.text = "AI is thinking…"
	else:
		turn_hint.text = "Choose a link to connect your sides." if gale else ("Claim a link to build your route." if first else "Remove an unclaimed link.")
	if gale:
		stats.text = "Move %d\n%d links available" % [manager.move_count + 1, manager.gameLogic.player_one_edges.size()]
	else:
		stats.text = "Move %d\n%d links available · %d claimed" % [manager.move_count + 1, GlobalVariables.edges.size() - GlobalVariables.short_edges.size(), GlobalVariables.short_edges.size()]

func _confirm(message: String, action: Callable) -> void:
	if confirmation.visible:
		return
	pending_action = action
	confirmation.dialog_text = message
	get_tree().paused = true
	confirmation.popup_centered(Vector2i(440, 180))

func _resume_game() -> void:
	get_tree().paused = false

func _show_rules() -> void:
	GameStyle.show_rules(self, App.game_type == App.GameType.GALE)

func _request_restart() -> void:
	_confirm("Restart this board? Your current moves will be cleared.", func():
		get_tree().paused = false
		GlobalVariables.restore_board()
		get_tree().reload_current_scene()
	)

func _request_menu() -> void:
	_confirm("Return to the menu? Your current game will end.", func():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
	)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			_request_restart()
		elif event.keycode == KEY_ESCAPE:
			_request_menu()
