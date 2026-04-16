class_name WinConditions

# Builds an adjaceny list to see if a winning path has been found
func build_adjacency(points : Array, edges: Dictionary) -> Dictionary:
	var adjacency: Dictionary = {}
	
	for point_id in range(points.size()):
		adjacency[point_id] = []
		
	for edge_id in edges.keys():
		var edge = edges[edge_id]
		var start_node = edge["start"]
		var end_node = edge["end"]
		
		adjacency[start_node].append(end_node)
		adjacency[end_node].append(start_node)
		
	return adjacency

func _dfs(current_node: int, target_node: int, adjacency: Dictionary, visited: Dictionary) -> bool:
	if current_node == target_node:
		return true
		
	visited[current_node] = true
	
	for neighbour in adjacency.get(current_node, []):
		#print("neighbour: ", neighbour)
		if not visited.has(neighbour):
			if _dfs(neighbour, target_node, adjacency, visited):
				return true
	
	return false
	
func path_exists(start_node: int, target_node: int, adjacency: Dictionary) -> bool:
	var visited: Dictionary = {}
	return _dfs(start_node, target_node, adjacency, visited)
		

# Check to see if the "short" player can still win the game, if not "cut" player wins
func is_game_over(start_node: int, target_node: int, points: Array, edges: Dictionary) -> bool:
	var adjacency = build_adjacency(points, edges)
	
	if path_exists(start_node, target_node, adjacency):
		#Player 1s dictionary of moves
		var shortAdjacency = build_adjacency(points, GlobalVariables.short_edges)
		
		if path_exists(start_node, target_node, shortAdjacency):
			GlobalVariables.winner_label = "Player 1 wins"
			return true
		return false
	else:
		GlobalVariables.winner_label = "Player 2 wins"
		return true
