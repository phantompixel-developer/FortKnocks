class_name CombatPlatformDefinition
extends Resource

@export var id := "platform"
@export var display_name := "Combat Platform"
@export_multiline var tactical_summary := ""
@export var purchase_cost := 0
@export var unlock_after_mission_id := ""
@export var purchasable := true
@export_range(0, 3, 1) var utility_slot_count := 0

@export_group("Garage upgrade")
@export_range(1, 4, 1) var max_level := 4
@export var upgrade_base_cost := 40
@export var upgrade_health_per_level := 20

@export_group("Battle profile")
@export var cover_health := 150
@export var cover_size := Vector2(240.0, 95.0)
@export var cover_color := Color("7a6554")
@export_range(0, 3, 1) var visual_profile := 0


func upgrade_cost(current_level: int) -> int:
	var safe_level: int = clampi(current_level, 1, max_level)
	if safe_level >= max_level:
		return 0
	return maxi(0, upgrade_base_cost * safe_level)

func cover_health_at_level(level: int) -> int:
	var safe_level: int = clampi(level, 1, max_level)
	return cover_health + (safe_level - 1) * upgrade_health_per_level
