extends RefCounted
class_name AIController

# AI V1 logic and settings

var ai_enabled := false
var ai_player := 1
var terminal_start := 0
var terminal_end := 2

func ai_take_turn(globals: Node, board_root: Node) -> void:
	if not ai_enabled or globals.currentPlayer != ai_player:
		return

	var edge_to_remove := choose_ai_edge(globals, board_root)
	if edge_to_remove == -1:
		globals.currentPlayer = globals.Player.P1
		return

	globals.edges.erase(edge_to_remove)

	for child in board_root.get_children():
		if child is Edge and child.edgeReference == edge_to_remove:
			child.queue_free()
			break

	globals.currentPlayer = globals.Player.P1
	print("AI removed edge: ", edge_to_remove)

func choose_ai_edge(globals: Node, board_root: Node) -> int:
	var candidates: Array[int] = []

	for child in board_root.get_children():
		if child is Edge and not child.is_captured and globals.edges.has(child.edgeReference):
			candidates.append(child.edgeReference)

	if candidates.is_empty():
		return -1

	var best_edge := candidates[0]
	var best_score := -1

	for edge_id in candidates:
		var simulated_edges: Dictionary = globals.edges.duplicate(true)
		simulated_edges.erase(edge_id)

		var distance := shortest_path_length(globals, simulated_edges, terminal_start, terminal_end)
		var score := 999999 if distance == -1 else distance

		if score > best_score:
			best_score = score
			best_edge = edge_id

	return best_edge

func shortest_path_length(globals: Node, edge_dict: Dictionary, start_node: int, end_node: int) -> int:
	if start_node == end_node:
		return 0

	var adjacency := {}
	for i in range(globals.points.size()):
		adjacency[i] = []

	for edge_id in edge_dict.keys():
		var edge = edge_dict[edge_id]
		var a: int = edge["start"]
		var b: int = edge["end"]
		adjacency[a].append(b)
		adjacency[b].append(a)

	var visited := {}
	var queue: Array = [[start_node, 0]]
	visited[start_node] = true

	while not queue.is_empty():
		var item = queue.pop_front()
		var node: int = item[0]
		var distance: int = item[1]

		for neighbour in adjacency[node]:
			if visited.has(neighbour):
				continue
			if neighbour == end_node:
				return distance + 1

			visited[neighbour] = true
			queue.append([neighbour, distance + 1])

	return -1
