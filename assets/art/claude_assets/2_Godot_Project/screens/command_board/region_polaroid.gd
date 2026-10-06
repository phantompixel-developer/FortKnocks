@tool
class_name RegionPolaroid
extends Control
## Polaroid header for a region. Size 460x420; rotate via `rotation_degrees`.

@export var photo: Texture2D:
	set(v):
		photo = v
		_refresh()
@export var caption := "REGION":
	set(v):
		caption = v
		_refresh()
@export_enum("Pin", "Tape") var attachment := 0:
	set(v):
		attachment = v
		_refresh()
## True for regions the player hasn't reached yet (photo dimmed).
@export var dimmed := false:
	set(v):
		dimmed = v
		_refresh()


func _ready() -> void:
	pivot_offset = size * 0.5
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return
	%Photo.texture = photo
	%Caption.text = caption
	%Pin.visible = attachment == 0
	%Tape.visible = attachment == 1
	%Photo.self_modulate = Color(0.55, 0.55, 0.6) if dimmed else Color.WHITE
