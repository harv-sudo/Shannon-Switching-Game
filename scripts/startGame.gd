extends Control

func _ready() -> void:
	var button = Button.new()
	button.text = "Start Game"
	button.pressed.connect(_start_game)
	button.position = Vector2(240, 450)
	add_child(button)

func _start_game():
	get_tree().change_scene_to_file("res://shannonBoard.tscn")
