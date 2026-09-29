class_name EncounterCatalog
extends RefCounted

const RoadblockTrial := preload("res://game/campaign/missions/roadblock_trial.tres")
const HighGroundTrial := preload("res://game/campaign/missions/high_ground_trial.tres")
const ScrapGateTrial := preload("res://game/campaign/missions/scrap_gate_trial.tres")

static func all() -> Array[MissionDefinition]:
	var missions: Array[MissionDefinition] = []
	missions.append(RoadblockTrial as MissionDefinition)
	missions.append(HighGroundTrial as MissionDefinition)
	missions.append(ScrapGateTrial as MissionDefinition)
	return missions

static func by_id(mission_id: String) -> MissionDefinition:
	for mission in all():
		if mission.id == mission_id:
			return mission
	return null
