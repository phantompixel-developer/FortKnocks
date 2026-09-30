class_name CommandBoardScreen
extends Control

signal mission_selected(mission: MissionDefinition)
signal back_requested

const EncounterCatalogScript := preload("res://game/campaign/encounter_catalog.gd")
const ThemeScript := preload("res://game/presentation/fort_knocks_theme.gd")

@onready var salvage_label: Label = $TopBar/SalvageLabel
@onready var mission_list: VBoxContainer = $MissionPanel/MissionScroll/MissionList
@onready var back_button: Button = $BackButton

var _snapshot: Dictionary = {}

func _ready() -> void:
	ThemeScript.apply(self)
	ThemeScript.style_card($Header, 1)
	ThemeScript.style_card($TopBar)
	ThemeScript.style_card($MissionPanel)
	$Header/Title.add_theme_color_override("font_color", ThemeScript.HAZARD)
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

	var missions := EncounterCatalogScript.all()
	for index in range(missions.size()):
		var mission := missions[index]
		var is_unlocked := unlocked.has(mission.id)
		var is_completed := completed.has(mission.id)

		var button := Button.new()
		button.custom_minimum_size = Vector2(0.0, 112.0)
		button.add_theme_font_size_override("font_size", 16)
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
	_play_ui(&"ui_confirm")
	mission_selected.emit(mission)

func _play_ui(cue: StringName) -> void:
	var audio := get_tree().get_first_node_in_group("fort_knocks_audio")
	if audio != null and audio.has_method("play_cue"):
		audio.call("play_cue", cue)
