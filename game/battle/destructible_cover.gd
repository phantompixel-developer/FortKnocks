extends StaticBody2D

signal health_changed(current: int, maximum: int)
signal destroyed

@export var max_health := 100
@export var body_color := Color("7a6554")
@export var facing := 1

var health := 100
var is_destroyed := false

func _ready() -> void:
	health = max_health
	queue_redraw()

func apply_hit(damage: int, _impulse: Vector2, _hit_position: Vector2) -> void:
	if is_destroyed:
		return

	health = maxi(0, health - damage)
	health_changed.emit(health, max_health)
	if health <= 0:
		is_destroyed = true
		collision_layer = 0
		collision_mask = 0
		$CollisionShape2D.set_deferred("disabled", true)
		destroyed.emit()
	queue_redraw()

func _draw() -> void:
	if is_destroyed:
		_draw_rubble()
		return

	var damage_ratio := 1.0 - (float(health) / float(max_health))
	var shell := body_color.darkened(damage_ratio * 0.35)
	var outline := Color("292c2a")

	# Simplified ruined civilian car.
	draw_rect(Rect2(-120, -40, 240, 78), outline)
	draw_rect(Rect2(-115, -36, 230, 68), shell)
	draw_polygon(
		PackedVector2Array([
			Vector2(-64, -40),
			Vector2(-30, -82),
			Vector2(48, -82),
			Vector2(82, -40),
		]),
		PackedColorArray([outline])
	)
	draw_polygon(
		PackedVector2Array([
			Vector2(-57, -42),
			Vector2(-25, -75),
			Vector2(42, -75),
			Vector2(72, -42),
		]),
		PackedColorArray([shell.lightened(0.06)])
	)
	draw_rect(Rect2(-18, -70, 48, 24), Color("5e716f"))
	draw_circle(Vector2(-72, 38), 27, outline)
	draw_circle(Vector2(74, 38), 27, outline)
	draw_circle(Vector2(-72, 38), 14, Color("5d625e"))
	draw_circle(Vector2(74, 38), 14, Color("5d625e"))

	if damage_ratio > 0.25:
		draw_line(Vector2(-15, -35), Vector2(14, 8), Color("333735"), 5.0)
	if damage_ratio > 0.60:
		draw_line(Vector2(45, -34), Vector2(83, 18), Color("333735"), 6.0)

func _draw_rubble() -> void:
	var rubble := body_color.darkened(0.4)
	draw_polygon(
		PackedVector2Array([
			Vector2(-120, 35),
			Vector2(-82, -5),
			Vector2(-35, 18),
			Vector2(4, -22),
			Vector2(55, 8),
			Vector2(118, 32),
		]),
		PackedColorArray([rubble])
	)
	draw_circle(Vector2(-68, 37), 20, Color("303331"))
	draw_circle(Vector2(72, 38), 18, Color("303331"))
