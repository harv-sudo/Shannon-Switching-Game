extends Node2D
class_name GameManager

enum Player { P1 , P2 }
var currentPlayer = Player.P1
var move_count: int = 0

var gameLogic: Node

@onready var ai_controller: AIController = AIController.new()

func _ready() -> void:
	add_child(BoardBackdrop.new())
	get_viewport().physics_object_picking_first_only = true
	get_viewport().physics_object_picking_sort = true
	if App.game_type == App.GameType.SHANNON:
		GlobalVariables.remember_board()
	add_child(ai_controller)
	ai_controller.name = "AI"
	
	match App.game_type:
		App.GameType.SHANNON:
			gameLogic = ShannonGame.new()
			gameLogic.name = "ShannonGame"
		
		App.GameType.GALE:
			gameLogic = GaleGame.new()
			gameLogic.name = "GaleGame"
	
	add_child(gameLogic)
	gameLogic.set_game_manager(self)
	_fit_board()
	get_viewport().size_changed.connect(_fit_board)
	
	if App.game_type == App.GameType.SHANNON:
		if GlobalVariables.game_mode == GlobalVariables.Mode.AIVSAI:
			(gameLogic as ShannonGame)._start_first_ai_turn()
		elif GlobalVariables.game_mode == GlobalVariables.Mode.AI and GlobalVariables.selected_role == "Cut":
			currentPlayer = Player.P1
			(gameLogic as ShannonGame)._start_first_ai_turn()

func switchPlayer() -> void:
	currentPlayer = Player.P1 if currentPlayer == Player.P2 else Player.P2

func gameOver():
	GlobalVariables.last_move_count = move_count
	get_tree().change_scene_to_file("res://scenes/gameOverScreen.tscn")

func _fit_board() -> void:
	var points: Array = GlobalVariables.points if App.game_type == App.GameType.SHANNON else gameLogic.player_one_points + gameLogic.player_two_points
	if points.is_empty():
		return
	var first = points[0]["position"]
	var bounds = Rect2(Vector2(first[0], first[1]), Vector2.ZERO)
	for point in points:
		var raw = point["position"]
		bounds = bounds.expand(Vector2(raw[0], raw[1]))
	bounds = bounds.grow(40)
	var viewport_size = get_viewport_rect().size
	var space = Rect2(28, 112, viewport_size.x - 366, viewport_size.y - 140)
	var factor = minf(space.size.x / bounds.size.x, space.size.y / bounds.size.y)
	factor = minf(factor, 1.5)
	gameLogic.scale = Vector2.ONE * factor
	gameLogic.position = space.get_center() - bounds.get_center() * factor
