class_name AimGuide
extends Node2D

var _velocity := Vector2.ZERO
var _active := false
var _gravity := 980.0

func _ready() -> void:
	_gravity = float(ProjectSettings.get_setting("physics/2d/default_gravity", 980.0))

func show_prediction(origin: Vector2, launch_velocity: Vector2) -> void:
	global_position = origin
	_velocity = launch_velocity
	_active = true
	queue_redraw()

func clear() -> void:
	_active = false
	queue_redraw()

func _draw() -> void:
	if not _active:
		return

	for i in range(1, 10):
		var t := float(i) * 0.085
		var point := _velocity * t + Vector2(0.0, 0.5 * _gravity * t * t)
		var radius := maxf(2.5, 5.5 - float(i) * 0.3)
		draw_circle(point, radius, Color(0.95, 0.92, 0.70, 0.82))
