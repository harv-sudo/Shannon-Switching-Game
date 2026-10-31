extends Control

var mode: int = GlobalVariables.Mode.PVP
var graph_mode: int = 0
var role: String = "Short"
var role_row: VBoxContainer
var graph_hint: Label

func _ready() -> void:
	add_child(BoardBackdrop.new())
	mode = GlobalVariables.game_mode
	role = GlobalVariables.selected_role
	var page = GameStyle.page(self, 850)
	page.add_child(GameStyle.label("SHANNON SWITCHING", 15, GameStyle.TEAL))
	page.add_child(GameStyle.label("Make your next move.", 40))
	page.add_child(GameStyle.label("Choose your opponent and your playing field.", 19, GameStyle.MUTED))
	var card = GameStyle.card(page)
	_choices(card, "01  Opponent", ["Two players", "Play the AI", "Watch AI vs AI"], mode,
		func(index): mode = index; role_row.visible = mode == GlobalVariables.Mode.AI)
	role_row = VBoxContainer.new()
	card.add_child(role_row)
	_choices(role_row, "Your role", ["Short · build a route", "Cut · break the route"],
		0 if role == "Short" else 1, func(index): role = "Short" if index == 0 else "Cut")
	role_row.visible = mode == GlobalVariables.Mode.AI
	_choices(card, "02  Playing field", ["Classic", "Random", "Create your own"], 0,
		func(index): graph_mode = index; _update_hint())
	graph_hint = GameStyle.paragraph("")
	card.add_child(graph_hint)
	_update_hint()
	var actions = HBoxContainer.new()
	page.add_child(actions)
	actions.add_child(GameStyle.button("Back", func(): get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")))
	actions.add_child(GameStyle.button("How to play", func(): GameStyle.show_rules(self)))
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(spacer)
	var start = GameStyle.button("Start game", _start_game, true)
	actions.add_child(start)
	start.grab_focus()

func _choices(parent: Node, title: String, values: Array, selected: int, action: Callable) -> void:
	parent.add_child(GameStyle.label(title, 17, GameStyle.MUTED))
	var row = HBoxContainer.new()
	parent.add_child(row)
	var group = ButtonGroup.new()
	for index in range(values.size()):
		var choice = GameStyle.button(values[index], action.bind(index))
		choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		choice.toggle_mode = true
		choice.button_group = group
		choice.set_pressed_no_signal(index == selected)
		row.add_child(choice)

func _update_hint() -> void:
	graph_hint.text = [
		"A balanced starting point: 7 nodes, 13 links. Short always plays first.",
		"A fresh network each game. Replay keeps the same board for another attempt.",
		"Place nodes, draw links, then choose your start and goal."
	][graph_mode]

func _start_game() -> void:
	GlobalVariables.game_mode = mode
	GlobalVariables.selected_role = role
	GlobalVariables.use_custom_graph = graph_mode == 2
	GlobalVariables.use_dynamic_graph = graph_mode == 1
	GlobalVariables.short_edges = {}
	GlobalVariables.winner_label = ""
	if graph_mode == 2:
		GlobalVariables.custom_points = []
		GlobalVariables.custom_edges = {}
		get_tree().change_scene_to_file("res://scenes/customGraphSetup.tscn")
		return
	if graph_mode == 1:
		GlobalVariables.setup_dynamic_graph(GlobalVariables.dynamic_node_count, GlobalVariables.dynamic_edge_count)
	else:
		GlobalVariables.points = GlobalVariables.presetPoints[0].duplicate(true)
		GlobalVariables.edges = GlobalVariables.presetEdges[0].duplicate(true)
		GlobalVariables.start_node = 0
		GlobalVariables.end_node = GlobalVariables.points.size() - 1
	App.start_game(App.GameType.SHANNON)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
