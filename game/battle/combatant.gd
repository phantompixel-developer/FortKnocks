class_name Combatant
extends CharacterBody2D

signal health_changed(current: int, maximum: int)

@export var display_name := "Survivor"
@export var facing := 1
@export var accent_color := Color("d8c49b")
@export var max_health := 100

var health := 100

func _ready() -> void:
	health = max_health
	queue_redraw()

func is_alive() -> bool:
	return health > 0

func get_launch_origin() -> Vector2:
	return global_position + Vector2(60.0 * float(facing), -110.0)

func apply_hit(damage: int, impulse: Vector2, _hit_position: Vector2) -> void:
	if health <= 0:
		return

	health = maxi(0, health - damage)
	var push := clampf(impulse.x * 0.025, -34.0, 34.0)
	global_position.x += push
	health_changed.emit(health, max_health)
	queue_redraw()

func _draw() -> void:
	var body_color := accent_color if health > 0 else Color("555555")
	var outline := Color("252827")

	draw_line(Vector2(-10, -35), Vector2(-18, 0), outline, 10.0)
	draw_line(Vector2(10, -35), Vector2(18, 0), outline, 10.0)
	draw_line(Vector2(0, -92), Vector2(0, -32), outline, 26.0)
	draw_line(Vector2(0, -90), Vector2(0, -35), body_color, 18.0)

	draw_line(Vector2(-2, -76), Vector2(38 * facing, -62), outline, 11.0)
	draw_line(Vector2(-2, -76), Vector2(38 * facing, -62), body_color, 7.0)
	draw_line(Vector2(28 * facing, -67), Vector2(65 * facing, -77), Color("373c39"), 9.0)

	draw_circle(Vector2(0, -112), 23.0, outline)
	draw_circle(Vector2(0, -112), 18.0, Color("d8b691"))

	draw_rect(Rect2(Vector2(-24 if facing > 0 else 5, -86), Vector2(19, 42)), Color("596057"))

	draw_rect(Rect2(-34, -158, 68, 8), Color("2d302f"))
	var ratio := float(health) / float(max_health)
	draw_rect(Rect2(-32, -156, 64.0 * ratio, 4), Color("d6d0a0"))
