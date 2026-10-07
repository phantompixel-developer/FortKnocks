class_name UnstablePowerCell
extends StaticBody2D

const ProductionArtScript := preload("res://game/presentation/production_art.gd")
const POWER_CELL_TEXTURE_PATH := "res://assets/art/production/battle/shared/unstable_power_cell.svg"
const POWER_CELL_SPENT_TEXTURE_PATH := "res://assets/art/production/battle/shared/unstable_power_cell_spent.svg"

var _production_texture: Texture2D
var _spent_texture: Texture2D

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
	_draw_ground_treatment()
	if is_discharged:
		if _spent_texture == null:
			_spent_texture = ProductionArtScript.texture_from_svg(POWER_CELL_SPENT_TEXTURE_PATH)
		if _spent_texture != null:
			draw_texture_rect(_spent_texture, Rect2(-75.0, -68.0, 150.0, 100.0), false)
			return
		_draw_spent_cell()
		return

	if _production_texture == null:
		_production_texture = ProductionArtScript.texture_from_svg(POWER_CELL_TEXTURE_PATH)
	if _production_texture != null:
		draw_texture_rect(_production_texture, Rect2(-75.0, -146.0, 150.0, 180.0), false)
		return

	var outline := Color("171c1b")
	var casing := Color("344741")
	var tank := Color("4e716d")
	var cold := Color("77b6bf")
	var hazard := Color("d4aa55")
	var rust := Color("8f5540")

	# Salvaged industrial capacitor: twin pressure cans held in a welded carrier.
	draw_rect(Rect2(-31, -60, 62, 96), outline)
	draw_rect(Rect2(-26, -55, 52, 86), casing)
	draw_rect(Rect2(-20, -49, 16, 72), tank)
	draw_rect(Rect2(4, -49, 16, 72), tank.lightened(0.05))
	draw_line(Vector2(-12, -47), Vector2(-12, 20), cold, 4.0)
	draw_line(Vector2(12, -47), Vector2(12, 20), cold, 4.0)
	draw_rect(Rect2(-19, -66, 38, 13), outline)
	draw_rect(Rect2(-15, -63, 30, 7), rust)

	# Live charge window and warning paint.
	draw_circle(Vector2(0, -12), 13.0, outline)
	draw_circle(Vector2(0, -12), 8.0, cold)
	draw_circle(Vector2(0, -12), 4.0, Color("dff5f1"))
	draw_line(Vector2(-24, 6), Vector2(-4, -14), hazard, 7.0)
	draw_line(Vector2(4, 28), Vector2(24, 8), rust, 7.0)
	draw_line(Vector2(-25, 34), Vector2(-38, 48), Color("303b37"), 5.0)
	draw_line(Vector2(25, 34), Vector2(38, 48), Color("303b37"), 5.0)
	draw_circle(Vector2(0, -12), 24.0, Color(cold, 0.10))

func _draw_ground_treatment() -> void:
	# The live cell is allowed the strongest cold-tech spill in the current battlefield.
	draw_set_transform(Vector2(0.0, 32.0), 0.0, Vector2(1.05, 0.24))
	draw_circle(Vector2.ZERO, 54.0, Color(0.025, 0.035, 0.040, 0.30))
	if not is_discharged:
		draw_circle(Vector2.ZERO, 70.0, Color(0.32, 0.72, 0.76, 0.10))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_spent_cell() -> void:
	var outline := Color("171c1b")
	var shell := Color("313b37")
	var points := PackedVector2Array()
	for i in range(24):
		var angle := TAU * float(i) / 24.0
		points.append(Vector2(cos(angle) * 46.0, sin(angle) * 13.0))
	draw_colored_polygon(points, shell)
	draw_line(Vector2(-28, -1), Vector2(-7, -28), outline, 8.0)
	draw_line(Vector2(8, -3), Vector2(33, -20), Color("48544e"), 7.0)
	draw_line(Vector2(-18, 5), Vector2(18, -7), Color("8f5540", 0.64), 5.0)
	draw_circle(Vector2(25, -15), 5.0, Color("77b6bf", 0.20))
