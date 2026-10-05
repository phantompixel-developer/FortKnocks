class_name Combatant
extends CharacterBody2D

const PLAYER_SURVIVOR_TEXTURE: Texture2D = preload("res://assets/art/production/characters/fort_knocks_survivor.svg")

signal health_changed(current: int, maximum: int)

@export var display_name := "Survivor"
@export var facing := 1
@export var accent_color := Color("d8c49b")
@export var max_health := 100
@export var use_production_survivor := false

var health := 100
var knockback_multiplier: float = 1.0
var _reaction_tween: Tween

func _ready() -> void:
	health = max_health
	queue_redraw()

func is_alive() -> bool:
	return health > 0

func configure_knockback_multiplier(value: float) -> void:
	knockback_multiplier = clampf(value, 0.25, 1.0)

func get_launch_origin() -> Vector2:
	return global_position + Vector2(60.0 * float(facing), -110.0)

func apply_hit(damage: int, impulse: Vector2, _hit_position: Vector2) -> void:
	if health <= 0:
		return

	health = maxi(0, health - damage)
	var push: float = clampf(impulse.x * 0.025 * knockback_multiplier, -34.0, 34.0)
	global_position.x += push
	_play_hit_reaction(impulse)
	health_changed.emit(health, max_health)
	queue_redraw()

func _play_hit_reaction(impulse: Vector2) -> void:
	if _reaction_tween != null and _reaction_tween.is_running():
		_reaction_tween.kill()

	var direction := signf(impulse.x)
	if is_zero_approx(direction):
		direction = 1.0

	modulate = Color(1.55, 0.88, 0.78, 1.0)
	rotation = deg_to_rad(5.0 * direction)
	_reaction_tween = create_tween()
	_reaction_tween.set_parallel(true)
	_reaction_tween.tween_property(self, "modulate", Color.WHITE, 0.22)
	_reaction_tween.tween_property(self, "rotation", 0.0, 0.20).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _draw() -> void:
	if use_production_survivor:
		_draw_production_survivor()
		return

	var alive := health > 0
	var cloth := accent_color if alive else Color("4b504d")
	var outline := Color("171b1a")
	var leather := Color("4a3b31")
	var metal := Color("5d6762")
	var skin := Color("c89d78") if alive else Color("686c68")
	var scarf := accent_color.lightened(0.18) if alive else Color("5c605d")

	# Backpack and scavenged shoulder plate make the survivor silhouette readable
	# at phone size without increasing the collision footprint.
	var backpack_x := -27.0 if facing > 0 else 3.0
	var backpack_inner_x := -24.0 if facing > 0 else 6.0
	draw_rect(Rect2(backpack_x, -94, 24, 54), outline)
	draw_rect(Rect2(backpack_inner_x, -90, 18, 45), leather)
	draw_circle(Vector2(-15.0 * facing, -82), 13.0, outline)
	draw_circle(Vector2(-15.0 * facing, -82), 9.0, metal)

	# Boots / legs.
	draw_line(Vector2(-10, -36), Vector2(-18, 0), outline, 13.0)
	draw_line(Vector2(10, -36), Vector2(18, 0), outline, 13.0)
	draw_line(Vector2(-10, -36), Vector2(-18, -2), Color("313633"), 7.0)
	draw_line(Vector2(10, -36), Vector2(18, -2), Color("313633"), 7.0)
	draw_line(Vector2(-25, 0), Vector2(-9, 0), outline, 8.0)
	draw_line(Vector2(9, 0), Vector2(27, 0), outline, 8.0)

	# Layered coat / torso.
	draw_polygon(
		PackedVector2Array([
			Vector2(-20, -98),
			Vector2(20, -98),
			Vector2(29, -38),
			Vector2(13, -27),
			Vector2(-17, -30),
			Vector2(-28, -42),
		]),
		PackedColorArray([outline])
	)
	draw_polygon(
		PackedVector2Array([
			Vector2(-15, -93),
			Vector2(15, -93),
			Vector2(22, -43),
			Vector2(10, -35),
			Vector2(-12, -37),
			Vector2(-21, -46),
		]),
		PackedColorArray([cloth.darkened(0.08)])
	)
	draw_line(Vector2(-3, -90), Vector2(-4, -40), Color(cloth.lightened(0.18), 0.75), 3.0)

	# Sling and arm bracing the improvised launcher.
	draw_line(Vector2(-17 * facing, -88), Vector2(18 * facing, -43), leather, 7.0)
	draw_line(Vector2(-3, -78), Vector2(38 * facing, -62), outline, 13.0)
	draw_line(Vector2(-3, -78), Vector2(38 * facing, -62), cloth.lightened(0.05), 7.0)
	draw_circle(Vector2(35 * facing, -63), 6.0, skin)
	draw_line(Vector2(28 * facing, -67), Vector2(68 * facing, -79), outline, 12.0)
	draw_line(Vector2(31 * facing, -67), Vector2(65 * facing, -77), Color("3b443f"), 7.0)
	var launcher_plate_x := 48.0 if facing > 0 else -62.0
	draw_rect(Rect2(launcher_plate_x, -84, 14, 9), Color("6e5d43"))

	# Head, scarf, scavenged cap and eye mark.
	draw_circle(Vector2(0, -116), 25.0, outline)
	draw_circle(Vector2(0, -116), 19.0, skin)
	draw_rect(Rect2(-22, -104, 44, 11), scarf)
	draw_polygon(
		PackedVector2Array([
			Vector2(-23, -132),
			Vector2(-8, -144),
			Vector2(18, -139),
			Vector2(24, -127),
			Vector2(-18, -126),
		]),
		PackedColorArray([Color("343b37")])
	)
	draw_line(Vector2(-2 * facing, -120), Vector2(11 * facing, -120), Color("202523"), 4.0)
	draw_circle(Vector2(9 * facing, -120), 2.5, Color("d7b85e"))

	# Readable health strip uses the same hazard accent as the wider UI.
	draw_rect(Rect2(-36, -166, 72, 10), outline)
	var ratio := float(health) / float(max_health)
	draw_rect(Rect2(-33, -163, 66.0 * ratio, 4), Color("d4aa55") if alive else Color("5c625e"))


func _draw_production_survivor() -> void:
	var alive := health > 0
	var tint := Color.WHITE if alive else Color(0.48, 0.50, 0.49, 1.0)
	# The SVG was authored around the existing collision/launch contract.
	# Muzzle remains close to get_launch_origin(); neither physics nor aim math
	# derives from this rectangle.
	var rect := Rect2(-90.0, -216.0, 180.0, 240.0)
	draw_texture_rect(PLAYER_SURVIVOR_TEXTURE, rect, false, tint)

	# Keep the established world-space health strip as gameplay information.
	var outline := Color("090d11")
	draw_rect(Rect2(-39, -236, 78, 11), outline)
	var ratio := clampf(float(health) / float(max_health), 0.0, 1.0)
	draw_rect(
		Rect2(-35, -232, 70.0 * ratio, 4),
		Color("e7ad3c") if alive else Color("5c625e")
	)
