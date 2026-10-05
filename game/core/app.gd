class_name FortKnocksApp
extends Node

const HubScene := preload("res://game/hub/fort_knocks_hub.tscn")
const CommandBoardScene := preload("res://game/campaign/command_board.tscn")
const GarageScene := preload("res://game/progression/garage_screen.tscn")
const WorkshopScene := preload("res://game/progression/workshop_screen.tscn")
const BattleScene := preload("res://game/battle/battle.tscn")
const EncounterCatalogScript := preload("res://game/campaign/encounter_catalog.gd")
const PlatformCatalogScript := preload("res://game/platforms/platform_catalog.gd")
const PlatformModuleCatalogScript := preload("res://game/platforms/platform_module_catalog.gd")
const SCREEN_REVEAL_DURATION := 0.18
const SCREEN_REVEAL_COLOR := Color("0b1116")

@onready var save_service: SaveService = $SaveService
@onready var audio_director: FortKnocksAudioDirector = $AudioDirector
@onready var current_screen: Node = $CurrentScreen

var _active_mission: MissionDefinition
var _hub_notice := ""
var _garage_notice := ""
var _workshop_notice := ""
var _transition_overlay: ColorRect
var _transition_tween: Tween

func _ready() -> void:
	_ensure_transition_overlay()
	_reconcile_campaign_unlocks()
	_show_hub()

func _show_hub() -> void:
	audio_director.set_context(&"hub")
	var hub := HubScene.instantiate() as FortKnocksHub
	_replace_screen(hub)
	hub.command_board_requested.connect(_show_command_board)
	hub.garage_requested.connect(_show_garage)
	hub.workshop_requested.connect(_show_workshop)
	hub.configure(save_service.snapshot(), _hub_notice)
	_hub_notice = ""

func _show_command_board() -> void:
	audio_director.play_cue(&"ui_confirm")
	audio_director.set_context(&"menu")
	var board := CommandBoardScene.instantiate() as CommandBoardScreen
	_replace_screen(board)
	board.mission_selected.connect(_start_mission)
	board.back_requested.connect(_show_hub)
	board.configure(save_service.snapshot())

func _show_garage() -> void:
	audio_director.play_cue(&"ui_confirm")
	audio_director.set_context(&"menu")
	var garage := GarageScene.instantiate() as GarageScreen
	_replace_screen(garage)
	garage.back_requested.connect(_show_hub)
	garage.platform_requested.connect(_on_platform_requested)
	garage.configure(save_service.snapshot(), _garage_notice)
	_garage_notice = ""

func _show_workshop() -> void:
	audio_director.play_cue(&"ui_confirm")
	audio_director.set_context(&"menu")
	var workshop := WorkshopScene.instantiate() as WorkshopScreen
	_replace_screen(workshop)
	workshop.back_requested.connect(_show_hub)
	workshop.module_requested.connect(_on_module_requested)
	workshop.specialist_weapon_requested.connect(_on_specialist_weapon_requested)
	workshop.configure(save_service.snapshot(), _workshop_notice)
	_workshop_notice = ""

func _reconcile_campaign_unlocks() -> void:
	for mission_id in save_service.completed_missions():
		var mission := EncounterCatalogScript.by_id(str(mission_id))
		if mission != null and not mission.next_mission_id.is_empty():
			save_service.unlock_mission(mission.next_mission_id)

func _on_specialist_weapon_requested(weapon_id: String) -> void:
	if not save_service.set_specialist_weapon(weapon_id):
		return

	audio_director.play_cue(&"ui_confirm")
	var display_name := "HEAVY SLUG" if weapon_id == "heavy_slug" else "SHOCK CAPSULE"
	_workshop_notice = "%s SET AS SPECIALIST" % display_name
	_hub_notice = "FIELD RACK UPDATED • BOLT + %s" % display_name
	_show_workshop()

func _on_module_requested(module_id: String) -> void:
	var platform_id := save_service.current_platform_id()
	var definition := PlatformModuleCatalogScript.by_id(module_id)
	if definition == null or not definition.supports_platform(platform_id):
		return

	if save_service.owns_module(module_id):
		if save_service.equip_module(platform_id, module_id):
			audio_director.play_cue(&"ui_confirm")
			_workshop_notice = "%s EQUIPPED" % definition.display_name.to_upper()
			_hub_notice = "WORKSHOP UPDATED • %s ACTIVE" % definition.display_name.to_upper()
			_show_workshop()
		return

	if not save_service.purchase_module(module_id, definition.purchase_cost):
		_workshop_notice = "NOT ENOUGH SALVAGE"
		_show_workshop()
		return

	audio_director.play_cue(&"ui_confirm")
	save_service.equip_module(platform_id, module_id)
	_workshop_notice = "%s BUILT • -%d SALVAGE" % [
		definition.display_name.to_upper(),
		definition.purchase_cost,
	]
	_hub_notice = "PLATFORM MODULE FITTED • %s" % definition.display_name.to_upper()
	_show_workshop()

func _on_platform_requested(platform_id: String) -> void:
	var definition := PlatformCatalogScript.by_id(platform_id)
	if definition == null:
		return

	var completed := save_service.completed_missions()
	var unlocked := definition.unlock_after_mission_id.is_empty() or completed.has(definition.unlock_after_mission_id)
	if not unlocked or not definition.purchasable:
		return

	if save_service.owns_platform(platform_id):
		if save_service.equip_platform(platform_id):
			audio_director.play_cue(&"ui_confirm")
			_garage_notice = "%s EQUIPPED" % definition.display_name.to_upper()
			_hub_notice = "GARAGE UPDATED • %s ACTIVE" % definition.display_name.to_upper()
		_show_garage()
		return

	if not save_service.purchase_platform(platform_id, definition.purchase_cost):
		_garage_notice = "NOT ENOUGH SALVAGE"
		_show_garage()
		return

	audio_director.play_cue(&"ui_confirm")
	save_service.equip_platform(platform_id)
	_garage_notice = "%s ACQUIRED • -%d SALVAGE" % [
		definition.display_name.to_upper(),
		definition.purchase_cost,
	]
	_hub_notice = "GARAGE UPGRADE COMPLETE • %s ACTIVE" % definition.display_name.to_upper()
	_show_garage()

func _start_mission(mission: MissionDefinition) -> void:
	if mission == null:
		return

	_active_mission = mission
	audio_director.play_cue(&"ui_confirm")
	audio_director.set_context(&"battle")
	var battle := BattleScene.instantiate()
	if battle == null:
		push_error("Battle scene could not be instantiated.")
		return

	var platform_id := save_service.current_platform_id()
	var platform := PlatformCatalogScript.by_id(platform_id)
	var module_id := save_service.equipped_module_id(platform_id)
	var module := PlatformModuleCatalogScript.by_id(module_id) if not module_id.is_empty() else null
	var weapon_ids: Array[String] = ["scrap_bolt"]
	if module != null and module.carry_both_specialists:
		weapon_ids.append("heavy_slug")
		weapon_ids.append("shock_capsule")
	else:
		weapon_ids.append(save_service.specialist_weapon_id())
	battle.call("prepare_for_campaign", mission, platform, module, weapon_ids)
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
	audio_director.play_cue(&"ui_back")
	_active_mission = null
	_show_hub()

func _on_battle_rematch_requested() -> void:
	var mission := _active_mission
	if mission != null:
		_start_mission(mission)

func _replace_screen(screen: Node) -> void:
	_ensure_transition_overlay()
	if _transition_overlay != null:
		_transition_overlay.visible = true
		_transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
		_transition_overlay.modulate.a = 1.0

	for child in current_screen.get_children():
		current_screen.remove_child(child)
		child.queue_free()
	current_screen.add_child(screen)
	_play_screen_reveal()

func _ensure_transition_overlay() -> void:
	if is_instance_valid(_transition_overlay):
		return

	var layer := CanvasLayer.new()
	layer.name = "ScreenTransitionLayer"
	layer.layer = 100
	add_child(layer)

	_transition_overlay = ColorRect.new()
	_transition_overlay.name = "ScreenReveal"
	_transition_overlay.color = SCREEN_REVEAL_COLOR
	_transition_overlay.modulate.a = 0.0
	_transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_overlay.visible = false
	layer.add_child(_transition_overlay)
	_transition_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _play_screen_reveal() -> void:
	if not is_instance_valid(_transition_overlay):
		return

	if _transition_tween != null:
		_transition_tween.kill()
	_transition_tween = create_tween()
	_transition_tween.tween_property(
		_transition_overlay,
		"modulate:a",
		0.0,
		SCREEN_REVEAL_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_transition_tween.finished.connect(_on_screen_reveal_finished)

func _on_screen_reveal_finished() -> void:
	if not is_instance_valid(_transition_overlay):
		return
	_transition_overlay.visible = false
	_transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_tween = null

func _current_child() -> Node:
	if current_screen.get_child_count() == 0:
		return null
	return current_screen.get_child(0)
