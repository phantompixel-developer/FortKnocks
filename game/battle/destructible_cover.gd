class_name DestructibleCover
extends StaticBody2D

signal health_changed(current: int, maximum: int)
signal destroyed

@export var max_health := 150
@export var body_color := Color("7a6554")
@export var facing := 1

var health := 150
var is_destroyed := false
var _reaction_tween: Tween

func _ready() -> void:
	health = max_health
	queue_redraw()

func apply_hit(damage: int, impulse: Vector2, _hit_position: Vector2) -> void:
	if is_destroyed:
		return

	health = maxi(0, health - damage)
	_play_hit_reaction(impulse)
	health_changed.emit(health, max_health)

	if health <= 0:
		is_destroyed = true
		collision_layer = 0
		collision_mask = 0
		$CollisionShape2D.set_deferred("disabled", true)
		destroyed.emit()

	queue_redraw()

func get_damage_stage() -> int:
	if is_destroyed or health <= 0:
		return 3

	var ratio := float(health) / float(max_health)
	if ratio <= 0.34:
		return 2
	if ratio <= 0.67:
		return 1
	return 0

func _play_hit_reaction(impulse: Vector2) -> void:
	if _reaction_tween != null and _reaction_tween.is_running():
		_reaction_tween.kill()

	var direction := signf(impulse.x)
	if is_zero_approx(direction):
		direction = 1.0

	modulate = Color(1.45, 1.16, 0.78, 1.0)
	rotation = deg_to_rad(1.8 * direction)
	_reaction_tween = create_tween()
	_reaction_tween.set_parallel(true)
	_reaction_tween.tween_property(self, "modulate", Color.WHITE, 0.18)
	_reaction_tween.tween_property(self, "rotation", 0.0, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _draw() -> void:
	var stage := get_damage_stage()
	if stage >= 3:
		_draw_rubble()
		return

	var darkening := float(stage) * 0.12
	var shell := body_color.darkened(darkening)
	var outline := Color("292c2a")

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

	var window_color := Color("5e716f")
	if stage >= 1:
		window_color = Color("333a38")
	draw_rect(Rect2(-18, -70, 48, 24), window_color)

	draw_circle(Vector2(-72, 38), 27, outline)
	draw_circle(Vector2(74, 38), 27, outline)
	draw_circle(Vector2(-72, 38), 14, Color("5d625e"))
	draw_circle(Vector2(74, 38), 14, Color("5d625e"))

	if stage >= 1:
		draw_line(Vector2(-28, -33), Vector2(5, 5), Color("333735"), 5.0)
		draw_line(Vector2(28, -71), Vector2(12, -48), Color("b4b9a6"), 3.0)
	if stage >= 2:
		draw_line(Vector2(40, -34), Vector2(84, 18), Color("333735"), 7.0)
		draw_line(Vector2(-102, -22), Vector2(-58, 22), Color("333735"), 6.0)
		draw_rect(Rect2(62, -30, 48, 10), Color("343735"))
		draw_circle(Vector2(74, 38), 17, Color("343735"))

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
