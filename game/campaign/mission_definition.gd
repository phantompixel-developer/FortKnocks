class_name MissionDefinition
extends Resource

@export var id := "mission"
@export var display_name := "Encounter"
@export var test_focus := "BASELINE"

@export_group("Player-facing presentation")
@export_enum("outskirts", "suburbs") var region_id: String = "outskirts"
@export var location_tag := "ROADSIDE"
@export var tactical_warning := ""
@export_multiline var briefing := ""
@export var objective_text := "INCAPACITATE ENEMY"
@export_enum("incapacitate_enemy", "disable_relay", "protect_salvage") var objective_mode: String = "incapacitate_enemy"

@export_group("Campaign progression")
@export var campaign_order := 0
@export var salvage_reward := 0
@export var next_mission_id := ""

@export_group("Tactical preview")
@export var feature_preview_enabled := false
@export var feature_preview_position := Vector2(1080.0, 900.0)
@export var feature_preview_text := "KEY BATTLEFIELD FEATURE"

@export_group("Combatant positions")
@export var player_position := Vector2(300.0, 1040.0)
@export var player_cover_position := Vector2(520.0, 1000.0)
@export var enemy_position := Vector2(1860.0, 1040.0)
@export var enemy_cover_position := Vector2(1540.0, 1000.0)

@export_group("Authored encounter features")
@export var roadblock_enabled := true
@export var roadblock_position := Vector2(1080.0, 958.0)
@export var power_cell_enabled := true
@export var power_cell_position := Vector2(1715.0, 1028.0)
@export var collapsible_barrier_enabled := false
@export var collapsible_barrier_position := Vector2(1220.0, 900.0)
@export var signal_relay_enabled: bool = false
@export var signal_relay_position: Vector2 = Vector2(1450.0, 1000.0)
@export var signal_relay_health: int = 120
@export var salvage_load_enabled: bool = false
@export var salvage_load_position: Vector2 = Vector2(760.0, 1000.0)
@export var salvage_load_health: int = 150

@export_group("Enemy tactics")
@export_enum("balanced", "breacher", "displacer", "raider") var enemy_tactic: String = "balanced"

@export_group("Greybox geometry")
@export var platform_rects: Array[Rect2] = []
@export_range(0, 3, 1) var visual_variant := 0
