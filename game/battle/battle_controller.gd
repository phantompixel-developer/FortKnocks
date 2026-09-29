extends Node2D

enum Phase {
	INTRO,
	PLAYER_AIM,
	PROJECTILE,
	ENEMY_THINKING,
	GAME_OVER,
}

const ProjectileScene := preload("res://game/battle/projectile.tscn")
const MAX_DRAG := 340.0
const MIN_FIRE_DRAG := 36.0
const MIN_SPEED := 520.0
const MAX_SPEED := 1380.0

@onready var camera_director: Node2D = $CameraDirector
@onready var player: CharacterBody2D = $World/Player
@onready var enemy: CharacterBody2D = $World/Enemy
@onready var player_cover: StaticBody2D = $World/PlayerCover
@onready var enemy_cover: StaticBody2D = $World/EnemyCover
@onready var projectile_layer: Node2D = $ProjectileLayer
@onready var aim_guide: Node2D = $AimGuide
@onready var turn_label: Label = $HUD/Root/TurnLabel
@onready var health_label: Label = $HUD/Root/HealthLabel
@onready var enemy_health_label: Label = $HUD/Root/EnemyHealthLabel
@onready var power_label: Label = $HUD/Root/PowerLabel
@onready var hint_label: Label = $HUD/Root/HintLabel
@onready var restart_button: Button = $HUD/Root/RestartButton

var phase := Phase.INTRO
var _dragging := false
var _drag_start := Vector2.ZERO
var _aim_velocity := Vector2.ZERO
var _aim_power := 0.0
var _active_shooter: CharacterBody2D

func _ready() -> void:
	player.health_changed.connect(_on_health_changed)
	enemy.health_changed.connect(_on_health_changed)
	restart_button.pressed.connect(_restart)
	restart_button.visible = false
	_update_hud()
	await get_tree().process_frame
	_start_player_turn(true)

func _unhandled_input(event: InputEvent) -> void:
	if phase != Phase.PLAYER_AIM:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			_begin_drag(event.position)
		else:
			_end_drag(event.position)
	elif event is InputEventScreenDrag:
		_update_drag(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_begin_drag(event.position)
		else:
			_end_drag(event.position)
	elif event is InputEventMouseMotion and _dragging and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_update_drag(event.position)

func _begin_drag(screen_position: Vector2) -> void:
	if screen_position.y < 250.0:
		return
	_dragging = true
	_drag_start = screen_position
	_aim_power = 0.0
	hint_label.text = "Drag up and right • release to fire"

func _update_drag(screen_position: Vector2) -> void:
	if not _dragging:
		return

	var drag := screen_position - _drag_start
	var length := minf(drag.length(), MAX_DRAG)
	if length < 1.0:
		return

	var angle := atan2(-drag.y, maxf(drag.x, 1.0))
	angle = clampf(angle, deg_to_rad(10.0), deg_to_rad(80.0))
	_aim_power = clampf(length / MAX_DRAG, 0.0, 1.0)
	var speed := lerpf(MIN_SPEED, MAX_SPEED, _aim_power)
	_aim_velocity = Vector2(cos(angle), -sin(angle)) * speed

	aim_guide.show_prediction(player.get_launch_origin(), _aim_velocity)
	power_label.text = "POWER %d%%" % int(round(_aim_power * 100.0))

func _end_drag(screen_position: Vector2) -> void:
	if not _dragging:
		return

	_update_drag(screen_position)
	_dragging = false

	if _aim_power * MAX_DRAG < MIN_FIRE_DRAG:
		aim_guide.clear()
		power_label.text = "POWER —"
		hint_label.text = "Drag up and right to aim"
		return

	_fire_projectile(player, _aim_velocity)

func _start_player_turn(show_enemy_preview: bool) -> void:
	if _check_game_over():
		return

	phase = Phase.INTRO
	aim_guide.clear()
	power_label.text = "POWER —"
	turn_label.text = "YOUR TURN"

	if show_enemy_preview:
		hint_label.text = "Enemy position"
		camera_director.focus_x(enemy.global_position.x, 0.35)
		await get_tree().create_timer(0.70).timeout
		if phase == Phase.GAME_OVER:
			return

	hint_label.text = "Returning to your position"
	camera_director.focus_x(player.global_position.x, 0.48)
	await get_tree().create_timer(0.52).timeout
	if phase == Phase.GAME_OVER:
		return

	phase = Phase.PLAYER_AIM
	hint_label.text = "Drag up and right to aim • release to fire"

func _start_enemy_turn() -> void:
	if _check_game_over():
		return

	phase = Phase.ENEMY_THINKING
	aim_guide.clear()
	turn_label.text = "ENEMY TURN"
	power_label.text = "POWER —"
	hint_label.text = "Enemy is lining up a shot"
	camera_director.focus_x(enemy.global_position.x, 0.42)
	await get_tree().create_timer(0.72).timeout
	if phase == Phase.GAME_OVER:
		return

	var origin := enemy.get_launch_origin()
	var target := player.global_position + Vector2(0.0, -70.0)
	var velocity := _calculate_enemy_velocity(origin, target)
	_fire_projectile(enemy, velocity)

func _fire_projectile(shooter: CharacterBody2D, launch_velocity: Vector2) -> void:
	if phase == Phase.GAME_OVER:
		return

	phase = Phase.PROJECTILE
	_active_shooter = shooter
	aim_guide.clear()
	hint_label.text = "SHOT AWAY"

	var projectile := ProjectileScene.instantiate()
	projectile_layer.add_child(projectile)
	projectile.resolved.connect(_on_projectile_resolved)
	projectile.launch(shooter.get_launch_origin(), launch_velocity, shooter)
	camera_director.follow(projectile)

func _on_projectile_resolved(impact_position: Vector2, _hit_body: Node) -> void:
	camera_director.stop_follow_at(impact_position, 0.14)
	_update_hud()
	await get_tree().create_timer(0.75).timeout

	if _check_game_over():
		return

	if _active_shooter == player:
		_start_enemy_turn()
	else:
		_start_player_turn(false)

func _calculate_enemy_velocity(origin: Vector2, target: Vector2) -> Vector2:
	var gravity := float(ProjectSettings.get_setting("physics/2d/default_gravity", 980.0))
	var dx := absf(target.x - origin.x)
	var dy_up := origin.y - target.y
	var theta := deg_to_rad(52.0)
	var cos_theta := cos(theta)
	var denominator := 2.0 * cos_theta * cos_theta * (dx * tan(theta) - dy_up)

	var speed := 1080.0
	if denominator > 1.0:
		speed = sqrt((gravity * dx * dx) / denominator)

	# Primitive AI is intentionally imperfect.
	speed *= randf_range(0.965, 1.025)
	var direction := signf(target.x - origin.x)
	return Vector2(direction * speed * cos_theta, -speed * sin(theta))

func _check_game_over() -> bool:
	if enemy.is_alive() and player.is_alive():
		return false

	phase = Phase.GAME_OVER
	aim_guide.clear()
	restart_button.visible = true
	power_label.text = ""

	if player.is_alive():
		turn_label.text = "YOU WIN"
		hint_label.text = "Enemy survivor incapacitated"
		camera_director.focus_x(enemy.global_position.x, 0.35)
	else:
		turn_label.text = "DEFEAT"
		hint_label.text = "Your survivor was incapacitated"
		camera_director.focus_x(player.global_position.x, 0.35)

	return true

func _on_health_changed(_current: int, _maximum: int) -> void:
	_update_hud()

func _update_hud() -> void:
	health_label.text = "YOU  %d/100" % player.health
	enemy_health_label.text = "ENEMY  %d/100" % enemy.health

func _restart() -> void:
	get_tree().reload_current_scene()
