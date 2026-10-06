class_name WorkshopScreen
extends Control

signal back_requested
signal module_requested(module_id: String)
signal specialist_weapon_requested(weapon_id: String)

const PlatformCatalogScript := preload("res://game/platforms/platform_catalog.gd")
const PlatformModuleCatalogScript := preload("res://game/platforms/platform_module_catalog.gd")
const ThemeScript := preload("res://game/presentation/fort_knocks_theme.gd")
const ProductionUIScript := preload("res://game/presentation/production_ui.gd")
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

const SWIPE_MIN := 60.0

@onready var safe: MarginContainer = %Safe
@onready var showroom: Control = %Showroom
@onready var weapon_display: TextureRect = %WeaponDisplay
@onready var swipe_area: Control = %SwipeArea
@onready var title_label: Label = %WeaponTitle
@onready var status_label: Label = %WeaponStatus
@onready var rows: VBoxContainer = %Rows
@onready var action_button: Button = %ActionButton
@onready var action_label: Label = %ActionLabel
@onready var action_coin: TextureRect = %ActionCoin
@onready var action_cost: Label = %ActionCost
@onready var weapon_row: HBoxContainer = %WeaponRow
@onready var card_scroll: ScrollContainer = %CardScroll
@onready var module_panel: PanelContainer = %ModulePanel
@onready var module_display: WorkshopHardwareDisplay = %ModuleDisplay
@onready var module_row: HBoxContainer = %ModuleRow
@onready var module_note: Label = %ModuleNote
@onready var prev_button: TextureButton = %PrevButton
@onready var next_button: TextureButton = %NextButton
@onready var back_button: TextureButton = %BackButton
@onready var notice_label: Label = %NoticeLabel

var _snapshot: Dictionary = {}
var _weapons: Array[WeaponDefinition] = []
var _selected_index := 0
var _weapon_cards: Array[Button] = []
var _swipe_start := Vector2.INF

func _ready() -> void:
	ThemeScript.apply(self)
	ProductionUIScript.apply_safe_area(safe, Vector4(24.0, 26.0, 24.0, 13.0))

	var panel_style := ProductionUIScript.texture_box(
		PANEL_PATH,
		Vector4(27.0, 27.0, 27.0, 27.0),
		Color.WHITE,
		Vector4(29.0, 22.0, 29.0, 20.0)
	)
	%StatsPanel.add_theme_stylebox_override("panel", panel_style)
	module_panel.add_theme_stylebox_override(
		"panel",
		ProductionUIScript.texture_box(
			PANEL_PATH,
			Vector4(27.0, 27.0, 27.0, 27.0),
			Color(0.92, 0.94, 0.96, 0.96),
			Vector4(14.0, 10.0, 14.0, 10.0)
		)
	)
	ProductionUIScript.style_action_button(action_button)
	action_coin.texture = ProductionUIScript.texture(COIN_PATH)

	back_button.pressed.connect(func() -> void:
		_play_ui(&"ui_back")
		back_requested.emit()
	)
	prev_button.pressed.connect(_step.bind(-1))
	next_button.pressed.connect(_step.bind(1))
	action_button.pressed.connect(_request_selected_weapon)
	swipe_area.gui_input.connect(_on_swipe_input)

	resized.connect(_sync_showroom)
	%Header.item_rect_changed.connect(_sync_showroom)
	_sync_showroom.call_deferred()

func configure(save_snapshot: Dictionary, notice := "") -> void:
	_snapshot = save_snapshot.duplicate(true)
	_weapons.clear()
	_weapons.append(ScrapBolt as WeaponDefinition)
	_weapons.append(HeavySlug as WeaponDefinition)
	_weapons.append(ShockCapsule as WeaponDefinition)

	var inventory := _snapshot.get("inventory", {}) as Dictionary
	var specialist_id := str(inventory.get("specialist_weapon_id", "heavy_slug"))
	_selected_index = 1 if specialist_id == "heavy_slug" else 2

	notice_label.text = notice
	notice_label.visible = not notice.is_empty()
	_build_weapon_cards()
	_rebuild_modules()
	_show_selected(false)

func _sync_showroom() -> void:
	if not is_node_ready():
		return
	var target_bottom := %Header.global_position.y - global_position.y + 48.0
	var reference_height := 656.0
	showroom.size = Vector2(size.x, maxf(target_bottom, 430.0))
	var scale_up := maxf(showroom.size.y / reference_height, 1.0)
	if scale_up > 1.0:
		var base_width := showroom.size.x * 0.70
		var grow := (base_width * scale_up - base_width) * 0.5
		weapon_display.offset_left = -grow
		weapon_display.offset_right = grow

func _step(direction: int) -> void:
	if _weapons.is_empty():
		return
	var next_index := clampi(_selected_index + direction, 0, _weapons.size() - 1)
	if next_index == _selected_index:
		return
	_selected_index = next_index
	_play_ui(&"ui_confirm")
	_show_selected()

func _show_selected(animate := true) -> void:
	if _weapons.is_empty():
		return

	var weapon := _weapons[_selected_index]
	var inventory := _snapshot.get("inventory", {}) as Dictionary
	var specialist_id := str(inventory.get("specialist_weapon_id", "heavy_slug"))
	var full_rack_active := _full_rack_active()

	title_label.text = weapon.display_name.to_upper()
	weapon_display.texture = ProductionUIScript.texture(str(DISPLAY_PATHS.get(weapon.id, "")))
	_rebuild_stats(weapon)
	_update_action(weapon.id, specialist_id, full_rack_active)

	prev_button.disabled = _selected_index == 0
	next_button.disabled = _selected_index == _weapons.size() - 1

	for i in range(_weapon_cards.size()):
		_set_card_selected(_weapon_cards[i], i == _selected_index)
	if _selected_index < _weapon_cards.size():
		card_scroll.ensure_control_visible.call_deferred(_weapon_cards[_selected_index])

	if animate:
		weapon_display.pivot_offset = weapon_display.size * 0.5
		weapon_display.modulate.a = 0.0
		weapon_display.scale = Vector2(0.94, 0.94)
		var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(weapon_display, "modulate:a", 1.0, 0.18)
		tween.tween_property(weapon_display, "scale", Vector2.ONE, 0.22)

func _update_action(weapon_id: String, specialist_id: String, full_rack_active: bool) -> void:
	action_coin.visible = false
	action_cost.visible = false
	action_button.disabled = true

	if weapon_id == "scrap_bolt":
		status_label.text = "CORE ROUND"
		action_label.text = "ALWAYS CARRIED"
	elif full_rack_active:
		status_label.text = "TWIN FIELD RACK"
		action_label.text = "CARRIED"
	elif weapon_id == specialist_id:
		status_label.text = "ACTIVE SPECIALIST"
		action_label.text = "ACTIVE"
	else:
		status_label.text = "SPECIALIST ROUND"
		action_label.text = "EQUIP"
		action_button.disabled = false

func _request_selected_weapon() -> void:
	if _weapons.is_empty() or action_button.disabled:
		return
	var id := _weapons[_selected_index].id
	if id == "heavy_slug" or id == "shock_capsule":
		specialist_weapon_requested.emit(id)

func _rebuild_stats(weapon: WeaponDefinition) -> void:
	for child in rows.get_children():
		if child != action_button:
			child.queue_free()

	var damage := clampi(int(ceil(float(weapon.direct_damage) / 15.0)), 1, 4)
	var explosion := 0
	if weapon.blast_radius > 0.0:
		explosion = clampi(int(ceil(weapon.blast_radius / 55.0)), 1, 4)
	var range_level := clampi(int(round(weapon.speed_multiplier * 2.5)), 1, 4)
	var bounce := clampi(weapon.max_ground_bounces, 0, 4)

	_add_stat_row("DAMAGE", ICON_DAMAGE, damage, action_button.get_index())
	_add_stat_row("EXPLOSION", ICON_EXPLOSION, explosion, action_button.get_index())
	_add_stat_row("RANGE", ICON_RANGE, range_level, action_button.get_index())
	_add_stat_row("BOUNCE", ICON_BOUNCE, bounce, action_button.get_index())

func _add_stat_row(label_text: String, icon_path: String, filled: int, insert_index: int) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0.0, 38.0)
	row.add_theme_constant_override("separation", 12)

	var icon := TextureRect.new()
	icon.texture = ProductionUIScript.texture(icon_path)
	icon.custom_minimum_size = Vector2(38.0, 38.0)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(icon)

	var label := Label.new()
	label.custom_minimum_size = Vector2(150.0, 0.0)
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
	rows.move_child(row, insert_index)

func _build_weapon_cards() -> void:
	for child in weapon_row.get_children():
		child.queue_free()
	_weapon_cards.clear()

	for i in range(_weapons.size()):
		var weapon := _weapons[i]

		var card := Button.new()
		card.custom_minimum_size = Vector2(152.0, 188.0)
		card.focus_mode = Control.FOCUS_NONE
		card.flat = true
		card.clip_contents = false
		card.pressed.connect(_select_weapon_card.bind(i))

		var frame := NinePatchRect.new()
		frame.name = "_Frame"
		frame.texture = ProductionUIScript.texture(CARD_PATH)
		frame.set_anchors_preset(Control.PRESET_FULL_RECT)
		frame.patch_margin_left = 20
		frame.patch_margin_top = 20
		frame.patch_margin_right = 20
		frame.patch_margin_bottom = 20
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(frame)

		var selected := NinePatchRect.new()
		selected.name = "_SelectedFrame"
		selected.texture = ProductionUIScript.texture(CARD_SELECTED_PATH)
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

		var thumb := TextureRect.new()
		thumb.texture = ProductionUIScript.texture(str(THUMB_PATHS.get(weapon.id, "")))
		thumb.anchor_left = 0.08
		thumb.anchor_top = 0.04
		thumb.anchor_right = 0.92
		thumb.anchor_bottom = 0.72
		thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(thumb)

		var caption := Label.new()
		caption.anchor_left = 0.0
		caption.anchor_top = 0.72
		caption.anchor_right = 1.0
		caption.anchor_bottom = 1.0
		caption.offset_left = 4.0
		caption.offset_right = -4.0
		caption.text = weapon.display_name
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		caption.add_theme_color_override("font_color", Color(0.95, 0.96, 0.965, 1))
		caption.add_theme_font_size_override("font_size", 21)
		caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(caption)

		weapon_row.add_child(card)
		_weapon_cards.append(card)

func _set_card_selected(card: Button, selected: bool) -> void:
	var normal := card.get_node_or_null("_Frame") as CanvasItem
	var glow := card.get_node_or_null("_SelectedFrame") as CanvasItem
	if normal != null:
		normal.visible = not selected
	if glow != null:
		glow.visible = selected

func _select_weapon_card(index: int) -> void:
	if index < 0 or index >= _weapons.size():
		return
	_selected_index = index
	_play_ui(&"ui_confirm")
	_show_selected()

func _rebuild_modules() -> void:
	for child in module_row.get_children():
		child.queue_free()

	var inventory := _snapshot.get("inventory", {}) as Dictionary
	var platform_id := str(inventory.get("platform_id", "run_down_compact"))
	var platform := PlatformCatalogScript.by_id(platform_id)
	var equipped := inventory.get("equipped_module_by_platform", {}) as Dictionary
	var active_module_id := str(equipped.get(platform_id, ""))
	module_display.configure_module(active_module_id)

	if platform == null or platform.utility_slot_count <= 0:
		module_panel.visible = false
		return

	var modules := PlatformModuleCatalogScript.for_platform(platform_id)
	module_panel.visible = not modules.is_empty()
	if modules.is_empty():
		return

	var owned := inventory.get("owned_module_ids", []) as Array
	var salvage := int(inventory.get("salvage", 0))
	module_note.text = "%s • PLATFORM MODULE" % platform.display_name.to_upper()

	for definition in modules:
		var is_owned := owned.has(definition.id)
		var is_active := active_module_id == definition.id

		var button := Button.new()
		button.custom_minimum_size = Vector2(150.0, 58.0)
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 12)
		ProductionUIScript.style_card_button(button, is_active)

		if is_active:
			button.text = "%s\nACTIVE" % definition.display_name.to_upper()
			button.disabled = true
		elif is_owned:
			button.text = "%s\nEQUIP" % definition.display_name.to_upper()
			button.pressed.connect(_request_module.bind(definition.id))
		elif salvage >= definition.purchase_cost:
			button.text = "%s\nBUILD %d" % [definition.display_name.to_upper(), definition.purchase_cost]
			button.pressed.connect(_request_module.bind(definition.id))
		else:
			button.text = "%s\nNEED %d" % [definition.display_name.to_upper(), definition.purchase_cost]
			button.disabled = true
		module_row.add_child(button)

func _request_module(module_id: String) -> void:
	module_requested.emit(module_id)

func _full_rack_active() -> bool:
	var inventory := _snapshot.get("inventory", {}) as Dictionary
	var platform_id := str(inventory.get("platform_id", "run_down_compact"))
	var equipped := inventory.get("equipped_module_by_platform", {}) as Dictionary
	var active_module_id := str(equipped.get(platform_id, ""))
	var active_module: PlatformModuleDefinition = PlatformModuleCatalogScript.by_id(active_module_id) if not active_module_id.is_empty() else null
	return active_module != null and active_module.carry_both_specialists

func _on_swipe_input(event: InputEvent) -> void:
	var pressed := false
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

func _play_ui(cue: StringName) -> void:
	var audio := get_tree().get_first_node_in_group("fort_knocks_audio")
	if audio != null and audio.has_method("play_cue"):
		audio.call("play_cue", cue)
