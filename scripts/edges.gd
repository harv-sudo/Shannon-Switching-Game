extends Node2D
class_name Edge

signal edge_clicked(edge)

var start_position: Vector2
var end_position: Vector2
var width: float = 5.0
var colour: Color = Color.BLACK
var edgeReference: int
var is_hovered: bool = false
var is_captured: bool = false
var hovered_colour: Color = Color.GRAY
var area: Area2D
var collision: CollisionShape2D
var pulse: float = 0.0

func _init(start: Vector2, end: Vector2, index: int) -> void:
	start_position = start
	end_position = end
	edgeReference = index

func _ready() -> void:
	area = Area2D.new()
	add_child(area)
	var shape = RectangleShape2D.new()
	shape.size = Vector2(start_position.distance_to(end_position), 22)
	collision = CollisionShape2D.new()
	collision.shape = shape
	area.add_child(collision)
	area.position = (start_position + end_position) * 0.5
	area.rotation = (end_position - start_position).angle()
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	area.input_event.connect(_select_edge)

func _on_mouse_entered() -> void:
	if is_captured:
		return
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	is_hovered = true
	queue_redraw()

func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	is_hovered = false
	queue_redraw()

func capture(change_color: Color) -> void:
	colour = change_color
	is_captured = true
	is_hovered = false
	area.input_pickable = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	pulse = 1.0
	var tween = create_tween()
	tween.tween_method(func(value: float): pulse = value; queue_redraw(), 1.0, 0.0, 0.3)
	queue_redraw()

func remove() -> void:
	area.input_pickable = false
	is_hovered = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.18)
	tween.tween_callback(queue_free)

func _ink(value: Color) -> Color:
	if value == Color.GREEN:
		return GameStyle.TEAL
	if value == Color.BLUE:
		return GameStyle.BLUE
	if value == Color.RED:
		return GameStyle.CORAL
	if value == Color.GRAY:
		return GameStyle.TEXT
	return Color("#617784")

func _draw() -> void:
	var ink = _ink(hovered_colour if is_hovered else colour)
	if is_hovered or is_captured:
		draw_line(start_position, end_position, Color(ink, 0.12 + pulse * 0.12), width + 8 + pulse * 8, true)
	draw_line(start_position, end_position, ink, width + (1.5 if is_hovered else 0.0), true)
	draw_circle(start_position, width / 2, ink, true, -1, true)
	draw_circle(end_position, width / 2, ink, true, -1, true)

func _select_edge(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_captured:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_viewport().set_input_as_handled()
		edge_clicked.emit(self)

func _exit_tree() -> void:
	if is_hovered:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
