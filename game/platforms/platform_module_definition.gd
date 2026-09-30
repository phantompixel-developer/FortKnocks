class_name PlatformModuleDefinition
extends Resource

@export var id := "module"
@export var display_name := "Utility Module"
@export_multiline var tactical_summary := ""
@export var purchase_cost := 0
@export var compatible_platform_ids: Array[String] = []

@export_group("Battle effects")
@export var cover_health_bonus := 0
@export_range(0, 8, 1) var trajectory_preview_steps_bonus := 0
@export var carry_both_specialists: bool = false
@export_range(0.25, 1.0, 0.05) var crew_knockback_multiplier: float = 1.0

func supports_platform(platform_id: String) -> bool:
	return compatible_platform_ids.has(platform_id)
