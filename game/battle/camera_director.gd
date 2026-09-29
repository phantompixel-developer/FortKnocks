class_name BattleCameraDirector
extends Node2D

@export var world_left := 0.0
@export var world_right := 2160.0
@export var viewport_half_width := 360.0
@export var fixed_y := 640.0
@export var follow_response := 8.0

@onready var camera: Camera2D = $Camera2D

var _follow_target: Node2D
var _move_tween: Tween
var _impulse_tween: Tween

func _ready() -> void:
	global_position = Vector2(viewport_half_width, fixed_y)
	camera.enabled = true

func focus_x(world_x: float, duration := 0.45) -> void:
	_follow_target = null
	if _move_tween != null and _move_tween.is_running():
		_move_tween.kill()

	var target := Vector2(_clamp_x(world_x), fixed_y)
	if duration <= 0.0:
		global_position = target
		return

	_move_tween = create_tween()
	_move_tween.set_trans(Tween.TRANS_CUBIC)
	_move_tween.set_ease(Tween.EASE_IN_OUT)
	_move_tween.tween_property(self, "global_position", target, duration)

func follow(target: Node2D) -> void:
	if _move_tween != null and _move_tween.is_running():
		_move_tween.kill()
	_follow_target = target

func stop_follow_at(world_position: Vector2, duration := 0.16) -> void:
	_follow_target = null
	focus_x(world_position.x, duration)

func impact_impulse(strength := 1.0, horizontal_direction := 1.0) -> void:
	if _impulse_tween != null and _impulse_tween.is_running():
		_impulse_tween.kill()

	var direction := signf(horizontal_direction)
	if is_zero_approx(direction):
		direction = 1.0

	var amount := clampf(strength, 0.25, 1.25)
	camera.offset = Vector2(17.0 * amount * direction, -10.0 * amount)

	_impulse_tween = create_tween()
	_impulse_tween.tween_property(camera, "offset", Vector2(-8.0 * amount * direction, 5.0 * amount), 0.055)
	_impulse_tween.tween_property(camera, "offset", Vector2.ZERO, 0.11).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	if _follow_target == null or not is_instance_valid(_follow_target):
		return

	var desired_x := _clamp_x(_follow_target.global_position.x)
	var smoothing := 1.0 - exp(-follow_response * delta)
	global_position.x = lerpf(global_position.x, desired_x, smoothing)
	global_position.y = fixed_y

func _clamp_x(value: float) -> float:
	return clampf(value, world_left + viewport_half_width, world_right - viewport_half_width)
