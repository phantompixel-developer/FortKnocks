class_name RegionData
extends Resource
## A location within a chapter (Outskirts, Suburbs ...) and its missions.

@export var id := &""
@export var display_name := "REGION"
@export var photo: Texture2D
@export var layout: RegionLayout
@export var mirrored := false
@export var missions: Array[MissionData] = []
