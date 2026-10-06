class_name GarageScreen
extends Control

signal back_requested
signal platform_requested(platform_id: String)

const PlatformCatalogScript := preload("res://game/platforms/platform_catalog.gd")
const ThemeScript := preload("res://game/presentation/fort_knocks_theme.gd")
const ProductionUIScript := preload("res://game/presentation/production_ui.gd")

const PANEL_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/ui/panel_stats_9s.png"
const COIN_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/icons/icon_coin.png"
const LOCK_PATH := "res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/icons/icon_lock.png"

@onready var safe: MarginContainer = %Safe
@onready var salvage_label: Label = %SalvageLabel
@onready var platform_showcase: PlatformShowcase = %PlatformShowcase
@onready var title_label: Label = %PlatformTitle
@onready var status_label: Label = %PlatformStatus
@onready var summary_label: Label = %Summary
@onready var stat_rows: VBoxContainer = %StatRows
@onready var platform_row: HBoxContainer = %PlatformRow
@onready var action_button: Button = %ActionButton
@onready var prev_button: TextureButton = %PrevButton
@onready var next_button: TextureButton = %NextButton
@onready var notice_label: Label = %NoticeLabel
@onready var back_button: TextureButton = %BackButton
@onready var swipe_area: Control = %SwipeArea

const SWIPE_MIN := 62.0
var _swipe_start := Vector2.INF
var _snapshot: Dictionary = {}
var _definitions: Array[CombatPlatformDefinition] = []
var _selected_index := 0
var _card_buttons: Array[Button] = []

func _ready() -> void:
	ThemeScript.apply(self)
	ProductionUIScript.apply_safe_area(safe)
	%StatsPanel.add_theme_stylebox_override(
		"panel",
		ProductionUIScript.texture_box(PANEL_PATH, Vector4(40.0, 40.0, 40.0, 40.0))
	)
	ProductionUIScript.style_action_button(action_button)
	%Coin.texture = ProductionUIScript.texture(COIN_PATH)
	back_button.pressed.connect(func() -> void:
		_play_ui(&"ui_back")
		back_requested.emit()
	)
	prev_button.pressed.connect(_step.bind(-1))
	next_button.pressed.connect(_step.bind(1))
	swipe_area.gui_input.connect(_on_swipe_input)
	action_button.pressed.connect(_request_selected)

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

	salvage_label.text = "%d" % int(inventory.get("salvage", 0))
	notice_label.text = notice
	notice_label.visible = not notice.is_empty()
	_build_cards()
	_show_selected(false)

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
	var owned := inventory.get("owned_platform_ids", ["run_down_compact"]) as Array
	var active_id := str(inventory.get("platform_id", "run_down_compact"))
	var equipped_modules := inventory.get("equipped_module_by_platform", {}) as Dictionary
	var module_id := str(equipped_modules.get(definition.id, ""))

	title_label.text = definition.display_name.to_upper()
	status_label.text = _status_text(definition, owned, active_id)
	summary_label.text = definition.tactical_summary
	platform_showcase.configure(definition.id, module_id)
	_rebuild_stats(definition)
	_update_action(definition, owned, active_id)
	prev_button.disabled = _selected_index <= 0
	next_button.disabled = _selected_index >= _definitions.size() - 1

	for i in range(_card_buttons.size()):
		ProductionUIScript.style_card_button(_card_buttons[i], i == _selected_index)

	if animate:
		platform_showcase.pivot_offset = platform_showcase.size * 0.5
		platform_showcase.modulate.a = 0.0
		platform_showcase.scale = Vector2(0.95, 0.95)
		var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(platform_showcase, "modulate:a", 1.0, 0.16)
		tween.tween_property(platform_showcase, "scale", Vector2.ONE, 0.20)

func _status_text(definition: CombatPlatformDefinition, owned: Array, active_id: String) -> String:
	if definition.id == active_id:
		return "ACTIVE PLATFORM"
	if owned.has(definition.id):
		return "OWNED • READY TO EQUIP"
	var campaign := _snapshot.get("campaign", {}) as Dictionary
	var completed := campaign.get("completed_missions", []) as Array
	var unlocked := definition.unlock_after_mission_id.is_empty() or completed.has(definition.unlock_after_mission_id)
	if not unlocked:
		return "CAMPAIGN LOCKED"
	if not definition.purchasable:
		return "PROGRESSION LOCKED"
	return "AVAILABLE • %d SALVAGE" % definition.purchase_cost

func _update_action(definition: CombatPlatformDefinition, owned: Array, active_id: String) -> void:
	var campaign := _snapshot.get("campaign", {}) as Dictionary
	var inventory := _snapshot.get("inventory", {}) as Dictionary
	var completed := campaign.get("completed_missions", []) as Array
	var salvage := int(inventory.get("salvage", 0))
	var unlocked := definition.unlock_after_mission_id.is_empty() or completed.has(definition.unlock_after_mission_id)

	action_button.disabled = true
	if definition.id == active_id:
		action_button.text = "ACTIVE PLATFORM"
	elif owned.has(definition.id):
		action_button.text = "EQUIP"
		action_button.disabled = false
	elif not definition.purchasable:
		action_button.text = "PROGRESSION LOCKED"
	elif not unlocked:
		action_button.text = "LOCKED BY CAMPAIGN"
	elif salvage >= definition.purchase_cost:
		action_button.text = "ACQUIRE • %d SALVAGE" % definition.purchase_cost
		action_button.disabled = false
	else:
		action_button.text = "NEED %d SALVAGE" % definition.purchase_cost

func _request_selected() -> void:
	if _definitions.is_empty() or action_button.disabled:
		return
	platform_requested.emit(_definitions[_selected_index].id)

func _rebuild_stats(definition: CombatPlatformDefinition) -> void:
	for child in stat_rows.get_children():
		child.queue_free()

	var armour_fill := clampi(int(round(float(definition.cover_health) / 75.0)), 1, 4)
	var width_fill := clampi(1 + int(round((definition.cover_size.x - 240.0) / 35.0)), 1, 4)
	var utility_fill := 4 if definition.utility_slot_count > 0 else 0
	_add_stat_row("PROTECTION", "%d HP" % definition.cover_health, armour_fill)
	_add_stat_row("FOOTPRINT", "%d WIDE" % int(definition.cover_size.x), width_fill)
	_add_stat_row("UTILITY", "%d SLOT" % definition.utility_slot_count, utility_fill)

func _add_stat_row(label_text: String, value_text: String, filled: int) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0.0, 34.0)
	row.add_theme_constant_override("separation", 10)

	var label := Label.new()
	label.custom_minimum_size = Vector2(116.0, 0.0)
	label.text = label_text
	label.add_theme_font_size_override("font_size", 15)
	row.add_child(label)

	var segments := HBoxContainer.new()
	segments.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	segments.add_theme_constant_override("separation", 4)
	row.add_child(segments)
	ProductionUIScript.rebuild_segments(segments, filled, 4)

	var value := Label.new()
	value.custom_minimum_size = Vector2(92.0, 0.0)
	value.text = value_text
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value.add_theme_font_size_override("font_size", 14)
	row.add_child(value)
	stat_rows.add_child(row)

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
		var button := Button.new()
		button.custom_minimum_size = Vector2(166.0, 148.0)
		button.clip_contents = true
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(_select_card.bind(i))
		ProductionUIScript.style_card_button(button, i == _selected_index)

		var preview := PlatformShowcase.new()
		preview.set_anchors_preset(Control.PRESET_FULL_RECT)
		preview.offset_left = 12.0
		preview.offset_top = 8.0
		preview.offset_right = -12.0
		preview.offset_bottom = -42.0
		preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
		preview.configure(definition.id)
		button.add_child(preview)

		var name_label := Label.new()
		name_label.anchor_left = 0.0
		name_label.anchor_top = 1.0
		name_label.anchor_right = 1.0
		name_label.anchor_bottom = 1.0
		name_label.offset_left = 10.0
		name_label.offset_top = -42.0
		name_label.offset_right = -10.0
		name_label.offset_bottom = -8.0
		name_label.text = definition.display_name.to_upper()
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 13)
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(name_label)

		var unlocked := definition.unlock_after_mission_id.is_empty() or completed.has(definition.unlock_after_mission_id)
		if not owned.has(definition.id) and not unlocked:
			var lock := TextureRect.new()
			lock.texture = ProductionUIScript.texture(LOCK_PATH)
			lock.position = Vector2(124.0, 10.0)
			lock.size = Vector2(30.0, 30.0)
			lock.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
			button.add_child(lock)

		platform_row.add_child(button)
		_card_buttons.append(button)

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
		if absf(delta.x) >= SWIPE_MIN and absf(delta.x) > absf(delta.y) * 1.4:
			_step(-1 if delta.x > 0.0 else 1)

func _play_ui(cue: StringName) -> void:
	var audio := get_tree().get_first_node_in_group("fort_knocks_audio")
	if audio != null and audio.has_method("play_cue"):
		audio.call("play_cue", cue)
