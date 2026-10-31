extends RefCounted
class_name GameStyle

const BACKGROUND = Color("#101b24")
const PANEL = Color("#192934")
const BORDER = Color("#304552")
const TEXT = Color("#edf3ef")
const MUTED = Color("#a4b7c2")
const TEAL = Color("#75dfbd")
const CORAL = Color("#ffa38e")
const BLUE = Color("#94beff")
const GOLD = Color("#efd28f")

static func box(fill: Color, border: Color = BORDER, radius: int = 14, padding: int = 20) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = padding
	style.content_margin_bottom = padding
	return style

static func make_theme() -> Theme:
	var result = Theme.new()
	result.default_font_size = 18
	result.set_color("font_color", "Label", TEXT)
	result.set_color("font_color", "Button", TEXT)
	result.set_color("font_hover_color", "Button", TEXT)
	result.set_color("font_pressed_color", "Button", BACKGROUND)
	result.set_color("font_hover_pressed_color", "Button", BACKGROUND)
	result.set_color("font_focus_color", "Button", TEXT)
	result.set_stylebox("normal", "Button", box(PANEL, BORDER, 10, 14))
	result.set_stylebox("hover", "Button", box(Color("#253e4a"), TEAL, 10, 14))
	result.set_stylebox("pressed", "Button", box(TEAL, TEAL, 10, 14))
	var focus = box(Color.TRANSPARENT, GOLD, 10, 14)
	focus.set_border_width_all(2)
	result.set_stylebox("focus", "Button", focus)
	result.set_stylebox("panel", "PanelContainer", box(PANEL))
	result.set_stylebox("panel", "Panel", box(PANEL))
	result.set_stylebox("panel", "AcceptDialog", box(PANEL))
	var window_frame = box(PANEL, BORDER, 10, 12)
	window_frame.expand_margin_top = 32
	result.set_stylebox("embedded_border", "Window", window_frame)
	result.set_stylebox("embedded_unfocused_border", "Window", window_frame)
	result.set_constant("separation", "VBoxContainer", 14)
	result.set_constant("separation", "HBoxContainer", 14)
	return result

static func label(value: String, font_size: int = 18, color: Color = TEXT) -> Label:
	var node = Label.new()
	node.text = value
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return node

static func paragraph(value: String, font_size: int = 17) -> Label:
	var node = label(value, font_size, MUTED)
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return node

static func button(value: String, action: Callable, primary: bool = false) -> Button:
	var node = Button.new()
	node.text = value
	node.custom_minimum_size.y = 46
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	node.pressed.connect(action)
	if primary:
		node.add_theme_stylebox_override("normal", box(TEAL, TEAL, 10, 14))
		node.add_theme_stylebox_override("hover", box(TEAL.lightened(0.12), TEAL, 10, 14))
		node.add_theme_color_override("font_color", BACKGROUND)
		node.add_theme_color_override("font_focus_color", BACKGROUND)
		node.add_theme_color_override("font_hover_color", BACKGROUND)
	return node

static func page(root: Control, width: float = 1040) -> VBoxContainer:
	root.theme = make_theme()
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	var column = VBoxContainer.new()
	column.custom_minimum_size.x = width
	column.add_theme_constant_override("separation", 22)
	center.add_child(column)
	return column

static func card(parent: Node) -> VBoxContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)
	var column = VBoxContainer.new()
	panel.add_child(column)
	return column

static func sound_button() -> Button:
	var node = button("", func(): AudioPlayer.toggle_mute())
	node.tooltip_text = "Toggle all audio (M)"
	var refresh = func(): node.text = "Sound off" if AudioPlayer.muted else "Sound on"
	AudioPlayer.mute_changed.connect(refresh)
	node.tree_exiting.connect(func(): AudioPlayer.mute_changed.disconnect(refresh))
	refresh.call()
	return node

static func show_rules(parent: Node, gale: bool = false) -> void:
	var dialog = AcceptDialog.new()
	dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	dialog.title = "How to play"
	dialog.dialog_text = (
		"Blue connects the top and bottom. Red connects the left and right.\n\n"
		+ "Take turns selecting a link on your grid. Each link blocks the\n"
		+ "crossing link on the other grid. The first complete connection wins."
	) if gale else (
		"Short claims links to connect S (start) to G (goal).\n"
		+ "Cut removes unclaimed links to break every possible route.\n\n"
		+ "Short plays first. Claimed links cannot be removed.\n"
		+ "Short wins with a complete route; Cut wins when none remains."
	)
	dialog.dialog_text += "\n\nM  Sound on/off     |     R  Restart     |     Esc  Menu"
	parent.add_child(dialog)
	var tree = parent.get_tree()
	var was_paused = tree.paused
	tree.paused = true
	dialog.tree_exiting.connect(func(): tree.paused = was_paused)
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered(Vector2i(600, 300))
