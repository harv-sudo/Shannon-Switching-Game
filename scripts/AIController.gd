extends Node
class_name AIController

var ai_enabled: bool = true
var ai_player: int = GlobalVariables.Player.P2

var terminal_start: int = 0
var terminal_end: int = 6


func ai_take_turn(board_root: Node, globals) -> void:
	if not ai_enabled:
		return
	if globals.currentPlayer != ai_player:
		return
	if globals.game_state == globals.GameState.GAME_OVER:
		return

	var best_edge: int = choose_ai_edge(globals.edges, globals.edge_states, globals.points)
	if best_edge == -1:
		return

	# Mark the chosen edge as cut
	globals.edge_states[best_edge] = "cut"

	# Update the matching edge node visually
	for child in board_root.get_children():
		if child is Edge and child.edgeReference == best_edge:
			if child.has_method("queue_redraw"):
				child.queue_redraw()
			break

	globals.check_win_conditions()

	if globals.game_state != globals.GameState.GAME_OVER:
		globals.currentPlayer = GlobalVariables.Player.P1


func choose_ai_edge(edges: Dictionary, edge_states: Dictionary, points: Array) -> int:
	var best_move: int = -1
	var best_score: int = -9999

	# Try every free edge the AI could cut
	for ai_edge in edges.keys():
		if edge_states.get(ai_edge, "free") != "free":
			continue

		var simulated_states: Dictionary = edge_states.duplicate(true)
		simulated_states[ai_edge] = "cut"

		# Assume the player makes the best reply
		var worst_player_move: int = 9999

		var has_free_reply: bool = false

		for player_edge in edges.keys():
			if simulated_states.get(player_edge, "free") != "free":
				continue

			has_free_reply = true

			var player_move_states: Dictionary = simulated_states.duplicate(true)
			player_move_states[player_edge] = "short"

			var score: int = evaluate_board(edges, player_move_states, points)

			if score < worst_player_move:
				worst_player_move = score

		if not has_free_reply:
			worst_player_move = evaluate_board(edges, simulated_states, points)

		if worst_player_move > best_score:
			best_score = worst_player_move
			best_move = ai_edge

	return best_move


func evaluate_board(edges: Dictionary, edge_states: Dictionary, points: Array) -> int:
	var path_length: int = shortest_path_length(edges, edge_states, points, terminal_start, terminal_end)

	# No connection left between the two winning points
	if path_length == -1:
		return 10000

	# Longer path between the winning points = better for AI
	return path_length


func shortest_path_length(
	edges: Dictionary,
	edge_states: Dictionary,
	points: Array,
	start_node: int,
	end_node: int
) -> int:
	if start_node == end_node:
		return 0

	var adjacency: Dictionary = {}
	for i in range(points.size()):
		adjacency[i] = []

	# Use every edge that is not cut
	for edge_id in edges.keys():
		var state: String = edge_states.get(edge_id, "free")
		if state == "cut":
			continue

		var edge: Dictionary = edges[edge_id]
		var a: int = edge["start"]
		var b: int = edge["end"]
		adjacency[a].append(b)
		adjacency[b].append(a)

	var visited: Dictionary = {}
	var queue: Array = [[start_node, 0]]
	visited[start_node] = true

	while not queue.is_empty():
		var current: Array = queue.pop_front()
		var node: int = current[0]
		var dist: int = current[1]

		if node == end_node:
			return dist

		for neighbour in adjacency[node]:
			if not visited.has(neighbour):
				visited[neighbour] = true
				queue.append([neighbour, dist + 1])

	return -1
