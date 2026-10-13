extends SceneTree

const BattleScene := preload("res://game/battle/battle.tscn")
const EncounterCatalogScript := preload("res://game/campaign/encounter_catalog.gd")
const CAPTURE_DIR := "res://.godot/validation/battlefield_v2"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(720, 1280)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))

	debug_collisions_hint = true
	await _capture_mission("roadblock_trial", false, "roadblock_player_collision.png")
	await _capture_mission("roadblock_trial", true, "roadblock_enemy_collision.png")

	debug_collisions_hint = false
	await _capture_mission("high_ground_trial", true, "high_ground_enemy_vehicle.png")
	await _capture_mission("suburbs_dead_air", true, "suburbs_enemy_vehicle.png")

	print("BATTLE_VISUAL_CAPTURE: PASS -> %s" % ProjectSettings.globalize_path(CAPTURE_DIR))
	quit(0)


func _capture_mission(mission_id: String, focus_enemy: bool, file_name: String) -> void:
	var definition: MissionDefinition = EncounterCatalogScript.by_id(mission_id)
	if definition == null:
		push_error("BATTLE_VISUAL_CAPTURE: unknown mission %s" % mission_id)
		return

	var battle := BattleScene.instantiate()
	root.add_child(battle)
	await process_frame
	battle.call("_begin_mission", definition)
	await process_frame
	await physics_frame

	var mission_brief := battle.get_node("HUD/Root/MissionBriefCard") as Control
	var encounter_picker := battle.get_node("HUD/Root/EncounterPicker") as Control
	mission_brief.visible = false
	encounter_picker.visible = false
	if focus_enemy:
		battle.call("_focus_enemy", 0.0)
	else:
		battle.call("_focus_player", 0.0)
	await process_frame
	await RenderingServer.frame_post_draw

	var image := root.get_texture().get_image()
	var output_path := "%s/%s" % [CAPTURE_DIR, file_name]
	var error := image.save_png(output_path)
	if error != OK:
		push_error("BATTLE_VISUAL_CAPTURE: failed to save %s (%s)" % [output_path, error_string(error)])

	battle.queue_free()
	await process_frame
