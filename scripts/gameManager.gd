extends Node2D
class_name GameManager

enum Player { P1 , P2 }
var currentPlayer = Player.P1
var move_count: int = 0

var gameLogic: Node

const BOARD_PAN_SPEED: float = 420.0
const BOARD_ZOOM_STEP: float = 1.15
const BOARD_MIN_ZOOM: float = 0.55
const BOARD_MAX_ZOOM: float = 2.5

var board_base_scale: Vector2 = Vector2.ONE
var board_base_position: Vector2 = Vector2.ZERO
var board_pan: Vector2 = Vector2.ZERO
var board_zoom: float = 1.0
var board_view_rect: Rect2 = Rect2()
var is_dragging_board: bool = false
var last_drag_position: Vector2 = Vector2.ZERO

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

func _process(delta: float) -> void:
	if gameLogic == null:
		return

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_key_pressed(KEY_A):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		direction.x += 1.0
	if Input.is_key_pressed(KEY_W):
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		direction.y += 1.0

	if direction.length_squared() > 0.0:
		board_pan += direction.normalized() * BOARD_PAN_SPEED * delta
		_apply_board_transform()

func _input(event: InputEvent) -> void:
	if gameLogic == null:
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F:
		_reset_board_view()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			is_dragging_board = event.pressed and board_view_rect.has_point(event.position)
			last_drag_position = event.position
			if is_dragging_board:
				get_viewport().set_input_as_handled()
			return

		if event.pressed and board_view_rect.has_point(event.position):
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_zoom_board_at(event.position, BOARD_ZOOM_STEP)
				get_viewport().set_input_as_handled()
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_board_at(event.position, 1.0 / BOARD_ZOOM_STEP)
				get_viewport().set_input_as_handled()

	if event is InputEventMouseMotion and is_dragging_board:
		board_pan += event.position - last_drag_position
		last_drag_position = event.position
		_apply_board_transform()
		get_viewport().set_input_as_handled()

func _zoom_board_at(screen_position: Vector2, multiplier: float) -> void:
	var old_zoom = board_zoom
	board_zoom = clampf(board_zoom * multiplier, BOARD_MIN_ZOOM, BOARD_MAX_ZOOM)
	if is_equal_approx(old_zoom, board_zoom):
		return

	var old_scale = board_base_scale * old_zoom
	var local_point = (screen_position - (board_base_position + board_pan)) / old_scale
	var new_scale = board_base_scale * board_zoom
	board_pan = screen_position - local_point * new_scale - board_base_position
	_apply_board_transform()

func _reset_board_view() -> void:
	board_pan = Vector2.ZERO
	board_zoom = 1.0
	_apply_board_transform()

func _apply_board_transform() -> void:
	gameLogic.scale = board_base_scale * board_zoom
	gameLogic.position = board_base_position + board_pan

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
	board_view_rect = space
	board_base_scale = Vector2.ONE * factor
	board_base_position = space.get_center() - bounds.get_center() * factor
	_apply_board_transform()
