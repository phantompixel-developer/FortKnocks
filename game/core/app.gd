class_name FortKnocksApp
extends Node

const HubScene := preload("res://game/hub/fort_knocks_hub.tscn")
const CommandBoardScene := preload("res://game/campaign/command_board.tscn")
const GarageScene := preload("res://game/progression/garage_screen.tscn")
const WorkshopScene := preload("res://game/progression/workshop_screen.tscn")
const BattleScene := preload("res://game/battle/battle.tscn")
const EncounterCatalogScript := preload("res://game/campaign/encounter_catalog.gd")

@onready var save_service: SaveService = $SaveService
@onready var current_screen: Node = $CurrentScreen

var _active_mission: MissionDefinition
var _hub_notice := ""

func _ready() -> void:
	_show_hub()

func _show_hub() -> void:
	var hub := HubScene.instantiate() as FortKnocksHub
	_replace_screen(hub)
	hub.command_board_requested.connect(_show_command_board)
	hub.garage_requested.connect(_show_garage)
	hub.workshop_requested.connect(_show_workshop)
	hub.configure(save_service.snapshot(), _hub_notice)
	_hub_notice = ""

func _show_command_board() -> void:
	var board := CommandBoardScene.instantiate() as CommandBoardScreen
	_replace_screen(board)
	board.mission_selected.connect(_start_mission)
	board.back_requested.connect(_show_hub)
	board.configure(save_service.snapshot())

func _show_garage() -> void:
	var garage := GarageScene.instantiate() as GarageScreen
	_replace_screen(garage)
	garage.back_requested.connect(_show_hub)
	garage.configure(save_service.snapshot())

func _show_workshop() -> void:
	var workshop := WorkshopScene.instantiate() as WorkshopScreen
	_replace_screen(workshop)
	workshop.back_requested.connect(_show_hub)
	workshop.configure(save_service.snapshot())

func _start_mission(mission: MissionDefinition) -> void:
	if mission == null:
		return

	_active_mission = mission
	var battle := BattleScene.instantiate()
	if battle == null:
		push_error("Battle scene could not be instantiated.")
		return

	battle.call("prepare_for_campaign", mission)
	battle.connect("battle_completed", Callable(self, "_on_battle_completed"))
	battle.connect("exit_requested", Callable(self, "_on_battle_exit_requested"))
	battle.connect("rematch_requested", Callable(self, "_on_battle_rematch_requested"))
	_replace_screen(battle)

func _on_battle_completed(result: Dictionary) -> void:
	if _active_mission == null:
		return

	var victory := bool(result.get("victory", false))
	var awarded := 0
	if victory:
		awarded = save_service.complete_mission(
			_active_mission.id,
			_active_mission.salvage_reward,
			_active_mission.next_mission_id
		)

	var battle := _current_child()
	if battle != null and battle.has_method("set_progression_reward"):
		battle.call("set_progression_reward", awarded)

	if victory and awarded > 0:
		_hub_notice = "MISSION CLEARED • +%d SALVAGE" % awarded
		if not _active_mission.next_mission_id.is_empty():
			var next_mission := EncounterCatalogScript.by_id(_active_mission.next_mission_id)
			if next_mission != null:
				_hub_notice += "\n%s UNLOCKED" % next_mission.display_name.to_upper()
	elif victory:
		_hub_notice = "ROUTE ALREADY CLEARED • NO NEW SALVAGE"
	else:
		_hub_notice = "RUN FAILED • NO SALVAGE RECOVERED"

func _on_battle_exit_requested() -> void:
	_active_mission = null
	_show_hub()

func _on_battle_rematch_requested() -> void:
	var mission := _active_mission
	if mission != null:
		_start_mission(mission)

func _replace_screen(screen: Node) -> void:
	for child in current_screen.get_children():
		current_screen.remove_child(child)
		child.queue_free()
	current_screen.add_child(screen)

func _current_child() -> Node:
	if current_screen.get_child_count() == 0:
		return null
	return current_screen.get_child(0)
