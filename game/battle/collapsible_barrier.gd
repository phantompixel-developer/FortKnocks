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
	var outline := Color("171c1b")
	var frame := Color("2b3531")
	var panel_a := Color("657069")
	var panel_b := Color("545e58")
	var rust := Color("8f5540")
	var hazard := Color("d4aa55")

	# Welded frame.
	draw_rect(Rect2(-32, -132, 64, 264), outline)
	draw_rect(Rect2(-25, -125, 50, 250), frame)

	# Mismatched corrugated panels show that the gate is built from found material.
	for i in range(5):
		var top := -119.0 + float(i) * 48.0
		var panel_color := panel_a if i % 2 == 0 else panel_b
		draw_rect(Rect2(-20, top, 40, 42), panel_color)
		for x in [-12.0, 0.0, 12.0]:
			draw_line(Vector2(x, top + 2), Vector2(x, top + 40), panel_color.lightened(0.10), 2.0)

	# Cross-braces remain visually legible when the gate rotates down.
	draw_line(Vector2(-21, -105), Vector2(21, 94), outline, 9.0)
	draw_line(Vector2(21, -105), Vector2(-21, 94), Color("3e4843"), 7.0)
	draw_line(Vector2(-23, -44), Vector2(23, -44), rust, 6.0)
	draw_line(Vector2(-23, 45), Vector2(23, 45), rust, 6.0)

	# Painted knock-mark / hazard identifier.
	draw_line(Vector2(-18, 83), Vector2(2, 61), hazard, 8.0)
	draw_line(Vector2(1, 87), Vector2(21, 65), rust, 8.0)
	for p in [Vector2(-21, -115), Vector2(21, -115), Vector2(-21, 115), Vector2(21, 115)]:
		draw_circle(p, 4.0, Color("9a8a65"))

	if not is_collapsed:
		var ratio := float(health) / float(max_health)
		draw_rect(Rect2(-28, -151, 56, 10), outline)
		draw_rect(Rect2(-25, -148, 50.0 * ratio, 4), hazard)
