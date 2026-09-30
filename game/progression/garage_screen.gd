class_name GarageScreen
extends Control

signal back_requested
signal platform_requested(platform_id: String)

const PlatformCatalogScript := preload("res://game/platforms/platform_catalog.gd")

@onready var salvage_label: Label = $TopBar/SalvageLabel
@onready var current_label: Label = $CurrentCard/CurrentLabel
@onready var platform_list: VBoxContainer = $ProgressionCard/PlatformList
@onready var detail_label: Label = $ProgressionCard/DetailLabel
@onready var notice_label: Label = $NoticeLabel
@onready var back_button: Button = $BackButton

var _snapshot: Dictionary = {}

func _ready() -> void:
	back_button.pressed.connect(func() -> void: back_requested.emit())

func configure(save_snapshot: Dictionary, notice := "") -> void:
	_snapshot = save_snapshot.duplicate(true)
	var inventory := _snapshot.get("inventory", {}) as Dictionary
	salvage_label.text = "SALVAGE  %d" % int(inventory.get("salvage", 0))
	current_label.text = "ACTIVE\n%s" % _platform_display_name(
		str(inventory.get("platform_id", "run_down_compact"))
	)
	notice_label.text = notice
	notice_label.visible = not notice.is_empty()
	_rebuild_platform_list()

func _rebuild_platform_list() -> void:
	for child in platform_list.get_children():
		child.queue_free()

	var campaign := _snapshot.get("campaign", {}) as Dictionary
	var inventory := _snapshot.get("inventory", {}) as Dictionary
	var completed := campaign.get("completed_missions", []) as Array
	var owned := inventory.get("owned_platform_ids", ["run_down_compact"]) as Array
	var active_id := str(inventory.get("platform_id", "run_down_compact"))
	var salvage := int(inventory.get("salvage", 0))

	for definition in PlatformCatalogScript.all():
		var unlocked := definition.unlock_after_mission_id.is_empty() or completed.has(definition.unlock_after_mission_id)
		var is_owned := owned.has(definition.id)
		var is_active := active_id == definition.id

		var action := ""
		var enabled := false
		if is_active:
			action = "ACTIVE"
		elif is_owned:
			action = "EQUIP"
			enabled = true
		elif not definition.purchasable:
			action = "NEXT PROGRESSION PROOF"
		elif not unlocked:
			action = "LOCKED"
		elif salvage >= definition.purchase_cost:
			action = "BUY  %d SALVAGE" % definition.purchase_cost
			enabled = true
		else:
			action = "NEED %d SALVAGE" % definition.purchase_cost

		var button := Button.new()
		button.custom_minimum_size = Vector2(0.0, 104.0)
		button.add_theme_font_size_override("font_size", 15)
		button.disabled = not enabled
		button.text = "%s\n%s\n%s" % [
			definition.display_name.to_upper(),
			definition.tactical_summary,
			action,
		]
		button.pressed.connect(_request_platform.bind(definition.id))
		platform_list.add_child(button)

	detail_label.text = "Sedan trade-off: stronger, wider cover protects longer but occupies more of the shallow firing line."

func _request_platform(platform_id: String) -> void:
	platform_requested.emit(platform_id)

func _platform_display_name(platform_id: String) -> String:
	var definition := PlatformCatalogScript.by_id(platform_id)
	return definition.display_name.to_upper() if definition != null else platform_id.replace("_", " ").to_upper()
