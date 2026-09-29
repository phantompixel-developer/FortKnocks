class_name MissionDefinition
extends Resource

@export var id := "mission"
@export var display_name := "Encounter"
@export_multiline var briefing := ""
@export var objective_text := "INCAPACITATE ENEMY"

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

@export_group("Greybox geometry")
@export var platform_rects: Array[Rect2] = []
@export_range(0, 2, 1) var visual_variant := 0
