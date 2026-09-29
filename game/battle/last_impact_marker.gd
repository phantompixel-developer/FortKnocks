class_name LastImpactMarker
extends Node2D

var has_valid_marker := false

func place_marker(world_position: Vector2) -> void:
	global_position = world_position
	has_valid_marker = true
	visible = true
	queue_redraw()

func clear_marker() -> void:
	has_valid_marker = false
	visible = false

func _draw() -> void:
	var outer := Color(0.94, 0.84, 0.46, 0.82)
	var inner := Color(0.22, 0.23, 0.21, 0.92)

	draw_circle(Vector2.ZERO, 20.0, Color(outer, 0.18))
	draw_arc(Vector2.ZERO, 17.0, 0.0, TAU, 28, outer, 3.0, true)
	draw_line(Vector2(-13, 0), Vector2(13, 0), inner, 3.0, true)
	draw_line(Vector2(0, -13), Vector2(0, 13), inner, 3.0, true)
