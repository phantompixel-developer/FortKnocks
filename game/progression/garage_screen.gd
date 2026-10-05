class_name GarageScreen
extends Control

signal back_requested
signal platform_requested(platform_id: String)

const PlatformCatalogScript := preload("res://game/platforms/platform_catalog.gd")
const PlatformModuleCatalogScript := preload("res://game/platforms/platform_module_catalog.gd")
const ThemeScript := preload("res://game/presentation/fort_knocks_theme.gd")
const PortraitLayoutScript := preload("res://game/presentation/portrait_layout.gd")

@onready var salvage_label: Label = $TopBar/SalvageLabel
@onready var current_label: Label = $CurrentCard/CurrentLabel
@onready var platform_showcase: PlatformShowcase = $CurrentCard/PlatformShowcase
@onready var platform_list: GridContainer = $ProgressionCard/PlatformList
@onready var detail_label: Label = $ProgressionCard/DetailLabel
@onready var notice_label: Label = $NoticeLabel
@onready var back_button: Button = $BackButton

var _snapshot: Dictionary = {}

func _ready() -> void:
	ThemeScript.apply(self)
	ThemeScript.style_card($TopBar)
	$CurrentCard.color = Color(0.02, 0.025, 0.023, 0.12)
	ThemeScript.style_card($ProgressionCard)
	ThemeScript.style_display_label($Title)
	ThemeScript.style_section_label($CurrentCard/Header)
	ThemeScript.style_section_label($CurrentCard/CurrentLabel, true)
	ThemeScript.style_section_label($ProgressionCard/Title)
	ThemeScript.style_meta_label(detail_label)
	ThemeScript.style_secondary_button(back_button)
	get_viewport().size_changed.connect(_apply_responsive_layout)
	call_deferred("_apply_responsive_layout")
	back_button.pressed.connect(func() -> void:
		_play_ui(&"ui_back")
		back_requested.emit()
	)

func configure(save_snapshot: Dictionary, notice := "") -> void:
	_snapshot = save_snapshot.duplicate(true)
	var inventory := _snapshot.get("inventory", {}) as Dictionary
	salvage_label.text = "SALVAGE  %d" % int(inventory.get("salvage", 0))
	var active_id := str(inventory.get("platform_id", "run_down_compact"))
	var equipped_modules := inventory.get("equipped_module_by_platform", {}) as Dictionary
	var module_id := str(equipped_modules.get(active_id, ""))
	current_label.text = "ACTIVE • %s" % _platform_display_name(active_id)
	platform_showcase.configure(active_id, module_id)
	var active_definition := PlatformCatalogScript.by_id(active_id)
	if active_definition != null:
		var effective_cover := active_definition.cover_health
		var active_module := PlatformModuleCatalogScript.by_id(module_id) if not module_id.is_empty() else null
		if active_module != null:
			effective_cover += active_module.cover_health_bonus
		detail_label.text = "%s • %d COVER%s" % [
			active_definition.tactical_summary,
			effective_cover,
			(" • %s" % active_module.display_name.to_upper()) if active_module != null else "",
		]
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
			action = "FUTURE TIER"
		elif not unlocked:
			action = "LOCKED"
		elif salvage >= definition.purchase_cost:
			action = "BUY  %d SALVAGE" % definition.purchase_cost
			enabled = true
		else:
			action = "NEED %d SALVAGE" % definition.purchase_cost

		var button := Button.new()
		button.custom_minimum_size = Vector2(0.0, 80.0)
		button.add_theme_font_size_override("font_size", 14)
		button.disabled = not enabled
		button.text = "%s\n%s • %s" % [
			definition.display_name.to_upper(),
			action,
			_platform_selector_summary(definition.id),
		]
		ThemeScript.mark_active(button, is_active)
		button.pressed.connect(_request_platform.bind(definition.id))
		platform_list.add_child(button)

func _platform_selector_summary(platform_id: String) -> String:
	match platform_id:
		"old_sedan":
			return "MORE COVER • WIDER"
		"pickup":
			return "UTILITY SLOT"
		"improvised_technical":
			return "SUPPORT SLOT • HEAVY"
		_:
			return "LIGHT • NARROW"

func _request_platform(platform_id: String) -> void:
	platform_requested.emit(platform_id)

func _platform_display_name(platform_id: String) -> String:
	var definition := PlatformCatalogScript.by_id(platform_id)
	return definition.display_name.to_upper() if definition != null else platform_id.replace("_", " ").to_upper()

func _play_ui(cue: StringName) -> void:
	var audio := get_tree().get_first_node_in_group("fort_knocks_audio")
	if audio != null and audio.has_method("play_cue"):
		audio.call("play_cue", cue)


func _apply_responsive_layout() -> void:
	PortraitLayoutScript.apply(
		self,
		[$Title, $TopBar],
		[$CurrentCard, $NoticeLabel, $ProgressionCard],
		[$BackButton]
	)
