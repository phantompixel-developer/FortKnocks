class_name WorkshopScreen
extends Control

signal back_requested
signal module_requested(module_id: String)
signal specialist_weapon_requested(weapon_id: String)

const PlatformModuleCatalogScript := preload("res://game/platforms/platform_module_catalog.gd")
const PlatformCatalogScript := preload("res://game/platforms/platform_catalog.gd")

@onready var salvage_label: Label = $TopBar/SalvageLabel
@onready var specialist_label: Label = $LoadoutCard/SpecialistLabel
@onready var heavy_button: Button = $LoadoutCard/HeavyButton
@onready var shock_button: Button = $LoadoutCard/ShockButton
@onready var platform_label: Label = $UtilityCard/PlatformLabel
@onready var module_list: VBoxContainer = $UtilityCard/ModuleList
@onready var utility_note: Label = $UtilityCard/Note
@onready var notice_label: Label = $NoticeLabel
@onready var back_button: Button = $BackButton

var _snapshot: Dictionary = {}

func _ready() -> void:
	back_button.pressed.connect(func() -> void: back_requested.emit())
	heavy_button.pressed.connect(func() -> void: specialist_weapon_requested.emit("heavy_slug"))
	shock_button.pressed.connect(func() -> void: specialist_weapon_requested.emit("shock_capsule"))

func configure(save_snapshot: Dictionary, notice := "") -> void:
	_snapshot = save_snapshot.duplicate(true)
	var inventory := _snapshot.get("inventory", {}) as Dictionary
	var platform_id := str(inventory.get("platform_id", "run_down_compact"))
	var platform := PlatformCatalogScript.by_id(platform_id)
	var specialist_id := str(inventory.get("specialist_weapon_id", "heavy_slug"))

	salvage_label.text = "SALVAGE  %d" % int(inventory.get("salvage", 0))
	platform_label.text = "ACTIVE PLATFORM: %s" % (
		platform.display_name.to_upper() if platform != null else platform_id.to_upper()
	)
	notice_label.text = notice
	notice_label.visible = not notice.is_empty()
	_update_specialist_loadout(specialist_id)
	_rebuild_modules(platform_id)

func _update_specialist_loadout(specialist_id: String) -> void:
	specialist_label.text = "FIELD RACK: SCRAP BOLT + %s" % (
		"HEAVY SLUG" if specialist_id == "heavy_slug" else "SHOCK CAPSULE"
	)
	heavy_button.disabled = specialist_id == "heavy_slug"
	shock_button.disabled = specialist_id == "shock_capsule"
	heavy_button.text = "HEAVY SLUG\nCover breaker • high force\n%s" % (
		"ACTIVE SPECIALIST" if specialist_id == "heavy_slug" else "EQUIP SPECIALIST"
	)
	shock_button.text = "SHOCK CAPSULE\nRadial pulse • displacement\n%s" % (
		"ACTIVE SPECIALIST" if specialist_id == "shock_capsule" else "EQUIP SPECIALIST"
	)

func _rebuild_modules(platform_id: String) -> void:
	for child in module_list.get_children():
		child.queue_free()

	var inventory := _snapshot.get("inventory", {}) as Dictionary
	var owned_modules := inventory.get("owned_module_ids", []) as Array
	var equipped := inventory.get("equipped_module_by_platform", {}) as Dictionary
	var salvage := int(inventory.get("salvage", 0))
	var platform := PlatformCatalogScript.by_id(platform_id)

	if platform == null or platform.utility_slot_count <= 0:
		utility_note.text = "The active platform has no utility slot. Progress to the Pickup to configure field utility."
		return

	var compatible_modules := PlatformModuleCatalogScript.for_platform(platform_id)
	if compatible_modules.is_empty():
		utility_note.text = "No utility modules are available for this platform yet."
		return

	var active_module_id := str(equipped.get(platform_id, ""))
	for definition in compatible_modules:
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

	utility_note.text = "%d utility slot. Choose one active module; owned modules can be swapped freely." % platform.utility_slot_count

func _request_module(module_id: String) -> void:
	module_requested.emit(module_id)
