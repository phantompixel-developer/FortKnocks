class_name AimGuide
extends Node2D

const BASE_PREVIEW_STEPS := 9
const SAMPLE_INTERVAL := 0.085

var _velocity := Vector2.ZERO
var _pullback_offset := Vector2.ZERO
var _active := false
var _gravity := 980.0
var _preview_steps := BASE_PREVIEW_STEPS

func _ready() -> void:
	_gravity = float(ProjectSettings.get_setting("physics/2d/default_gravity", 980.0))

func set_preview_steps(steps: int) -> void:
	_preview_steps = clampi(steps, BASE_PREVIEW_STEPS, 17)
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

func has_precision_preview() -> bool:
	return _preview_steps > BASE_PREVIEW_STEPS

func _trajectory_point(t: float) -> Vector2:
	return _velocity * t + Vector2(0.0, 0.5 * _gravity * t * t)

func _draw() -> void:
	if not _active:
		return

	draw_line(Vector2.ZERO, _pullback_offset, Color("33413c", 0.90), 7.0, true)
	draw_circle(_pullback_offset, 18.0, Color("171c1b", 0.96))
	draw_circle(_pullback_offset, 13.0, Color("d4aa55", 0.94))
	draw_circle(_pullback_offset, 6.0, Color("303a35", 0.98))

	for i in range(1, BASE_PREVIEW_STEPS + 1):
		var t := float(i) * SAMPLE_INTERVAL
		var point := _trajectory_point(t)
		var radius := maxf(2.8, 5.6 - float(i) * 0.28)
		draw_circle(point, radius + 2.0, Color("171c1b", 0.42))
		draw_circle(point, radius, Color("eadca9", 0.90))

	if not has_precision_preview():
		return

	for i in range(1, BASE_PREVIEW_STEPS):
		var t := (float(i) + 0.5) * SAMPLE_INTERVAL
		var point := _trajectory_point(t)
		draw_circle(point, 4.5, Color("171c1b", 0.36))
		draw_circle(point, 2.7, Color("77b6bf", 0.88))

	var extension_steps := _preview_steps - BASE_PREVIEW_STEPS
	for extension_index in range(1, extension_steps + 1):
		var sample_index := BASE_PREVIEW_STEPS + extension_index
		var t := float(sample_index) * SAMPLE_INTERVAL
		var point := _trajectory_point(t)
		draw_circle(point, 5.2, Color("171c1b", 0.36))
		draw_circle(point, 3.5, Color("77b6bf", 0.94))
		if extension_index == extension_steps:
			draw_arc(point, 8.0, 0.0, TAU, 20, Color("c5eeee", 0.88), 2.0, true)
