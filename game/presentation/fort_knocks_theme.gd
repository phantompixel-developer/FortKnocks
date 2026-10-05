class_name FortKnocksTheme
extends RefCounted

const PANEL_TEXTURE: Texture2D = preload("res://assets/art/production/shared/ui/panel_industrial.svg")
const BUTTON_TEXTURE: Texture2D = preload("res://assets/art/production/shared/ui/button_industrial.svg")

# Locked production palette: dark industrial UI, warm salvage lighting, restrained cold-tech accents.
const COAL := Color("111820")
const IRON := Color("18232c")
const PLATE := Color("22303a")
const PLATE_LIGHT := Color("31424c")
const BONE := Color("f0e6d0")
const MUTED := Color("aab4b1")
const HAZARD := Color("e7ad3c")
const RUST := Color("b65c36")
const SIGNAL := Color("d85a3f")
const OXIDE := Color("5d918e")
const COLD := Color("69b8c8")
const SHADOW := Color("090d11")
const WARM_LIGHT := Color("f0a14a")

static func apply(root: Control) -> void:
	if root == null:
		return
	root.theme = build()

static func build() -> Theme:
	var theme := Theme.new()
	theme.set_color("font_color", "Label", BONE)
	theme.set_color("font_shadow_color", "Label", Color(0.0, 0.0, 0.0, 0.66))
	theme.set_constant("shadow_offset_x", "Label", 2)
	theme.set_constant("shadow_offset_y", "Label", 2)

	theme.set_color("font_color", "Button", BONE)
	theme.set_color("font_hover_color", "Button", Color("fff3d5"))
	theme.set_color("font_pressed_color", "Button", SHADOW)
	theme.set_color("font_disabled_color", "Button", Color(0.68, 0.70, 0.68, 0.42))
	theme.set_color("font_focus_color", "Button", BONE)
	theme.set_stylebox("normal", "Button", _texture_box(BUTTON_TEXTURE, Color.WHITE, 20.0, 15.0))
	theme.set_stylebox("hover", "Button", _texture_box(BUTTON_TEXTURE, Color(1.0, 0.91, 0.68, 1.0), 20.0, 15.0))
	theme.set_stylebox("pressed", "Button", _texture_box(BUTTON_TEXTURE, Color(1.0, 0.76, 0.38, 1.0), 20.0, 15.0))
	theme.set_stylebox("focus", "Button", _texture_box(BUTTON_TEXTURE, Color(0.72, 0.94, 0.94, 1.0), 20.0, 15.0))
	theme.set_stylebox("disabled", "Button", _texture_box(BUTTON_TEXTURE, Color(0.46, 0.50, 0.51, 0.68), 20.0, 15.0))
	theme.set_constant("outline_size", "Button", 1)

	theme.set_stylebox("panel", "PanelContainer", _texture_box(PANEL_TEXTURE, Color.WHITE, 22.0, 22.0))
	theme.set_color("font_color", "RichTextLabel", BONE)
	return theme

static func style_card(rect: ColorRect, emphasis := 0) -> void:
	if rect == null:
		return

	rect.color = Color.TRANSPARENT
	var surface := rect.get_node_or_null("_ProductionSurface") as NinePatchRect
	if surface == null:
		surface = NinePatchRect.new()
		surface.name = "_ProductionSurface"
		surface.texture = PANEL_TEXTURE
		surface.patch_margin_left = 22
		surface.patch_margin_top = 22
		surface.patch_margin_right = 22
		surface.patch_margin_bottom = 22
		surface.anchor_left = 0.0
		surface.anchor_top = 0.0
		surface.anchor_right = 1.0
		surface.anchor_bottom = 1.0
		surface.offset_left = 0.0
		surface.offset_top = 0.0
		surface.offset_right = 0.0
		surface.offset_bottom = 0.0
		surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect.add_child(surface)
		rect.move_child(surface, 0)

	match emphasis:
		1:
			surface.modulate = Color(1.0, 0.96, 0.80, 1.0)
		2:
			surface.modulate = Color(1.0, 0.82, 0.64, 1.0)
		_:
			surface.modulate = Color.WHITE

static func mark_active(button: Button, active: bool) -> void:
	if button == null:
		return
	if active:
		button.add_theme_color_override("font_color", HAZARD)
		button.add_theme_color_override("font_disabled_color", HAZARD)
		button.add_theme_stylebox_override(
			"normal",
			_texture_box(BUTTON_TEXTURE, Color(1.0, 0.90, 0.58, 1.0), 20.0, 15.0)
		)
		button.add_theme_stylebox_override(
			"disabled",
			_texture_box(BUTTON_TEXTURE, Color(0.88, 0.72, 0.42, 0.76), 20.0, 15.0)
		)
	else:
		button.remove_theme_color_override("font_color")
		button.remove_theme_color_override("font_disabled_color")
		button.remove_theme_stylebox_override("normal")
		button.remove_theme_stylebox_override("disabled")

static func _texture_box(
	texture: Texture2D,
	modulate: Color,
	horizontal_margin: float,
	vertical_margin: float
) -> StyleBoxTexture:
	var box := StyleBoxTexture.new()
	box.texture = texture
	box.modulate_color = modulate
	box.set_texture_margin(SIDE_LEFT, horizontal_margin)
	box.set_texture_margin(SIDE_RIGHT, horizontal_margin)
	box.set_texture_margin(SIDE_TOP, vertical_margin)
	box.set_texture_margin(SIDE_BOTTOM, vertical_margin)
	box.set_content_margin(SIDE_LEFT, 14.0)
	box.set_content_margin(SIDE_RIGHT, 14.0)
	box.set_content_margin(SIDE_TOP, 10.0)
	box.set_content_margin(SIDE_BOTTOM, 10.0)
	return box
