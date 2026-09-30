class_name WorkshopScreen
extends Control

signal back_requested
signal module_requested(module_id: String)

const PlatformModuleCatalogScript := preload("res://game/platforms/platform_module_catalog.gd")
const PlatformCatalogScript := preload("res://game/platforms/platform_catalog.gd")

@onready var salvage_label: Label = $TopBar/SalvageLabel
@onready var platform_label: Label = $UtilityCard/PlatformLabel
@onready var module_list: VBoxContainer = $UtilityCard/ModuleList
@onready var utility_note: Label = $UtilityCard/Note
@onready var notice_label: Label = $NoticeLabel
@onready var back_button: Button = $BackButton

var _snapshot: Dictionary = {}

func _ready() -> void:
	back_button.pressed.connect(func() -> void: back_requested.emit())

func configure(save_snapshot: Dictionary, notice := "") -> void:
	_snapshot = save_snapshot.duplicate(true)
	var inventory := _snapshot.get("inventory", {}) as Dictionary
	var platform_id := str(inventory.get("platform_id", "run_down_compact"))
	var platform := PlatformCatalogScript.by_id(platform_id)

	salvage_label.text = "SALVAGE  %d" % int(inventory.get("salvage", 0))
	platform_label.text = "ACTIVE PLATFORM: %s" % (
		platform.display_name.to_upper() if platform != null else platform_id.to_upper()
	)
	notice_label.text = notice
	notice_label.visible = not notice.is_empty()
	_rebuild_modules(platform_id)

func _rebuild_modules(platform_id: String) -> void:
	for child in module_list.get_children():
		child.queue_free()

	var inventory := _snapshot.get("inventory", {}) as Dictionary
	var owned_platforms := inventory.get("owned_platform_ids", ["run_down_compact"]) as Array
	var owned_modules := inventory.get("owned_module_ids", []) as Array
	var equipped := inventory.get("equipped_module_by_platform", {}) as Dictionary
	var salvage := int(inventory.get("salvage", 0))

	if not owned_platforms.has("pickup"):
		utility_note.text = "Recover the Pickup through the Outskirts route before utility modules become available."
		return

	if platform_id != "pickup":
		utility_note.text = "Equip the Pickup in the Garage to configure its utility bed."
		return

	var active_module_id := str(equipped.get("pickup", ""))
	for definition in PlatformModuleCatalogScript.for_platform("pickup"):
		var is_owned := owned_modules.has(definition.id)
		var is_active := active_module_id == definition.id
		var action := ""
		var enabled := false

		if is_active:
			action = "ACTIVE"
		elif is_owned:
			action = "EQUIP"
			enabled = true
		elif salvage >= definition.purchase_cost:
			action = "BUILD  %d SALVAGE" % definition.purchase_cost
			enabled = true
		else:
			action = "NEED %d SALVAGE" % definition.purchase_cost

		var button := Button.new()
		button.custom_minimum_size = Vector2(0.0, 96.0)
		button.add_theme_font_size_override("font_size", 14)
		button.disabled = not enabled
		button.text = "%s\n%s\n%s" % [
			definition.display_name.to_upper(),
			definition.tactical_summary,
			action,
		]
		button.pressed.connect(_request_module.bind(definition.id))
		module_list.add_child(button)

	utility_note.text = "One Pickup utility slot. Choose precision or protection; owned modules can be swapped freely."

func _request_module(module_id: String) -> void:
	module_requested.emit(module_id)
