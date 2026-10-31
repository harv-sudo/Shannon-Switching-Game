extends Control

func _ready() -> void:
	add_child(BoardBackdrop.new())
	AudioPlayer.play_music_level()
	var page = GameStyle.page(self)
	var eyebrow = GameStyle.label("THE CONNECTION COLLECTION", 15, GameStyle.TEAL)
	page.add_child(eyebrow)
	page.add_child(GameStyle.label("A simple move. A deeper game.", 44))
	page.add_child(GameStyle.label("Connect, cut, and think one step ahead.", 21, GameStyle.MUTED))
	var cards = HBoxContainer.new()
	cards.add_theme_constant_override("separation", 24)
	page.add_child(cards)
	_add_game_card(cards, false)
	_add_game_card(cards, true)
	var footer = HBoxContainer.new()
	page.add_child(footer)
	var credit = GameStyle.label("Shannon Switching Game  /  Team 4 · COMP530", 15, GameStyle.MUTED)
	credit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(credit)
	footer.add_child(GameStyle.sound_button())
	if not OS.has_feature("web"):
		footer.add_child(GameStyle.button("Quit", func(): get_tree().quit()))

func _add_game_card(parent: Node, gale: bool) -> void:
	var card = GameStyle.card(parent)
	card.get_parent().custom_minimum_size.x = 508
	var art = NetworkArt.new()
	art.gale = gale
	card.add_child(art)
	card.add_child(GameStyle.label("02  /  CROSS & CONNECT" if gale else "01  /  CONNECT & CUT", 14, GameStyle.MUTED))
	card.add_child(GameStyle.label("Gale’s Game" if gale else "Shannon Switching", 28))
	card.add_child(GameStyle.paragraph(
		"Two crossing grids. Race to connect your sides while blocking your opponent."
		if gale else "One shared network. Build a route as Short, or break every route as Cut."
	))
	card.add_child(GameStyle.label("Local two-player" if gale else "Local two-player · Play the AI · Watch the AI", 14, GameStyle.MUTED))
	var play = GameStyle.button("Play Gale’s Game" if gale else "Play Shannon", func():
		if gale:
			GlobalVariables.game_mode = GlobalVariables.Mode.PVP
			App.start_game(App.GameType.GALE)
		else:
			App.game_type = App.GameType.SHANNON
			get_tree().change_scene_to_file("res://scenes/gameSetup.tscn")
	, not gale)
	card.add_child(play)
	if not gale:
		play.grab_focus()
