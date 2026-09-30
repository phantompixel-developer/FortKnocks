class_name FortKnocksTheme
extends RefCounted

const COAL := Color("171c1b")
const IRON := Color("242c29")
const PLATE := Color("303a35")
const PLATE_LIGHT := Color("3c4942")
const BONE := Color("e5ddc8")
const MUTED := Color("a9ad9f")
const HAZARD := Color("d4aa55")
const RUST := Color("a45f42")
const SIGNAL := Color("c85f4c")
const OXIDE := Color("6c9589")
const COLD := Color("77b6bf")

static func apply(root: Control) -> void:
	if root == null:
		return
	root.theme = build()

static func build() -> Theme:
	var theme := Theme.new()
	theme.set_color("font_color", "Label", BONE)
	theme.set_color("font_shadow_color", "Label", Color(0.0, 0.0, 0.0, 0.48))
	theme.set_constant("shadow_offset_x", "Label", 2)
	theme.set_constant("shadow_offset_y", "Label", 2)

	theme.set_color("font_color", "Button", BONE)
	theme.set_color("font_hover_color", "Button", Color("fff0c8"))
	theme.set_color("font_pressed_color", "Button", COAL)
	theme.set_color("font_disabled_color", "Button", Color(0.66, 0.66, 0.60, 0.48))
	theme.set_color("font_focus_color", "Button", BONE)
	theme.set_stylebox("normal", "Button", _box(IRON, Color("56625b"), 2, 5))
	theme.set_stylebox("hover", "Button", _box(PLATE_LIGHT, HAZARD, 2, 5))
	theme.set_stylebox("pressed", "Button", _box(HAZARD, Color("f0cc79"), 2, 5))
	theme.set_stylebox("focus", "Button", _box(Color(0.0, 0.0, 0.0, 0.0), OXIDE, 2, 5))
	theme.set_stylebox("disabled", "Button", _box(Color("202624"), Color("353d39"), 1, 5))
	theme.set_constant("outline_size", "Button", 1)

	theme.set_stylebox("panel", "PanelContainer", _box(Color("202724"), Color("4d5a53"), 2, 6))
	theme.set_color("font_color", "RichTextLabel", BONE)
	return theme

static func style_card(rect: ColorRect, emphasis := 0) -> void:
	if rect == null:
		return
	match emphasis:
		1:
			rect.color = Color(0.13, 0.16, 0.145, 0.97)
		2:
			rect.color = Color(0.19, 0.15, 0.10, 0.96)
		_:
			rect.color = Color(0.095, 0.115, 0.105, 0.94)

static func mark_active(button: Button, active: bool) -> void:
	if button == null:
		return
	if active:
		button.add_theme_color_override("font_color", HAZARD)
		button.add_theme_color_override("font_disabled_color", HAZARD)
	else:
		button.remove_theme_color_override("font_color")
		button.remove_theme_color_override("font_disabled_color")

static func _box(background: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = background
	box.border_color = border
	box.border_width_left = border_width
	box.border_width_top = border_width
	box.border_width_right = border_width
	box.border_width_bottom = border_width
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_left = radius
	box.corner_radius_bottom_right = radius
	box.content_margin_left = 14.0
	box.content_margin_right = 14.0
	box.content_margin_top = 10.0
	box.content_margin_bottom = 10.0
	return box
