class_name CommandBoardScreen
extends Control

signal mission_selected(mission: MissionDefinition)
signal back_requested

const EncounterCatalogScript := preload("res://game/campaign/encounter_catalog.gd")
const ThemeScript := preload("res://game/presentation/fort_knocks_theme.gd")
const PortraitLayoutScript := preload("res://game/presentation/portrait_layout.gd")

@onready var salvage_label: Label = $TopBar/SalvageLabel
@onready var mission_list: VBoxContainer = $MissionPanel/MissionScroll/MissionList
@onready var route_visual: CommandBoardVisual = $MissionPanel/RouteVisual
@onready var back_button: Button = $BackButton

var _snapshot: Dictionary = {}

func _ready() -> void:
	ThemeScript.apply(self)
	ThemeScript.style_card($Header, 1)
	ThemeScript.style_card($TopBar)
	ThemeScript.style_card($MissionPanel)
	$Header/Title.add_theme_color_override("font_color", ThemeScript.HAZARD)
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
	route_visual.configure(missions.size(), unlocked_count, completed_count)

	for index in range(missions.size()):
		var mission: MissionDefinition = missions[index]
		var is_unlocked := unlocked.has(mission.id)
		var is_completed := completed.has(mission.id)

		var button := Button.new()
		button.custom_minimum_size = Vector2(0.0, 96.0)
		button.add_theme_font_size_override("font_size", 14)
		button.disabled = not is_unlocked

		var state := "LOCKED"
		if is_completed:
			state = "CLEARED • REPLAY"
		elif is_unlocked:
			state = "AVAILABLE"

		button.text = "%02d  %s\n%s\nREWARD  %d SALVAGE • %s" % [
			index + 1,
			mission.display_name.to_upper(),
			mission.test_focus,
			mission.salvage_reward,
			state,
		]
		ThemeScript.mark_active(button, is_completed)
		button.pressed.connect(_select_mission.bind(mission))
		mission_list.add_child(button)

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
