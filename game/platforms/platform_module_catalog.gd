class_name PlatformModuleCatalog
extends RefCounted

const SpotterRack := preload("res://game/platforms/modules/spotter_rack.tres")
const BallastCrates := preload("res://game/platforms/modules/ballast_crates.tres")
const TwinFieldRack := preload("res://game/platforms/modules/twin_field_rack.tres")
const StabilizerRig := preload("res://game/platforms/modules/stabilizer_rig.tres")

static func all() -> Array[PlatformModuleDefinition]:
	var definitions: Array[PlatformModuleDefinition] = []
	definitions.append(SpotterRack as PlatformModuleDefinition)
	definitions.append(BallastCrates as PlatformModuleDefinition)
	definitions.append(TwinFieldRack as PlatformModuleDefinition)
	definitions.append(StabilizerRig as PlatformModuleDefinition)
	return definitions

static func for_platform(platform_id: String) -> Array[PlatformModuleDefinition]:
	var definitions: Array[PlatformModuleDefinition] = []
	for definition in all():
		if definition.supports_platform(platform_id):
			definitions.append(definition)
	return definitions

static func by_id(module_id: String) -> PlatformModuleDefinition:
	for definition in all():
		if definition.id == module_id:
			return definition
	return null
