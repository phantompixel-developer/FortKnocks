class_name ProductionUI
extends RefCounted

const SHARED_ROOT := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png"
const CARD_PATH := SHARED_ROOT + "/ui/card_item_9s.png"
const CARD_SELECTED_PATH := SHARED_ROOT + "/ui/card_item_selected_9s.png"
const BAR_EMPTY_PATH := SHARED_ROOT + "/ui/statbar_seg_empty_9s.png"
const BAR_FILLED_PATH := SHARED_ROOT + "/ui/statbar_seg_filled_9s.png"
const BAR_PREVIEW_PATH := SHARED_ROOT + "/ui/statbar_seg_preview_9s.png"
const UPGRADE_PATH := SHARED_ROOT + "/ui/btn_upgrade_9s.png"
const UPGRADE_PRESSED_PATH := SHARED_ROOT + "/ui/btn_upgrade_pressed_9s.png"
const UPGRADE_DISABLED_PATH := SHARED_ROOT + "/ui/btn_upgrade_disabled_9s.png"

static func texture(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D

static func texture_box(
	path: String,
	margins := Vector4(30.0, 30.0, 30.0, 30.0),
	tint := Color.WHITE,
	content := Vector4(12.0, 10.0, 12.0, 10.0)
) -> StyleBoxTexture:
	var box := StyleBoxTexture.new()
	box.texture = texture(path)
	box.modulate_color = tint
	box.set_texture_margin(SIDE_LEFT, margins.x)
	box.set_texture_margin(SIDE_TOP, margins.y)
	box.set_texture_margin(SIDE_RIGHT, margins.z)
	box.set_texture_margin(SIDE_BOTTOM, margins.w)
	box.set_content_margin(SIDE_LEFT, content.x)
	box.set_content_margin(SIDE_TOP, content.y)
	box.set_content_margin(SIDE_RIGHT, content.z)
	box.set_content_margin(SIDE_BOTTOM, content.w)
	return box

static func style_card_button(button: Button, selected := false) -> void:
	if button == null:
		return
	var path := CARD_SELECTED_PATH if selected else CARD_PATH
	var margins := Vector4(50.0, 50.0, 50.0, 50.0) if selected else Vector4(30.0, 30.0, 30.0, 30.0)
	var normal := texture_box(path, margins)
	var hover := texture_box(path, margins, Color(1.0, 0.96, 0.82, 1.0))
	var pressed := texture_box(path, margins, Color(0.94, 0.86, 0.66, 1.0))
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", normal)
	button.add_theme_stylebox_override("disabled", texture_box(CARD_PATH, Vector4(30.0, 30.0, 30.0, 30.0), Color(0.48, 0.50, 0.52, 0.72)))
	button.add_theme_color_override("font_color", Color("f2f4f6"))
	button.add_theme_color_override("font_disabled_color", Color(0.78, 0.80, 0.82, 0.52))

static func style_action_button(button: Button) -> void:
	if button == null:
		return
	button.add_theme_stylebox_override("normal", texture_box(UPGRADE_PATH, Vector4(36.0, 30.0, 36.0, 40.0)))
	button.add_theme_stylebox_override("hover", texture_box(UPGRADE_PATH, Vector4(36.0, 30.0, 36.0, 40.0), Color(1.0, 1.0, 0.90, 1.0)))
	button.add_theme_stylebox_override("pressed", texture_box(UPGRADE_PRESSED_PATH, Vector4(36.0, 30.0, 36.0, 40.0)))
	button.add_theme_stylebox_override("focus", texture_box(UPGRADE_PATH, Vector4(36.0, 30.0, 36.0, 40.0), Color(1.0, 0.92, 0.68, 1.0)))
	button.add_theme_stylebox_override("disabled", texture_box(UPGRADE_DISABLED_PATH, Vector4(36.0, 30.0, 36.0, 40.0)))
	button.add_theme_color_override("font_color", Color("10171e"))
	button.add_theme_color_override("font_hover_color", Color("10171e"))
	button.add_theme_color_override("font_pressed_color", Color("10171e"))
	button.add_theme_color_override("font_disabled_color", Color(0.58, 0.63, 0.66, 0.92))

static func rebuild_segments(container: HBoxContainer, filled: int, total := 4, preview := -1) -> void:
	if container == null:
		return
	for child in container.get_children():
		child.queue_free()
	for i in range(total):
		var segment := TextureRect.new()
		segment.custom_minimum_size = Vector2(62.0, 22.0)
		segment.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		segment.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		segment.stretch_mode = TextureRect.STRETCH_SCALE
		if i < filled:
			segment.texture = texture(BAR_FILLED_PATH)
		elif preview >= 0 and i < preview:
			segment.texture = texture(BAR_PREVIEW_PATH)
		else:
			segment.texture = texture(BAR_EMPTY_PATH)
		container.add_child(segment)

static func apply_safe_area(container: MarginContainer, base := Vector4(24.0, 24.0, 24.0, 18.0)) -> void:
	if container == null:
		return
	var viewport_size := container.get_viewport_rect().size
	var window_size := DisplayServer.window_get_size()
	var left := base.x
	var top := base.y
	var right := base.z
	var bottom := base.w
	if window_size.x > 0 and window_size.y > 0:
		var safe := DisplayServer.get_display_safe_area()
		if safe.size.x > 0 and safe.size.y > 0:
			var scale := Vector2(
				viewport_size.x / float(window_size.x),
				viewport_size.y / float(window_size.y)
			)
			left += float(safe.position.x) * scale.x
			top += float(safe.position.y) * scale.y
			right += float(window_size.x - safe.end.x) * scale.x
			bottom += float(window_size.y - safe.end.y) * scale.y
	container.add_theme_constant_override("margin_left", int(round(left)))
	container.add_theme_constant_override("margin_top", int(round(top)))
	container.add_theme_constant_override("margin_right", int(round(right)))
	container.add_theme_constant_override("margin_bottom", int(round(bottom)))
