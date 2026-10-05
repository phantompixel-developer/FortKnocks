class_name CommandBoardScreen
extends Control

signal mission_selected(mission: MissionDefinition)
signal back_requested

const EncounterCatalogScript := preload("res://game/campaign/encounter_catalog.gd")
const ThemeScript := preload("res://game/presentation/fort_knocks_theme.gd")
const PortraitLayoutScript := preload("res://game/presentation/portrait_layout.gd")

@onready var subtitle_label: Label = $Header/Subtitle
@onready var salvage_label: Label = $TopBar/SalvageLabel
@onready var mission_list: VBoxContainer = $MissionPanel/MissionScroll/MissionList
@onready var route_visual: CommandBoardVisual = $MissionPanel/RouteVisual
@onready var back_button: Button = $BackButton

var _snapshot: Dictionary = {}

func _ready() -> void:
	ThemeScript.apply(self)
	ThemeScript.style_card($Header, 1)
	ThemeScript.style_card($TopBar)
	$MissionPanel.color = Color(0.02, 0.025, 0.023, 0.18)
	ThemeScript.style_display_label($Header/Title)
	ThemeScript.style_meta_label($Header/Subtitle)
	ThemeScript.style_section_label($MissionPanel/SectionTitle)
	ThemeScript.style_meta_label($MissionPanel/RouteVisual/OutskirtsTag)
	ThemeScript.style_meta_label($MissionPanel/RouteVisual/SuburbsTag, true)
	ThemeScript.style_secondary_button(back_button)
	get_viewport().size_changed.connect(_apply_responsive_layout)
	call_deferred("_apply_responsive_layout")
	back_button.pressed.connect(func() -> void:
		_play_ui(&"ui_back")
		back_requested.emit()
	)

func configure(save_snapshot: Dictionary) -> void:
	_snapshot = save_snapshot.duplicate(true)
	_rebuild()

func _rebuild() -> void:
	for child in mission_list.get_children():
		child.queue_free()

	var inventory := _snapshot.get("inventory", {}) as Dictionary
	var campaign := _snapshot.get("campaign", {}) as Dictionary
	var unlocked := campaign.get("unlocked_missions", []) as Array
	var completed := campaign.get("completed_missions", []) as Array
	salvage_label.text = "SALVAGE  %d" % int(inventory.get("salvage", 0))

	var missions: Array[MissionDefinition] = EncounterCatalogScript.all()
	var unlocked_count := 0
	var completed_count := 0
	for mission in missions:
		if unlocked.has(mission.id):
			unlocked_count += 1
		if completed.has(mission.id):
			completed_count += 1
	route_visual.configure(missions, unlocked, completed)
	_update_campaign_heading(completed_count)

	var current_region := ""
	for index in range(missions.size()):
		var mission: MissionDefinition = missions[index]
		if mission.region_id != current_region:
			current_region = mission.region_id
			var region_label := Label.new()
			region_label.custom_minimum_size = Vector2(0.0, 28.0)
			region_label.text = _region_display_name(current_region)
			region_label.add_theme_font_size_override("font_size", 14)
			ThemeScript.style_section_label(region_label, current_region == "outskirts")
			mission_list.add_child(region_label)

		var is_unlocked := unlocked.has(mission.id)
		var is_completed := completed.has(mission.id)

		var button := Button.new()
		button.custom_minimum_size = Vector2(0.0, 68.0)
		button.add_theme_font_size_override("font_size", 13)
		button.disabled = not is_unlocked

		var state := "LOCKED"
		if is_completed:
			state = "CLEARED • REPLAY"
		elif is_unlocked:
			state = "AVAILABLE"

		button.text = "%02d  %s • %s\n%d SALVAGE • %s" % [
			index + 1,
			mission.display_name.to_upper(),
			mission.location_tag,
			mission.salvage_reward,
			state,
		]
		ThemeScript.mark_active(button, is_completed)
		button.pressed.connect(_select_mission.bind(mission))
		mission_list.add_child(button)


func _update_campaign_heading(completed_count: int) -> void:
	if completed_count < 6:
		subtitle_label.text = "OUTSKIRTS • %d/6 CLEARED • PUSH EAST" % mini(completed_count, 6)
	else:
		subtitle_label.text = "OUTSKIRTS SECURED • SUBURBS %d/4 CLEARED" % mini(maxi(0, completed_count - 6), 4)

func _region_display_name(region_id: String) -> String:
	return "SUBURBS" if region_id == "suburbs" else "OUTSKIRTS"

func _select_mission(mission: MissionDefinition) -> void:
	mission_selected.emit(mission)

func _play_ui(cue: StringName) -> void:
	var audio := get_tree().get_first_node_in_group("fort_knocks_audio")
	if audio != null and audio.has_method("play_cue"):
		audio.call("play_cue", cue)


func _apply_responsive_layout() -> void:
	PortraitLayoutScript.apply(
		self,
		[$Header, $TopBar],
		[$MissionPanel],
		[$Footer, $BackButton]
	)
