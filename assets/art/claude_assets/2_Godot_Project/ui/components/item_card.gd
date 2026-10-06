@tool
class_name ItemCard
extends Button
## Selectable card used by the Garage (vehicles) and Workshop (ammo).
## Locked state is applied here: the thumbnail is darkened and the lock icon shown.
## Each item therefore needs only ONE normal thumbnail.

const LOCKED_TINT := Color(0.42, 0.45, 0.52)

@export var thumbnail: Texture2D:
	set(v):
		thumbnail = v
		_refresh()
@export var locked := false:
	set(v):
		locked = v
		_refresh()
@export var selected := false:
	set(v):
		selected = v
		_refresh()
## Optional caption at the bottom of the card (Workshop uses this).
@export var caption := "":
	set(v):
		caption = v
		_refresh()


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return
	%Thumb.texture = thumbnail
	%Thumb.self_modulate = LOCKED_TINT if locked else Color.WHITE
	%Lock.visible = locked
	%Frame.visible = not selected
	%SelectedFrame.visible = selected
	%Caption.text = caption
	%Caption.visible = caption != ""
	%Thumb.offset_bottom = -64.0 if caption != "" else -18.0
