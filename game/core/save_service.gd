class_name SaveService
extends Node

signal save_changed(snapshot: Dictionary)

const SAVE_PATH := "user://fort_knocks_save.json"
const CURRENT_SAVE_VERSION := 1
const STARTING_MISSION_ID := "roadblock_trial"

var _data: Dictionary = {}

func _ready() -> void:
	load_save()

func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_data = _default_data()
		_persist()
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("Fort Knocks save could not be opened. Starting with a fresh save.")
		_data = _default_data()
		return

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("Fort Knocks save was invalid JSON. Starting with a fresh save.")
		_data = _default_data()
		_persist()
		return

	_data = _migrate_save(parsed as Dictionary)
	_normalize()
	save_changed.emit(snapshot())

func snapshot() -> Dictionary:
	return _data.duplicate(true)

func salvage() -> int:
	var inventory := _data.get("inventory", {}) as Dictionary
	return int(inventory.get("salvage", 0))

func current_platform_id() -> String:
	var inventory := _data.get("inventory", {}) as Dictionary
	return str(inventory.get("platform_id", "run_down_compact"))

func completed_missions() -> Array:
	var campaign := _data.get("campaign", {}) as Dictionary
	return (campaign.get("completed_missions", []) as Array).duplicate()

func unlocked_missions() -> Array:
	var campaign := _data.get("campaign", {}) as Dictionary
	return (campaign.get("unlocked_missions", [STARTING_MISSION_ID]) as Array).duplicate()

func is_mission_completed(mission_id: String) -> bool:
	return completed_missions().has(mission_id)

func is_mission_unlocked(mission_id: String) -> bool:
	return unlocked_missions().has(mission_id)

func complete_mission(
	mission_id: String,
	salvage_reward: int,
	next_mission_id: String
) -> int:
	var campaign := _data.get("campaign", {}) as Dictionary
	var inventory := _data.get("inventory", {}) as Dictionary
	var completed := campaign.get("completed_missions", []) as Array
	var unlocked := campaign.get("unlocked_missions", [STARTING_MISSION_ID]) as Array

	if completed.has(mission_id):
		return 0

	completed.append(mission_id)
	if not next_mission_id.is_empty() and not unlocked.has(next_mission_id):
		unlocked.append(next_mission_id)

	var awarded := maxi(0, salvage_reward)
	inventory["salvage"] = int(inventory.get("salvage", 0)) + awarded
	campaign["completed_missions"] = completed
	campaign["unlocked_missions"] = unlocked
	_data["campaign"] = campaign
	_data["inventory"] = inventory
	_persist()
	save_changed.emit(snapshot())
	return awarded

func reset_to_new_game() -> void:
	_data = _default_data()
	_persist()
	save_changed.emit(snapshot())

func _default_data() -> Dictionary:
	return {
		"save_version": CURRENT_SAVE_VERSION,
		"campaign": {
			"completed_missions": [],
			"unlocked_missions": [STARTING_MISSION_ID],
		},
		"inventory": {
			"salvage": 0,
			"platform_id": "run_down_compact",
		},
		"crew": {},
		"settings": {},
	}

func _migrate_save(source: Dictionary) -> Dictionary:
	var version := int(source.get("save_version", 0))
	if version == CURRENT_SAVE_VERSION:
		return source.duplicate(true)

	# Persistence starts at schema v1. Future migrations are added here rather
	# than teaching gameplay systems how to reinterpret older saves.
	push_warning("Unsupported Fort Knocks save version %d. Starting a new v%d save." % [
		version,
		CURRENT_SAVE_VERSION,
	])
	return _default_data()

func _normalize() -> void:
	if typeof(_data.get("campaign", null)) != TYPE_DICTIONARY:
		_data["campaign"] = {}
	if typeof(_data.get("inventory", null)) != TYPE_DICTIONARY:
		_data["inventory"] = {}
	if typeof(_data.get("crew", null)) != TYPE_DICTIONARY:
		_data["crew"] = {}
	if typeof(_data.get("settings", null)) != TYPE_DICTIONARY:
		_data["settings"] = {}

	var campaign := _data["campaign"] as Dictionary
	var inventory := _data["inventory"] as Dictionary

	if typeof(campaign.get("completed_missions", null)) != TYPE_ARRAY:
		campaign["completed_missions"] = []
	if typeof(campaign.get("unlocked_missions", null)) != TYPE_ARRAY:
		campaign["unlocked_missions"] = [STARTING_MISSION_ID]
	if not (campaign["unlocked_missions"] as Array).has(STARTING_MISSION_ID):
		(campaign["unlocked_missions"] as Array).append(STARTING_MISSION_ID)

	if typeof(inventory.get("salvage", null)) not in [TYPE_INT, TYPE_FLOAT]:
		inventory["salvage"] = 0
	inventory["salvage"] = maxi(0, int(inventory.get("salvage", 0)))
	if not inventory.has("platform_id") or str(inventory.get("platform_id", "")).is_empty():
		inventory["platform_id"] = "run_down_compact"

	_data["save_version"] = CURRENT_SAVE_VERSION
	_data["campaign"] = campaign
	_data["inventory"] = inventory

func _persist() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Fort Knocks save could not be written.")
		return
	file.store_string(JSON.stringify(_data, "\t"))
