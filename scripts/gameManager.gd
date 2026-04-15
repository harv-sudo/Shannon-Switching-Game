extends Node2D

func drawGraph() -> void:
	draw_edges()
	draw_nodes()

func draw_edges() -> void:
	for edge_id in GlobalVariables.edges.keys():
		var edge = GlobalVariables.edges[edge_id]
		var start_position: Vector2 = GlobalVariables.points[edge["start"]]["position"]
		var end_position: Vector2 = GlobalVariables.points[edge["end"]]["position"]
		add_child(Edge.new(start_position, end_position, edge_id))

func draw_nodes() -> void:
	for i in range(GlobalVariables.points.size()):
		var pos: Vector2 = GlobalVariables.points[i]["position"]

		var point_colour = Color.BLACK
		var point_radius = 12.0
		var point_label = ""

		if i == GlobalVariables.terminal_a:
			point_colour = Color(0.25, 0.55, 1.0)
			point_radius = 18.0
			point_label = "S"
		elif i == GlobalVariables.terminal_b:
			point_colour = Color(1.0, 0.55, 0.15)
			point_radius = 18.0
			point_label = "G"

		add_child(GraphPoint.new(
			pos.x,
			pos.y,
			point_radius,
			point_colour,
			point_label,
			Color.WHITE
		))

func _ready() -> void:
	GlobalVariables.winner_label = get_node_or_null("WinnerLabel")
	GlobalVariables.turn_label = get_node_or_null("TurnLabel")
	GlobalVariables.game_over_panel = get_node_or_null("GameOverPanel")
	GlobalVariables.game_over_winner_label = get_node_or_null("GameOverPanel/GameOverWin")

	var restart_button = get_node_or_null("RestartButton")
	if restart_button != null:
		restart_button.pressed.connect(_restart)

	var play_again_button = get_node_or_null("GameOverPanel/PlayAgainButton")
	if play_again_button != null:
		play_again_button.pressed.connect(_restart)

	GlobalVariables.reset_game()
	drawGraph()

func _restart() -> void:
	get_tree().reload_current_scene()
