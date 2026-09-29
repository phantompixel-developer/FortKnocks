extends RigidBody2D

signal resolved(impact_position: Vector2, hit_body: Node)

@export var damage := 50
@export var knockback_force := 520.0

var _source_body: PhysicsBody2D
var _resolved := false

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 8
	body_entered.connect(_on_body_entered)
	queue_redraw()

func launch(origin: Vector2, launch_velocity: Vector2, source_body: PhysicsBody2D) -> void:
	global_position = origin
	linear_velocity = launch_velocity
	_source_body = source_body
	if _source_body != null:
		add_collision_exception_with(_source_body)

func _physics_process(_delta: float) -> void:
	if _resolved:
		return
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
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	set_deferred("freeze", true)
	resolved.emit(impact, body)
	queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 12.0, Color("e9d982"))
	draw_circle(Vector2.ZERO, 7.0, Color("4a4d48"))
