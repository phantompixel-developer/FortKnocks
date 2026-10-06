class_name WorkshopScreen
extends Control

signal back_requested
signal module_requested(module_id: String)
signal specialist_weapon_requested(weapon_id: String)

const PlatformModuleCatalogScript := preload("res://game/platforms/platform_module_catalog.gd")
const PlatformCatalogScript := preload("res://game/platforms/platform_catalog.gd")
const ThemeScript := preload("res://game/presentation/fort_knocks_theme.gd")
const ProductionUIScript := preload("res://game/presentation/production_ui.gd")
const ScrapBolt := preload("res://game/weapons/scrap_bolt.tres")
const HeavySlug := preload("res://game/weapons/heavy_slug.tres")
const ShockCapsule := preload("res://game/weapons/shock_capsule.tres")

const PANEL_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/ui/panel_stats_9s.png"
const COIN_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/icons/icon_coin.png"
const LOCK_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/icons/icon_lock.png"
const WORKSHOP_ART_ROOT := "res://assets/art/claude_assets/1_Asset_Kit/03_workshop/png/art"

const DISPLAY_PATHS := {
	"scrap_bolt": WORKSHOP_ART_ROOT + "/ammo_standard_display.png",
	"heavy_slug": WORKSHOP_ART_ROOT + "/ammo_heavy_display.png",
	"shock_capsule": WORKSHOP_ART_ROOT + "/ammo_emp_display.png",
}
const THUMB_PATHS := {
	"scrap_bolt": WORKSHOP_ART_ROOT + "/ammo_standard_thumb.png",
	"heavy_slug": WORKSHOP_ART_ROOT + "/ammo_heavy_thumb.png",
	"shock_capsule": WORKSHOP_ART_ROOT + "/ammo_emp_thumb.png",
}

@onready var safe: MarginContainer = %Safe
@onready var salvage_label: Label = %SalvageLabel
@onready var weapon_display: TextureRect = %WeaponDisplay
@onready var title_label: Label = %WeaponTitle
@onready var status_label: Label = %WeaponStatus
@onready var description_label: Label = %Description
@onready var stat_rows: VBoxContainer = %StatRows
@onready var weapon_row: HBoxContainer = %WeaponRow
@onready var action_button: Button = %ActionButton
@onready var prev_button: TextureButton = %PrevButton
@onready var next_button: TextureButton = %NextButton
@onready var module_display: WorkshopHardwareDisplay = %ModuleDisplay
@onready var module_row: HBoxContainer = %ModuleRow
@onready var module_note: Label = %ModuleNote
@onready var notice_label: Label = %NoticeLabel
@onready var back_button: TextureButton = %BackButton

var _snapshot: Dictionary = {}
var _weapons: Array[WeaponDefinition] = []
var _selected_index := 1
var _weapon_cards: Array[Button] = []

func _ready() -> void:
	ThemeScript.apply(self)
	ProductionUIScript.apply_safe_area(safe)
	%StatsPanel.add_theme_stylebox_override(
		"panel",
		ProductionUIScript.texture_box(PANEL_PATH, Vector4(40.0, 40.0, 40.0, 40.0))
	)
	%ModulePanel.add_theme_stylebox_override(
		"panel",
		ProductionUIScript.texture_box(PANEL_PATH, Vector4(40.0, 40.0, 40.0, 40.0), Color(0.88, 0.92, 0.94, 0.96))
	)
	ProductionUIScript.style_action_button(action_button)
	%Coin.texture = ProductionUIScript.texture(COIN_PATH)
	back_button.pressed.connect(func() -> void:
		_play_ui(&"ui_back")
		back_requested.emit()
	)
	prev_button.pressed.connect(_step.bind(-1))
	next_button.pressed.connect(_step.bind(1))
	action_button.pressed.connect(_request_selected_weapon)

func configure(save_snapshot: Dictionary, notice := "") -> void:
	_snapshot = save_snapshot.duplicate(true)
	_weapons.clear()
	_weapons.append(ScrapBolt as WeaponDefinition)
	_weapons.append(HeavySlug as WeaponDefinition)
	_weapons.append(ShockCapsule as WeaponDefinition)

	var inventory := _snapshot.get("inventory", {}) as Dictionary
	var specialist_id := str(inventory.get("specialist_weapon_id", "heavy_slug"))
	_selected_index = 1 if specialist_id == "heavy_slug" else 2
	salvage_label.text = "%d" % int(inventory.get("salvage", 0))
	notice_label.text = notice
	notice_label.visible = not notice.is_empty()
	_build_weapon_cards()
	_rebuild_modules()
	_show_selected(false)

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
	status_label.text = _weapon_status(weapon.id, specialist_id, full_rack_active)
	description_label.text = weapon.description
	weapon_display.texture = ProductionUIScript.texture(str(DISPLAY_PATHS.get(weapon.id, "")))
	_rebuild_weapon_stats(weapon)
	_update_weapon_action(weapon.id, specialist_id, full_rack_active)
	prev_button.disabled = _selected_index <= 0
	next_button.disabled = _selected_index >= _weapons.size() - 1

	for i in range(_weapon_cards.size()):
		ProductionUIScript.style_card_button(_weapon_cards[i], i == _selected_index)

	if animate:
		weapon_display.pivot_offset = weapon_display.size * 0.5
		weapon_display.modulate.a = 0.0
		weapon_display.scale = Vector2(0.94, 0.94)
		var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(weapon_display, "modulate:a", 1.0, 0.16)
		tween.tween_property(weapon_display, "scale", Vector2.ONE, 0.20)

func _weapon_status(weapon_id: String, specialist_id: String, full_rack_active: bool) -> String:
	if weapon_id == "scrap_bolt":
		return "CORE ROUND • ALWAYS CARRIED"
	if full_rack_active:
		return "TWIN FIELD RACK • CARRIED"
	if weapon_id == specialist_id:
		return "ACTIVE SPECIALIST"
	return "AVAILABLE SPECIALIST"

func _update_weapon_action(weapon_id: String, specialist_id: String, full_rack_active: bool) -> void:
	action_button.disabled = true
	if weapon_id == "scrap_bolt":
		action_button.text = "CORE ROUND • ALWAYS CARRIED"
	elif full_rack_active:
		action_button.text = "CARRIED BY TWIN FIELD RACK"
	elif weapon_id == specialist_id:
		action_button.text = "ACTIVE SPECIALIST"
	else:
		action_button.text = "EQUIP SPECIALIST"
		action_button.disabled = false

func _request_selected_weapon() -> void:
	if _weapons.is_empty() or action_button.disabled:
		return
	var weapon := _weapons[_selected_index]
	if weapon.id == "heavy_slug" or weapon.id == "shock_capsule":
		specialist_weapon_requested.emit(weapon.id)

func _rebuild_weapon_stats(weapon: WeaponDefinition) -> void:
	for child in stat_rows.get_children():
		child.queue_free()

	_add_stat_row(
		"DAMAGE",
		str(weapon.direct_damage),
		clampi(int(ceil(float(weapon.direct_damage) / 15.0)), 1, 4)
	)
	_add_stat_row(
		"COVER",
		str(weapon.cover_damage),
		clampi(int(ceil(float(weapon.cover_damage) / 23.0)), 1, 4)
	)
	_add_stat_row(
		"FORCE",
		str(int(weapon.knockback_force)),
		clampi(int(ceil(weapon.knockback_force / 200.0)), 1, 4)
	)

	if weapon.max_ground_bounces > 0:
		_add_stat_row("BOUNCE", "%d×" % weapon.max_ground_bounces, clampi(weapon.max_ground_bounces, 1, 4))
	elif weapon.blast_radius > 0.0:
		_add_stat_row("BLAST", str(int(weapon.blast_radius)), clampi(int(ceil(weapon.blast_radius / 55.0)), 1, 4))
	else:
		var speed_fill := clampi(int(round(weapon.speed_multiplier * 3.0)), 1, 4)
		_add_stat_row("FLIGHT", "×%.2f" % weapon.speed_multiplier, speed_fill)

func _add_stat_row(label_text: String, value_text: String, filled: int) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0.0, 30.0)
	row.add_theme_constant_override("separation", 8)

	var label := Label.new()
	label.custom_minimum_size = Vector2(88.0, 0.0)
	label.text = label_text
	label.add_theme_font_size_override("font_size", 14)
	row.add_child(label)

	var segments := HBoxContainer.new()
	segments.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	segments.add_theme_constant_override("separation", 4)
	row.add_child(segments)
	ProductionUIScript.rebuild_segments(segments, filled, 4)

	var value := Label.new()
	value.custom_minimum_size = Vector2(72.0, 0.0)
	value.text = value_text
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value.add_theme_font_size_override("font_size", 13)
	row.add_child(value)
	stat_rows.add_child(row)

func _build_weapon_cards() -> void:
	for child in weapon_row.get_children():
		child.queue_free()
	_weapon_cards.clear()

	for i in range(_weapons.size()):
		var weapon := _weapons[i]
		var button := Button.new()
		button.custom_minimum_size = Vector2(182.0, 112.0)
		button.clip_contents = true
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(_select_weapon_card.bind(i))
		ProductionUIScript.style_card_button(button, i == _selected_index)

		var art := TextureRect.new()
		art.texture = ProductionUIScript.texture(str(THUMB_PATHS.get(weapon.id, "")))
		art.anchor_left = 0.06
		art.anchor_top = 0.04
		art.anchor_right = 0.94
		art.anchor_bottom = 0.72
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(art)

		var label := Label.new()
		label.anchor_left = 0.0
		label.anchor_top = 0.72
		label.anchor_right = 1.0
		label.anchor_bottom = 1.0
		label.offset_left = 8.0
		label.offset_right = -8.0
		label.text = weapon.display_name.to_upper()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 13)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(label)

		weapon_row.add_child(button)
		_weapon_cards.append(button)

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
		module_note.text = "CURRENT PLATFORM HAS NO UTILITY MOUNT"
		return

	var modules := PlatformModuleCatalogScript.for_platform(platform_id)
	if modules.is_empty():
		module_note.text = "NO MODULES AVAILABLE FOR THIS PLATFORM"
		return

	var owned := inventory.get("owned_module_ids", []) as Array
	var salvage := int(inventory.get("salvage", 0))
	module_note.text = "%s • %d UTILITY SLOT" % [platform.display_name.to_upper(), platform.utility_slot_count]

	for definition in modules:
		var is_owned := owned.has(definition.id)
		var is_active := active_module_id == definition.id
		var button := Button.new()
		button.custom_minimum_size = Vector2(220.0, 66.0)
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 12)
		ProductionUIScript.style_card_button(button, is_active)

		if is_active:
			button.text = "%s
ACTIVE" % definition.display_name.to_upper()
			button.disabled = true
		elif is_owned:
			button.text = "%s
EQUIP" % definition.display_name.to_upper()
			button.pressed.connect(_request_module.bind(definition.id))
		elif salvage >= definition.purchase_cost:
			button.text = "%s
BUILD • %d" % [definition.display_name.to_upper(), definition.purchase_cost]
			button.pressed.connect(_request_module.bind(definition.id))
		else:
			button.text = "%s
NEED %d SALVAGE" % [definition.display_name.to_upper(), definition.purchase_cost]
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

func _play_ui(cue: StringName) -> void:
	var audio := get_tree().get_first_node_in_group("fort_knocks_audio")
	if audio != null and audio.has_method("play_cue"):
		audio.call("play_cue", cue)
