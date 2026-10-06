class_name GarageScreen
extends Control

signal back_requested
signal platform_requested(platform_id: String)

const PlatformCatalogScript := preload("res://game/platforms/platform_catalog.gd")
const ThemeScript := preload("res://game/presentation/fort_knocks_theme.gd")
const ProductionUIScript := preload("res://game/presentation/production_ui.gd")

const GARAGE_ROOT := "res://assets/art/claude_assets/1_Asset_Kit/02_garage/png/icons"
const ICON_ARMOUR := GARAGE_ROOT + "/icon_stat_armour.png"
const ICON_SPEED := GARAGE_ROOT + "/icon_stat_speed.png"
const ICON_FUEL := GARAGE_ROOT + "/icon_stat_fuel.png"
const ICON_LOAD := GARAGE_ROOT + "/icon_stat_load.png"
const PANEL_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/ui/panel_stats_9s.png"
const CARD_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/ui/card_item_9s.png"
const CARD_SELECTED_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/ui/card_item_selected_9s.png"
const LOCK_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/icons/icon_lock.png"
const COIN_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/icons/icon_coin.png"
const SEG_EMPTY_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/ui/statbar_seg_empty_9s.png"
const SEG_FILLED_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/ui/statbar_seg_filled_9s.png"

const SWIPE_MIN := 60.0

@onready var safe: MarginContainer = %Safe
@onready var showroom: Control = %Showroom
@onready var platform_showcase: PlatformShowcase = %PlatformShowcase
@onready var swipe_area: Control = %SwipeArea
@onready var title_label: Label = %PlatformTitle
@onready var status_label: Label = %PlatformStatus
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

var _snapshot: Dictionary = {}
var _definitions: Array[CombatPlatformDefinition] = []
var _selected_index := 0
var _card_buttons: Array[Button] = []
var _swipe_start := Vector2.INF

func _ready() -> void:
	ThemeScript.apply(self)
	ProductionUIScript.apply_safe_area(safe, Vector4(24.0, 26.0, 24.0, 13.0))
	%StatsPanel.add_theme_stylebox_override(
		"panel",
		ProductionUIScript.texture_box(
			PANEL_PATH,
			Vector4(27.0, 27.0, 27.0, 27.0),
			Color.WHITE,
			Vector4(29.0, 22.0, 29.0, 20.0)
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
	action_button.pressed.connect(_request_selected)
	swipe_area.gui_input.connect(_on_swipe_input)

	resized.connect(_sync_showroom)
	%Header.item_rect_changed.connect(_sync_showroom)
	_sync_showroom.call_deferred()

func configure(save_snapshot: Dictionary, notice := "") -> void:
	_snapshot = save_snapshot.duplicate(true)
	_definitions = PlatformCatalogScript.all()

	var inventory := _snapshot.get("inventory", {}) as Dictionary
	var active_id := str(inventory.get("platform_id", "run_down_compact"))
	_selected_index = 0
	for i in range(_definitions.size()):
		if _definitions[i].id == active_id:
			_selected_index = i
			break

	notice_label.text = notice
	notice_label.visible = not notice.is_empty()
	_build_cards()
	_show_selected(false)

func _sync_showroom() -> void:
	if not is_node_ready():
		return
	var target_bottom := %Header.global_position.y - global_position.y + 48.0
	showroom.size = Vector2(size.x, maxf(target_bottom, 420.0))

func _step(direction: int) -> void:
	if _definitions.is_empty():
		return
	var next_index := clampi(_selected_index + direction, 0, _definitions.size() - 1)
	if next_index == _selected_index:
		return
	_selected_index = next_index
	_play_ui(&"ui_confirm")
	_show_selected()

func _show_selected(animate := true) -> void:
	if _definitions.is_empty():
		return

	var definition := _definitions[_selected_index]
	var inventory := _snapshot.get("inventory", {}) as Dictionary
	var campaign := _snapshot.get("campaign", {}) as Dictionary
	var owned := inventory.get("owned_platform_ids", ["run_down_compact"]) as Array
	var completed := campaign.get("completed_missions", []) as Array
	var active_id := str(inventory.get("platform_id", "run_down_compact"))
	var equipped_modules := inventory.get("equipped_module_by_platform", {}) as Dictionary
	var module_id := str(equipped_modules.get(definition.id, ""))

	title_label.text = definition.display_name.to_upper()
	platform_showcase.configure(definition.id, module_id)
	_rebuild_stats(definition)
	_update_action(definition, owned, completed, active_id)

	prev_button.disabled = _selected_index == 0
	next_button.disabled = _selected_index == _definitions.size() - 1

	for i in range(_card_buttons.size()):
		_set_card_selected(_card_buttons[i], i == _selected_index)
	if _selected_index < _card_buttons.size():
		card_scroll.ensure_control_visible.call_deferred(_card_buttons[_selected_index])

	if animate:
		platform_showcase.pivot_offset = platform_showcase.size * 0.5
		platform_showcase.modulate.a = 0.0
		platform_showcase.scale = Vector2(0.94, 0.94)
		var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(platform_showcase, "modulate:a", 1.0, 0.18)
		tween.tween_property(platform_showcase, "scale", Vector2.ONE, 0.22)

func _update_action(
	definition: CombatPlatformDefinition,
	owned: Array,
	completed: Array,
	active_id: String
) -> void:
	var inventory := _snapshot.get("inventory", {}) as Dictionary
	var salvage := int(inventory.get("salvage", 0))
	var unlocked := definition.unlock_after_mission_id.is_empty() or completed.has(definition.unlock_after_mission_id)

	action_coin.visible = false
	action_cost.visible = false
	action_button.disabled = true

	if definition.id == active_id:
		status_label.text = "ACTIVE PLATFORM"
		action_label.text = "ACTIVE"
	elif owned.has(definition.id):
		status_label.text = "OWNED"
		action_label.text = "EQUIP"
		action_button.disabled = false
	elif not unlocked or not definition.purchasable:
		status_label.text = "LOCKED"
		action_label.text = "LOCKED"
	else:
		status_label.text = "AVAILABLE"
		action_label.text = "ACQUIRE" if salvage >= definition.purchase_cost else "NEED"
		action_coin.visible = true
		action_cost.visible = true
		action_cost.text = _format_number(definition.purchase_cost)
		action_button.disabled = salvage < definition.purchase_cost

func _request_selected() -> void:
	if _definitions.is_empty() or action_button.disabled:
		return
	platform_requested.emit(_definitions[_selected_index].id)

func _rebuild_stats(definition: CombatPlatformDefinition) -> void:
	for child in rows.get_children():
		if child != action_button:
			child.queue_free()

	var armour := clampi(int(round(float(definition.cover_health) / 75.0)), 1, 4)
	var size_level := clampi(1 + int(round((definition.cover_size.x - 240.0) / 35.0)), 1, 4)
	var utility := 4 if definition.utility_slot_count > 0 else 0
	var clearance := clampi(5 - size_level, 1, 4)

	_add_stat_row("ARMOUR", ICON_ARMOUR, armour, action_button.get_index())
	_add_stat_row("PROFILE", ICON_SPEED, size_level, action_button.get_index())
	_add_stat_row("UTILITY", ICON_LOAD, utility, action_button.get_index())
	_add_stat_row("CLEARANCE", ICON_FUEL, clearance, action_button.get_index())

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

func _build_cards() -> void:
	for child in platform_row.get_children():
		child.queue_free()
	_card_buttons.clear()

	var campaign := _snapshot.get("campaign", {}) as Dictionary
	var completed := campaign.get("completed_missions", []) as Array
	var inventory := _snapshot.get("inventory", {}) as Dictionary
	var owned := inventory.get("owned_platform_ids", ["run_down_compact"]) as Array

	for i in range(_definitions.size()):
		var definition := _definitions[i]
		var unlocked := definition.unlock_after_mission_id.is_empty() or completed.has(definition.unlock_after_mission_id)

		var card := Button.new()
		card.custom_minimum_size = Vector2(229.0, 188.0)
		card.focus_mode = Control.FOCUS_NONE
		card.flat = true
		card.clip_contents = false
		card.pressed.connect(_select_card.bind(i))

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

		var preview := PlatformShowcase.new()
		preview.name = "_Preview"
		preview.set_anchors_preset(Control.PRESET_FULL_RECT)
		preview.offset_left = 12.0
		preview.offset_top = 8.0
		preview.offset_right = -12.0
		preview.offset_bottom = -8.0
		preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
		preview.draw_floor_shadow = false
		preview.configure(definition.id)
		if not owned.has(definition.id) and not unlocked:
			preview.modulate = Color(0.42, 0.45, 0.52, 1.0)
		card.add_child(preview)

		if not owned.has(definition.id) and not unlocked:
			var lock := TextureRect.new()
			lock.texture = ProductionUIScript.texture(LOCK_PATH)
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

		platform_row.add_child(card)
		_card_buttons.append(card)

func _set_card_selected(card: Button, selected: bool) -> void:
	var normal := card.get_node_or_null("_Frame") as CanvasItem
	var glow := card.get_node_or_null("_SelectedFrame") as CanvasItem
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

func _format_number(value: int) -> String:
	var source := str(absi(value))
	var out := ""
	while source.length() > 3:
		out = "," + source.substr(source.length() - 3) + out
		source = source.substr(0, source.length() - 3)
	return source + out

func _play_ui(cue: StringName) -> void:
	var audio := get_tree().get_first_node_in_group("fort_knocks_audio")
	if audio != null and audio.has_method("play_cue"):
		audio.call("play_cue", cue)
