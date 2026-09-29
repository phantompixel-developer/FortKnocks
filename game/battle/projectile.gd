class_name BattleProjectile
extends RigidBody2D

signal bounced(world_position: Vector2, remaining_bounces: int)
signal resolved(impact_position: Vector2, hit_body: Node, impact_velocity: Vector2, damage_amount: int, weapon: WeaponDefinition)

const MAX_TRAIL_POINTS := 16

var weapon: WeaponDefinition
var _source_body: PhysicsBody2D
var _resolved := false
var _ground_bounces_used := 0
var _trail_world_points: Array[Vector2] = []

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 8
	body_entered.connect(_on_body_entered)
	queue_redraw()

func configure(definition: WeaponDefinition) -> void:
	weapon = definition
	var material := PhysicsMaterial.new()
	material.friction = 0.16
	if weapon != null and weapon.max_ground_bounces > 0:
		material.bounce = clampf(weapon.bounce_factor, 0.0, 0.9)
	else:
		material.bounce = 0.0
	physics_material_override = material
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
		_resolve(null, 0)

func _on_body_entered(body: Node) -> void:
	if _resolved or body == _source_body:
		return

	if body.is_in_group("ground_surface") and _can_ground_bounce():
		_ground_bounces_used += 1
		var remaining := maxi(0, weapon.max_ground_bounces - _ground_bounces_used)
		if remaining <= 0:
			call_deferred("_disable_future_bounce")
		_trail_world_points.clear()
		_trail_world_points.append(global_position)
		bounced.emit(global_position, remaining)
		return

	var applied_damage := 0
	if body.has_method("apply_hit"):
		applied_damage = _damage_for_body(body)
		var impulse := linear_velocity.normalized() * _knockback_force()
		body.apply_hit(applied_damage, impulse, global_position)

	_resolve(body, applied_damage)

func _disable_future_bounce() -> void:
	if physics_material_override != null:
		physics_material_override.bounce = 0.0

func _can_ground_bounce() -> bool:
	return weapon != null and _ground_bounces_used < weapon.max_ground_bounces

func _damage_for_body(body: Node) -> int:
	if weapon == null:
		return 50
	if body is DestructibleCover:
		return weapon.cover_damage
	return weapon.direct_damage

func _knockback_force() -> float:
	if weapon == null:
		return 520.0
	return weapon.knockback_force

func _resolve(body: Node, applied_damage: int) -> void:
	if _resolved:
		return

	_resolved = true
	var impact := global_position
	var impact_velocity := linear_velocity
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	set_deferred("freeze", true)
	resolved.emit(impact, body, impact_velocity, applied_damage, weapon)
	queue_free()

func _draw() -> void:
	var projectile_color := Color("f2df85")
	var trail_color := Color(0.91, 0.82, 0.53, 0.58)
	if weapon != null:
		projectile_color = weapon.projectile_color
		trail_color = weapon.trail_color

	if _trail_world_points.size() >= 2:
		var local_points := PackedVector2Array()
		for world_point in _trail_world_points:
			local_points.append(to_local(world_point))
		draw_polyline(local_points, trail_color, 7.0, true)

	draw_circle(Vector2.ZERO, 13.0, projectile_color)
	draw_circle(Vector2.ZERO, 7.0, Color("454944"))
