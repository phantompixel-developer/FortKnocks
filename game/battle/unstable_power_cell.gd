class_name UnstablePowerCell
extends StaticBody2D

signal discharged(world_position: Vector2, radius: float, damage: int, force: float)

@export var pulse_radius := 230.0
@export var pulse_damage := 58
@export var pulse_force := 920.0

var is_discharged := false
var _reaction_tween: Tween

func apply_hit(_damage: int, impulse: Vector2, _hit_position: Vector2) -> void:
	if is_discharged:
		return

	is_discharged = true
	collision_layer = 0
	collision_mask = 0
	$CollisionShape2D.set_deferred("disabled", true)
	_play_hit_reaction(impulse)
	queue_redraw()
	discharged.emit(global_position, pulse_radius, pulse_damage, pulse_force)

func _play_hit_reaction(impulse: Vector2) -> void:
	if _reaction_tween != null and _reaction_tween.is_running():
		_reaction_tween.kill()

	var direction := signf(impulse.x)
	if is_zero_approx(direction):
		direction = 1.0

	modulate = Color(1.35, 1.45, 1.65, 1.0)
	rotation = deg_to_rad(4.0 * direction)
	_reaction_tween = create_tween()
	_reaction_tween.set_parallel(true)
	_reaction_tween.tween_property(self, "modulate", Color.WHITE, 0.22)
	_reaction_tween.tween_property(self, "rotation", 0.0, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _draw() -> void:
	if is_discharged:
		_draw_spent_cell()
		return

	var outline := Color("292b29")
	draw_rect(Rect2(-27, -58, 54, 92), outline)
	draw_rect(Rect2(-23, -54, 46, 84), Color("455f72"))
	draw_rect(Rect2(-23, -22, 46, 11), Color("90c5d9"))
	draw_rect(Rect2(-23, 4, 46, 9), Color("90c5d9"))
	draw_rect(Rect2(-15, -66, 30, 12), outline)
	draw_circle(Vector2(0, -10), 8.0, Color("c4edf1"))
	draw_line(Vector2(-12, -42), Vector2(14, -30), Color("2c414f"), 4.0)
	draw_line(Vector2(8, 16), Vector2(-13, 25), Color("2c414f"), 4.0)

func _draw_spent_cell() -> void:
	var points := PackedVector2Array()
	for i in range(24):
		var angle := TAU * float(i) / 24.0
		points.append(Vector2(cos(angle) * 44.0, sin(angle) * 12.0))
	draw_colored_polygon(points, Color("343a3c"))
	draw_line(Vector2(-24, -1), Vector2(-4, -25), Color("4c5559"), 7.0)
	draw_line(Vector2(10, -2), Vector2(31, -18), Color("4c5559"), 6.0)
