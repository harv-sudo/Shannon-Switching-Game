extends Node

class_name DynamicGraph

# -----------------------------
# MAIN ENTRY
# -----------------------------
func generate(node_count: int, edge_count: int) -> Dictionary:
	var width = 800
	var height = 600

	var points = generate_points(node_count, width, height, 100)

	# optional extra safety (perfect centering)
	center_graph(points, width, height)

	var start_end = assign_start_and_end(points)
	var start_node = start_end[0]
	var end_node = start_end[1]

	var edges = generate_mst(points, start_node, end_node)
	edges = add_extra_edges(points, edges, edge_count, start_node, end_node)

	return {
		"points": points,
		"edges": edges,
		"start": start_node,
		"end": end_node
	}

# -----------------------------
# NODE GENERATION (CENTERED AREA)
# -----------------------------
func generate_points(count, width, height, min_dist):
	var pts = []
	var attempts = 0

	# Use only 60% of screen space
	var scale = 0.6
	var usable_w = width * scale
	var usable_h = height * scale

	# Offset to center
	var offset_x = (width - usable_w) / 2
	var offset_y = (height - usable_h) / 2

	while pts.size() < count and attempts < count * 50:
		attempts += 1

		var pos = Vector2(
			offset_x + randf() * usable_w,
			offset_y + randf() * usable_h
		)

		var valid = true
		for p in pts:
			if p["position"].distance_to(pos) < min_dist:
				valid = false
				break

		if valid:
			pts.append({ "position": pos })

	return pts

# -----------------------------
# CENTER GRAPH (POST PROCESS)
# -----------------------------
func center_graph(points, width, height):
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF

	for p in points:
		min_x = min(min_x, p.position.x)
		max_x = max(max_x, p.position.x)
		min_y = min(min_y, p.position.y)
		max_y = max(max_y, p.position.y)

	var graph_center = Vector2(
		(min_x + max_x) / 2,
		(min_y + max_y) / 2
	)

	var screen_center = Vector2(width / 2, height / 2)
	var offset = screen_center - graph_center

	for p in points:
		p.position += offset

# -----------------------------
# START / END
# -----------------------------
func assign_start_and_end(points):
	var min_x = INF
	var max_x = -INF
	var start_node = 0
	var end_node = 0

	for i in range(points.size()):
		var x = points[i]["position"].x

		if x < min_x:
			min_x = x
			start_node = i

		if x > max_x:
			max_x = x
			end_node = i

	return [start_node, end_node]

# -----------------------------
# DISTANCE
# -----------------------------
func get_dist(a, b):
	return a.position.distance_to(b.position)

# -----------------------------
# RULE
# -----------------------------
func is_start_end_edge(a, b, start, end):
	return (a == start and b == end) or (a == end and b == start)

# -----------------------------
# INTERSECTION
# -----------------------------
func direction(a, b, c):
	return (c.x - a.x) * (b.y - a.y) - (c.y - a.y) * (b.x - a.x)

func lines_intersect(p1, p2, p3, p4):
	var d1 = direction(p3, p4, p1)
	var d2 = direction(p3, p4, p2)
	var d3 = direction(p1, p2, p3)
	var d4 = direction(p1, p2, p4)

	return (d1 * d2 < 0 and d3 * d4 < 0)

func is_edge_valid(points, edges, a, b):
	var p1 = points[a].position
	var p2 = points[b].position

	for e in edges.values():
		var c = e["start"]
		var d = e["end"]

		if a == c or a == d or b == c or b == d:
			continue

		var p3 = points[c].position
		var p4 = points[d].position

		if lines_intersect(p1, p2, p3, p4):
			return false

	return true

# -----------------------------
# MST
# -----------------------------
func generate_mst(points, start_node, end_node):
	var n = points.size()
	var in_tree = [0]
	var result = {}
	var edge_id = 0

	while in_tree.size() < n:
		var best_dist = INF
		var best = null

		for i in in_tree:
			for j in range(n):
				if j in in_tree:
					continue

				if is_start_end_edge(i, j, start_node, end_node):
					continue

				var dist = get_dist(points[i], points[j])

				if dist < best_dist:
					best_dist = dist
					best = [i, j]

		if best != null:
			in_tree.append(best[1])
			result[edge_id] = {
				"start": best[0],
				"end": best[1]
			}
			edge_id += 1

	return result

# -----------------------------
# EXTRA EDGES (PLANAR)
# -----------------------------
func add_extra_edges(points, edges, target_edge_count, start_node, end_node):
	var needed = target_edge_count - edges.size()
	if needed <= 0:
		return edges

	var candidates = []
	var n = points.size()

	for i in range(n):
		for j in range(i + 1, n):
			if is_start_end_edge(i, j, start_node, end_node):
				continue

			candidates.append([i, j, get_dist(points[i], points[j])])

	candidates.sort_custom(func(a, b): return a[2] < b[2])

	var edge_id = edges.size()

	for c in candidates:
		if needed <= 0:
			break

		var a = c[0]
		var b = c[1]

		var exists = false
		for e in edges.values():
			if (e.start == a and e.end == b) or (e.start == b and e.end == a):
				exists = true
				break

		if exists:
			continue

		if not is_edge_valid(points, edges, a, b):
			continue
		edges[edge_id] = {
			"start": a,
			"end": b
		}
		edge_id += 1
		needed -= 1

	return edges
