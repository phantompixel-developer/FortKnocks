class_name CollapsibleBarrier
extends StaticBody2D

signal collapsed(world_position: Vector2)

@export var max_health := 70
@export var collapsed_drop := 105.0

var health := 70
var is_collapsed := false
var _reaction_tween: Tween

func _ready() -> void:
	health = max_health

	var collision_shape := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(60.0, 260.0)
	collision_shape.shape = shape
	add_child(collision_shape)
	queue_redraw()

func apply_hit(damage: int, impulse: Vector2, _hit_position: Vector2) -> void:
	if is_collapsed:
		return

	health = maxi(0, health - damage)
	_play_hit_reaction(impulse)

	if health <= 0:
		_collapse(impulse)
	else:
		queue_redraw()

func status_text() -> String:
	if is_collapsed:
		return "SCRAP GATE: DOWN"
	return "SCRAP GATE: %d/%d" % [health, max_health]

func _collapse(impulse: Vector2) -> void:
	if is_collapsed:
		return

	is_collapsed = true
	var start_position := global_position
	var direction := signf(impulse.x)
	if is_zero_approx(direction):
		direction = 1.0

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "rotation", deg_to_rad(90.0 * direction), 0.34).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "global_position", start_position + Vector2(0.0, collapsed_drop), 0.34).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(func() -> void:
		collapsed.emit(global_position)
		queue_redraw()
	)

func _play_hit_reaction(impulse: Vector2) -> void:
	if _reaction_tween != null and _reaction_tween.is_running():
		_reaction_tween.kill()

	var direction := signf(impulse.x)
	if is_zero_approx(direction):
		direction = 1.0

	modulate = Color(1.35, 1.18, 0.86, 1.0)
	_reaction_tween = create_tween()
	_reaction_tween.tween_property(self, "modulate", Color.WHITE, 0.18)

func _draw() -> void:
	var frame := Color("343936")
	var metal := Color("777267")
	var warning := Color("c2a45e")

	draw_rect(Rect2(-30, -130, 60, 260), frame)
	draw_rect(Rect2(-22, -122, 44, 244), metal)
	draw_line(Vector2(-20, -88), Vector2(20, -48), frame, 8.0)
	draw_line(Vector2(20, -48), Vector2(-20, -8), frame, 8.0)
	draw_line(Vector2(-20, -8), Vector2(20, 32), frame, 8.0)
	draw_line(Vector2(20, 32), Vector2(-20, 72), frame, 8.0)
	draw_rect(Rect2(-22, 88, 44, 18), warning)

	if not is_collapsed:
		var ratio := float(health) / float(max_health)
		draw_rect(Rect2(-26, -148, 52, 8), Color("252927"))
		draw_rect(Rect2(-24, -146, 48.0 * ratio, 4), warning)
