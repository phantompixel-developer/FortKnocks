class_name MissionData
extends Resource
## One mission. Its number and lock state are worked out by the board from
## campaign order + the player's current mission, so they are not stored here.

@export var id := &""
@export var title := "MISSION"
@export_multiline var objective := ""
@export var reward_coins := 0
