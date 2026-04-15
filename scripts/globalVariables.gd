extends Node2D

const AIControllerScript = preload("res://scripts/AIController.gd")

var ai_controller: AIController = AIControllerScript.new()

enum Player { P1 = 0, P2 = 1 }
enum GameState { PLAYING, GAME_OVER }

var _currentPlayer: int = Player.P1
var currentPlayer: int:
	get:
		return _currentPlayer
	set(value):
		_currentPlayer = value
		if turn_label != null:
			update_turn_label()
		if ai_controller.ai_enabled and _currentPlayer == ai_controller.ai_player and game_state == GameState.PLAYING:
			call_deferred("_run_ai_turn")

var game_state: int = GameState.PLAYING

# 0 = Start terminal
# 6 = Goal terminal
var points: Array = [
	{"position": Vector2(120, 280)},
	{"position": Vector2(240, 180)},
	{"position": Vector2(240, 380)},
	{"position": Vector2(420, 160)},
	{"position": Vector2(420, 420)},
	{"position": Vector2(600, 280)},
	{"position": Vector2(740, 280)}
]

var edges: Dictionary = {
	0:  {"start": 0, "end": 1},
	1:  {"start": 0, "end": 2},
	2:  {"start": 1, "end": 2},
	3:  {"start": 1, "end": 3},
	4:  {"start": 2, "end": 4},
	5:  {"start": 1, "end": 4},
	6:  {"start": 2, "end": 3},
	7:  {"start": 3, "end": 4},
	8:  {"start": 3, "end": 5},
	9:  {"start": 4, "end": 5},
	10: {"start": 3, "end": 6},
	11: {"start": 4, "end": 6},
	12: {"start": 5, "end": 6}
}

var terminal_a: int = 0
var terminal_b: int = 6

# free  = untouched
# short = claimed by Player 1
# cut   = removed by Player 2
var edge_states: Dictionary = {}

# UI references
var winner_label: Label = null
var turn_label: Label = null
var game_over_panel: Control = null
var game_over_winner_label: Label = null

var edgesRemaining: int = 0

func _ready() -> void:
	reset_game()

func _run_ai_turn() -> void:
	var board_root: Node = get_tree().current_scene
	if board_root == null:
		return
	ai_controller.ai_take_turn(board_root, self)

func ai_take_turn(board_root: Node) -> void:
	ai_controller.ai_take_turn(board_root, self)

func reset_edge_states() -> void:
	edge_states.clear()
	for edge_id in edges.keys():
		edge_states[edge_id] = "free"

func reset_game() -> void:
	currentPlayer = Player.P1
	game_state = GameState.PLAYING
	reset_edge_states()
	edgesRemaining = edges.size()

	if winner_label != null:
		winner_label.text = ""

	if turn_label != null:
		update_turn_label()

	if game_over_panel != null:
		game_over_panel.visible = false

	if game_over_winner_label != null:
		game_over_winner_label.text = ""

func update_turn_label() -> void:
	if turn_label == null:
		return

	if game_state == GameState.GAME_OVER:
		turn_label.text = "Game Over"
		return

	if currentPlayer == Player.P1:
		turn_label.text = "Player 1 (Short) Turn"
	else:
		turn_label.text = "Player 2 (Cut) Turn"

func switch_turn() -> void:
	if currentPlayer == Player.P1:
		currentPlayer = Player.P2
	else:
		currentPlayer = Player.P1

	update_turn_label()

func can_select_edge(edge_id: int) -> bool:
	if game_state == GameState.GAME_OVER:
		return false

	if not edge_states.has(edge_id):
		return false

	return edge_states[edge_id] == "free"

func build_adjacency(mode: String) -> Dictionary:
	var adjacency: Dictionary = {}

	for point_id in range(points.size()):
		adjacency[point_id] = []

	for edge_id in edges.keys():
		var edge: Dictionary = edges[edge_id]
		var start_node: int = edge["start"]
		var end_node: int = edge["end"]
		var state: String = edge_states.get(edge_id, "free")

		if mode == "short_only" and state != "short":
			continue
		if mode == "not_cut" and state == "cut":
			continue

		adjacency[start_node].append(end_node)
		adjacency[end_node].append(start_node)

	return adjacency

func has_path(start_node: int, target_node: int, adjacency: Dictionary) -> bool:
	var visited: Dictionary = {}
	return _dfs(start_node, target_node, adjacency, visited)

func _dfs(current_node: int, target_node: int, adjacency: Dictionary, visited: Dictionary) -> bool:
	if current_node == target_node:
		return true

	visited[current_node] = true

	for neighbour in adjacency.get(current_node, []):
		if not visited.has(neighbour):
			if _dfs(neighbour, target_node, adjacency, visited):
				return true

	return false

func show_game_over(message: String) -> void:
	game_state = GameState.GAME_OVER

	if winner_label != null:
		winner_label.text = message

	if turn_label != null:
		turn_label.text = "Game Over"

	if game_over_panel != null:
		game_over_panel.visible = true

	if game_over_winner_label != null:
		game_over_winner_label.text = message

func check_win_conditions() -> void:
	if game_state == GameState.GAME_OVER:
		return

	var short_graph: Dictionary = build_adjacency("short_only")
	if has_path(terminal_a, terminal_b, short_graph):
		print("PLAYER 1 WINS")
		show_game_over("Player 1 Wins!")
		return

	var possible_graph: Dictionary = build_adjacency("not_cut")
	if not has_path(terminal_a, terminal_b, possible_graph):
		print("PLAYER 2 WINS")
		show_game_over("Player 2 Wins!")
		return

func is_game_over() -> void:
	if edgesRemaining == 0:
		get_tree().change_scene_to_file("res://gameOverScreen.tscn")
