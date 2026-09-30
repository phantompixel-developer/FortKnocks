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

	# Virtual tension line shows the finger pulling opposite the firing direction.
	draw_line(Vector2.ZERO, _pullback_offset, Color(0.32, 0.30, 0.25, 0.82), 5.0, true)
	draw_circle(_pullback_offset, 16.0, Color(0.86, 0.78, 0.52, 0.92))
	draw_circle(_pullback_offset, 8.0, Color(0.27, 0.27, 0.24, 0.96))

	# Baseline preview: nine sparse gold markers. This remains deliberately partial.
	for i in range(1, BASE_PREVIEW_STEPS + 1):
		var t := float(i) * SAMPLE_INTERVAL
		var point := _trajectory_point(t)
		var radius := maxf(2.8, 5.5 - float(i) * 0.28)
		draw_circle(point, radius, Color(0.95, 0.92, 0.70, 0.84))

	if not has_precision_preview():
		return

	# Spotter Rack adds visible information inside the existing portrait view:
	# midpoint samples make the known section of the curve denser instead of
	# placing the whole advantage off-screen.
	for i in range(1, BASE_PREVIEW_STEPS):
		var t := (float(i) + 0.5) * SAMPLE_INTERVAL
		var point := _trajectory_point(t)
		draw_circle(point, 2.8, Color(0.61, 0.84, 0.88, 0.78))

	# It also adds a short highlighted continuation beyond the normal horizon.
	var extension_steps := _preview_steps - BASE_PREVIEW_STEPS
	for extension_index in range(1, extension_steps + 1):
		var sample_index := BASE_PREVIEW_STEPS + extension_index
		var t := float(sample_index) * SAMPLE_INTERVAL
		var point := _trajectory_point(t)
		draw_circle(point, 3.5, Color(0.61, 0.84, 0.88, 0.88))
		if extension_index == extension_steps:
			draw_arc(point, 7.0, 0.0, TAU, 20, Color(0.74, 0.93, 0.95, 0.82), 1.8, true)
