class_name BattleProjectile
extends RigidBody2D

signal resolved(impact_position: Vector2, hit_body: Node, impact_velocity: Vector2)

@export var damage := 50
@export var knockback_force := 520.0

const MAX_TRAIL_POINTS := 16

var _source_body: PhysicsBody2D
var _resolved := false
var _trail_world_points: Array[Vector2] = []

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 8
	body_entered.connect(_on_body_entered)
	queue_redraw()

func launch(origin: Vector2, launch_velocity: Vector2, source_body: PhysicsBody2D) -> void:
	global_position = origin
	linear_velocity = launch_velocity
	_source_body = source_body
	_trail_world_points.append(global_position)
	if _source_body != null:
		add_collision_exception_with(_source_body)

func _physics_process(_delta: float) -> void:
	if _resolved:
		return

	if _trail_world_points.is_empty() or _trail_world_points[-1].distance_to(global_position) >= 18.0:
		_trail_world_points.append(global_position)
		if _trail_world_points.size() > MAX_TRAIL_POINTS:
			_trail_world_points.pop_front()
		queue_redraw()

	if global_position.y > 1500.0 or global_position.x < -200.0 or global_position.x > 2360.0:
		_resolve(null)

func _on_body_entered(body: Node) -> void:
	if _resolved or body == _source_body:
		return

	if body.has_method("apply_hit"):
		var impulse := linear_velocity.normalized() * knockback_force
		body.apply_hit(damage, impulse, global_position)

	_resolve(body)

func _resolve(body: Node) -> void:
	if _resolved:
		return

	_resolved = true
	var impact := global_position
	var impact_velocity := linear_velocity
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	set_deferred("freeze", true)
	resolved.emit(impact, body, impact_velocity)
	queue_free()

func _draw() -> void:
	if _trail_world_points.size() >= 2:
		var local_points := PackedVector2Array()
		for world_point in _trail_world_points:
			local_points.append(to_local(world_point))
		draw_polyline(local_points, Color(0.91, 0.82, 0.53, 0.58), 7.0, true)

	draw_circle(Vector2.ZERO, 13.0, Color("f2df85"))
	draw_circle(Vector2.ZERO, 7.0, Color("454944"))
