class_name FortKnocksTheme
extends RefCounted

const ProductionArtScript := preload("res://game/presentation/production_art.gd")
const PANEL_TEXTURE_PATH := "res://assets/art/production/shared/ui/panel_industrial.svg"
const BUTTON_TEXTURE_PATH := "res://assets/art/production/shared/ui/button_industrial.svg"

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
	var panel_texture: Texture2D = ProductionArtScript.texture_from_svg(PANEL_TEXTURE_PATH)
	var button_texture: Texture2D = ProductionArtScript.texture_from_svg(BUTTON_TEXTURE_PATH)
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
	if button_texture != null:
		theme.set_stylebox("normal", "Button", _texture_box(button_texture, Color.WHITE, 20.0, 15.0))
		theme.set_stylebox("hover", "Button", _texture_box(button_texture, Color(1.0, 0.91, 0.68, 1.0), 20.0, 15.0))
		theme.set_stylebox("pressed", "Button", _texture_box(button_texture, Color(1.0, 0.76, 0.38, 1.0), 20.0, 15.0))
		theme.set_stylebox("focus", "Button", _texture_box(button_texture, Color(0.72, 0.94, 0.94, 1.0), 20.0, 15.0))
		theme.set_stylebox("disabled", "Button", _texture_box(button_texture, Color(0.46, 0.50, 0.51, 0.68), 20.0, 15.0))
	else:
		theme.set_stylebox("normal", "Button", _box(IRON, Color("3b4b55"), 2, 6))
		theme.set_stylebox("hover", "Button", _box(PLATE_LIGHT, HAZARD, 2, 6))
		theme.set_stylebox("pressed", "Button", _box(HAZARD, Color("ffd16b"), 2, 6))
		theme.set_stylebox("focus", "Button", _box(Color(0.0, 0.0, 0.0, 0.0), COLD, 2, 6))
		theme.set_stylebox("disabled", "Button", _box(Color("131b22"), Color("27343c"), 1, 6))
	theme.set_constant("outline_size", "Button", 1)

	if panel_texture != null:
		theme.set_stylebox("panel", "PanelContainer", _texture_box(panel_texture, Color.WHITE, 22.0, 22.0))
	else:
		theme.set_stylebox("panel", "PanelContainer", _box(Color("141e26"), Color("40515b"), 2, 7))
	theme.set_color("font_color", "RichTextLabel", BONE)
	return theme

static func style_card(rect: ColorRect, emphasis := 0) -> void:
	if rect == null:
		return

	var panel_texture: Texture2D = ProductionArtScript.texture_from_svg(PANEL_TEXTURE_PATH)
	if panel_texture == null:
		match emphasis:
			1:
				rect.color = Color(0.075, 0.11, 0.135, 0.97)
			2:
				rect.color = Color(0.18, 0.12, 0.075, 0.97)
			_:
				rect.color = Color(0.055, 0.085, 0.105, 0.95)
		return

	rect.color = Color.TRANSPARENT
	var surface := rect.get_node_or_null("_ProductionSurface") as NinePatchRect
	if surface == null:
		surface = NinePatchRect.new()
		surface.name = "_ProductionSurface"
		surface.texture = panel_texture
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
	var button_texture: Texture2D = ProductionArtScript.texture_from_svg(BUTTON_TEXTURE_PATH)
	if active:
		button.add_theme_color_override("font_color", HAZARD)
		button.add_theme_color_override("font_disabled_color", HAZARD)
		if button_texture != null:
			button.add_theme_stylebox_override(
				"normal",
				_texture_box(button_texture, Color(1.0, 0.90, 0.58, 1.0), 20.0, 15.0)
			)
			button.add_theme_stylebox_override(
				"disabled",
				_texture_box(button_texture, Color(0.88, 0.72, 0.42, 0.76), 20.0, 15.0)
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
