class_name GarageScreen
extends Control

signal back_requested
signal platform_requested(platform_id: String)
signal platform_active_requested(platform_id: String)
signal platform_upgrade_requested(platform_id: String)

const PlatformCatalogScript := preload("res://game/platforms/platform_catalog.gd")
const ThemeScript := preload("res://game/presentation/fort_knocks_theme.gd")
const ProductionUIScript := preload("res://game/presentation/production_ui.gd")
const GarageSharpenShader := preload("res://game/progression/garage_sharpen.gdshader")

const GARAGE_ROOT := "res://assets/art/claude_assets/1_Asset_Kit/02_garage"
const ICON_ARMOUR := GARAGE_ROOT + "/png/icons/icon_stat_armour.png"
const ICON_SPEED := GARAGE_ROOT + "/png/icons/icon_stat_speed.png"
const ICON_FUEL := GARAGE_ROOT + "/png/icons/icon_stat_fuel.png"
const ICON_LOAD := GARAGE_ROOT + "/png/icons/icon_stat_load.png"
const PICKUP_THUMB := GARAGE_ROOT + "/art/thumb_veh_01_scavenger_pickup_PLACEHOLDER.png"

const PANEL_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/ui/panel_stats_9s.png"
const CARD_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/ui/card_item_9s.png"
const CARD_SELECTED_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/ui/card_item_selected_9s.png"
const LOCK_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/icons/icon_lock.png"
const COIN_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/icons/icon_coin.png"
const SEG_EMPTY_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/ui/statbar_seg_empty_9s.png"
const SEG_FILLED_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/ui/statbar_seg_filled_9s.png"

const SWIPE_MIN: float = 60.0
static var ACTIVE_ACCENT: Color = Color("42c7dc")
static var ACTIVE_DARK: Color = Color("101b24")

@onready var platform_showcase: PlatformShowcase = %PlatformShowcase
@onready var pickup_hero: TextureRect = %PickupHero
@onready var swipe_area: Control = %SwipeArea
@onready var title_label: Label = %PlatformTitle
@onready var status_label: Label = %PlatformStatus
@onready var active_toggle: Button = %ActiveToggle
@onready var rows: VBoxContainer = %Rows
@onready var action_button: Button = %ActionButton
@onready var action_label: Label = %ActionLabel
@onready var action_coin: TextureRect = %ActionCoin
@onready var action_cost: Label = %ActionCost
@onready var platform_row: HBoxContainer = %PlatformRow
@onready var card_scroll: ScrollContainer = %CardScroll
@onready var prev_button: TextureButton = %PrevButton
@onready var next_button: TextureButton = %NextButton
@onready var back_button: TextureButton = %BackButton
@onready var notice_label: Label = %NoticeLabel
@onready var stats_panel: PanelContainer = %StatsPanel

var _snapshot: Dictionary = {}
var _definitions: Array[CombatPlatformDefinition] = []
var _selected_index: int = 0
var _card_buttons: Array[Button] = []
var _swipe_start: Vector2 = Vector2.INF
var _action_available: bool = false
var _action_is_upgrade: bool = false

func _ready() -> void:
	ThemeScript.apply(self)
	stats_panel.add_theme_stylebox_override(
		"panel",
		ProductionUIScript.texture_box(
			PANEL_PATH,
			Vector4(27.0, 27.0, 27.0, 27.0),
			Color.WHITE,
			Vector4.ZERO
		)
	)
	ProductionUIScript.style_action_button(action_button)
	_style_active_toggle()
	pickup_hero.material = _sharpen_material(0.10)
	action_coin.texture = ProductionUIScript.texture(COIN_PATH)
	_apply_back_safe_area()

	back_button.pressed.connect(func() -> void:
		_play_ui(&"ui_back")
		back_requested.emit()
	)
	prev_button.pressed.connect(_step.bind(-1))
	next_button.pressed.connect(_step.bind(1))
	action_button.pressed.connect(_request_selected)
	active_toggle.pressed.connect(_request_active_selected)
	swipe_area.gui_input.connect(_on_swipe_input)

func configure(save_snapshot: Dictionary, notice := "") -> void:
	_snapshot = save_snapshot.duplicate(true)
	_definitions = PlatformCatalogScript.all()

	var inventory: Dictionary = _snapshot.get("inventory", {}) as Dictionary
	var active_id: String = str(inventory.get("platform_id", "run_down_compact"))
	_selected_index = 0
	for i in range(_definitions.size()):
		if _definitions[i].id == active_id:
			_selected_index = i
			break

	notice_label.text = notice
	notice_label.visible = not notice.is_empty()
	_build_cards()
	_show_selected(false)

func _step(direction: int) -> void:
	if _definitions.is_empty():
		return
	var next_index: int = clampi(_selected_index + direction, 0, _definitions.size() - 1)
	if next_index == _selected_index:
		return
	_selected_index = next_index
	_play_ui(&"ui_confirm")
	_show_selected()

func _show_selected(animate := true) -> void:
	if _definitions.is_empty():
		return

	var definition: CombatPlatformDefinition = _definitions[_selected_index]
	var inventory: Dictionary = _snapshot.get("inventory", {}) as Dictionary
	var campaign: Dictionary = _snapshot.get("campaign", {}) as Dictionary
	var owned: Array = inventory.get("owned_platform_ids", ["run_down_compact"]) as Array
	var completed: Array = campaign.get("completed_missions", []) as Array
	var active_id: String = str(inventory.get("platform_id", "run_down_compact"))
	var equipped_modules: Dictionary = inventory.get("equipped_module_by_platform", {}) as Dictionary
	var module_id: String = str(equipped_modules.get(definition.id, ""))
	var owned_selected: bool = owned.has(definition.id)
	var level: int = _platform_level(definition.id)

	title_label.text = definition.display_name.to_upper()
	status_label.text = "LEVEL %d" % level if owned_selected else "LOCKED"

	active_toggle.visible = owned_selected
	active_toggle.button_pressed = definition.id == active_id
	active_toggle.disabled = definition.id == active_id
	active_toggle.text = "✓" if definition.id == active_id else "□"
	active_toggle.tooltip_text = "Active vehicle" if definition.id == active_id else "Set this vehicle as active"

	var use_pickup_art: bool = definition.id == "pickup"
	pickup_hero.visible = use_pickup_art
	platform_showcase.visible = not use_pickup_art
	if not use_pickup_art:
		platform_showcase.configure(definition.id, module_id)

	_rebuild_stats(definition, level)
	_update_action(definition, owned, completed)

	prev_button.disabled = _selected_index == 0
	next_button.disabled = _selected_index == _definitions.size() - 1

	for i in range(_card_buttons.size()):
		_set_card_selected(_card_buttons[i], i == _selected_index)
	if _selected_index < _card_buttons.size():
		card_scroll.ensure_control_visible.call_deferred(_card_buttons[_selected_index])

	if animate:
		var display: Control = pickup_hero if use_pickup_art else platform_showcase
		display.pivot_offset = display.size * 0.5
		display.modulate.a = 0.0
		display.scale = Vector2(0.94, 0.94)
		var tween: Tween = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(display, "modulate:a", 1.0, 0.18)
		tween.tween_property(display, "scale", Vector2.ONE, 0.22)

func _update_action(
	definition: CombatPlatformDefinition,
	owned: Array,
	completed: Array
) -> void:
	var inventory: Dictionary = _snapshot.get("inventory", {}) as Dictionary
	var salvage: int = int(inventory.get("salvage", 0))
	var unlocked: bool = definition.unlock_after_mission_id.is_empty() or completed.has(definition.unlock_after_mission_id)
	var is_owned: bool = owned.has(definition.id)

	_action_available = false
	_action_is_upgrade = false
	action_button.disabled = false
	action_coin.visible = false
	action_cost.visible = false

	if is_owned:
		var level: int = _platform_level(definition.id)
		if level >= definition.max_level:
			action_label.text = "MAX LEVEL"
			action_button.disabled = true
			return

		var cost: int = definition.upgrade_cost(level)
		action_label.text = "UPGRADE"
		action_coin.visible = true
		action_cost.visible = true
		action_cost.text = _format_number(cost)
		_action_is_upgrade = true
		if salvage >= cost:
			_action_available = true
		else:
			action_button.disabled = true
		return

	if not unlocked or not definition.purchasable:
		action_label.text = "LOCKED"
		action_button.disabled = true
		return

	action_label.text = "ACQUIRE"
	action_coin.visible = true
	action_cost.visible = true
	action_cost.text = _format_number(definition.purchase_cost)
	if salvage >= definition.purchase_cost:
		_action_available = true
	else:
		action_button.disabled = true

func _request_selected() -> void:
	if _definitions.is_empty() or not _action_available:
		return
	var platform_id: String = _definitions[_selected_index].id
	if _action_is_upgrade:
		platform_upgrade_requested.emit(platform_id)
	else:
		platform_requested.emit(platform_id)

func _request_active_selected() -> void:
	if _definitions.is_empty() or active_toggle.disabled:
		return
	var definition: CombatPlatformDefinition = _definitions[_selected_index]
	var inventory: Dictionary = _snapshot.get("inventory", {}) as Dictionary
	var owned: Array = inventory.get("owned_platform_ids", ["run_down_compact"]) as Array
	if owned.has(definition.id):
		platform_active_requested.emit(definition.id)

func _rebuild_stats(definition: CombatPlatformDefinition, level: int) -> void:
	for child in rows.get_children():
		child.queue_free()

	var effective_health: int = definition.cover_health_at_level(level)
	var armour: int = clampi(int(round(float(effective_health) / 75.0)), 1, 4)
	var speed: int = clampi(1 + int(round((definition.cover_size.x - 240.0) / 35.0)), 1, 4)
	var fuel: int = 4 if definition.utility_slot_count > 0 else 0
	var load: int = clampi(maxi(speed, definition.utility_slot_count + 1), 1, 4)

	_add_stat_row("ARMOUR", ICON_ARMOUR, armour)
	_add_stat_row("SPEED", ICON_SPEED, speed)
	_add_stat_row("FUEL", ICON_FUEL, fuel)
	_add_stat_row("LOAD", ICON_LOAD, load)

func _add_stat_row(label_text: String, icon_path: String, filled: int) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0.0, 38.0)
	row.add_theme_constant_override("separation", 12)

	var icon := TextureRect.new()
	icon.texture = ProductionUIScript.texture(icon_path)
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	icon.custom_minimum_size = Vector2(38.0, 38.0)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(icon)

	var label := Label.new()
	label.custom_minimum_size = Vector2(132.0, 0.0)
	label.text = label_text
	label.add_theme_font_size_override("font_size", 26)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(label)

	var segments := HBoxContainer.new()
	segments.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	segments.add_theme_constant_override("separation", 5)
	row.add_child(segments)

	for i in range(4):
		var segment := NinePatchRect.new()
		segment.texture = ProductionUIScript.texture(SEG_FILLED_PATH if i < filled else SEG_EMPTY_PATH)
		segment.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		segment.patch_margin_left = 8
		segment.patch_margin_top = 8
		segment.patch_margin_right = 8
		segment.patch_margin_bottom = 8
		segment.custom_minimum_size = Vector2(40.0, 31.0)
		segment.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		segment.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		segment.mouse_filter = Control.MOUSE_FILTER_IGNORE
		segments.add_child(segment)

	rows.add_child(row)

func _build_cards() -> void:
	for child in platform_row.get_children():
		child.queue_free()
	_card_buttons.clear()

	var campaign: Dictionary = _snapshot.get("campaign", {}) as Dictionary
	var completed: Array = campaign.get("completed_missions", []) as Array
	var inventory: Dictionary = _snapshot.get("inventory", {}) as Dictionary
	var owned: Array = inventory.get("owned_platform_ids", ["run_down_compact"]) as Array
	var active_id: String = str(inventory.get("platform_id", "run_down_compact"))

	for i in range(_definitions.size()):
		var definition: CombatPlatformDefinition = _definitions[i]
		var unlocked: bool = definition.unlock_after_mission_id.is_empty() or completed.has(definition.unlock_after_mission_id)
		var locked: bool = not owned.has(definition.id) and not unlocked
		var is_active: bool = definition.id == active_id

		var card := Button.new()
		card.custom_minimum_size = Vector2(229.0, 188.0)
		card.focus_mode = Control.FOCUS_NONE
		card.flat = true
		card.clip_contents = false
		card.pressed.connect(_select_card.bind(i))

		var frame := NinePatchRect.new()
		frame.name = "_Frame"
		frame.texture = ProductionUIScript.texture(CARD_PATH)
		frame.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		frame.set_anchors_preset(Control.PRESET_FULL_RECT)
		frame.patch_margin_left = 20
		frame.patch_margin_top = 20
		frame.patch_margin_right = 20
		frame.patch_margin_bottom = 20
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(frame)

		var active_frame := Panel.new()
		active_frame.name = "_ActiveFrame"
		active_frame.set_anchors_preset(Control.PRESET_FULL_RECT)
		active_frame.offset_left = 4.0
		active_frame.offset_top = 4.0
		active_frame.offset_right = -4.0
		active_frame.offset_bottom = -4.0
		active_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		active_frame.add_theme_stylebox_override("panel", _active_card_style())
		active_frame.visible = is_active
		card.add_child(active_frame)

		var selected := NinePatchRect.new()
		selected.name = "_SelectedFrame"
		selected.texture = ProductionUIScript.texture(CARD_SELECTED_PATH)
		selected.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		selected.set_anchors_preset(Control.PRESET_FULL_RECT)
		selected.offset_left = -13.0
		selected.offset_top = -13.0
		selected.offset_right = 13.0
		selected.offset_bottom = 13.0
		selected.patch_margin_left = 33
		selected.patch_margin_top = 33
		selected.patch_margin_right = 33
		selected.patch_margin_bottom = 33
		selected.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(selected)

		if definition.id == "pickup":
			var thumb := TextureRect.new()
			thumb.texture = ProductionUIScript.texture(PICKUP_THUMB)
			thumb.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			thumb.set_anchors_preset(Control.PRESET_FULL_RECT)
			thumb.offset_left = 14.0
			thumb.offset_top = 13.0
			thumb.offset_right = -14.0
			thumb.offset_bottom = -13.0
			thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
			thumb.material = _sharpen_material(0.10)
			if locked:
				thumb.modulate = Color(0.42, 0.45, 0.52, 1.0)
			card.add_child(thumb)
		else:
			var preview := PlatformShowcase.new()
			preview.set_anchors_preset(Control.PRESET_FULL_RECT)
			preview.offset_left = 12.0
			preview.offset_top = 8.0
			preview.offset_right = -12.0
			preview.offset_bottom = -8.0
			preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
			preview.draw_floor_shadow = false
			preview.max_display_width = 205.0
			preview.configure(definition.id)
			if locked:
				preview.modulate = Color(0.42, 0.45, 0.52, 1.0)
			card.add_child(preview)

		if locked:
			var lock := TextureRect.new()
			lock.texture = ProductionUIScript.texture(LOCK_PATH)
			lock.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			lock.anchor_left = 0.5
			lock.anchor_top = 0.5
			lock.anchor_right = 0.5
			lock.anchor_bottom = 0.5
			lock.offset_left = -30.0
			lock.offset_top = -24.0
			lock.offset_right = 30.0
			lock.offset_bottom = 50.0
			lock.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			lock.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
			card.add_child(lock)

		if is_active:
			var badge := Panel.new()
			badge.position = Vector2(181.0, 9.0)
			badge.size = Vector2(34.0, 34.0)
			badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
			badge.add_theme_stylebox_override("panel", _active_badge_style())
			var tick := Label.new()
			tick.set_anchors_preset(Control.PRESET_FULL_RECT)
			tick.text = "✓"
			tick.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			tick.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			tick.add_theme_color_override("font_color", ACTIVE_ACCENT)
			tick.add_theme_font_size_override("font_size", 22)
			tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
			badge.add_child(tick)
			card.add_child(badge)

		platform_row.add_child(card)
		_card_buttons.append(card)

func _set_card_selected(card: Button, selected: bool) -> void:
	var normal: CanvasItem = card.get_node_or_null("_Frame") as CanvasItem
	var glow: CanvasItem = card.get_node_or_null("_SelectedFrame") as CanvasItem
	if normal != null:
		normal.visible = not selected
	if glow != null:
		glow.visible = selected

func _select_card(index: int) -> void:
	if index < 0 or index >= _definitions.size():
		return
	_selected_index = index
	_play_ui(&"ui_confirm")
	_show_selected()

func _platform_level(platform_id: String) -> int:
	var inventory: Dictionary = _snapshot.get("inventory", {}) as Dictionary
	var levels: Dictionary = inventory.get("platform_levels", {}) as Dictionary
	return clampi(int(levels.get(platform_id, 1)), 1, 4)

func _sharpen_material(strength: float) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = GarageSharpenShader
	material.set_shader_parameter("strength", strength)
	return material

func _style_active_toggle() -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.035, 0.065, 0.085, 0.92)
	normal.border_color = Color(0.32, 0.40, 0.46, 1.0)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(7)

	var hover := normal.duplicate() as StyleBoxFlat
	hover.border_color = ACTIVE_ACCENT.darkened(0.15)

	var active := normal.duplicate() as StyleBoxFlat
	active.bg_color = ACTIVE_DARK
	active.border_color = ACTIVE_ACCENT
	active.set_border_width_all(3)

	active_toggle.add_theme_stylebox_override("normal", normal)
	active_toggle.add_theme_stylebox_override("hover", hover)
	active_toggle.add_theme_stylebox_override("pressed", active)
	active_toggle.add_theme_stylebox_override("hover_pressed", active)
	active_toggle.add_theme_stylebox_override("disabled", active)
	active_toggle.add_theme_color_override("font_color", Color(0.72, 0.79, 0.83, 1.0))
	active_toggle.add_theme_color_override("font_pressed_color", ACTIVE_ACCENT)
	active_toggle.add_theme_color_override("font_disabled_color", ACTIVE_ACCENT)

func _active_card_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.border_color = ACTIVE_ACCENT
	style.set_border_width_all(4)
	style.set_corner_radius_all(16)
	return style

func _active_badge_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = ACTIVE_DARK
	style.border_color = ACTIVE_ACCENT
	style.set_border_width_all(2)
	style.set_corner_radius_all(7)
	return style

func _on_swipe_input(event: InputEvent) -> void:
	var pressed: bool = false
	if event is InputEventScreenTouch:
		pressed = event.pressed
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		pressed = event.pressed
	else:
		return

	if pressed:
		_swipe_start = event.position
	elif _swipe_start != Vector2.INF:
		var delta: Vector2 = event.position - _swipe_start
		_swipe_start = Vector2.INF
		if absf(delta.x) >= SWIPE_MIN and absf(delta.x) > absf(delta.y) * 1.5:
			_step(-1 if delta.x > 0.0 else 1)

func _apply_back_safe_area() -> void:
	var window_size: Vector2i = DisplayServer.window_get_size()
	if window_size.y <= 0:
		return
	var safe_rect: Rect2i = DisplayServer.get_display_safe_area()
	if safe_rect.size.y <= 0:
		return
	var viewport_height: float = get_viewport_rect().size.y
	var inset: float = float(safe_rect.position.y) * (viewport_height / float(window_size.y))
	if inset > 0.0 and inset < 120.0:
		back_button.position.y += inset

func _format_number(value: int) -> String:
	var source: String = str(absi(value))
	var output: String = ""
	while source.length() > 3:
		output = "," + source.substr(source.length() - 3) + output
		source = source.substr(0, source.length() - 3)
	return source + output

func _play_ui(cue: StringName) -> void:
	var audio := get_tree().get_first_node_in_group("fort_knocks_audio")
	if audio != null and audio.has_method("play_cue"):
		audio.call("play_cue", cue)
