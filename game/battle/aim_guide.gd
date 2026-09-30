class_name AimGuide
extends Node2D

var _velocity := Vector2.ZERO
var _pullback_offset := Vector2.ZERO
var _active := false
var _gravity := 980.0
var _preview_steps := 9

func _ready() -> void:
	_gravity = float(ProjectSettings.get_setting("physics/2d/default_gravity", 980.0))

func set_preview_steps(steps: int) -> void:
	_preview_steps = clampi(steps, 6, 17)
	if _active:
		queue_redraw()

func show_prediction(origin: Vector2, launch_velocity: Vector2, pullback_offset: Vector2) -> void:
	global_position = origin
	_velocity = launch_velocity
	_pullback_offset = pullback_offset
	_active = true
	queue_redraw()

func clear() -> void:
	_active = false
	queue_redraw()

func _draw() -> void:
	if not _active:
		return

	# Virtual tension line shows the finger pulling opposite the firing direction.
	draw_line(Vector2.ZERO, _pullback_offset, Color(0.32, 0.30, 0.25, 0.82), 5.0, true)
	draw_circle(_pullback_offset, 16.0, Color(0.86, 0.78, 0.52, 0.92))
	draw_circle(_pullback_offset, 8.0, Color(0.27, 0.27, 0.24, 0.96))

	for i in range(1, _preview_steps + 1):
		var t := float(i) * 0.085
		var point := _velocity * t + Vector2(0.0, 0.5 * _gravity * t * t)
		var radius := maxf(2.5, 5.5 - float(i) * 0.3)
		draw_circle(point, radius, Color(0.95, 0.92, 0.70, 0.82))
