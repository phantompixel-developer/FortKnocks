class_name UpgradeItemData
extends Resource
## One upgradeable item (vehicle, ammo, ...). Stats are in bar segments.

@export var id := &""
@export var display_name := "ITEM"
## Short label shown on the card (Workshop uses it; leave empty for none).
@export var caption := ""
@export var level := 1
@export var locked := false
@export var upgrade_cost := 0
## Card thumbnail. One normal version only - the locked look is applied in-engine.
@export var thumbnail: Texture2D
## Large display art for the showroom. Falls back to the thumbnail if empty.
@export var showroom_texture: Texture2D
## One value per stat row, in the order the screen lists its stats.
@export var stats: Array[int] = [1, 1, 1, 1]
## Extra segments the next upgrade adds (drawn in the "preview" colour).
@export var upgrade_preview: Array[int] = [0, 0, 0, 0]
