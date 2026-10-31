extends Control

func _ready() -> void:
	add_child(BoardBackdrop.new())
	AudioPlayer.play_sound_effect(preload("res://audio/victory_sound_effect.mp3"), -8.0)
	var page = GameStyle.page(self, 640)
	page.add_child(GameStyle.label("CONNECTION COMPLETE" if GlobalVariables.winner_label.begins_with("Short") else "WELL PLAYED", 15, GameStyle.TEAL))
	page.add_child(GameStyle.label(GlobalVariables.winner_label, 52))
	var explanation = "A complete route from start to goal."
	if GlobalVariables.winner_label.begins_with("Cut"):
		explanation = "Every route from start to goal has been disconnected."
	elif App.game_type == App.GameType.GALE:
		explanation = "A winning connection across the board."
	page.add_child(GameStyle.paragraph(explanation, 21))
	page.add_child(GameStyle.label("%d moves played" % GlobalVariables.last_move_count, 17, GameStyle.MUTED))
	var art = NetworkArt.new()
	art.gale = App.game_type == App.GameType.GALE
	page.add_child(art)
	var row = HBoxContainer.new()
	page.add_child(row)
	var replay = GameStyle.button("Play this board again", _replay, true)
	row.add_child(replay)
	row.add_child(GameStyle.button("Main menu", func(): get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")))
	row.add_child(GameStyle.sound_button())
	replay.grab_focus()

func _replay() -> void:
	GlobalVariables.restore_board()
	App.start_game(App.game_type)
