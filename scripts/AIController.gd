extends Node
class_name AIController

var ai_enabled: bool = false
var ai_player: int = GlobalVariables.Player.P2

#how many turns ahead the ai searches
var search_depth: int = 5

#score returned when the ai wins
var win_score: int = 10000

func ai_take_turn(globals) -> int:
	if not ai_enabled:
		return -1
	if globals == null:
		return -1

	#picks best edge for ai move
	var best_edge: int = choose_ai_edge(
		globals.edges,
		globals.short_edges,
		globals.points,
		globals.start_node,
		globals.end_node
	)

	return best_edge


func choose_ai_edge(edges: Dictionary, short_edges: Dictionary, points: Array, start_node: int, end_node: int) -> int:
	#looks to block any edge that would let actual player win next turn
	for edge_id in edges.keys():
		if short_edges.has(edge_id):
			continue

		var simulated_short_edges: Dictionary = short_edges.duplicate(true)
		simulated_short_edges[edge_id] = edges[edge_id]

		if path_exists(points, simulated_short_edges, start_node, end_node):
			return edge_id

	var best_move: int = -1
	var best_score: int = -9999
	
	#alpha stores best score for ai can guarantee so far
	var alpha: int = -9999
	#beta stores best score actual player can get so far
	var beta: int = 9999
	
	#tries every edge that ai could use
	for edge_id in edges.keys():
		if short_edges.has(edge_id):
			continue

		var simulated_edges: Dictionary = edges.duplicate(true)
		var simulated_short_edges: Dictionary = short_edges.duplicate(true)

		if ai_player == GlobalVariables.Player.P2:
			simulated_edges.erase(edge_id)
		else:
			simulated_short_edges[edge_id] = simulated_edges[edge_id]

		#runs the minmax search on the simulated board
		var score: int = minimax(
			simulated_edges,
			simulated_short_edges,
			points,
			start_node,
			end_node,
			search_depth - 1,
			false,
			alpha,
			beta
		)

		if best_move == -1 or score > best_score:
			best_score = score
			best_move = edge_id

		if best_score > alpha:
			alpha = best_score

	return best_move


func minimax(
	edges: Dictionary,
	short_edges: Dictionary,
	points: Array,
	start_node: int,
	end_node: int,
	depth: int,
	is_ai_turn: bool,
	alpha: int,
	beta: int
) -> int:
	#if depth is 0 or game ends, search stops
	if depth == 0 or is_terminal(edges, short_edges, points, start_node, end_node):
		return evaluate_board(edges, short_edges, points, start_node, end_node)
		
	#ai turns goal is to maximise the score
	if is_ai_turn:
		var best_score: int = -9999

		for edge_id in edges.keys():
			if short_edges.has(edge_id):
				continue

			var simulated_edges: Dictionary = edges.duplicate(true)
			var simulated_short_edges: Dictionary = short_edges.duplicate(true)

			if ai_player == GlobalVariables.Player.P2:
				simulated_edges.erase(edge_id)
			else:
				simulated_short_edges[edge_id] = simulated_edges[edge_id]

			var score: int = minimax(
				simulated_edges,
				simulated_short_edges,
				points,
				start_node,
				end_node,
				depth - 1,
				false,
				alpha,
				beta
			)

			if score > best_score:
				best_score = score

			if best_score > alpha:
				alpha = best_score

			#stops checking the branches that will not improve ai score
			if beta <= alpha:
				break

		return best_score

	#players turn to minimise score
	else:
		var best_score: int = 9999

		for edge_id in edges.keys():
			if short_edges.has(edge_id):
				continue

			var simulated_edges: Dictionary = edges.duplicate(true)
			var simulated_short_edges: Dictionary = short_edges.duplicate(true)

			#simulates player move
			if ai_player == GlobalVariables.Player.P2:
				simulated_short_edges[edge_id] = simulated_edges[edge_id]
			else:
				simulated_edges.erase(edge_id)

			var score: int = minimax(
				simulated_edges,
				simulated_short_edges,
				points,
				start_node,
				end_node,
				depth - 1,
				true,
				alpha,
				beta
			)

			if score < best_score:
				best_score = score

			if best_score < beta:
				beta = best_score

			#stops checking the branches that will not improve player score
			if beta <= alpha:
				break

		return best_score


func is_terminal(edges: Dictionary, short_edges: Dictionary, points: Array, start_node: int, end_node: int) -> bool:
	#player 1 has won
	if path_exists(points, short_edges, start_node, end_node):
		return true

	#cut has won because no winning paths left
	if not path_exists(points, edges, start_node, end_node):
		return true

	#no more possible moves
	var move_exists: bool = false
	for edge_id in edges.keys():
		if not short_edges.has(edge_id):
			move_exists = true
			break

	return not move_exists


func evaluate_board(edges: Dictionary, short_edges: Dictionary, points: Array, start_node: int, end_node: int) -> int:
	var short_wins: bool = path_exists(points, short_edges, start_node, end_node)
	var cut_wins: bool = not path_exists(points, edges, start_node, end_node)

	if ai_player == GlobalVariables.Player.P2:
		#player connected and won
		if short_wins:
			return -win_score
		#ai has blocked all the paths and won
		if cut_wins:
			return win_score

		#shortest path left on the board
		var remaining_path: int = shortest_path_length(points, edges, start_node, end_node)

		#shortest path using only player claimed edges
		var claimed_path: int = shortest_path_length(points, short_edges, start_node, end_node)

		#if no claimed path exists yet, use a default value
		if claimed_path == -1:
			claimed_path = 10
		
		#scores based on:
		# how much of the route is left to be completed
		# how good the current path is
		# how many edges the player has claimed so far
		return (remaining_path * 100) + (claimed_path * 60) - (short_edges.size() * 15)
	else:
		#ai as short connected and won
		if short_wins:
			return win_score
		#player as cut blocked all the paths
		if cut_wins:
			return -win_score

		#shortest path left on the board
		var remaining_path: int = shortest_path_length(points, edges, start_node, end_node)

		#shortest path using only player claimed edges
		var claimed_path: int = shortest_path_length(points, short_edges, start_node, end_node)

		#if no claimed path exists yet, use a default value
		if claimed_path == -1:
			claimed_path = 100

		#scores based on:
		# how many edges short has claimed so far
		# how close the claimed path is to winning
		# how much route is still left overall
		return (short_edges.size() * 15) - (claimed_path * 80) - (remaining_path * 10)


func shortest_path_length(points: Array, edge_dict: Dictionary, start_node: int, end_node: int) -> int:
	if start_node == end_node:
		return 0

	#creates graph from remaining edges
	var adjacency: Dictionary = build_adjacency(points, edge_dict)
	var visited: Dictionary = {}
	var queue: Array = [[start_node, 0]]
	visited[start_node] = true

	while not queue.is_empty():
		var current: Array = queue.pop_front()
		var node: int = current[0]
		var dist: int = current[1]

		if node == end_node:
			return dist

		for neighbour in adjacency.get(node, []):
			if not visited.has(neighbour):
				visited[neighbour] = true
				queue.append([neighbour, dist + 1])

	return -1


func path_exists(points: Array, edge_dict: Dictionary, start_node: int, end_node: int) -> bool:
	#builds graph and checks if there is a route between nodes
	var adjacency: Dictionary = build_adjacency(points, edge_dict)
	var visited: Dictionary = {}
	return dfs(start_node, end_node, adjacency, visited)


func build_adjacency(points: Array, edge_dict: Dictionary) -> Dictionary:
	#builds adjacency list from current edges dict
	var adjacency: Dictionary = {}

	for point_id in range(points.size()):
		adjacency[point_id] = []

	for edge_id in edge_dict.keys():
		var edge: Dictionary = edge_dict[edge_id]
		var start_n: int = edge["start"]
		var end_n: int = edge["end"]

		adjacency[start_n].append(end_n)
		adjacency[end_n].append(start_n)

	return adjacency


func dfs(current_node: int, target_node: int, adjacency: Dictionary, visited: Dictionary) -> bool:
	#dfs checking if nodes can be reached or not
	if current_node == target_node:
		return true

	visited[current_node] = true

	for neighbour in adjacency.get(current_node, []):
		if not visited.has(neighbour):
			if dfs(neighbour, target_node, adjacency, visited):
				return true

	return false
