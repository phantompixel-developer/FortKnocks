class_name SalvageLoad
extends StaticBody2D

signal destroyed(world_position: Vector2)

@export var max_health: int = 150

var health: int = 150
var is_destroyed: bool = false
var _reaction_tween: Tween

func _ready() -> void:
	health = max_health
	if get_node_or_null("CollisionShape2D") == null:
		var collision_shape: CollisionShape2D = CollisionShape2D.new()
		collision_shape.name = "CollisionShape2D"
		collision_shape.position = Vector2(0.0, -44.0)
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = Vector2(150.0, 88.0)
		collision_shape.shape = shape
		add_child(collision_shape)
	queue_redraw()

func configure(configured_health: int) -> void:
	max_health = maxi(1, configured_health)
	health = max_health
	is_destroyed = false
	collision_layer = 1
	collision_mask = 1
	var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape != null:
		collision_shape.set_deferred("disabled", false)
	queue_redraw()

func apply_hit(damage: int, impulse: Vector2, _hit_position: Vector2) -> void:
	if is_destroyed:
		return

	health = maxi(0, health - damage)
	_play_hit_reaction(impulse)
	if health <= 0:
		is_destroyed = true
		collision_layer = 0
		collision_mask = 0
		var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D
		if collision_shape != null:
			collision_shape.set_deferred("disabled", true)
		destroyed.emit(global_position)
	queue_redraw()

func status_text() -> String:
	if is_destroyed:
		return "SALVAGE LOAD: LOST"
	return "SALVAGE LOAD: %d/%d" % [health, max_health]

func _play_hit_reaction(impulse: Vector2) -> void:
	if _reaction_tween != null and _reaction_tween.is_running():
		_reaction_tween.kill()
	var direction: float = signf(impulse.x)
	if is_zero_approx(direction):
		direction = 1.0
	modulate = Color(1.35, 1.05, 0.82, 1.0)
	rotation = deg_to_rad(1.4 * direction)
	_reaction_tween = create_tween()
	_reaction_tween.set_parallel(true)
	_reaction_tween.tween_property(self, "modulate", Color.WHITE, 0.18)
	_reaction_tween.tween_property(self, "rotation", 0.0, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _draw() -> void:
	var outline: Color = Color("171c1b")
	var crate: Color = Color("665b46")
	var metal: Color = Color("58635d")
	var hazard: Color = Color("d4aa55")
	var rust: Color = Color("8f5540")

	if is_destroyed:
		draw_rect(Rect2(-76, -18, 152, 18), outline)
		draw_rect(Rect2(-68, -14, 136, 10), Color("403b32"))
		draw_line(Vector2(-52, -20), Vector2(-8, -44), rust, 7.0)
		draw_line(Vector2(12, -17), Vector2(58, -39), metal, 7.0)
		draw_circle(Vector2(-32, -10), 13.0, Color("2d3430"))
		draw_circle(Vector2(44, -8), 10.0, Color("2d3430"))
		return

	# Recovered materials strapped onto a low hand-cart / pallet.
	draw_rect(Rect2(-78, -72, 156, 72), outline)
	draw_rect(Rect2(-70, -65, 140, 57), metal)
	draw_rect(Rect2(-61, -58, 58, 44), crate)
	draw_rect(Rect2(7, -56, 52, 42), crate.lightened(0.08))
	draw_line(Vector2(-64, -36), Vector2(60, -36), Color("343d39"), 8.0)
	draw_line(Vector2(-15, -64), Vector2(-15, -8), hazard, 6.0)
	draw_line(Vector2(28, -60), Vector2(44, -18), rust, 6.0)

	draw_rect(Rect2(-84, -9, 168, 12), outline)
	draw_circle(Vector2(-54, 5), 17.0, outline)
	draw_circle(Vector2(-54, 5), 8.0, Color("59625c"))
	draw_circle(Vector2(54, 5), 17.0, outline)
	draw_circle(Vector2(54, 5), 8.0, Color("59625c"))

	# Health strip makes the protected objective readable during inspect.
	var ratio: float = float(health) / float(max_health)
	draw_rect(Rect2(-72, -91, 144, 10), outline)
	draw_rect(Rect2(-68, -88, 136.0 * ratio, 4), hazard)
