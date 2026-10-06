class_name WorkshopScreen
extends Control

signal back_requested
signal module_requested(module_id: String)
signal specialist_weapon_requested(weapon_id: String)
signal weapon_upgrade_requested(weapon_id: String)

const PlatformCatalogScript := preload("res://game/platforms/platform_catalog.gd")
const PlatformModuleCatalogScript := preload("res://game/platforms/platform_module_catalog.gd")
const ThemeScript := preload("res://game/presentation/fort_knocks_theme.gd")
const ProductionUIScript := preload("res://game/presentation/production_ui.gd")
const WorkshopBoldFont := preload("res://assets/art/production/hub/reference_v1/fonts/BarlowCondensed-Bold.ttf")
const ScrapBolt := preload("res://game/weapons/scrap_bolt.tres")
const HeavySlug := preload("res://game/weapons/heavy_slug.tres")
const ShockCapsule := preload("res://game/weapons/shock_capsule.tres")

const WORKSHOP_ROOT := "res://assets/art/claude_assets/1_Asset_Kit/03_workshop"
const DISPLAY_PATHS := {
	"scrap_bolt": WORKSHOP_ROOT + "/png/art/ammo_standard_display.png",
	"heavy_slug": WORKSHOP_ROOT + "/png/art/ammo_heavy_display.png",
	"shock_capsule": WORKSHOP_ROOT + "/png/art/ammo_emp_display.png",
}
const THUMB_PATHS := {
	"scrap_bolt": WORKSHOP_ROOT + "/png/art/ammo_standard_thumb.png",
	"heavy_slug": WORKSHOP_ROOT + "/png/art/ammo_heavy_thumb.png",
	"shock_capsule": WORKSHOP_ROOT + "/png/art/ammo_emp_thumb.png",
}
const CLUSTER_THUMB := WORKSHOP_ROOT + "/png/art/ammo_cluster_thumb.png"

const ICON_DAMAGE := WORKSHOP_ROOT + "/png/icons/icon_stat_damage.png"
const ICON_EXPLOSION := WORKSHOP_ROOT + "/png/icons/icon_stat_explosion.png"
const ICON_RANGE := WORKSHOP_ROOT + "/png/icons/icon_stat_range.png"
const ICON_BOUNCE := WORKSHOP_ROOT + "/png/icons/icon_stat_bounce.png"

const PANEL_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/ui/panel_stats_9s.png"
const CARD_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/ui/card_item_9s.png"
const CARD_SELECTED_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/ui/card_item_selected_9s.png"
const SEG_EMPTY_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/ui/statbar_seg_empty_9s.png"
const SEG_FILLED_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/ui/statbar_seg_filled_9s.png"
const COIN_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/icons/icon_coin.png"
const LOCK_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/icons/icon_lock.png"

const SWIPE_MIN: float = 60.0
static var ACTIVE_ACCENT: Color = Color("42c7dc")
static var ACTIVE_DARK: Color = Color("101b24")

@onready var weapon_display: TextureRect = %WeaponDisplay
@onready var swipe_area: Control = %SwipeArea
@onready var title_label: Label = %WeaponTitle
@onready var status_label: Label = %WeaponStatus
@onready var active_toggle: Button = %ActiveToggle
@onready var rows: VBoxContainer = %Rows
@onready var action_button: Button = %ActionButton
@onready var action_label: Label = %ActionLabel
@onready var action_coin: TextureRect = %ActionCoin
@onready var action_cost: Label = %ActionCost
@onready var weapon_row: HBoxContainer = %WeaponRow
@onready var card_scroll: ScrollContainer = %CardScroll
@onready var prev_button: TextureButton = %PrevButton
@onready var next_button: TextureButton = %NextButton
@onready var back_button: TextureButton = %BackButton
@onready var notice_label: Label = %NoticeLabel
@onready var stats_panel: PanelContainer = %StatsPanel

@onready var module_button: Button = %ModuleButton
@onready var module_overlay: Control = %ModuleOverlay
@onready var module_panel: PanelContainer = %ModulePanel
@onready var module_display: WorkshopHardwareDisplay = %ModuleDisplay
@onready var module_row: HBoxContainer = %ModuleRow
@onready var module_note: Label = %ModuleNote
@onready var module_close: TextureButton = %ModuleClose

var _snapshot: Dictionary = {}
var _weapons: Array[WeaponDefinition] = []
var _selected_index: int = 0
var _weapon_cards: Dictionary = {}
var _swipe_start: Vector2 = Vector2.INF
var _upgrade_available: bool = false

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
	module_panel.add_theme_stylebox_override(
		"panel",
		ProductionUIScript.texture_box(
			PANEL_PATH,
			Vector4(27.0, 27.0, 27.0, 27.0),
			Color.WHITE,
			Vector4(24.0, 20.0, 24.0, 20.0)
		)
	)

	ProductionUIScript.style_action_button(action_button)
	_style_workshop_text()
	_style_active_toggle()
	action_coin.texture = ProductionUIScript.texture(COIN_PATH)
	_apply_back_safe_area()

	back_button.pressed.connect(func() -> void:
		_play_ui(&"ui_back")
		back_requested.emit()
	)
	prev_button.pressed.connect(_step.bind(-1))
	next_button.pressed.connect(_step.bind(1))
	action_button.pressed.connect(_request_upgrade)
	active_toggle.pressed.connect(_request_active_specialist)
	swipe_area.gui_input.connect(_on_swipe_input)

	module_button.pressed.connect(_open_modules)
	module_close.pressed.connect(_close_modules)

func configure(save_snapshot: Dictionary, notice := "") -> void:
	_snapshot = save_snapshot.duplicate(true)
	_weapons.clear()
	_weapons.append(ScrapBolt as WeaponDefinition)
	_weapons.append(HeavySlug as WeaponDefinition)
	_weapons.append(ShockCapsule as WeaponDefinition)

	_selected_index = 0
	notice_label.text = notice
	notice_label.visible = not notice.is_empty()

	_build_weapon_cards()
	_rebuild_modules()
	_show_selected(false)

func _step(direction: int) -> void:
	if _weapons.is_empty():
		return
	var next_index: int = clampi(_selected_index + direction, 0, _weapons.size() - 1)
	if next_index == _selected_index:
		return
	_selected_index = next_index
	_play_ui(&"ui_confirm")
	_show_selected()

func _show_selected(animate := true) -> void:
	if _weapons.is_empty():
		return

	var weapon: WeaponDefinition = _weapons[_selected_index]
	var inventory: Dictionary = _snapshot.get("inventory", {}) as Dictionary
	var specialist_id: String = str(inventory.get("specialist_weapon_id", "heavy_slug"))
	var full_rack_active: bool = _full_rack_active()
	var level: int = _weapon_level(weapon.id)

	title_label.text = weapon.display_name.to_upper()
	status_label.text = "LEVEL %d" % level
	weapon_display.texture = ProductionUIScript.texture(str(DISPLAY_PATHS.get(weapon.id, "")))

	var is_specialist: bool = weapon.id in ["heavy_slug", "shock_capsule"]
	active_toggle.visible = is_specialist
	if is_specialist:
		var is_active: bool = full_rack_active or weapon.id == specialist_id
		active_toggle.button_pressed = is_active
		active_toggle.disabled = is_active
		active_toggle.text = "✓" if is_active else "□"
		active_toggle.tooltip_text = (
			"Both specialists carried by Twin Field Rack"
			if full_rack_active
			else ("Active specialist" if is_active else "Set this specialist as active")
		)

	_rebuild_stats(weapon, level)
	_update_upgrade_action(weapon, level)

	prev_button.disabled = _selected_index == 0
	next_button.disabled = _selected_index == _weapons.size() - 1

	for weapon_id in _weapon_cards.keys():
		var card: Button = _weapon_cards[weapon_id] as Button
		_set_card_selected(card, str(weapon_id) == weapon.id)

	if _weapon_cards.has(weapon.id):
		card_scroll.ensure_control_visible.call_deferred(_weapon_cards[weapon.id])

	if animate:
		weapon_display.pivot_offset = weapon_display.size * 0.5
		weapon_display.modulate.a = 0.0
		weapon_display.scale = Vector2(0.94, 0.94)
		var tween: Tween = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(weapon_display, "modulate:a", 1.0, 0.18)
		tween.tween_property(weapon_display, "scale", Vector2.ONE, 0.22)

func _update_upgrade_action(weapon: WeaponDefinition, level: int) -> void:
	var inventory: Dictionary = _snapshot.get("inventory", {}) as Dictionary
	var salvage: int = int(inventory.get("salvage", 0))

	_upgrade_available = false
	action_coin.visible = false
	action_cost.visible = false
	action_button.disabled = false

	if level >= weapon.max_level:
		action_label.text = "MAX LEVEL"
		action_button.disabled = true
		return

	var cost: int = weapon.upgrade_cost(level)
	action_label.text = "UPGRADE"
	action_coin.visible = true
	action_cost.visible = true
	action_cost.text = _format_number(cost)
	if salvage >= cost:
		_upgrade_available = true
	else:
		action_button.disabled = true

func _request_upgrade() -> void:
	if _weapons.is_empty() or not _upgrade_available:
		return
	weapon_upgrade_requested.emit(_weapons[_selected_index].id)

func _request_active_specialist() -> void:
	if _weapons.is_empty() or active_toggle.disabled:
		return
	var weapon: WeaponDefinition = _weapons[_selected_index]
	if weapon.id in ["heavy_slug", "shock_capsule"]:
		specialist_weapon_requested.emit(weapon.id)

func _rebuild_stats(weapon: WeaponDefinition, level: int) -> void:
	for child in rows.get_children():
		child.queue_free()

	var effective: WeaponDefinition = weapon.copy_at_level(level)
	var damage: int = clampi(int(ceil(float(effective.direct_damage) / 25.0)), 1, 4)
	var explosion: int = 0
	if effective.blast_radius > 0.0:
		explosion = clampi(int(ceil(float(effective.blast_damage) / 20.0)), 1, 4)
	var range_level: int = clampi(int(round(effective.speed_multiplier * 2.0)), 1, 4)
	var bounce: int = clampi(effective.max_ground_bounces, 0, 4)

	_add_stat_row("DAMAGE", ICON_DAMAGE, damage)
	_add_stat_row("EXPLOSION", ICON_EXPLOSION, explosion)
	_add_stat_row("RANGE", ICON_RANGE, range_level)
	_add_stat_row("BOUNCE", ICON_BOUNCE, bounce)

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
	label.custom_minimum_size = Vector2(158.0, 0.0)
	label.text = label_text
	label.add_theme_font_override("font", WorkshopBoldFont)
	label.add_theme_font_size_override("font_size", 26)
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 0)
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

func _build_weapon_cards() -> void:
	for child in weapon_row.get_children():
		child.queue_free()
	_weapon_cards.clear()

	var inventory: Dictionary = _snapshot.get("inventory", {}) as Dictionary
	var specialist_id: String = str(inventory.get("specialist_weapon_id", "heavy_slug"))
	var full_rack_active: bool = _full_rack_active()

	_add_weapon_card(ScrapBolt as WeaponDefinition, "Standard", false, false)
	_add_weapon_card(
		HeavySlug as WeaponDefinition,
		"Heavy",
		full_rack_active or specialist_id == "heavy_slug",
		false
	)
	_add_cluster_card()
	_add_weapon_card(
		ShockCapsule as WeaponDefinition,
		"EMP",
		full_rack_active or specialist_id == "shock_capsule",
		false
	)

func _add_weapon_card(
	weapon: WeaponDefinition,
	caption_text: String,
	is_active: bool,
	is_locked: bool
) -> void:
	var card := Button.new()
	card.custom_minimum_size = Vector2(152.0, 188.0)
	card.focus_mode = Control.FOCUS_NONE
	card.flat = true
	card.clip_contents = false
	card.disabled = is_locked
	card.pressed.connect(_select_weapon_id.bind(weapon.id))

	_add_card_surfaces(card, is_active)

	var thumb := TextureRect.new()
	thumb.texture = ProductionUIScript.texture(str(THUMB_PATHS.get(weapon.id, "")))
	thumb.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	thumb.anchor_left = 0.08
	thumb.anchor_top = 0.04
	thumb.anchor_right = 0.92
	thumb.anchor_bottom = 0.74
	thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(thumb)

	_add_card_caption(card, caption_text)

	if is_active:
		_add_active_badge(card)

	weapon_row.add_child(card)
	_weapon_cards[weapon.id] = card

func _add_cluster_card() -> void:
	var card := Button.new()
	card.custom_minimum_size = Vector2(152.0, 188.0)
	card.focus_mode = Control.FOCUS_NONE
	card.flat = true
	card.clip_contents = false
	card.disabled = true
	card.tooltip_text = "Cluster ammunition is not yet available"

	_add_card_surfaces(card, false)

	var thumb := TextureRect.new()
	thumb.texture = ProductionUIScript.texture(CLUSTER_THUMB)
	thumb.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	thumb.anchor_left = 0.08
	thumb.anchor_top = 0.04
	thumb.anchor_right = 0.92
	thumb.anchor_bottom = 0.74
	thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	thumb.modulate = Color(0.72, 0.74, 0.76, 1.0)
	thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(thumb)

	_add_card_caption(card, "Cluster")

	var lock := TextureRect.new()
	lock.texture = ProductionUIScript.texture(LOCK_PATH)
	lock.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	lock.anchor_left = 0.5
	lock.anchor_top = 0.5
	lock.anchor_right = 0.5
	lock.anchor_bottom = 0.5
	lock.offset_left = -25.0
	lock.offset_top = -20.0
	lock.offset_right = 25.0
	lock.offset_bottom = 42.0
	lock.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	lock.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(lock)

	weapon_row.add_child(card)

func _add_card_surfaces(card: Button, is_active: bool) -> void:
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
	selected.visible = false
	card.add_child(selected)

func _add_card_caption(card: Button, text_value: String) -> void:
	var caption := Label.new()
	caption.anchor_left = 0.0
	caption.anchor_top = 0.73
	caption.anchor_right = 1.0
	caption.anchor_bottom = 1.0
	caption.offset_left = 4.0
	caption.offset_right = -4.0
	caption.text = text_value
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caption.add_theme_font_override("font", WorkshopBoldFont)
	caption.add_theme_color_override("font_color", Color(0.95, 0.96, 0.965, 1))
	caption.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	caption.add_theme_constant_override("shadow_offset_x", 0)
	caption.add_theme_constant_override("shadow_offset_y", 0)
	caption.add_theme_font_size_override("font_size", 21)
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(caption)

func _add_active_badge(card: Button) -> void:
	var badge := Panel.new()
	badge.position = Vector2(116.0, 9.0)
	badge.size = Vector2(27.0, 27.0)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_theme_stylebox_override("panel", _active_badge_style())

	var tick := Label.new()
	tick.set_anchors_preset(Control.PRESET_FULL_RECT)
	tick.text = "✓"
	tick.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tick.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tick.add_theme_font_override("font", WorkshopBoldFont)
	tick.add_theme_color_override("font_color", ACTIVE_ACCENT)
	tick.add_theme_font_size_override("font_size", 18)
	tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_child(tick)
	card.add_child(badge)

func _set_card_selected(card: Button, selected: bool) -> void:
	var normal: CanvasItem = card.get_node_or_null("_Frame") as CanvasItem
	var glow: CanvasItem = card.get_node_or_null("_SelectedFrame") as CanvasItem
	if normal != null:
		normal.visible = not selected
	if glow != null:
		glow.visible = selected

func _select_weapon_id(weapon_id: String) -> void:
	for i in range(_weapons.size()):
		if _weapons[i].id == weapon_id:
			_selected_index = i
			_play_ui(&"ui_confirm")
			_show_selected()
			return

func _weapon_level(weapon_id: String) -> int:
	var inventory: Dictionary = _snapshot.get("inventory", {}) as Dictionary
	var levels: Dictionary = inventory.get("weapon_levels", {}) as Dictionary
	return clampi(int(levels.get(weapon_id, 1)), 1, 4)

func _rebuild_modules() -> void:
	for child in module_row.get_children():
		child.queue_free()

	var inventory: Dictionary = _snapshot.get("inventory", {}) as Dictionary
	var platform_id: String = str(inventory.get("platform_id", "run_down_compact"))
	var platform: CombatPlatformDefinition = PlatformCatalogScript.by_id(platform_id)
	var equipped: Dictionary = inventory.get("equipped_module_by_platform", {}) as Dictionary
	var active_module_id: String = str(equipped.get(platform_id, ""))
	module_display.configure_module(active_module_id)

	if platform == null or platform.utility_slot_count <= 0:
		module_button.visible = false
		return

	var modules: Array[PlatformModuleDefinition] = PlatformModuleCatalogScript.for_platform(platform_id)
	module_button.visible = not modules.is_empty()
	if modules.is_empty():
		return

	var owned: Array = inventory.get("owned_module_ids", []) as Array
	var salvage: int = int(inventory.get("salvage", 0))
	module_note.text = "%s • PLATFORM MODULES" % platform.display_name.to_upper()

	for definition in modules:
		var is_owned: bool = owned.has(definition.id)
		var is_active: bool = active_module_id == definition.id

		var button := Button.new()
		button.custom_minimum_size = Vector2(170.0, 62.0)
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_override("font", WorkshopBoldFont)
		button.add_theme_font_size_override("font_size", 13)
		ProductionUIScript.style_card_button(button, is_active)

		if is_active:
			button.text = "%s\nACTIVE" % definition.display_name.to_upper()
			button.disabled = true
		elif is_owned:
			button.text = "%s\nEQUIP" % definition.display_name.to_upper()
			button.pressed.connect(_request_module.bind(definition.id))
		elif salvage >= definition.purchase_cost:
			button.text = "%s\nBUILD • %d" % [definition.display_name.to_upper(), definition.purchase_cost]
			button.pressed.connect(_request_module.bind(definition.id))
		else:
			button.text = "%s\nNEED %d" % [definition.display_name.to_upper(), definition.purchase_cost]
			button.disabled = true

		module_row.add_child(button)

func _request_module(module_id: String) -> void:
	module_requested.emit(module_id)

func _open_modules() -> void:
	module_overlay.visible = true

func _close_modules() -> void:
	module_overlay.visible = false

func _full_rack_active() -> bool:
	var inventory: Dictionary = _snapshot.get("inventory", {}) as Dictionary
	var platform_id: String = str(inventory.get("platform_id", "run_down_compact"))
	var equipped: Dictionary = inventory.get("equipped_module_by_platform", {}) as Dictionary
	var active_module_id: String = str(equipped.get(platform_id, ""))
	if active_module_id.is_empty():
		return false
	var active_module: PlatformModuleDefinition = PlatformModuleCatalogScript.by_id(active_module_id)
	return active_module != null and active_module.carry_both_specialists

func _style_workshop_text() -> void:
	for label in [action_label, action_cost]:
		label.add_theme_font_override("font", WorkshopBoldFont)
		label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
		label.add_theme_constant_override("shadow_offset_x", 0)
		label.add_theme_constant_override("shadow_offset_y", 0)

func _style_active_toggle() -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.035, 0.065, 0.085, 0.92)
	normal.border_color = Color(0.32, 0.40, 0.46, 1.0)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(7)

	var hover: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	hover.border_color = ACTIVE_ACCENT.darkened(0.15)

	var active: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
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
	style.set_corner_radius_all(14)
	return style

func _active_badge_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = ACTIVE_DARK
	style.border_color = ACTIVE_ACCENT
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
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
		module_button.position.y += inset

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
