class_name PlatformCatalog
extends RefCounted

const RunDownCompact := preload("res://game/platforms/run_down_compact.tres")
const OldSedan := preload("res://game/platforms/old_sedan.tres")
const Pickup := preload("res://game/platforms/pickup.tres")
const ImprovisedTechnical := preload("res://game/platforms/improvised_technical.tres")

static func all() -> Array[CombatPlatformDefinition]:
	var definitions: Array[CombatPlatformDefinition] = []
	definitions.append(RunDownCompact as CombatPlatformDefinition)
	definitions.append(OldSedan as CombatPlatformDefinition)
	definitions.append(Pickup as CombatPlatformDefinition)
	definitions.append(ImprovisedTechnical as CombatPlatformDefinition)
	return definitions

static func by_id(platform_id: String) -> CombatPlatformDefinition:
	for definition in all():
		if definition.id == platform_id:
			return definition
	return RunDownCompact as CombatPlatformDefinition
