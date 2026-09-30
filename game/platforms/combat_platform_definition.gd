class_name CombatPlatformDefinition
extends Resource

@export var id := "platform"
@export var display_name := "Combat Platform"
@export_multiline var tactical_summary := ""
@export var purchase_cost := 0
@export var unlock_after_mission_id := ""
@export var purchasable := true
@export_range(0, 3, 1) var utility_slot_count := 0

@export_group("Battle profile")
@export var cover_health := 150
@export var cover_size := Vector2(240.0, 95.0)
@export var cover_color := Color("7a6554")
@export_range(0, 3, 1) var visual_profile := 0
