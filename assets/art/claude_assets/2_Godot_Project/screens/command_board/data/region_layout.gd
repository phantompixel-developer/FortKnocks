class_name RegionLayout
extends Resource
## A hand-composed region section, authored for a 1080px-wide board.
## Coordinates are relative to the section's top-left. Regions can use a layout
## mirrored left/right so the same composition reads differently.

@export var section_height := 1000.0
@export var polaroid_position := Vector2(290, 250)
@export var polaroid_rotation_deg := -4.0
## 0 = push pin, 1 = tape
@export_enum("Pin", "Tape") var polaroid_attachment := 0
## Mission pin centres, in route order. A region uses the first N (N = its mission count).
@export var pins: PackedVector2Array = PackedVector2Array()
## Decor items: {"id": String, "pos": Vector2, "rot": float (deg), "scale": float, "over": bool}
## "over" = drawn above the polaroid (tape, pins); otherwise beneath it.
@export var decor: Array = []
