class_name WeaponDefinition
extends Resource

@export var id := "weapon"
@export var display_name := "Weapon"
@export_multiline var description := ""
@export var direct_damage := 50
@export var cover_damage := 50
@export var knockback_force := 520.0
@export var speed_multiplier := 1.0
@export var max_ground_bounces := 0
@export var bounce_factor := 0.0
@export var secondary_bounce_factor := 0.0
@export var blast_radius := 0.0
@export var blast_damage := 0
@export var blast_force := 0.0
@export var projectile_color := Color("f2df85")
@export var trail_color := Color(0.91, 0.82, 0.53, 0.58)


@export_group("Workshop upgrade")
@export_range(1, 4, 1) var max_level := 4
@export var upgrade_base_cost := 35
@export var direct_damage_per_level := 5
@export var cover_damage_per_level := 6
@export var blast_damage_per_level := 4

func upgrade_cost(current_level: int) -> int:
	var safe_level: int = clampi(current_level, 1, max_level)
	if safe_level >= max_level:
		return 0
	return maxi(0, upgrade_base_cost * safe_level)

func copy_at_level(level: int) -> WeaponDefinition:
	var upgraded := duplicate(true) as WeaponDefinition
	if upgraded == null:
		return self
	var safe_level: int = clampi(level, 1, max_level)
	var bonus_levels: int = safe_level - 1
	upgraded.direct_damage += direct_damage_per_level * bonus_levels
	upgraded.cover_damage += cover_damage_per_level * bonus_levels
	upgraded.blast_damage += blast_damage_per_level * bonus_levels
	return upgraded
